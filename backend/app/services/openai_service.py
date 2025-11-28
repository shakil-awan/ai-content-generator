"""
AI Content Generation Service
✅ PRIMARY: Google Gemini 2.0 Flash ($0.10/$0.40 per 1M tokens)
⚠️ FALLBACK: OpenAI GPT-4o-mini ($0.15/$0.60 per 1M tokens)
💾 CACHING: Redis + Gemini prompt caching (90% discount)
🎯 QUALITY: Auto-regeneration for low-quality content (<0.60 score)

Decision: Gemini 2.0 Flash chosen for:
- 75% cost savings vs GPT-4o-mini
- Equal/better quality (8.3/10 vs 8.5/10)
- Faster response times
- 1M token context window
- FREE tier for development

See backend/AI_MODELS_CONFIG.md for full analysis
Updated: November 25, 2025
"""
from typing import Dict, Any, List, Optional
import asyncio
from openai import AsyncOpenAI
from openai import (
    APIError as OpenAIAPIError,
    RateLimitError as OpenAIRateLimitError,
    APIConnectionError,
    APITimeoutError as OpenAITimeoutError,
    AuthenticationError,
    BadRequestError
)
import google.generativeai as genai
from google.api_core import exceptions as google_exceptions
from app.config import settings
from app.utils.cache_manager import cache_manager
from app.utils.quality_scorer import quality_scorer, QualityScore
from app.services.gemini_quality_analyzer import GeminiQualityAnalyzer, AIQualityAnalysis
from app.services.smart_fact_checker import SmartFactChecker, FactCheckResult
from app.exceptions import (
    AIServiceError,
    RateLimitError,
    InvalidAPIKeyError,
    AIModelNotFoundError,
    ContentPolicyViolationError,
    TokenLimitExceededError,
    AITimeoutError,
    NetworkError
)
import logging
import json
import time
from typing import Tuple

logger = logging.getLogger(__name__)

# ==================== HELPER FUNCTIONS ====================

# NOTE: clean_json_response() was removed - now using Gemini's native response_schema
# for guaranteed JSON structure. See generate_social_media() for implementation.

def calculate_max_tokens(target_word_count: int) -> int:
    """
    Calculate max_output_tokens for accurate word count generation (500-4000 words)
    
    Gemini token-to-word ratio: ~1 token = 0.75 words
    Formula: tokens = (words / 0.75) * safety_margin + system_overhead
    System overhead: ~800 tokens (concise few-shot examples + instructions)
    
    Args:
        target_word_count: Desired word count for content (500-4000)
    
    Returns:
        Optimal max_output_tokens value (includes system prompt overhead)
    """
    # Clamp to supported range
    target_word_count = max(500, min(target_word_count, 4000))
    
    # Base calculation: convert words to tokens with increased safety margin for JSON schema
    # 1 word ≈ 1.33 tokens, add 100% safety margin = 3.0x multiplier (increased from 2.0x)
    # This accounts for JSON schema overhead, structured output formatting, etc.
    base_tokens = int(target_word_count * 3.0)
    
    # Add system prompt overhead (concise examples + instructions ~800 tokens)
    tokens_with_overhead = base_tokens + 800
    
    # Map to word count ranges (Gemini 2.5 Flash: 65,536 output token limit per official docs)
    # Source: https://ai.google.dev/gemini-api/docs/models/gemini#gemini-2.5-flash
    #
    # DRASTICALLY INCREASED: Blog schema is complex (nested sections, metadata, SEO)
    # JSON overhead alone can be 3000+ tokens for structured output
    # Formula: (words * 4) + 4000 (JSON schema overhead)
    if target_word_count <= 500:
        return 6000  # 500: (500*4)+4000=6000
    elif target_word_count <= 1000:
        return 8000  # 1000: (1000*4)+4000=8000 (was 6144, causing truncation)
    elif target_word_count <= 1500:
        return 10000  # 1500: (1500*4)+4000=10000
    elif target_word_count <= 2000:
        return 12000  # 2000: (2000*4)+4000=12000
    elif target_word_count <= 2500:
        return 14000  # 2500: (2500*4)+4000=14000
    elif target_word_count <= 3000:
        return 16000  # 3000: (3000*4)+4000=16000
    elif target_word_count <= 3500:
        return 20000  # 3500: (3500*4)+4000=18000 → 20000
    else:  # 3500-4000 words
        return 24000  # 4000: (4000*4)+4000=20000 → 24000

def get_generation_config_for_word_count(
    word_count: int,
    tone: str,
    response_schema: Optional[Dict[str, Any]] = None
) -> Tuple[Dict[str, Any], int]:
    """
    Get optimized GenerationConfig parameters based on word count and tone
    
    Args:
        word_count: Target word count
        tone: Content tone (professional, casual, friendly, humorous, etc.)
        response_schema: Optional JSON schema for structured output
    
    Returns:
        Tuple of (config_dict, max_tokens)
    """
    # Calculate optimal token limit
    max_tokens = calculate_max_tokens(word_count)
    
    # Phase 2: Enhanced tone-specific configurations with top_k
    # NOTE: presence_penalty and frequency_penalty are NOT supported by gemini-2.5-flash
    # NOTE: 'description' field removed - not a valid GenerationConfig parameter
    tone_configs = {
        "professional": {
            "temperature": 0.70,
            "top_p": 0.90,
            "top_k": 40
        },
        "casual": {
            "temperature": 0.85,
            "top_p": 0.95,
            "top_k": 50
        },
        "friendly": {
            "temperature": 0.80,
            "top_p": 0.92,
            "top_k": 45
        },
        "formal": {
            "temperature": 0.65,
            "top_p": 0.88,
            "top_k": 35
        },
        "humorous": {
            "temperature": 0.90,
            "top_p": 0.95,
            "top_k": 55
        },
        "inspirational": {
            "temperature": 0.85,
            "top_p": 0.93,
            "top_k": 48
        },
        "informative": {
            "temperature": 0.70,
            "top_p": 0.90,
            "top_k": 40
        }
    }
    
    # Default config for unknown tones
    default_config = {
        "temperature": 0.75,
        "top_p": 0.92,
        "top_k": 42
    }
    
    # Get tone-specific config or use default (Phase 2)
    tone_lower = tone.lower()
    config = tone_configs.get(tone_lower, default_config).copy()
    
    # Word count adjustments no longer needed - top_k is already in config
    # (Longer content diversity is already handled by tone-specific top_k values)
    
    # Add max tokens and response format
    config["max_output_tokens"] = max_tokens
    config["response_mime_type"] = "application/json"
    
    # Note: response_schema has significant token overhead (~2K tokens)
    # Only use for larger content where structure is more complex
    if response_schema:
        config["response_schema"] = response_schema
    
    return config, max_tokens

def get_blog_response_schema(word_count: int) -> Dict[str, Any]:
    """
    DEPRECATED: Use get_blog_post_schema() from app.schemas.ai_schemas instead
    
    This function used the OLD SDK's response_schema format.
    New SDK uses Pydantic schemas with response_json_schema parameter.
    
    Args:
        word_count: Target word count for validation tolerance
    
    Returns:
        JSON schema dict for Gemini response_schema parameter
    """
    tolerance = 100  # ±100 words tolerance
    
    return {
        'type': 'object',
        'properties': {
            'title': {
                'type': 'string',
                'description': 'SEO-optimized blog title with primary keyword (max 60 characters)'
            },
            'metaDescription': {
                'type': 'string',
                'description': 'SEO meta description, exactly 155-160 characters'
            },
            'content': {
                'type': 'string',
                'description': f'Full blog post content in markdown format, approximately {word_count} words'
            },
            'headings': {
                'type': 'array',
                'items': {'type': 'string'},
                'description': 'Array of H2 section headings (3-7 headings)'
            },
            'wordCount': {
                'type': 'integer',
                'description': f'Actual word count of content (target: {word_count} ±{tolerance} words)'
            }
        },
        'required': ['title', 'metaDescription', 'content', 'headings', 'wordCount']
    }

def build_keyword_context(keywords: List[str], target_audience: Optional[str] = None) -> str:
    """
    Build keyword context for better SEO integration (Phase 2)
    
    Args:
        keywords: List of SEO keywords
        target_audience: Target audience description
    
    Returns:
        Formatted keyword strategy section
    """
    if not keywords:
        return ""
    
    primary = keywords[0]
    secondary = keywords[1:4] if len(keywords) > 1 else []
    
    context = f"""\n<keyword_strategy>
PRIMARY KEYWORD: \"{primary}\"
- Use EXACTLY 3-5 times naturally in content
- Include in title, meta description, and first paragraph
- Use in at least 2 H2 headings
"""
    
    if secondary:
        context += f"\nSECONDARY KEYWORDS: {', '.join(f'\"{k}\"' for k in secondary)}"
        context += "\n- Use each 1-2 times naturally"
        context += "\n- Weave into content seamlessly\n"
    
    if target_audience:
        context += f"\nTARGET AUDIENCE: {target_audience}"
        context += "\n- Write at appropriate comprehension level"
        context += "\n- Use vocabulary and examples they relate to\n"
    
    context += "</keyword_strategy>"
    return context

def build_blog_system_prompt_with_examples(word_count: int, tone: str) -> str:
    """
    Build system prompt with few-shot examples for blog generation
    
    Google Gemini Best Practice: "We recommend to always include few-shot examples"
    
    Args:
        word_count: Target word count
        tone: Content tone
    
    Returns:
        System prompt with examples and instructions
    """
    return f"""<role>
You are an expert SEO content writer with 10+ years of experience in digital publishing.
You specialize in creating comprehensive, engaging, and search-engine-optimized blog posts.
Your expertise includes keyword optimization, reader engagement, and content structure.
</role>

<critical_constraints>
1. Write EXACTLY {word_count} words (±50 words maximum tolerance)
2. Return ONLY valid JSON - no markdown code blocks, no extra text
3. Include primary keyword naturally 3-5 times throughout content
4. Use secondary keywords 1-2 times each, naturally integrated
5. Markdown formatting: headers (##, ###), bold (**text**), lists, blockquotes
6. Tone: {tone}
7. NO fluff, NO filler, NO generic statements
8. Include actionable insights and takeaways in conclusion
9. Use short paragraphs (3-4 sentences max) for readability
10. Add transition phrases between sections for flow
</critical_constraints>

<seo_requirements>
- Title: 60 characters max, include primary keyword
- Meta description: 155-160 characters exactly, compelling CTA
- H2 headings: 3-7 sections with keyword variations
- Content: Scannable with bullet points, numbered lists, bold key phrases
- Internal linking opportunities: Mention related topics naturally
- Conclusion: Clear call-to-action or next steps
</seo_requirements>

<few_shot_examples>
Example 1 - 500 words:
{{
    "title": "AI in Healthcare: 5 Revolutionary Changes",
    "metaDescription": "AI transforms healthcare through diagnostics, personalized treatment, drug discovery. Discover 5 ways artificial intelligence is revolutionizing medicine.",
    "content": "## Introduction\n\nAI is transforming healthcare...[500 words total]",
    "headings": ["Introduction", "AI Diagnostics", "Treatment Plans", "Drug Discovery", "Conclusion"],
    "wordCount": 500
}}

Example 2 - 1000 words:
{{
    "title": "Remote Work Productivity: 10 Proven Tips",
    "metaDescription": "Master remote work with 10 productivity strategies. Time management, workspace setup, work-life balance tips for working from home effectively.",
    "content": "## Introduction\n\nRemote work requires new strategies...[1000 words total]",
    "headings": ["Introduction", "Workspace", "Time Management", "Communication", "Breaks", "Boundaries", "Tools", "Balance", "Conclusion"],
    "wordCount": 1000
}}
</few_shot_examples>

<word_count_verification>
CRITICAL: Count every word in your content.
Target: {word_count} words
Acceptable range: {word_count - 50} to {word_count + 50} words

If your content is:
- TOO SHORT: Add more examples, data, or detailed explanations
- TOO LONG: Remove redundant phrases and tighten writing

Set the "wordCount" field to your ACTUAL word count.
</word_count_verification>

<seo_requirements>
- Title: Maximum 60 characters, include primary keyword
- Meta description: Exactly 155-160 characters
- H2 headings: 3-7 sections with keyword variations
- Content: Scannable with bullet points and short paragraphs (3-4 sentences max)
- First paragraph: Include primary keyword and hook readers
</seo_requirements>

<output_format>
Return ONLY valid JSON. No markdown code blocks. No explanations. Just the JSON object.
</output_format>
"""

def validate_blog_output(output: Dict[str, Any], target_word_count: int) -> Dict[str, Any]:
    """
    Validate and score blog output quality
    
    Works with both OLD schema (content + headings) and NEW schema (introduction + sections + conclusion)
    
    Checks:
    - Word count accuracy
    - Meta description length
    - Title length
    - Minimum sections/headings
    - Content structure
    
    Args:
        output: Generated blog output
        target_word_count: Target word count
    
    Returns:
        Validation results with issues and quality score
    """
    issues = []
    
    # Check word count accuracy (high priority)
    actual_words = output.get('wordCount', 0)
    if isinstance(actual_words, str):
        actual_words = int(actual_words) if actual_words.isdigit() else 0
    
    tolerance = 50
    if not (target_word_count - tolerance <= actual_words <= target_word_count + tolerance):
        issues.append({
            'field': 'wordCount',
            'expected': f"{target_word_count} ±{tolerance}",
            'actual': actual_words,
            'severity': 'high'
        })
    
    # Check meta description length (medium priority)
    meta_desc = output.get('metaDescription', '')
    if not (155 <= len(meta_desc) <= 160):
        issues.append({
            'field': 'metaDescription',
            'expected': '155-160 chars',
            'actual': len(meta_desc),
            'severity': 'medium'
        })
    
    # Check title length (medium priority)
    title = output.get('title', '')
    if len(title) > 60:
        issues.append({
            'field': 'title',
            'expected': '≤60 chars',
            'actual': len(title),
            'severity': 'medium'
        })
    
    # Check minimum sections/headings (low priority)
    # NEW schema: sections (list of objects with heading + content)
    # OLD schema: headings (list of strings)
    sections = output.get('sections', [])
    headings = output.get('headings', [])
    section_count = len(sections) if sections else len(headings)
    
    if section_count < 3:
        issues.append({
            'field': 'sections',
            'expected': '≥3 sections',
            'actual': section_count,
            'severity': 'low'
        })
    
    # Check content exists
    # NEW schema: introduction + sections + conclusion
    # OLD schema: content (single string)
    content_check = False
    
    if 'introduction' in output and 'sections' in output and 'conclusion' in output:
        # NEW schema
        intro = output.get('introduction', '')
        sections_content = ' '.join(s.get('content', '') for s in output.get('sections', []))
        conclusion = output.get('conclusion', '')
        total_content = intro + sections_content + conclusion
        content_check = len(total_content) >= 100
    else:
        # OLD schema
        content = output.get('content', '')
        content_check = len(content) >= 100
    
    if not content_check:
        issues.append({
            'field': 'content',
            'expected': 'substantial content (≥100 chars)',
            'actual': 'insufficient content',
            'severity': 'high'
        })
    
    # Calculate quality score (0-100)
    high_issues = sum(1 for i in issues if i['severity'] == 'high')
    medium_issues = sum(1 for i in issues if i['severity'] == 'medium')
    low_issues = sum(1 for i in issues if i['severity'] == 'low')
    
    quality_score = 100 - (high_issues * 30) - (medium_issues * 15) - (low_issues * 5)
    quality_score = max(0, quality_score)
    
    # Calculate word count accuracy percentage (0-100, where 100 is perfect)
    if target_word_count > 0 and actual_words > 0:
        word_count_accuracy = 100 - (abs(actual_words - target_word_count) / target_word_count * 100)
        word_count_accuracy = max(0, min(100, word_count_accuracy))
    else:
        word_count_accuracy = 0
    
    return {
        'valid': high_issues == 0,
        'issues': issues,
        'quality_score': quality_score,
        'word_count_accuracy': word_count_accuracy
    }

class OpenAIService:
    """
    AI Content Generation Service
    PRIMARY: Gemini 2.0 Flash (cost-optimized)
    FALLBACK: GPT-4o-mini (quality backup)
    """
    _instance: Optional['OpenAIService'] = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        # PRIMARY: Gemini 2.5 Flash - Use this by default
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self.gemini_model = genai.GenerativeModel(settings.PRIMARY_TEXT_MODEL)
        self.gemini_premium_model = genai.GenerativeModel(settings.PREMIUM_TEXT_MODEL)
        
        # FALLBACK: OpenAI GPT-4o-mini - Use only on errors or quality issues
        self.openai_client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
        self.openai_model = settings.FALLBACK_TEXT_MODEL
        
        # NOTE: Removed self.use_fallback - now handled per-request in _generate_with_ai
        # This prevents persistent fallback state across requests
        
        # Gemini cached system prompts (90% discount after 7-day TTL)
        # These are reused across all generations of the same content type
        self._cached_system_prompts: Dict[str, Any] = {}
        
        # AI-powered quality enhancement (Gemini 2.0 Flash + Google Custom Search)
        # Cost: ~$0.0001 per analysis (grammar, style, tone, engagement)
        # Optional fact-checking: ~$0.0005 per check (only for important content)
        try:
            self.ai_analyzer = GeminiQualityAnalyzer()
            self.fact_checker = SmartFactChecker()
            self.ai_analysis_enabled = True
            logger.info("✨ AI quality analyzer and fact-checker initialized successfully")
        except Exception as e:
            logger.warning(f"⚠️ AI analysis disabled (will use basic quality scoring only): {e}")
            self.ai_analyzer = None
            self.fact_checker = None
            self.ai_analysis_enabled = False
        
        # AI-powered quality enhancement (Gemini 2.0 Flash + Google Custom Search)
        # Cost: ~$0.0001 per analysis (grammar, style, tone, engagement)
        # Optional fact-checking: ~$0.0005 per check (only for important content)
        try:
            self.ai_analyzer = GeminiQualityAnalyzer()
            self.fact_checker = SmartFactChecker()
            self.ai_analysis_enabled = True
            logger.info("✨ AI quality analyzer and fact-checker initialized successfully")
        except Exception as e:
            logger.warning(f"⚠️ AI analysis disabled (will use basic quality scoring only): {e}")
            self.ai_analyzer = None
            self.fact_checker = None
            self.ai_analysis_enabled = False
    
    def _should_use_premium_model(self, user_tier: Optional[str] = None, content_complexity: str = "standard") -> bool:
        """
        Smart routing logic: Determine if premium model should be used
        
        Args:
            user_tier: User's subscription tier (free/hobby/pro/enterprise)
            content_complexity: Content complexity level (standard/complex/technical)
        
        Returns:
            bool: True if premium model (Gemini 2.5 Flash) should be used
        """
        from app.constants import SubscriptionPlan
        
        # Enterprise tier always gets premium model
        if user_tier == SubscriptionPlan.ENTERPRISE:
            return True
        
        # Pro tier gets premium for complex content
        if user_tier == SubscriptionPlan.PRO and content_complexity in ["complex", "technical"]:
            return True
        
        # Free/Hobby tiers always use standard model
        return False
    
    async def _generate_with_quality_check_v2(
        self,
        system_prompt: str,
        user_prompt: str,
        generation_config: Dict[str, Any],
        use_premium: bool,
        content_type: str,
        user_id: Optional[str],
        metadata: Optional[Dict[str, Any]] = None,
        max_regenerations: int = 1
    ) -> Dict[str, Any]:
        """
        Generate content with quality checking and new generation_config dict
        
        V2 Changes:
        - Accepts generation_config dict instead of max_tokens
        - Supports presence_penalty, frequency_penalty, response_schema
        - Better logging for debugging
        """
        metadata = metadata or {}
        attempts = 0
        current_use_premium = use_premium
        max_tokens = generation_config.get('max_output_tokens', 4000)
        
        while attempts <= max_regenerations:
            attempts += 1
            
            # Generate content with new config
            result = await self._generate_with_ai_v2(
                system_prompt=system_prompt,
                user_prompt=user_prompt,
                generation_config=generation_config,
                use_premium=current_use_premium,
                content_type=content_type,
                user_id=user_id
            )
            
            # Parse content for quality check
            try:
                if content_type in ['blog', 'email', 'product', 'ad']:
                    output = json.loads(result['content'])
                    content_text = output.get('content', '') or str(output)
                else:
                    content_text = result['content']
            except (json.JSONDecodeError, KeyError) as e:
                logger.debug(f"JSON parsing failed for quality check: {e}")
                content_text = result['content']
            
            # Phase 1: Basic quality scoring (regex-based - fast and free)
            quality_score = quality_scorer.score_content(
                content=content_text,
                content_type=content_type,
                metadata=metadata
            )
            
            # Phase 2: AI-powered deep analysis (optional, ~$0.0001 per analysis)
            ai_analysis = None
            if self.ai_analysis_enabled and self.ai_analyzer:
                try:
                    ai_analysis = await self.ai_analyzer.analyze_quality(
                        content=content_text,
                        content_type=content_type,
                        metadata=metadata
                    )
                    
                    # Blend AI scores with basic scores (50/50 weight for grammar)
                    # Keep other scores from basic analysis (they're reliable)
                    original_grammar = quality_score.grammar
                    quality_score.grammar = (original_grammar * 0.5 + ai_analysis.grammar_score * 0.5)
                    
                    # Add AI analysis to result for API response
                    result['ai_analysis'] = {
                        'grammar_score': ai_analysis.grammar_score,
                        'style_score': ai_analysis.style_score,
                        'tone_score': ai_analysis.tone_score,
                        'engagement_score': ai_analysis.engagement_score,
                        'overall_ai_score': ai_analysis.overall_ai_score,
                        'improvements': ai_analysis.improvements,
                        'strengths': ai_analysis.strengths
                    }
                    
                    logger.info(f"✨ AI Analysis: {ai_analysis.overall_ai_score:.2f} (grammar: {ai_analysis.grammar_score:.2f}, style: {ai_analysis.style_score:.2f}, tone: {ai_analysis.tone_score:.2f})")
                except Exception as e:
                    logger.error(f"AI analysis failed (using basic scores only): {e}")
                    result['ai_analysis'] = None
            else:
                result['ai_analysis'] = None
            
            logger.info(f"Quality score: {quality_score.overall:.2f} (grade: {quality_score._get_grade()}) - Attempt {attempts}")
            
            # Check if regeneration needed
            if quality_scorer.should_regenerate(quality_score) and attempts <= max_regenerations:
                logger.warning(f"⚠️ Low quality score ({quality_score.overall:.2f}). Regenerating with premium model...")
                current_use_premium = True
                continue
            
            # Quality acceptable or max attempts reached
            result['quality_score'] = quality_score.to_dict()
            result['regeneration_count'] = attempts - 1
            
            if quality_score.overall >= quality_scorer.EXCELLENT_THRESHOLD:
                logger.info(f"✅ Excellent quality achieved: {quality_score.overall:.2f}")
            elif quality_score.overall >= quality_scorer.GOOD_THRESHOLD:
                logger.info(f"✅ Good quality achieved: {quality_score.overall:.2f}")
            else:
                logger.warning(f"⚠️ Moderate quality: {quality_score.overall:.2f} (max attempts reached)")
            
            return result
        
        result['quality_score'] = quality_score.to_dict()
        result['regeneration_count'] = attempts - 1
        return result
    
    async def _generate_with_quality_check(
        self,
        system_prompt: str,
        user_prompt: str,
        max_tokens: int,
        use_premium: bool,
        content_type: str,
        user_id: Optional[str],
        metadata: Optional[Dict[str, Any]] = None,
        max_regenerations: int = 1
    ) -> Dict[str, Any]:
        """
        Generate content with automatic quality checking and regeneration
        
        If quality score < 0.60, automatically regenerates with premium model
        
        Args:
            system_prompt: System instructions
            user_prompt: User request
            max_tokens: Max tokens to generate
            use_premium: Whether to use premium model initially
            content_type: Type of content for quality scoring
            user_id: User ID for caching
            metadata: Metadata for quality scoring (keywords, target_length, etc.)
            max_regenerations: Maximum number of regeneration attempts
        
        Returns:
            Generation result with quality score
        """
        metadata = metadata or {}
        attempts = 0
        current_use_premium = use_premium
        
        while attempts <= max_regenerations:
            attempts += 1
            
            # Generate content
            result = await self._generate_with_ai(
                system_prompt=system_prompt,
                user_prompt=user_prompt,
                max_tokens=max_tokens,
                use_premium=current_use_premium,
                content_type=content_type,
                user_id=user_id
            )
            
            # Parse content for quality check
            try:
                if content_type in ['blog', 'email', 'product', 'ad']:
                    # JSON output - extract content field
                    output = json.loads(result['content'])
                    content_text = output.get('content', '') or str(output)
                else:
                    # Direct text
                    content_text = result['content']
            except (json.JSONDecodeError, KeyError) as e:
                # If JSON parsing fails, use raw content
                logger.debug(f"JSON parsing failed for quality check: {e}")
                content_text = result['content']
            
            # Score quality
            quality_score = quality_scorer.score_content(
                content=content_text,
                content_type=content_type,
                metadata=metadata
            )
            
            logger.info(f"Quality score: {quality_score.overall:.2f} (grade: {quality_score._get_grade()}) - Attempt {attempts}")
            
            # Check if regeneration needed
            if quality_scorer.should_regenerate(quality_score) and attempts <= max_regenerations:
                logger.warning(f"⚠️ Low quality score ({quality_score.overall:.2f}). Regenerating with premium model...")
                current_use_premium = True  # Upgrade to premium for retry
                continue
            
            # Quality acceptable or max attempts reached
            result['quality_score'] = quality_score.to_dict()
            result['regeneration_count'] = attempts - 1
            
            if quality_score.overall >= quality_scorer.EXCELLENT_THRESHOLD:
                logger.info(f"✅ Excellent quality achieved: {quality_score.overall:.2f}")
            elif quality_score.overall >= quality_scorer.GOOD_THRESHOLD:
                logger.info(f"✅ Good quality achieved: {quality_score.overall:.2f}")
            else:
                logger.warning(f"⚠️ Moderate quality: {quality_score.overall:.2f} (max attempts reached)")
            
            return result
        
        # Should never reach here, but return last attempt
        result['quality_score'] = quality_score.to_dict()
        result['regeneration_count'] = attempts - 1
        return result
    
    def _get_cached_system_content(self, content_type: str, system_prompt: str, use_premium: bool = False) -> Optional[Any]:
        """
        Get or create cached system prompt for Gemini
        Gemini prompt caching provides 90% discount on cached tokens
        
        Args:
            content_type: Type of content (blog, social, etc.)
            system_prompt: System prompt to cache
            use_premium: Whether using premium model
            
        Returns:
            Cached content object for Gemini or None
        """
        if not settings.ENABLE_PROMPT_CACHING:
            return None
        
        cache_key = f"{content_type}_{'premium' if use_premium else 'standard'}"
        
        # Return existing cached prompt if available
        if cache_key in self._cached_system_prompts:
            logger.debug(f"💾 Using cached system prompt for {cache_key}")
            return self._cached_system_prompts[cache_key]
        
        # Create new cached content for Gemini
        try:
            cached_content = genai.caching.CachedContent.create(
                model=settings.PREMIUM_TEXT_MODEL if use_premium else settings.PRIMARY_TEXT_MODEL,
                contents=[{
                    'role': 'user',
                    'parts': [{'text': system_prompt}]
                }],
                ttl=settings.CACHE_TTL_SYSTEM_PROMPTS,  # 7 days
                display_name=f"{content_type}_system_prompt"
            )
            self._cached_system_prompts[cache_key] = cached_content
            logger.info(f"✅ Created Gemini cached prompt for {cache_key} (90% discount for 7 days)")
            return cached_content
        except Exception as e:
            logger.warning(f"⚠️ Failed to create Gemini cache for {cache_key}: {e}")
            return None
    
    async def _generate_with_ai(
        self, 
        system_prompt: str, 
        user_prompt: str, 
        max_tokens: int = 2000,
        use_premium: bool = False,
        content_type: str = "generic",
        user_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Generate content with AI
        PRIMARY: Gemini 2.0 Flash (default) - 75% cheaper, excellent quality
        FALLBACK: GPT-4o-mini (on errors only)
        PREMIUM: Gemini 2.5 Flash (Enterprise tier, complex content)
        CACHING: Redis for generations + Gemini prompt caching (90% discount)
        
        Args:
            system_prompt: System instructions for the model
            user_prompt: User's actual request
            max_tokens: Maximum tokens to generate
            use_premium: If True, use premium model (Gemini 2.5 Flash)
            content_type: Type of content for caching
            user_id: User ID for personalized caching
        
        Returns:
            Dict with content, tokens used, model name, and cache stats
        """
        # Check Redis cache first for identical generations
        cache_key = None
        if user_id and settings.ENABLE_CACHE:
            cached_result = cache_manager.get_cached_generation(
                content_type=content_type,
                prompt=user_prompt,
                user_id=user_id
            )
            if cached_result:
                logger.info(f"💾 Cache HIT: Returning cached {content_type} generation")
                cached_result['cached'] = True
                return cached_result
        
        start_time = time.time()
        
        # Try PRIMARY model first (Gemini 2.5 Flash)
        try:
            # Select model based on premium flag
            model_name = settings.PREMIUM_TEXT_MODEL if use_premium else settings.PRIMARY_TEXT_MODEL
            
            # Get cached system prompt (90% discount)
            cached_system = self._get_cached_system_content(
                content_type=content_type,
                system_prompt=system_prompt,
                use_premium=use_premium
            )
            
            # Generate with Gemini using cached system prompt
            if cached_system:
                # Use model with cached system prompt
                model = genai.GenerativeModel.from_cached_content(cached_system)
                response = model.generate_content(
                    user_prompt,
                    generation_config=genai.types.GenerationConfig(
                        max_output_tokens=max_tokens,
                        temperature=0.7,
                    )
                )
            else:
                # Fallback to regular generation without caching
                model = self.gemini_premium_model if use_premium else self.gemini_model
                full_prompt = f"{system_prompt}\n\n{user_prompt}"
                response = model.generate_content(
                    full_prompt,
                    generation_config=genai.types.GenerationConfig(
                        max_output_tokens=max_tokens,
                        temperature=0.7,
                    )
                )
            
            # Clean response (remove markdown code blocks if present)
            content = response.text.strip()
            
            # Extract JSON from markdown code blocks
            if '```json' in content:
                start = content.find('```json') + 7
                end = content.find('```', start)
                if end > start:
                    content = content[start:end].strip()
            elif '```' in content:
                start = content.find('```') + 3
                end = content.find('```', start)
                if end > start:
                    content = content[start:end].strip()
            
            # Additional cleanup - find first { and last }
            if '{' in content and '}' in content:
                first_brace = content.find('{')
                last_brace = content.rfind('}')
                content = content[first_brace:last_brace + 1]
            
            generation_time = time.time() - start_time
            logger.info(f"✅ Generated with {model_name} in {generation_time:.2f}s (cached_prompt: {cached_system is not None})")
            
            result = {
                'content': content,
                'tokensUsed': 0,  # Gemini doesn't expose token count easily
                'model': model_name,
                'cached': False,
                'cached_prompt': cached_system is not None,
                'generation_time': generation_time
            }
            
            # Cache the result in Redis
            if user_id and settings.ENABLE_CACHE:
                cache_manager.cache_generation(
                    content_type=content_type,
                    prompt=user_prompt,
                    result=result,
                    user_id=user_id,
                    ttl=settings.CACHE_TTL_GENERATIONS
                )
            
            return result
                
        except google_exceptions.ResourceExhausted as e:
            # Gemini rate limit (429) - fallback to OpenAI for this request only
            logger.warning(f"⚠️ Gemini rate limited: {e}. Falling back to OpenAI for this request.")
        except google_exceptions.Unauthenticated as e:
            # Invalid API key (401)
            logger.error(f"❌ Gemini authentication failed: {e}")
            raise InvalidAPIKeyError("Gemini")
        except google_exceptions.InvalidArgument as e:
            # Invalid request (400) - possibly content policy or token limit
            logger.error(f"❌ Gemini invalid request: {e}")
            if "content" in str(e).lower() and "policy" in str(e).lower():
                raise ContentPolicyViolationError("Gemini", str(e))
            raise AIServiceError(str(e), "Gemini")
        except google_exceptions.DeadlineExceeded as e:
            # Timeout - fallback to OpenAI for this request only
            logger.warning(f"⚠️ Gemini timeout: {e}. Falling back to OpenAI for this request.")
        except google_exceptions.NotFound as e:
            # Model not found (404)
            logger.error(f"❌ Gemini model not found: {e}")
            raise AIModelNotFoundError(
                settings.PREMIUM_TEXT_MODEL if use_premium else settings.PRIMARY_TEXT_MODEL,
                "Gemini"
            )
        except Exception as e:
            # Unexpected Gemini error - fallback for this request only
            logger.warning(f"⚠️ Gemini error, falling back to OpenAI (GPT-4o-mini) for this request: {e}")
        
        # FALLBACK to OpenAI GPT-4o-mini
        try:
            response = await self.openai_client.chat.completions.create(
                model=self.openai_model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                temperature=0.7,
                max_tokens=max_tokens
            )
            content = response.choices[0].message.content
            
            generation_time = time.time() - start_time
            logger.info(f"✅ Generated with fallback {self.openai_model} in {generation_time:.2f}s")
            
            result = {
                'content': content,
                'tokensUsed': response.usage.total_tokens,
                'model': self.openai_model,
                'cached': False,
                'cached_prompt': False,
                'generation_time': generation_time
            }
            
            # Cache OpenAI result too
            if user_id and settings.ENABLE_CACHE:
                cache_manager.cache_generation(
                    content_type=content_type,
                    prompt=user_prompt,
                    result=result,
                    user_id=user_id,
                    ttl=settings.CACHE_TTL_GENERATIONS
                )
            
            return result
        except OpenAIRateLimitError as e:
            # OpenAI rate limit (429)
            logger.error(f"❌ Both Gemini and OpenAI rate limited: {e}")
            raise RateLimitError(
                service="OpenAI",
                retry_after=getattr(e, 'retry_after', None),
                limit="tokens or requests per minute"
            )
        except AuthenticationError as e:
            # Invalid API key (401)
            logger.error(f"❌ OpenAI authentication failed: {e}")
            raise InvalidAPIKeyError("OpenAI")
        except BadRequestError as e:
            # Invalid request (400) - token limit or content policy
            error_msg = str(e)
            logger.error(f"❌ OpenAI bad request: {error_msg}")
            if "maximum context length" in error_msg.lower():
                raise TokenLimitExceededError(
                    service="OpenAI",
                    requested=max_tokens,
                    limit=4096  # Default context window
                )
            elif "content" in error_msg.lower() and "policy" in error_msg.lower():
                raise ContentPolicyViolationError("OpenAI", error_msg)
            raise AIServiceError(error_msg, "OpenAI")
        except OpenAITimeoutError as e:
            # Timeout
            logger.error(f"❌ OpenAI timeout: {e}")
            raise AITimeoutError("OpenAI", timeout_seconds=60)
        except APIConnectionError as e:
            # Network error
            logger.error(f"❌ OpenAI connection error: {e}")
            raise NetworkError("OpenAI", str(e))
        except OpenAIAPIError as e:
            # Generic OpenAI API error (500, 502, 503)
            logger.error(f"❌ OpenAI API error: {e}")
            raise AIServiceError(str(e), "OpenAI")
        except Exception as e:
            logger.error(f"❌ Both Gemini and OpenAI failed with unexpected error: {e}", exc_info=True)
            raise AIServiceError(
                f"All AI services failed. Please try again later. Error: {str(e)}",
                "AI"
            )
    
    async def _generate_with_ai_v2(
        self,
        system_prompt: str,
        user_prompt: str,
        generation_config: Dict[str, Any],
        use_premium: bool = False,
        content_type: str = "generic",
        user_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        V2: Generate content with enhanced configuration (Phase 1 improvements)
        
        NEW FEATURES:
        - ✅ Accepts generation_config dict with presence_penalty, frequency_penalty
        - ✅ Supports response_schema for guaranteed JSON structure
        - ✅ Enhanced error handling and logging
        - ✅ Compatible with gemini-2.5-flash (65K tokens)
        
        Args:
            system_prompt: System instructions
            user_prompt: User request
            generation_config: Dict with max_output_tokens, temperature, top_p, top_k,
                              presence_penalty, frequency_penalty, response_schema, etc.
            use_premium: Use premium model
            content_type: Type of content for caching
            user_id: User ID for caching
        
        Returns:
            Dict with content, tokens, model, cache stats
        """
        # Check Redis cache first
        if user_id and settings.ENABLE_CACHE:
            cached_result = cache_manager.get_cached_generation(
                content_type=content_type,
                prompt=user_prompt,
                user_id=user_id
            )
            if cached_result:
                logger.info(f"💾 Cache HIT: Returning cached {content_type} generation")
                cached_result['cached'] = True
                return cached_result
        
        start_time = time.time()
        max_tokens = generation_config.get('max_output_tokens', 4000)
        
        # Try PRIMARY model first (Gemini 2.5 Flash)
        try:
            model_name = settings.PREMIUM_TEXT_MODEL if use_premium else settings.PRIMARY_TEXT_MODEL
            
            # Get cached system prompt (90% discount)
            cached_system = self._get_cached_system_content(
                content_type=content_type,
                system_prompt=system_prompt,
                use_premium=use_premium
            )
            
            # Convert config dict to GenerationConfig object
            gemini_config = genai.types.GenerationConfig(**generation_config)
            
            # Generate with Gemini
            if cached_system:
                model = genai.GenerativeModel.from_cached_content(cached_system)
                response = model.generate_content(
                    user_prompt,
                    generation_config=gemini_config
                )
            else:
                model = self.gemini_premium_model if use_premium else self.gemini_model
                full_prompt = f"{system_prompt}\n\n{user_prompt}"
                response = model.generate_content(
                    full_prompt,
                    generation_config=gemini_config
            )
            
            # Check response validity
            if not response.candidates or len(response.candidates) == 0:
                raise Exception("No candidates in response")
            
            candidate = response.candidates[0]
            finish_reason = candidate.finish_reason
            
            # Check for blocked/failed responses
            # finish_reason: 1=STOP (success), 2=MAX_TOKENS, 3=SAFETY, 4=RECITATION, 5=OTHER
            if finish_reason != 1:  # Not STOP
                error_msg = f"Generation stopped with finish_reason={finish_reason}"
                if finish_reason == 2:
                    error_msg += " (MAX_TOKENS: increase max_output_tokens)"
                elif finish_reason == 3:
                    error_msg += " (SAFETY: content filtered by safety settings)"
                elif finish_reason == 4:
                    error_msg += " (RECITATION: copyrighted content detected)"
                else:
                    error_msg += " (OTHER: unknown reason)"
                
                # Check for prompt feedback (safety issues)
                if hasattr(response, 'prompt_feedback'):
                    error_msg += f". Prompt feedback: {response.prompt_feedback}"
                
                raise Exception(error_msg)
            
            # Handle response based on whether response_schema was used
            try:
                # Try to access .text first (works for text responses)
                content = response.text.strip()
                
                # Extract JSON from markdown code blocks if present
                if '```json' in content:
                    start_idx = content.find('```json') + 7
                    end_idx = content.find('```', start_idx)
                    if end_idx > start_idx:
                        content = content[start_idx:end_idx].strip()
                elif '```' in content:
                    start_idx = content.find('```') + 3
                    end_idx = content.find('```', start_idx)
                    if end_idx > start_idx:
                        content = content[start_idx:end_idx].strip()
                
                # Additional cleanup - find first { and last }
                if '{' in content and '}' in content:
                    first_brace = content.find('{')
                    last_brace = content.rfind('}')
                    content = content[first_brace:last_brace + 1]
            except Exception as text_error:
                # If .text fails, try accessing content from parts directly
                if candidate.content and candidate.content.parts:
                    content = candidate.content.parts[0].text
                else:
                    raise Exception(f"No content in response parts. Finish reason: {finish_reason}")
            
            generation_time = time.time() - start_time
            
            # Estimate token count (Gemini doesn't expose usage metadata)
            # Formula: ~1.3 tokens per word (industry standard for English)
            prompt_tokens = (len(system_prompt.split()) + len(user_prompt.split())) * 1.3
            completion_tokens = len(content.split()) * 1.3
            estimated_tokens = int(prompt_tokens + completion_tokens)
            
            # Log detailed info
            logger.info(f"✅ Generated with {model_name} in {generation_time:.2f}s")
            logger.info(f"📊 Estimated tokens: {estimated_tokens} (prompt: {int(prompt_tokens)}, completion: {int(completion_tokens)})")
            logger.debug(f"Config: temp={generation_config.get('temperature')}, "
                       f"presence_penalty={generation_config.get('presence_penalty')}, "
                       f"frequency_penalty={generation_config.get('frequency_penalty')}")
            
            result = {
                'content': content,
                'tokensUsed': estimated_tokens,  # 📊 Estimated token count for Gemini
                'model': model_name,
                'cached': False,
                'cached_prompt': cached_system is not None,
                'generation_time': generation_time
            }
            
            # Cache the result
            if user_id and settings.ENABLE_CACHE:
                cache_manager.cache_generation(
                    content_type=content_type,
                    prompt=user_prompt,
                    result=result,
                    user_id=user_id,
                    ttl=settings.CACHE_TTL_GENERATIONS
                )
            
            return result
                
        except google_exceptions.ResourceExhausted as e:
            # Gemini rate limit - fallback to OpenAI for this request only
            logger.warning(f"⚠️ Gemini rate limited: {e}. Falling back to OpenAI for this request.")
        except google_exceptions.Unauthenticated as e:
            logger.error(f"❌ Gemini authentication failed: {e}")
            raise InvalidAPIKeyError("Gemini")
        except google_exceptions.InvalidArgument as e:
            logger.error(f"❌ Gemini invalid request: {e}")
            if "content" in str(e).lower() and "policy" in str(e).lower():
                raise ContentPolicyViolationError("Gemini", str(e))
            raise AIServiceError(str(e), "Gemini")
        except google_exceptions.DeadlineExceeded as e:
            # Timeout - fallback to OpenAI for this request only
            logger.warning(f"⚠️ Gemini timeout: {e}. Falling back to OpenAI for this request.")
        except google_exceptions.NotFound as e:
            logger.error(f"❌ Gemini model not found: {e}")
            raise AIModelNotFoundError(model_name, "Gemini")
        except Exception as e:
            # Unexpected Gemini error - fallback for this request only
            logger.warning(f"⚠️ Gemini error, falling back to OpenAI for this request: {e}")
        
        # FALLBACK to OpenAI GPT-4o-mini
        try:
            temperature = generation_config.get('temperature', 0.7)
            response = await self.openai_client.chat.completions.create(
                model=self.openai_model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                temperature=temperature,
                max_tokens=max_tokens
            )
            content = response.choices[0].message.content
            
            generation_time = time.time() - start_time
            logger.info(f"✅ Generated with fallback {self.openai_model} in {generation_time:.2f}s")
            
            result = {
                'content': content,
                'tokensUsed': response.usage.total_tokens,
                'model': self.openai_model,
                'cached': False,
                'cached_prompt': False,
                'generation_time': generation_time
            }
            
            # Cache OpenAI result
            if user_id and settings.ENABLE_CACHE:
                cache_manager.cache_generation(
                    content_type=content_type,
                    prompt=user_prompt,
                    result=result,
                    user_id=user_id,
                    ttl=settings.CACHE_TTL_GENERATIONS
                )
            
            return result
        except Exception as e:
            logger.error(f"❌ Fallback also failed: {e}", exc_info=True)
            raise AIServiceError(f"All AI services failed: {str(e)}", "AI")
    
    # ==================== CONTENT GENERATION ====================
    
    async def generate_blog_post(
        self,
        topic: str,
        keywords: List[str],
        tone: str,
        word_count: int,
        sections: Optional[List[str]] = None,
        user_tier: Optional[str] = None,
        user_id: Optional[str] = None,
        target_audience: Optional[str] = None,
        writing_style: Optional[str] = None,
        include_examples: bool = True,
        enable_fact_check: bool = False
    ) -> Dict[str, Any]:
        """
        Generate SEO-optimized blog post using new Gemini SDK with Pydantic schemas
        Uses guaranteed JSON structure with native Pydantic validation
        
        Features:
        - ✅ New google.genai.Client() with response_json_schema
        - ✅ Pydantic BlogPostOutput model validation
        - ✅ Tone-specific generation configs with top_k
        - ✅ XML-structured prompts with keyword strategy
        - ✅ Few-shot examples for quality
        - ✅ Post-generation validation
        - ✅ Target audience and writing style support
        - ✅ Fact-checking context integration
        """
        
        # Import new SDK and schemas
        from google import genai as new_genai
        from app.schemas.ai_schemas import BlogPostOutput, get_blog_post_schema
        
        # Smart routing: Use premium model for Enterprise or long-form content
        use_premium = self._should_use_premium_model(
            user_tier=user_tier,
            content_complexity="complex" if word_count > 1500 else "standard"
        )
        
        # Select model based on tier and complexity
        model_name = "gemini-2.5-pro" if use_premium else "gemini-2.5-flash"
        
        # Get optimized generation config (without response_schema parameter for new SDK)
        generation_config, max_tokens = get_generation_config_for_word_count(
            word_count=word_count,
            tone=tone,
            response_schema=None  # Not needed for new SDK
        )
        
        # Build system prompt with few-shot examples
        system_prompt = build_blog_system_prompt_with_examples(
            word_count=word_count,
            tone=tone
        )
        
        # Build keyword context
        primary_keyword = keywords[0] if keywords else topic
        secondary_keywords = keywords[1:4] if len(keywords) > 1 else []
        
        keyword_context = f"""
<keyword_strategy>
PRIMARY KEYWORD: "{primary_keyword}"
- Use EXACTLY 3-5 times naturally in content
- Include in title, meta description, and first paragraph
- Use in at least 2 H2 headings

SECONDARY KEYWORDS: {', '.join(f'"{k}"' for k in secondary_keywords) if secondary_keywords else 'None'}
- Use each 1-2 times naturally
- Weave into content seamlessly
</keyword_strategy>
"""
        
        # Build additional context
        style_note = ""
        if writing_style:
            style_map = {
                "narrative": "storytelling with narrative arc",
                "listicle": "numbered list format",
                "how-to": "step-by-step guide",
                "case-study": "problem-solution-results",
                "comparison": "pros/cons analysis"
            }
            style_note = f"\nWriting Style: {style_map.get(writing_style, 'standard article')}"
        
        examples_note = "\nInclude Examples: 2-3 concrete real-world examples" if include_examples else ""
        audience_note = f"\nTarget Audience: {target_audience}" if target_audience else ""
        
        # Add factual requirement when fact-checking is enabled
        factual_note = ""
        if enable_fact_check:
            factual_note = """
**IMPORTANT - FACT-CHECKING ENABLED:**
This content will be fact-checked with AI. Please include:
- Specific statistics, numbers, and data points (with years/dates)
- Historical facts and dates
- Research findings and study results
- Verifiable claims that can be fact-checked
- Avoid pure opinions, predictions, or subjective statements
- Focus on concrete, verifiable information
"""
        
        # Build user prompt with explicit word count instruction
        user_prompt = f"""<context>
Topic: {topic}
Keywords: {', '.join(keywords)}
Tone: {tone}
Sections: {', '.join(sections) if sections else 'Introduction, Main Body (3-5 sections), Conclusion'}{style_note}{examples_note}{audience_note}
</context>

{factual_note}

{keyword_context}

<word_count_target>
TARGET: **EXACTLY {word_count} WORDS** (±50 words tolerance)

Word count verification steps:
1. Count every word in your content (excluding headings)
2. If below {word_count - 50}, ADD more detail, examples, and explanations
3. If above {word_count + 50}, CUT unnecessary filler and tighten writing
4. Set "wordCount" field to ACTUAL word count

CRITICAL: Content MUST be between {word_count - 50} and {word_count + 50} words.
</word_count_target>

<task>
Create a comprehensive, SEO-optimized blog post.
The output will automatically follow the required JSON structure.
</task>
"""

        try:
            # Log generation config for debugging
            logger.info(f"📝 Generating blog: {word_count} words, tone: {tone}, model: {model_name}")
            logger.info(f"🔧 Config: temp={generation_config['temperature']}, "
                       f"top_p={generation_config['top_p']}, "
                       f"top_k={generation_config.get('top_k', 'N/A')}, "
                       f"max_output_tokens={max_tokens}")
            
            # Initialize new Gemini client
            client = new_genai.Client(api_key=settings.GEMINI_API_KEY)
            
            # Start timing
            start_time = time.time()
            
            # Generate with new SDK using Pydantic schema
            response = await asyncio.to_thread(
                client.models.generate_content,
                model=model_name,
                contents=f"{system_prompt}\n\n{user_prompt}",
                config={
                    "temperature": generation_config["temperature"],
                    "top_p": generation_config["top_p"],
                    "top_k": generation_config.get("top_k"),
                    "max_output_tokens": max_tokens,
                    "response_mime_type": "application/json",
                    "response_schema": get_blog_post_schema()
                }
            )
            
            # Calculate generation time
            generation_time = time.time() - start_time
            
            # Extract JSON text with better error handling
            json_text = None
            finish_reason = None
            
            # Try to get text from response
            if hasattr(response, 'text') and response.text:
                json_text = response.text
            
            # If text is None, try to get from parts (happens with MAX_TOKENS)
            if not json_text and hasattr(response, 'candidates') and response.candidates:
                candidate = response.candidates[0]
                finish_reason = getattr(candidate, 'finish_reason', None)
                
                if hasattr(candidate, 'content') and hasattr(candidate.content, 'parts'):
                    parts = candidate.content.parts
                    if parts and len(parts) > 0:
                        # Concatenate all parts
                        json_text = ''.join([part.text for part in parts if hasattr(part, 'text')])
            
            if not json_text:
                logger.error(f"❌ No text in response. Response type: {type(response)}")
                logger.error(f"Finish reason: {finish_reason}")
                raise ValueError(f"Gemini returned empty response. Finish reason: {finish_reason}")
            
            # Log response details for debugging
            logger.info(f"📝 Response length: {len(json_text)} chars, finish_reason: {finish_reason}")
            
            # Validate with Pydantic model
            try:
                blog_output = BlogPostOutput.model_validate_json(json_text)
            except Exception as validation_error:
                # Log JSON parsing error with context
                logger.error(f"❌ JSON validation failed: {validation_error}")
                logger.error(f"🔍 Finish reason: {finish_reason}")
                logger.error(f"📏 JSON length: {len(json_text)} chars")
                logger.error(f"🔚 Last 200 chars: ...{json_text[-200:]}")
                
                # If MAX_TOKENS, provide helpful error message
                if finish_reason and "MAX_TOKENS" in str(finish_reason):
                    raise ValueError(
                        f"Blog generation incomplete due to MAX_TOKENS limit. "
                        f"Requested {max_tokens} tokens but response was truncated. "
                        f"Try reducing word count or simplifying requirements."
                    )
                
                # Re-raise original error with context
                raise ValueError(f"Invalid JSON response: {validation_error}") from validation_error
            
            # Convert to dict for return
            output = blog_output.model_dump()
            
            # Get token usage
            tokens_used = response.usage_metadata.total_token_count if hasattr(response, 'usage_metadata') else 0
            
            # Validate output quality
            validation = validate_blog_output(output, word_count)
            
            logger.info(f"✅ Blog generated: {validation['word_count_accuracy']}% word count accuracy, "
                       f"{tokens_used} tokens, {generation_time:.2f}s")
            logger.info(f"📊 Validation: quality_score={validation['quality_score']}, valid={validation['valid']}")
            
            return {
                'output': output,
                'tokensUsed': tokens_used,
                'model': model_name,
                'cached': False,
                'cached_prompt': False,
                'quality_score': validation['quality_score'],
                'regeneration_count': 0,
                'validation': validation,
                'generation_time': generation_time
            }
        except Exception as e:
            logger.error(f"❌ Error generating blog post: {e}")
            raise
    
    async def generate_social_media(
        self,
        content_description: str,
        platform: str,
        target_audience: str,
        tone: str,
        include_cta: bool = True,
        include_hashtags: bool = True,
        include_emoji: bool = True,
        user_tier: Optional[str] = None,
        user_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Generate platform-optimized social media captions using new Gemini SDK
        Uses Pydantic schemas for guaranteed JSON structure
        """
        
        # Import new SDK and schemas
        from google import genai as new_genai
        from app.schemas.ai_schemas import SocialMediaOutput, get_social_media_schema
        
        # Social media captions use standard model (quick, cost-effective)
        use_premium = self._should_use_premium_model(user_tier=user_tier, content_complexity="standard")
        
        # Select model
        model_name = "gemini-2.5-pro" if use_premium else "gemini-2.5-flash"
        
        # Platform-specific specifications and best practices
        platform_specs = {
            'linkedin': {
                'max_chars': 1300,
                'style': 'professional, thought leadership',
                'guidance': 'Start with a hook, use line breaks for readability, include industry insights, ask thought-provoking questions',
                'emoji_note': 'Use professional emojis sparingly (💡🚀📊✨🎯)' if include_emoji else 'No emojis',
                'hashtag_note': 'Include 3-5 targeted professional hashtags' if include_hashtags else 'No hashtags'
            },
            'twitter': {
                'max_chars': 280,
                'style': 'snappy, conversational, punchy',
                'guidance': 'Hook in first 5 words, create curiosity, conversational tone, trending topics',
                'emoji_note': 'Use 1-2 relevant emojis to emphasize points' if include_emoji else 'No emojis',
                'hashtag_note': 'Include 1-2 highly relevant hashtags' if include_hashtags else 'No hashtags'
            },
            'instagram': {
                'max_chars': 2200,
                'style': 'engaging, storytelling, visually descriptive',
                'guidance': 'Strong opening hook, tell a story, create emotional connection, use line breaks, end with question',
                'emoji_note': 'Use expressive and trendy emojis throughout (5-10)' if include_emoji else 'No emojis',
                'hashtag_note': 'Include 8-15 mix of popular and niche hashtags' if include_hashtags else 'No hashtags'
            },
            'facebook': {
                'max_chars': 5000,
                'style': 'friendly, conversational, community-focused',
                'guidance': 'Engaging opening, tell stories, encourage interaction, use questions to drive comments',
                'emoji_note': 'Use friendly and relatable emojis (3-7)' if include_emoji else 'No emojis',
                'hashtag_note': 'Include 3-5 relevant hashtags' if include_hashtags else 'No hashtags'
            },
            'tiktok': {
                'max_chars': 300,
                'style': 'casual, trendy, youth-focused, energetic',
                'guidance': 'Immediate hook, casual language, trending phrases, create FOMO, speak directly to viewer',
                'emoji_note': 'Use fun and expressive emojis (3-5)' if include_emoji else 'No emojis',
                'hashtag_note': 'Include 3-5 trending and niche hashtags' if include_hashtags else 'No hashtags'
            }
        }
        
        spec = platform_specs.get(platform.lower(), platform_specs['linkedin'])
        
        # Build clean, focused prompt - let schema handle structure
        prompt = f"""Create 3 unique {platform} captions about: {content_description}

AUDIENCE: {target_audience}
TONE: {tone}
STYLE: {spec['style']}

PLATFORM GUIDANCE:
{spec['guidance']}

REQUIREMENTS:
- Max {spec['max_chars']} characters per caption
- Each caption should have a different angle or hook
- {spec['emoji_note']}
- {spec['hashtag_note']}
- {'Include compelling call-to-action' if include_cta else 'No call-to-action needed'}

CAPTION VARIETY (use these 3 different approaches):
1. Question/Hook: Start with engaging question to spark curiosity
2. Storytelling/Relatable: Use narrative approach or connect emotionally
3. Value/Actionable: Provide tips, insights, or data-driven content"""

        try:
            # Initialize new Gemini client
            client = new_genai.Client(api_key=settings.GEMINI_API_KEY)
            
            # Select model
            model_name = settings.PREMIUM_TEXT_MODEL if use_premium else settings.PRIMARY_TEXT_MODEL
            
            # Generate with Pydantic schema
            response = client.models.generate_content(
                model=model_name,
                contents=prompt,
                config={
                    "response_mime_type": "application/json",
                    "response_json_schema": get_social_media_schema(),
                }
            )
            
            # Extract JSON text with better error handling
            json_text = None
            if hasattr(response, 'text') and response.text:
                json_text = response.text
            elif hasattr(response, 'candidates') and response.candidates:
                candidate = response.candidates[0]
                if hasattr(candidate, 'content') and hasattr(candidate.content, 'parts'):
                    parts = candidate.content.parts
                    if parts and len(parts) > 0:
                        json_text = ''.join([part.text for part in parts if hasattr(part, 'text')])
            
            if not json_text:
                logger.error(f"❌ No text in response for social media generation")
                raise ValueError("Gemini returned empty response. The model may have hit a safety filter or content policy.")
            
            # Parse and validate using Pydantic
            result = SocialMediaOutput.model_validate_json(json_text)
            
            # Convert to dict for response
            output = result.model_dump()
            
            # Count tokens (new SDK structure)
            tokens_used = 0
            if hasattr(response, 'usage_metadata'):
                tokens_used = response.usage_metadata.total_token_count
            
            logger.info(f"✅ Generated {platform} content: {len(output['captions'])} captions, {len(output['hashtags'])} hashtags")
            
            return {
                'output': output,
                'tokensUsed': tokens_used,
                'model': model_name,
                'cached': False,
                'cached_prompt': False,
                'quality_score': None,
                'regeneration_count': 0
            }
            
        except Exception as e:
            logger.error(f"Error generating social media content with new SDK: {e}")
            # Log details for debugging
            if 'response' in locals():
                logger.error(f"Response text: {response.text[:500]}")
            raise
    
    async def generate_email_campaign(
        self,
        campaign_type: str,
        product_service: str,
        target_audience: str,
        goal: str,
        tone: str,
        user_tier: Optional[str] = None,
        user_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Generate email campaign content using new Gemini SDK with Pydantic schemas
        Uses guaranteed JSON structure with native Pydantic validation
        """
        
        # Import new SDK and schemas
        from google import genai as new_genai
        from app.schemas.ai_schemas import EmailCampaignOutput, get_email_campaign_schema
        
        # Import ModelConfig
        from app.config import ModelConfig
        
        # Email campaigns use standard model (quick, cost-effective)
        use_premium = self._should_use_premium_model(user_tier=user_tier, content_complexity="standard")
        
        # Select model using centralized config
        model_name = ModelConfig.GEMINI_PRO if use_premium else ModelConfig.EMAIL_MODEL
        
        # Campaign type specifications
        campaign_specs = {
            'promotional': 'Focus on limited-time offers, discounts, urgency. Use action-oriented language.',
            'newsletter': 'Focus on valuable content, updates, engagement. Use informative tone.',
            'welcome': 'Focus on onboarding, building relationship, setting expectations. Use friendly tone.',
            'abandoned_cart': 'Focus on reminder, incentive, easy checkout. Use gentle persuasion.',
            'product_launch': 'Focus on excitement, features, early access. Use enthusiastic tone.',
            're_engagement': 'Focus on winning back, special offer, reminder of value. Use compelling tone.'
        }
        
        campaign_guidance = campaign_specs.get(campaign_type.lower(), 'Standard marketing email with clear value proposition.')
        
        # System prompt
        system_prompt = f"""<role>
You are an expert email marketing copywriter with 10+ years of experience.
You specialize in creating high-converting email campaigns with compelling subject lines and CTAs.
</role>

<email_best_practices>
- Subject line: 40-60 characters, create curiosity or urgency
- Preheader: 40-100 characters, complement subject line
- Body: Clear value proposition, scannable, benefit-focused
- CTA: Action-oriented, clear next step
- Tone: {tone}
- Campaign type: {campaign_type}
</email_best_practices>

<campaign_guidance>
{campaign_guidance}
</campaign_guidance>"""

        # User prompt
        user_prompt = f"""<campaign_details>
Campaign Type: {campaign_type}
Product/Service: {product_service}
Target Audience: {target_audience}
Campaign Goal: {goal}
Tone: {tone}
</campaign_details>

<task>
Create a compelling email campaign that:
1. Grabs attention with the subject line
2. Provides clear value in the body
3. Has a strong, actionable CTA
4. Matches the tone and campaign type

The output will automatically follow the required JSON structure.
</task>"""

        try:
            logger.info(f"📧 Generating email: {campaign_type}, tone: {tone}, model: {model_name}")
            
            # Initialize new Gemini client
            client = new_genai.Client(api_key=settings.GEMINI_API_KEY)
            
            # Start timing
            start_time = time.time()
            
            # Generate with new SDK using Pydantic schema
            response = await asyncio.to_thread(
                client.models.generate_content,
                model=model_name,
                contents=f"{system_prompt}\n\n{user_prompt}",
                config={
                    "temperature": 0.80,
                    "top_p": 0.92,
                    "top_k": 45,
                    "max_output_tokens": 2000,
                    "response_mime_type": "application/json",
                    "response_schema": get_email_campaign_schema()
                }
            )
            
            # Calculate generation time
            generation_time = time.time() - start_time
            
            # Extract JSON text with better error handling
            json_text = None
            if hasattr(response, 'text') and response.text:
                json_text = response.text
            elif hasattr(response, 'candidates') and response.candidates:
                candidate = response.candidates[0]
                if hasattr(candidate, 'content') and hasattr(candidate.content, 'parts'):
                    parts = candidate.content.parts
                    if parts and len(parts) > 0:
                        json_text = ''.join([part.text for part in parts if hasattr(part, 'text')])
            
            if not json_text:
                logger.error(f"❌ No text in response for email generation")
                raise ValueError("Gemini returned empty response. The model may have hit a safety filter or content policy.")
            
            # Validate with Pydantic model
            email_output = EmailCampaignOutput.model_validate_json(json_text)
            
            # Convert to dict for return
            output = email_output.model_dump()
            
            # Get token usage
            tokens_used = response.usage_metadata.total_token_count if hasattr(response, 'usage_metadata') else 0
            
            logger.info(f"✅ Email generated: {tokens_used} tokens, {generation_time:.2f}s")
            
            return {
                'output': output,
                'tokensUsed': tokens_used,
                'model': model_name,
                'cached': False,
                'cached_prompt': False,
                'quality_score': 90,  # High quality with Pydantic validation
                'regeneration_count': 0,
                'generation_time': generation_time
            }
        except Exception as e:
            logger.error(f"❌ Error generating email campaign: {e}")
            raise
    
    async def generate_product_description(
        self,
        product_details: Dict[str, Any],
        target_customer: str,
        platform: str,
        include_seo: bool = True,
        user_tier: Optional[str] = None,
        user_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """Generate e-commerce product descriptions with smart model routing and caching"""
        
        # Product descriptions use standard model
        use_premium = self._should_use_premium_model(user_tier=user_tier, content_complexity="standard")
        
        prompt = f"""Create product descriptions for: {product_details.get('name', 'Product')}

Details: {json.dumps(product_details)}
Target Customer: {target_customer}
Platform: {platform}
Include SEO: {include_seo}

Format as JSON:
{{
    "shortDescription": "100 word description",
    "longDescription": "300 word detailed description",
    "bulletPoints": ["benefit 1", "benefit 2", ...] (5-7 key benefits),
    "seoTitle": "60 character title",
    "metaDescription": "160 character meta description",
    "categoryTags": ["tag1", "tag2", ...]
}}"""

        try:
            result = await self._generate_with_quality_check(
                system_prompt="You are an e-commerce copywriting expert. Always return valid JSON.",
                user_prompt=prompt,
                max_tokens=1500,
                use_premium=use_premium,
                content_type="product",
                user_id=user_id,
                metadata={'target_length': 400},
                max_regenerations=1
            )
            
            output = json.loads(result['content'])
            return {
                'output': output,
                'tokensUsed': result['tokensUsed'],
                'model': result['model'],
                'cached': result.get('cached', False),
                'cached_prompt': result.get('cached_prompt', False),
                'quality_score': result.get('quality_score'),
                'regeneration_count': result.get('regeneration_count', 0)
            }
        except Exception as e:
            logger.error(f"Error generating product description: {e}")
            raise
    
    async def generate_ad_copy(
        self,
        product_service: str,
        target_audience: str,
        platform: str,
        campaign_goal: str,
        user_tier: Optional[str] = None,
        user_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """Generate conversion-optimized ad copy with smart model routing and caching"""
        
        # Ad copy uses standard model (quick conversions)
        use_premium = self._should_use_premium_model(user_tier=user_tier, content_complexity="standard")
        
        prompt = f"""Create 3 high-converting ad copy variations:

Product/Service: {product_service}
Target Audience: {target_audience}
Platform: {platform}
Campaign Goal: {campaign_goal}

Format as JSON:
{{
    "adCopies": [
        {{
            "variation": 1,
            "uniqueAngle": "what makes this unique",
            "headlines": ["headline 1", "headline 2", "headline 3"],
            "body": "100-150 word ad copy",
            "ctas": ["CTA 1", "CTA 2", "CTA 3"],
            "emotionalTriggers": ["trigger 1", "trigger 2"]
        }},
        ...
    ],
    "estimatedCTR": "estimated click-through rate with reasoning"
}}"""

        try:
            result = await self._generate_with_quality_check(
                system_prompt="You are a conversion copywriting expert. Always return valid JSON.",
                user_prompt=prompt,
                max_tokens=2000,
                use_premium=use_premium,
                content_type="ad",
                user_id=user_id,
                metadata={'target_length': 150},
                max_regenerations=1
            )
            
            output = json.loads(result['content'])
            return {
                'output': output,
                'tokensUsed': result['tokensUsed'],
                'model': result['model'],
                'cached': result.get('cached', False),
                'cached_prompt': result.get('cached_prompt', False),
                'quality_score': result.get('quality_score'),
                'regeneration_count': result.get('regeneration_count', 0)
            }
        except Exception as e:
            logger.error(f"Error generating ad copy: {e}")
            raise
    
    async def generate_video_script(
        self,
        topic: str,
        duration_seconds: int,
        platform: str,
        target_audience: str,
        key_points: Optional[List[str]] = None,
        cta: str = "",
        user_tier: Optional[str] = None,
        user_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Generate platform-optimized video script using new Gemini SDK with Pydantic schemas
        Uses guaranteed JSON structure with native Pydantic validation
        """
        
        # Import new SDK and schemas
        from google import genai as new_genai
        from app.schemas.ai_schemas import VideoScriptOutput, get_video_script_schema
        
        # Video scripts use complex model for long-form content
        use_premium = self._should_use_premium_model(
            user_tier=user_tier,
            content_complexity="complex" if duration_seconds > 120 else "standard"
        )
        
        # Select model
        model_name = "gemini-2.5-pro" if use_premium else "gemini-2.5-flash"
        
        # Platform-specific guidance
        platform_specs = {
            'youtube': {
                'hook_emphasis': 'First 8 seconds are critical for retention',
                'pacing': 'Moderate pace with clear sections',
                'style': 'Engaging storytelling with value delivery'
            },
            'tiktok': {
                'hook_emphasis': 'First 3 seconds must grab attention',
                'pacing': 'Fast-paced, high energy',
                'style': 'Trendy, authentic, entertaining'
            },
            'instagram': {
                'hook_emphasis': 'Visual hook in first 5 seconds',
                'pacing': 'Quick, visually-driven',
                'style': 'Aesthetic, relatable, inspirational'
            },
            'facebook': {
                'hook_emphasis': 'First 5 seconds with text overlay',
                'pacing': 'Clear and conversational',
                'style': 'Informative, community-focused'
            }
        }
        
        spec = platform_specs.get(platform.lower(), platform_specs['youtube'])
        
        # System prompt
        system_prompt = f"""<role>
You are an expert video script writer specializing in {platform} content.
You create engaging, retention-optimized scripts that drive viewer engagement.
</role>

<platform_guidelines>
Platform: {platform}
Hook Emphasis: {spec['hook_emphasis']}
Pacing: {spec['pacing']}
Style: {spec['style']}
</platform_guidelines>

<script_structure>
1. Hook (first 3-8 seconds): Grab attention immediately
2. Introduction: Set context and promise value
3. Main Points: Deliver content in digestible sections
4. Transitions: Keep viewers engaged between sections
5. Call to Action: Clear next step for viewers
6. Outro: Thank viewers, reinforce CTA
</script_structure>

<best_practices>
- Use pattern interrupts to maintain attention
- Include visual cues for editing
- Suggest B-roll and graphics opportunities
- Optimize for watch time retention
- Match {platform} algorithm preferences
</best_practices>

<additional_elements>
Hashtags: Provide 10-20 relevant, trending hashtags optimized for {platform} algorithm discovery
Music Recommendations: Suggest 3-5 background music options with genre and mood that fit the video style
Retention Hooks: Create 3-5 strategic pattern interrupts or curiosity gaps to maintain viewer attention throughout
</additional_elements>"""

        # User prompt
        key_points_text = ', '.join(key_points) if key_points else 'Determine the most compelling points'
        
        user_prompt = f"""<video_details>
Topic: {topic}
Duration: {duration_seconds} seconds (~{duration_seconds // 60}:{duration_seconds % 60:02d})
Platform: {platform}
Target Audience: {target_audience}
Key Points: {key_points_text}
Call to Action: {cta if cta else 'Subscribe/Follow for more content'}
</video_details>

<task>
Create an engaging video script that:
1. Hooks viewers in the first few seconds
2. Delivers clear value throughout
3. Maintains pacing appropriate for the duration
4. Includes visual cues for editing
5. Ends with a strong call to action

The output will automatically follow the required JSON structure with sections, timestamps, and visual notes.
</task>"""

        try:
            logger.info(f"🎥 Generating video script: {duration_seconds}s, platform: {platform}, model: {model_name}")
            
            # Initialize new Gemini client
            client = new_genai.Client(api_key=settings.GEMINI_API_KEY)
            
            # Start timing
            start_time = time.time()
            
            # Calculate max tokens based on duration
            # Complex schema with sections, timestamps, visual notes, hashtags, music, retention hooks
            # Base: ~50 words/second script = 67 tokens/second
            # Add JSON overhead: schema structure, arrays, metadata = 3000-5000 tokens
            # Formula: (duration * 80) + 5000 for comprehensive output
            # 30s video: 2400 + 5000 = 7400 tokens
            # 90s video: 7200 + 5000 = 12200 tokens
            # 180s video: 14400 + 5000 = 19400 tokens
            # 300s video: 24000 + 5000 = 29000 tokens (capped at 65536)
            base_tokens = duration_seconds * 80
            json_overhead = 5000
            max_tokens = min(65536, base_tokens + json_overhead)  # Gemini 2.5 Flash limit: 65,536
            
            logger.info(f"📊 Token allocation: {max_tokens} tokens ({base_tokens} script + {json_overhead} overhead)")
            
            # Generate with new SDK using Pydantic schema
            response = await asyncio.to_thread(
                client.models.generate_content,
                model=model_name,
                contents=f"{system_prompt}\n\n{user_prompt}",
                config={
                    "temperature": 0.85,
                    "top_p": 0.93,
                    "top_k": 48,
                    "max_output_tokens": max_tokens,
                    "response_mime_type": "application/json",
                    "response_schema": get_video_script_schema()
                }
            )
            
            # Calculate generation time
            generation_time = time.time() - start_time
            
            # Extract JSON text
            json_text = response.text if hasattr(response, 'text') and response.text else None
            
            if not json_text:
                # Check if response has candidates
                if hasattr(response, 'candidates') and response.candidates:
                    candidate = response.candidates[0]
                    if hasattr(candidate, 'content') and candidate.content:
                        if hasattr(candidate.content, 'parts') and candidate.content.parts:
                            json_text = candidate.content.parts[0].text
                
                if not json_text:
                    logger.error(f"❌ No text in response. Response: {response}")
                    raise ValueError("No text content in API response")
            
            # Validate with Pydantic model
            try:
                video_output = VideoScriptOutput.model_validate_json(json_text)
            except Exception as validation_error:
                logger.error(f"❌ JSON validation failed. Response length: {len(json_text)} chars")
                logger.error(f"First 500 chars: {json_text[:500]}")
                logger.error(f"Last 500 chars: {json_text[-500:]}")
                logger.error(f"Validation error: {validation_error}")
                raise
            
            # Convert to dict for return
            output = video_output.model_dump()
            
            # Get token usage
            tokens_used = response.usage_metadata.total_token_count if hasattr(response, 'usage_metadata') else 0
            
            logger.info(f"✅ Video script generated: {len(output.get('sections', []))} sections, "
                       f"{tokens_used} tokens, {generation_time:.2f}s")
            
            return {
                'output': output,
                'tokensUsed': tokens_used,
                'model': model_name,
                'cached': False,
                'cached_prompt': False,
                'quality_score': 90,
                'regeneration_count': 0,
                'generation_time': generation_time
            }
        except Exception as e:
            logger.error(f"❌ Error generating video script: {e}")
            raise
    
    # ==================== QUALITY ANALYSIS ====================
    
    async def analyze_content_quality(self, content: str) -> Dict[str, Any]:
        """Analyze content quality metrics using primary AI model"""
        
        prompt = f"""Analyze this content for quality metrics:

{content}

Rate 0-100 for each metric and provide reasoning:

Format as JSON:
{{
    "readability_score": score,
    "grammar_score": score,
    "originality_score": score,
    "engagement_score": score,
    "overall_score": average_score,
    "improvements": ["suggestion 1", "suggestion 2", ...]
}}"""

        try:
            result = await self._generate_with_ai(
                system_prompt="You are a content quality analyst. Always return valid JSON.",
                user_prompt=prompt,
                max_tokens=500
            )
            
            output = json.loads(result['content'])
            return output
        except Exception as e:
            logger.error(f"Error analyzing content quality: {e}")
            raise

# Singleton instance
openai_service = OpenAIService()
