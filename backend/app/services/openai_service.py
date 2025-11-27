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
    
    # Base calculation: convert words to tokens with safety margin
    # 1 word ≈ 1.33 tokens, add 50% safety margin = 2.0x multiplier
    base_tokens = int(target_word_count * 2.0)
    
    # Add system prompt overhead (concise examples + instructions ~800 tokens)
    tokens_with_overhead = base_tokens + 800
    
    # Map to word count ranges (Gemini 2.5 Flash: 65,536 output token limit per official docs)
    # Source: https://ai.google.dev/gemini-api/docs/models/gemini#gemini-2.5-flash
    #
    # Formula: (words * 3) + 2500
    # - Words * 3: Conservative estimate (1 word ≈ 1.3 tokens, 2.3x safety margin)
    # - +2500: response_schema overhead (2000) + JSON structure (500)
    if target_word_count <= 500:
        return 4096  # 500: (500*3)+2500=4000 → 4096
    elif target_word_count <= 1000:
        return 6144  # 1000: (1000*3)+2500=5500 → 6144
    elif target_word_count <= 1500:
        return 8192  # 1500: (1500*3)+2500=7000 → 8192
    elif target_word_count <= 2000:
        return 10240  # 2000: (2000*3)+2500=8500 → 10240
    elif target_word_count <= 2500:
        return 12288  # 2500: (2500*3)+2500=10000 → 12288
    elif target_word_count <= 3000:
        return 14336  # 3000: (3000*3)+2500=11500 → 14336
    elif target_word_count <= 3500:
        return 16384  # 3500: (3500*3)+2500=13000 → 16384
    else:  # 3500-4000 words
        return 18432  # 4000: (4000*3)+2500=14500 → 18432

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
    Generate JSON schema for blog post output with validation
    
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
    Validate and score blog output quality (Phase 2)
    
    Checks:
    - Word count accuracy
    - Meta description length
    - Title length
    - Minimum headings
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
    
    # Check minimum headings (low priority)
    headings = output.get('headings', [])
    if len(headings) < 3:
        issues.append({
            'field': 'headings',
            'expected': '≥3 headings',
            'actual': len(headings),
            'severity': 'low'
        })
    
    # Check content exists
    content = output.get('content', '')
    if not content or len(content) < 100:
        issues.append({
            'field': 'content',
            'expected': 'substantial content',
            'actual': f"{len(content)} chars",
            'severity': 'high'
        })
    
    # Calculate quality score (0-100)
    high_issues = sum(1 for i in issues if i['severity'] == 'high')
    medium_issues = sum(1 for i in issues if i['severity'] == 'medium')
    low_issues = sum(1 for i in issues if i['severity'] == 'low')
    
    quality_score = 100 - (high_issues * 30) - (medium_issues * 15) - (low_issues * 5)
    quality_score = max(0, quality_score)
    
    return {
        'valid': high_issues == 0,
        'issues': issues,
        'quality_score': quality_score,
        'word_count_accuracy': abs(actual_words - target_word_count) / target_word_count * 100 if target_word_count > 0 else 0
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
        include_examples: bool = True
    ) -> Dict[str, Any]:
        """
        Generate comprehensive blog post with Phase 1 + Phase 2 improvements:
        
        Phase 1 (Complete):
        - ✅ Gemini 2.5 Flash (65K tokens for 3000+ words)
        - ✅ response_schema (guaranteed JSON structure)
        - ✅ Few-shot examples in system prompt
        - ✅ Dynamic token calculation (500-4000 words)
        - ✅ Tone-specific parameter tuning
        
        Phase 2 (NEW):
        - ✅ XML-structured system instructions
        - ✅ Enhanced tone configs with top_k
        - ✅ Keyword context builder
        - ✅ Post-generation validation
        - ✅ Target audience support
        - ✅ Writing style variations
        """
        
        # Smart routing: Use premium model for Enterprise or long-form content
        use_premium = self._should_use_premium_model(
            user_tier=user_tier,
            content_complexity="complex" if word_count > 1500 else "standard"
        )
        
        # Get optimized generation config with new parameters
        response_schema = get_blog_response_schema(word_count)
        generation_config, max_tokens = get_generation_config_for_word_count(
            word_count=word_count,
            tone=tone,
            response_schema=response_schema
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
        
        # Phase 2: Build additional context
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
        
        # Build user prompt with explicit word count instruction
        user_prompt = f"""<context>
Topic: {topic}
Keywords: {', '.join(keywords)}
Tone: {tone}
Sections: {', '.join(sections) if sections else 'Introduction, Main Body (3-5 sections), Conclusion'}{style_note}{examples_note}{audience_note}
</context>

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
Create a comprehensive, SEO-optimized blog post following the examples above.
Return ONLY valid JSON matching the schema.
</task>
"""

        try:
            # Log generation config for debugging
            logger.info(f"📝 Generating blog: {word_count} words, tone: {tone}")
            logger.info(f"🔧 Config: temp={generation_config['temperature']}, "
                       f"top_p={generation_config['top_p']}, "
                       f"top_k={generation_config.get('top_k', 'N/A')}, "
                       f"max_output_tokens={generation_config.get('max_output_tokens', max_tokens)}")
            
            result = await self._generate_with_quality_check_v2(
                system_prompt=system_prompt,
                user_prompt=user_prompt,
                generation_config=generation_config,
                use_premium=use_premium,
                content_type="blog",
                user_id=user_id,
                metadata={
                    'keywords': keywords,
                    'target_length': word_count,
                    'tone': tone
                },
                max_regenerations=1
            )
            
            output = json.loads(result['content'])
            
            # Phase 2: Validate output quality
            validation = validate_blog_output(output, word_count)
            
            logger.info(f"Blog validation: quality_score={validation['quality_score']}, "
                       f"word_count_accuracy={validation['word_count_accuracy']}%, "
                       f"valid={validation['valid']}")
            
            return {
                'output': output,
                'tokensUsed': result['tokensUsed'],
                'model': result['model'],
                'cached': result.get('cached', False),
                'cached_prompt': result.get('cached_prompt', False),
                'quality_score': result.get('quality_score'),
                'regeneration_count': result.get('regeneration_count', 0),
                'validation': validation,  # Phase 2: Include validation results
                'generation_time': result.get('generation_time', 0.0)  # ⏱️ CRITICAL: Time tracking
            }
        except Exception as e:
            logger.error(f"Error generating blog post: {e}")
            raise
    
    async def generate_social_media(
        self,
        content_description: str,
        platform: str,
        target_audience: str,
        tone: str,
        include_cta: bool = True,
        include_hashtags: bool = True,
        user_tier: Optional[str] = None,
        user_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """Generate platform-optimized social media captions with smart model routing and caching"""
        
        # Social media captions use standard model (quick, cost-effective)
        use_premium = self._should_use_premium_model(user_tier=user_tier, content_complexity="standard")
        
        platform_specs = {
            'linkedin': {'max_chars': 1300, 'style': 'professional, thought leadership'},
            'twitter': {'max_chars': 280, 'style': 'snappy, conversational'},
            'instagram': {'max_chars': 2200, 'style': 'engaging, storytelling'},
            'tiktok': {'max_chars': 300, 'style': 'casual, trendy, youth-focused'}
        }
        
        spec = platform_specs.get(platform.lower(), platform_specs['linkedin'])
        
        prompt = f"""Create 5 engaging {platform} captions for: {content_description}

Requirements:
- Platform: {platform} (max {spec['max_chars']} characters)
- Style: {spec['style']}
- Tone: {tone}
- Target audience: {target_audience}
- Include CTA: {include_cta}
- Include hashtags: {include_hashtags}

Format as JSON:
{{
    "captions": [
        {{"variation": 1, "text": "caption text", "length": char_count}},
        {{"variation": 2, "text": "caption text", "length": char_count}},
        ...
    ],
    "hashtags": ["#hashtag1", "#hashtag2", ...] (15-20 relevant hashtags),
    "emojiSuggestions": ["emoji1", "emoji2", ...],
    "engagementTips": "brief tips for maximizing engagement"
}}"""

        try:
            result = await self._generate_with_quality_check(
                system_prompt=f"You are a social media expert specializing in {platform} content. Always return valid JSON.",
                user_prompt=prompt,
                max_tokens=2000,
                use_premium=use_premium,
                content_type="social",
                user_id=user_id,
                metadata={'target_length': spec['max_chars']},
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
            logger.error(f"Error generating social media content: {e}")
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
        """Generate email campaign content with smart model routing and caching"""
        
        # Email campaigns use standard model
        use_premium = self._should_use_premium_model(user_tier=user_tier, content_complexity="standard")
        
        prompt = f"""Create a compelling email campaign:

Type: {campaign_type}
Product/Service: {product_service}
Target Audience: {target_audience}
Goal: {goal}
Tone: {tone}

Format as JSON:
{{
    "subjectLines": ["subject 1", "subject 2", "subject 3"],
    "previewText": "preview text for inbox",
    "body": {{
        "intro": "opening paragraph",
        "benefits": ["benefit 1", "benefit 2", "benefit 3"],
        "mainContent": "main body content",
        "cta": "call to action text",
        "closing": "closing paragraph"
    }},
    "ctaButtonText": ["CTA option 1", "CTA option 2", "CTA option 3"],
    "bestSendTime": "recommended send time with reason"
}}"""

        try:
            result = await self._generate_with_quality_check(
                system_prompt="You are an email marketing expert. Always return valid JSON.",
                user_prompt=prompt,
                max_tokens=2000,
                use_premium=use_premium,
                content_type="email",
                user_id=user_id,
                metadata={'target_length': 500},
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
            logger.error(f"Error generating email campaign: {e}")
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
        """Generate platform-optimized video script with smart model routing and caching"""
        
        # Video scripts use complex model for long-form content
        use_premium = self._should_use_premium_model(
            user_tier=user_tier,
            content_complexity="complex" if duration_seconds > 120 else "standard"
        )
        
        prompt = f"""Create a video script:

Topic: {topic}
Duration: {duration_seconds} seconds
Platform: {platform}
Target Audience: {target_audience}
Key Points: {', '.join(key_points) if key_points else 'Determine best points'}
CTA: {cta}

Format as JSON:
{{
    "hook": "first 5 seconds (retention optimized)",
    "script": [
        {{"timestamp": "0:00-0:05", "content": "hook content", "visualCue": "what to show"}},
        {{"timestamp": "0:05-0:15", "content": "main point 1", "visualCue": "b-roll suggestion"}},
        ...
    ],
    "ctaScript": "call to action script",
    "thumbnailTitles": ["title option 1", "title option 2", "title option 3"],
    "description": "platform-optimized description",
    "hashtags": ["#hashtag1", "#hashtag2", ...],
    "musicMood": "suggested music mood",
    "estimatedRetention": "estimated watch time retention with reasoning"
}}"""

        try:
            result = await self._generate_with_quality_check(
                system_prompt=f"You are a video script expert specializing in {platform}. Always return valid JSON.",
                user_prompt=prompt,
                max_tokens=3000,
                use_premium=use_premium,
                content_type="video",
                user_id=user_id,
                metadata={'target_length': duration_seconds * 2},  # ~2 words per second
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
            logger.error(f"Error generating video script: {e}")
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
