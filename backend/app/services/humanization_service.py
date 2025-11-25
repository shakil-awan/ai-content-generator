"""
AI Content Humanization Service
Detects AI-generated content and rewrites it to be more human-like
"""
from typing import Dict, Any, Optional
from openai import AsyncOpenAI
import google.generativeai as genai
from app.config import settings
import logging
import json
import time
import asyncio

logger = logging.getLogger(__name__)

class HumanizationService:
    """Service for AI content detection and humanization"""
    
    _instance: Optional['HumanizationService'] = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        if not hasattr(self, 'initialized'):
            self.openai_client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
            self.openai_model = "gpt-4o-mini"
            
            # Configure Gemini as fallback
            genai.configure(api_key=settings.GEMINI_API_KEY)
            self.gemini_model = genai.GenerativeModel('gemini-2.5-flash')
            
            self.initialized = True
            logger.info("Humanization service initialized")
    
    async def detect_ai_content(self, content: str) -> Dict[str, Any]:
        """
        Detect if content is AI-generated
        Returns score 0-100 (higher = more AI-like)
        
        Note: In production, integrate with services like:
        - GPTZero API
        - Originality.ai API
        - Writer.com AI Detector
        
        For now, we use AI itself to detect AI patterns
        """
        try:
            logger.info("Starting AI content detection...")
            prompt = f"""Analyze this content and rate how AI-generated it appears on a scale of 0-100.

Content:
{content}

Consider these AI indicators:
- Repetitive phrasing
- Overly formal language
- Lack of personal voice
- Perfect grammar with no natural flow
- Generic statements
- Predictable structure

Return ONLY a JSON object:
{{
    "aiScore": <number 0-100>,
    "confidence": <number 0-100>,
    "indicators": ["indicator1", "indicator2", ...],
    "reasoning": "brief explanation"
}}"""

            # Add timeout to prevent hanging
            response = await asyncio.wait_for(
                self.openai_client.chat.completions.create(
                    model=self.openai_model,
                    messages=[
                        {"role": "system", "content": "You are an AI content detection expert. Always return valid JSON."},
                        {"role": "user", "content": prompt}
                    ],
                    temperature=0.3,  # Lower temp for consistent detection
                    max_tokens=500,
                    timeout=30.0  # 30 second timeout per request
                ),
                timeout=35.0  # 35 second overall timeout
            )
            
            content_text = response.choices[0].message.content
            logger.info(f"Detection API response received: {len(content_text)} chars")
            result = json.loads(content_text)
            
            return {
                'aiScore': result.get('aiScore', 50),
                'confidence': result.get('confidence', 70),
                'indicators': result.get('indicators', []),
                'reasoning': result.get('reasoning', 'AI pattern analysis completed'),
                'detectionApi': 'openai-self-detection',
                'tokensUsed': response.usage.total_tokens
            }
            
        except asyncio.TimeoutError:
            logger.warning("OpenAI detection timed out, trying Gemini fallback...")
            try:
                return await self._detect_with_gemini(content)
            except Exception as gemini_error:
                logger.error(f"Gemini fallback also failed: {gemini_error}")
                return {
                    'aiScore': 75,
                    'confidence': 0,
                    'indicators': ['Detection timeout - using estimated score'],
                    'reasoning': 'API timeout - returning estimated AI score',
                    'detectionApi': 'timeout-fallback',
                    'tokensUsed': 0
                }
        except Exception as e:
            error_msg = str(e).lower()
            # Check if it's a rate limit or quota error
            if 'rate_limit' in error_msg or 'quota' in error_msg or '429' in error_msg:
                logger.warning(f"OpenAI rate limit hit: {e}, trying Gemini fallback...")
                try:
                    return await self._detect_with_gemini(content)
                except Exception as gemini_error:
                    logger.error(f"Gemini fallback also failed: {gemini_error}")
            else:
                logger.error(f"Error detecting AI content: {e}", exc_info=True)
            
            # Return neutral score on error
            return {
                'aiScore': 50,
                'confidence': 0,
                'indicators': [],
                'reasoning': f'Detection failed: {str(e)}',
                'detectionApi': 'error',
                'tokensUsed': 0
            }
    
    async def _detect_with_gemini(self, content: str) -> Dict[str, Any]:
        """Fallback detection using Gemini when OpenAI fails"""
        try:
            prompt = f"""Analyze this content and rate how AI-generated it appears on a scale of 0-100.

Content:
{content}

Consider these AI indicators:
- Repetitive phrasing
- Overly formal language
- Lack of personal voice
- Perfect grammar with no natural flow
- Generic statements
- Predictable structure

Return ONLY a JSON object:
{{
    "aiScore": <number 0-100>,
    "confidence": <number 0-100>,
    "indicators": ["indicator1", "indicator2", ...],
    "reasoning": "brief explanation"
}}"""

            response = await asyncio.to_thread(
                self.gemini_model.generate_content, prompt
            )
            
            response_text = response.text.strip()
            # Extract JSON from markdown code blocks if present
            if '```json' in response_text:
                response_text = response_text.split('```json')[1].split('```')[0].strip()
            elif '```' in response_text:
                response_text = response_text.split('```')[1].split('```')[0].strip()
            
            result = json.loads(response_text)
            logger.info("Gemini detection successful")
            
            return {
                'aiScore': result.get('aiScore', 50),
                'confidence': result.get('confidence', 70),
                'indicators': result.get('indicators', []),
                'reasoning': result.get('reasoning', 'AI pattern analysis completed'),
                'detectionApi': 'gemini-fallback',
                'tokensUsed': 0  # Gemini doesn't provide token count in same way
            }
        except Exception as e:
            logger.error(f"Gemini detection failed: {e}")
            raise
    
    async def humanize_content(
        self,
        content: str,
        content_type: str,
        level: str = "balanced",
        preserve_facts: bool = True
    ) -> Dict[str, Any]:
        """
        Rewrite AI content to be more human-like
        
        Args:
            content: The AI-generated content to humanize
            content_type: Type of content (blog, social, email, etc)
            level: Humanization level (light, balanced, aggressive)
            preserve_facts: Whether to keep factual information unchanged
            
        Returns:
            Dict with humanized content and metrics
        """
        start_time = time.time()
        
        try:
            # First, detect current AI score
            detection_before = await self.detect_ai_content(content)
            ai_score_before = detection_before['aiScore']
            
            # Build humanization instructions based on level
            level_instructions = {
                'light': """Make minimal changes to sound more natural:
- Add 1-2 contractions (e.g., "you're" instead of "you are")
- Vary sentence structure slightly
- Add one personal touch""",
                
                'balanced': """Make moderate changes for natural flow:
- Use contractions naturally
- Vary sentence length significantly
- Add personality and voice
- Include 1-2 colloquial expressions
- Break up perfect grammar occasionally
- Add natural transitions""",
                
                'aggressive': """Heavily rewrite to sound completely human:
- Maximum use of contractions
- Highly varied sentence structure
- Strong personal voice and opinions
- Multiple colloquialisms
- Natural grammar imperfections
- Conversational tone
- Add anecdotes or examples
- Remove corporate/formal language"""
            }
            
            instructions = level_instructions.get(level, level_instructions['balanced'])
            
            fact_instruction = """
CRITICAL: Preserve all factual information, statistics, and data points exactly as stated.
Only modify the writing style and tone.""" if preserve_facts else ""
            
            prompt = f"""Rewrite this {content_type} content to sound more human-written while maintaining its core message.

{instructions}

{fact_instruction}

Original Content:
{content}

Requirements:
- Keep the same length approximately
- Maintain the key points and message
- Make it sound like a real person wrote it
- Remove obvious AI patterns
- Add natural imperfections

Return ONLY the humanized content, no explanations."""

            logger.info(f"Starting humanization with level: {level}")
            response = await asyncio.wait_for(
                self.openai_client.chat.completions.create(
                    model=self.openai_model,
                    messages=[
                        {"role": "system", "content": "You are an expert at making AI content sound naturally human-written."},
                        {"role": "user", "content": prompt}
                    ],
                    temperature=0.9,  # Higher temp for more natural variation
                    max_tokens=4000,
                    timeout=60.0  # 60 second timeout for longer content
                ),
                timeout=65.0  # 65 second overall timeout
            )
            
            humanized_content = response.choices[0].message.content.strip()
            tokens_used = response.usage.total_tokens
            logger.info(f"Humanization complete: {len(humanized_content)} chars, {tokens_used} tokens")
            
            # Detect AI score after humanization
            detection_after = await self.detect_ai_content(humanized_content)
            ai_score_after = detection_after['aiScore']
            
            processing_time = time.time() - start_time
            improvement = ai_score_before - ai_score_after
            
            logger.info(f"Humanization complete: {ai_score_before} → {ai_score_after} (improvement: {improvement})")
            
            return {
                'humanizedContent': humanized_content,
                'beforeScore': ai_score_before,
                'afterScore': ai_score_after,
                'improvement': improvement,
                'improvementPercentage': (improvement / ai_score_before * 100) if ai_score_before > 0 else 0,
                'level': level,
                'detectionApi': 'openai-self-detection',
                'processingTime': processing_time,
                'tokensUsed': tokens_used,
                'beforeAnalysis': {
                    'indicators': detection_before.get('indicators', []),
                    'reasoning': detection_before.get('reasoning', '')
                },
                'afterAnalysis': {
                    'indicators': detection_after.get('indicators', []),
                    'reasoning': detection_after.get('reasoning', '')
                }
            }
            
        except asyncio.TimeoutError:
            logger.warning("OpenAI humanization timed out, trying Gemini fallback...")
            try:
                return await self._humanize_with_gemini(content, content_type, level, preserve_facts, ai_score_before, detection_before, start_time)
            except Exception as gemini_error:
                logger.error(f"Gemini humanization fallback failed: {gemini_error}")
                raise Exception("Humanization timed out on both OpenAI and Gemini")
        except Exception as e:
            error_msg = str(e).lower()
            # Check if it's a rate limit or quota error
            if 'rate_limit' in error_msg or 'quota' in error_msg or '429' in error_msg:
                logger.warning(f"OpenAI rate limit hit: {e}, trying Gemini fallback...")
                try:
                    return await self._humanize_with_gemini(content, content_type, level, preserve_facts, ai_score_before, detection_before, start_time)
                except Exception as gemini_error:
                    logger.error(f"Gemini humanization fallback failed: {gemini_error}")
                    raise Exception(f"OpenAI rate limit exceeded and Gemini fallback failed: {gemini_error}")
            else:
                logger.error(f"Error humanizing content: {e}", exc_info=True)
                raise
    
    async def _humanize_with_gemini(
        self,
        content: str,
        content_type: str,
        level: str,
        preserve_facts: bool,
        ai_score_before: float,
        detection_before: Dict[str, Any],
        start_time: float
    ) -> Dict[str, Any]:
        """Fallback humanization using Gemini when OpenAI fails"""
        try:
            logger.info("Using Gemini for humanization...")
            
            level_instructions = {
                'light': """Make minimal changes to sound more natural:
- Add 1-2 contractions (e.g., "you're" instead of "you are")
- Vary sentence structure slightly
- Add one personal touch""",
                
                'balanced': """Make moderate changes for natural flow:
- Use contractions naturally
- Vary sentence length significantly
- Add personality and voice
- Include 1-2 colloquial expressions
- Break up perfect grammar occasionally
- Add natural transitions""",
                
                'aggressive': """Heavily rewrite to sound completely human:
- Maximum use of contractions
- Highly varied sentence structure
- Strong personal voice and opinions
- Multiple colloquialisms
- Natural grammar imperfections
- Conversational tone
- Add anecdotes or examples
- Remove corporate/formal language"""
            }
            
            instructions = level_instructions.get(level, level_instructions['balanced'])
            
            fact_instruction = """
CRITICAL: Preserve all factual information, statistics, and data points exactly as stated.
Only modify the writing style and tone.""" if preserve_facts else ""
            
            prompt = f"""Rewrite this {content_type} content to sound more human-written while maintaining its core message.

{instructions}

{fact_instruction}

Original Content:
{content}

Requirements:
- Keep the same length approximately
- Maintain the key points and message
- Make it sound like a real person wrote it
- Remove obvious AI patterns
- Add natural imperfections

Return ONLY the humanized content, no explanations."""

            response = await asyncio.to_thread(
                self.gemini_model.generate_content, prompt
            )
            
            humanized_content = response.text.strip()
            logger.info(f"Gemini humanization complete: {len(humanized_content)} chars")
            
            # Detect AI score after humanization
            detection_after = await self.detect_ai_content(humanized_content)
            ai_score_after = detection_after['aiScore']
            
            processing_time = time.time() - start_time
            improvement = ai_score_before - ai_score_after
            
            logger.info(f"Gemini humanization result: {ai_score_before} → {ai_score_after} (improvement: {improvement})")
            
            return {
                'humanizedContent': humanized_content,
                'beforeScore': ai_score_before,
                'afterScore': ai_score_after,
                'improvement': improvement,
                'improvementPercentage': (improvement / ai_score_before * 100) if ai_score_before > 0 else 0,
                'level': level,
                'detectionApi': 'gemini-fallback',
                'processingTime': processing_time,
                'tokensUsed': 0,  # Gemini doesn't provide token count in same way
                'beforeAnalysis': {
                    'indicators': detection_before.get('indicators', []),
                    'reasoning': detection_before.get('reasoning', '')
                },
                'afterAnalysis': {
                    'indicators': detection_after.get('indicators', []),
                    'reasoning': detection_after.get('reasoning', '')
                }
            }
        except Exception as e:
            logger.error(f"Gemini humanization failed: {e}")
            raise
    
    async def batch_humanize(
        self,
        contents: list[str],
        content_type: str,
        level: str = "balanced"
    ) -> list[Dict[str, Any]]:
        """
        Humanize multiple content pieces in batch
        Useful for humanizing multiple social media posts at once
        """
        results = []
        for content in contents:
            try:
                result = await self.humanize_content(content, content_type, level)
                results.append({
                    'success': True,
                    'result': result
                })
            except Exception as e:
                results.append({
                    'success': False,
                    'error': str(e),
                    'originalContent': content
                })
        
        return results
    
    async def analyze_humanization_quality(
        self,
        original: str,
        humanized: str
    ) -> Dict[str, Any]:
        """
        Compare original and humanized content
        Check if meaning is preserved and quality improved
        """
        try:
            prompt = f"""Compare these two versions of the same content:

ORIGINAL:
{original}

HUMANIZED:
{humanized}

Analyze:
1. Is the core message preserved? (yes/no)
2. Are key facts unchanged? (yes/no)
3. Does it sound more human? (yes/no)
4. Quality rating: 0-10
5. What improved?
6. Any concerns?

Return JSON:
{{
    "messagePreserved": true/false,
    "factsUnchanged": true/false,
    "soundsMoreHuman": true/false,
    "qualityRating": <0-10>,
    "improvements": ["improvement1", ...],
    "concerns": ["concern1", ...],
    "recommendation": "approve/revise/reject"
}}"""

            response = await self.openai_client.chat.completions.create(
                model=self.openai_model,
                messages=[
                    {"role": "system", "content": "You are a content quality analyst. Always return valid JSON."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.3,
                max_tokens=500
            )
            
            result = json.loads(response.choices[0].message.content)
            return result
            
        except Exception as e:
            logger.error(f"Error analyzing humanization quality: {e}")
            return {
                'messagePreserved': True,
                'factsUnchanged': True,
                'soundsMoreHuman': True,
                'qualityRating': 5,
                'improvements': [],
                'concerns': [str(e)],
                'recommendation': 'approve'
            }

# Singleton instance
humanization_service = HumanizationService()
