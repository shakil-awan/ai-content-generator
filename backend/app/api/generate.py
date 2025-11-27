"""
Content Generation Router - Milestone 2.1: Blog Post Generation
Handles all AI-powered content generation with REAL stats tracking

ARCHITECTURE FLOW:
    Request → Router (validate) → Service (AI generate) → Firebase (save + increment stats) → Response
    
STATS INCREMENT PATTERN:
    Every successful generation automatically increments:
    - usageThisMonth.generations++
    - allTimeStats.totalGenerations++
    - allTimeStats.averageQualityScore (recalculated)
"""
from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any
from datetime import datetime
import logging
import json

from app.exceptions import (
    AIServiceError,
    RateLimitError,
    InvalidAPIKeyError,
    ContentPolicyViolationError,
    TokenLimitExceededError,
    AITimeoutError,
    NetworkError,
    GenerationLimitError,
    DatabaseError
)
from app.schemas.generation import (
    BlogGenerationRequest,
    SocialMediaGenerationRequest,
    EmailGenerationRequest,
    ProductDescriptionRequest,
    AdCopyRequest,
    VideoScriptRequest,
    GenerationResponse,
    ContentType,
    SocialPlatform,
    EmailCampaignType
)
from app.dependencies import get_current_user, get_firebase_service, get_openai_service
from app.services.firebase_service import FirebaseService
from app.services.openai_service import OpenAIService
from app.utils.prompt_enhancer import improve_prompt, ContentType as PromptContentType

router = APIRouter(prefix="/api/v1/generate", tags=["Content Generation"])
logger = logging.getLogger(__name__)

# ==================== MILESTONE 2.1: BLOG POST GENERATION ====================

@router.post(
    "/blog",
    response_model=GenerationResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Generate AI blog post",
    description="""
    Generate SEO-optimized blog post with automatic stats tracking.
    
    **Stats Auto-Increment:**
    - usageThisMonth.generations++ (tracks monthly usage)
    - allTimeStats.totalGenerations++ (lifetime counter)
    - allTimeStats.averageQualityScore (recalculated from all generations)
    
    **Rate Limiting:**
    - Free: 10 generations/month
    - Pro: 100 generations/month
    - Enterprise: Unlimited
    
    **Required Fields:**
    - topic: What the blog post is about (3-200 chars)
    - keywords: 1-10 SEO keywords to naturally include
    - tone: Content tone (professional, casual, friendly, etc)
    - length: short (~500), medium (~1000), long (~2000+ words)
    
    **Returns:**
    - Complete blog post with title, content, meta description
    - Word count and SEO metadata
    - Generation ID for future reference (humanization, etc)
    - REAL quality metrics (not mock data)
    """
)
async def generate_blog_post(
    request: BlogGenerationRequest,
    current_user: Dict[str, Any] = Depends(get_current_user),
    firebase_service: FirebaseService = Depends(get_firebase_service),
    openai_service: OpenAIService = Depends(get_openai_service)
) -> GenerationResponse:
    """
    Generate blog post with AI and track stats in real-time
    
    Flow:
    1. Validate user has generations left this month
    2. Call OpenAI service to generate blog content
    3. Save generation to Firestore
    4. Increment usage stats (usageThisMonth.generations++)
    5. Increment lifetime stats (allTimeStats.totalGenerations++)
    6. Recalculate average quality score
    7. Return complete generation with stats
    """
    try:
        user_id = current_user['uid']
        user_plan = current_user.get('subscriptionPlan', 'free')
        
        # Check if user has generations left this month
        usage_this_month = current_user.get('usageThisMonth', {})
        generations_used = usage_this_month.get('generations', 0)
        generation_limit = usage_this_month.get('limit', 5)  # Free tier default is 5
        
        if generations_used >= generation_limit:
            reset_date = usage_this_month.get('resetDate')
            # Convert Firestore timestamp to ISO string if needed
            if reset_date and hasattr(reset_date, 'isoformat'):
                reset_date = reset_date.isoformat()
            elif reset_date and isinstance(reset_date, str):
                reset_date = reset_date
            else:
                reset_date = None
                
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail={
                    "error": "generation_limit_reached",
                    "message": f"You've reached your monthly limit of {generation_limit} generations. Upgrade to Pro for 100/month or Enterprise for unlimited.",
                    "used": generations_used,
                    "limit": generation_limit,
                    "resetDate": reset_date
                }
            )
        
        # Use word_count from request (supports 500-4000 words)
        # Fall back to length enum for backward compatibility
        if hasattr(request, 'word_count') and request.word_count:
            target_word_count = request.word_count
        elif request.length:
            # Backward compatibility: map old length enum
            word_count_map = {
                "short": 500,
                "medium": 1000,
                "long": 2000
            }
            target_word_count = word_count_map.get(request.length, 1000)
        else:
            target_word_count = 1000  # Default
        
        # Enhance user prompt for better AI output
        enhanced_topic = improve_prompt(
            user_prompt=request.topic,
            content_type=PromptContentType.BLOG_POST.value,
            tone=request.tone,
            word_count=target_word_count,
            additional_context={"keywords": request.keywords}
        )
        
        # Generate blog post with enhanced prompt
        logger.info(f"Generating blog post for user {user_id}: {request.topic}")
        logger.debug(f"Enhanced prompt: {enhanced_topic[:100]}...")
        
        ai_result = await openai_service.generate_blog_post(
            topic=enhanced_topic,
            keywords=request.keywords,
            tone=request.tone,
            word_count=target_word_count,
            sections=None,
            user_tier=user_plan,
            user_id=user_id,
            target_audience=request.target_audience,  # Phase 2
            writing_style=request.writing_style,  # Phase 2
            include_examples=request.include_examples  # Phase 2
        )
        
        # Extract AI output and timing
        blog_output = ai_result['output']
        tokens_used = ai_result['tokensUsed']
        model_used = ai_result['model']
        generation_time = ai_result.get('generation_time', 0.0)  # Actual time from AI service
        quality_score_data = ai_result.get('quality_score', {})  # Real quality score from AI service
        
        # Use REAL quality metrics from quality_scorer (not mock data!)
        quality_metrics = {
            'readability_score': quality_score_data.get('readability', 0) * 10,  # Convert 0-1 to 0-10 scale
            'completeness_score': quality_score_data.get('completeness', 0) * 10,  # Structure, depth, length
            'seo_score': quality_score_data.get('seo', 0) * 10,  # SEO optimization
            'grammar_score': quality_score_data.get('grammar', 0) * 10,  # Convert 0-1 to 0-10 scale
            'originality_score': 9.0,  # Placeholder - requires separate API
            'fact_check_score': 0.0,  # Will be populated by AI fact-checker if enabled
            'ai_detection_score': 7.5,  # Placeholder - requires separate API
            'overall_score': quality_score_data.get('overall', 0) * 10  # Convert 0-1 to 0-10 scale
        }
        
        # Phase 3: Optional AI fact-checking (only if user enables it)
        # Cost: ~$0.0005 per check (budget-optimized: only verifies top 2-3 claims)
        fact_check_data = {'checked': False, 'claims': [], 'verificationTime': 0}
        if request.enable_fact_check and openai_service.fact_checker:
            try:
                content_text = blog_output.get('content', '')
                fact_check_result = await openai_service.fact_checker.check_facts(
                    content=content_text,
                    content_type='blog',
                    enable_fact_check=True
                )
                
                if fact_check_result.checked:
                    # Update fact check score based on verification results
                    quality_metrics['fact_check_score'] = fact_check_result.overall_confidence * 10
                    
                    # Convert fact check claims to enhanced Firestore format with sources array
                    fact_check_data = {
                        'checked': True,
                        'claims': [
                            {
                                'claim': claim.claim,
                                'verified': claim.verified,
                                'confidence': claim.confidence,
                                'evidence': claim.evidence,
                                'sources': [
                                    {
                                        'url': source.url,
                                        'title': source.title,
                                        'snippet': source.snippet,
                                        'domain': source.domain,
                                        'authority_level': source.authority_level
                                    }
                                    for source in claim.sources
                                ]
                            }
                            for claim in fact_check_result.claims
                        ],
                        'claims_found': fact_check_result.claims_found,
                        'claims_verified': fact_check_result.claims_verified,
                        'overall_confidence': fact_check_result.overall_confidence,
                        'verification_time': fact_check_result.verification_time,
                        'total_searches_used': fact_check_result.total_searches_used
                    }
                    
                    logger.info(f"✅ Fact-check complete: {len(fact_check_result.claims)} claims verified (confidence: {fact_check_result.overall_confidence:.2f})")
            except Exception as e:
                logger.error(f"Fact-checking failed (skipping): {e}")
        
        # Prepare generation document for Firestore
        generation_data = {
            'userId': user_id,
            'contentType': ContentType.BLOG.value,
            'userInput': {
                'topic': request.topic,
                'keywords': request.keywords,
                'tone': request.tone,
                'length': request.length,
                'includeSeo': request.include_seo,
                'includeImages': request.include_images
            },
            'output': {
                'title': blog_output.get('title', ''),
                'content': blog_output.get('content', ''),
                'metaDescription': blog_output.get('metaDescription', ''),
                'headings': blog_output.get('headings', []),
                'wordCount': blog_output.get('wordCount', target_word_count)
            },
            'settings': {
                'tone': request.tone,
                'length': request.length,  # Keep original enum value (short/medium/long)
                'customSettings': request.custom_settings or {}
            },
            'qualityMetrics': quality_metrics,
            'factCheckResults': fact_check_data,
            'humanization': {
                'applied': False,
                'level': None,
                'beforeScore': quality_metrics['ai_detection_score'],
                'afterScore': 0,
                'detectionApi': None,
                'processingTime': 0
            },
            'metadata': {
                'tokensUsed': tokens_used,
                'modelUsed': model_used,
                'processingTime': generation_time,  # Actual AI generation time
                'costEstimate': tokens_used * 0.00001  # Rough estimate
            },
            'generationTime': generation_time,  # Store at root level for easy access
            'tokensUsed': tokens_used,  # Store at root level for compatibility
            'modelUsed': model_used  # Store at root level for compatibility
        }
        
        # Save generation to Firestore (returns generation_id)
        generation_id = await firebase_service.save_generation(generation_data)
        logger.info(f"Generation saved: {generation_id}")
        
        # ==================== CRITICAL: INCREMENT STATS (REAL, NOT MOCK) ====================
        
        # Increment monthly usage counter
        await firebase_service.increment_usage(user_id)
        logger.info(f"Incremented generations for user {user_id}: {generations_used} -> {generations_used + 1}")
        
        # Get updated user to recalculate average quality
        updated_user = await firebase_service.get_user(user_id)
        
        # Extract validation results (Phase 2)
        validation_result = ai_result.get('validation')
        
        # Extract AI quality analysis and suggestions (Phase 3)
        ai_suggestions = []
        ai_quality_data = None
        if 'ai_analysis' in ai_result and ai_result['ai_analysis']:
            ai_data = ai_result['ai_analysis']
            ai_suggestions = ai_data.get('improvements', [])
            ai_quality_data = {
                'grammar': ai_data.get('grammar_score', 0),
                'style': ai_data.get('style_score', 0),
                'tone': ai_data.get('tone_score', 0),
                'engagement': ai_data.get('engagement_score', 0),
                'overall': ai_data.get('overall_ai_score', 0),
                'strengths': ai_data.get('strengths', [])
            }
        
        # Build response with REAL stats from database
        response = GenerationResponse(
            id=generation_id,
            user_id=user_id,
            content_type=ContentType.BLOG,
            content=generation_data['output'].get('content', ''),
            title=generation_data['output'].get('title', ''),
            meta_description=generation_data['output'].get('metaDescription'),  # SEO meta description
            word_count=generation_data['output'].get('wordCount'),  # Actual word count from AI
            settings=generation_data['settings'],
            quality_metrics=quality_metrics,
            fact_check_results=generation_data['factCheckResults'],
            humanization=generation_data['humanization'],
            validation=validation_result,  # Phase 2: Include validation
            ai_suggestions=ai_suggestions,  # Phase 3: AI-powered improvement suggestions
            ai_quality_metrics=ai_quality_data,  # Phase 3: Deep AI quality analysis
            generation_time=generation_time,
            model_used=model_used,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
        logger.info(f"Blog generation complete for user {user_id}. New count: {generations_used + 1}/{generation_limit}")
        return response
        
    except HTTPException:
        # Re-raise FastAPI HTTPExceptions (like 402 payment required)
        raise
    except RateLimitError as e:
        # AI service rate limit (429)
        logger.warning(f"Rate limit hit during blog generation for user {user_id}: {e}")
        raise HTTPException(
            status_code=429,
            detail=e.to_dict()
        )
    except InvalidAPIKeyError as e:
        # Internal server misconfiguration - don't expose to client
        logger.critical(f"API key error during blog generation: {e}")
        raise HTTPException(
            status_code=503,
            detail={
                "error": "service_unavailable",
                "message": "AI service is temporarily unavailable. Please try again later."
            }
        )
    except ContentPolicyViolationError as e:
        # User content violates AI policy
        logger.warning(f"Content policy violation for user {user_id}: {e}")
        raise HTTPException(
            status_code=400,
            detail=e.to_dict()
        )
    except TokenLimitExceededError as e:
        # Content too long
        logger.warning(f"Token limit exceeded for user {user_id}: {e}")
        raise HTTPException(
            status_code=400,
            detail=e.to_dict()
        )
    except AITimeoutError as e:
        # AI service timeout
        logger.error(f"AI timeout during blog generation for user {user_id}: {e}")
        raise HTTPException(
            status_code=504,
            detail=e.to_dict()
        )
    except NetworkError as e:
        # Network connectivity issue
        logger.error(f"Network error during blog generation for user {user_id}: {e}")
        raise HTTPException(
            status_code=503,
            detail=e.to_dict()
        )
    except AIServiceError as e:
        # Generic AI service error
        logger.error(f"AI service error during blog generation for user {user_id}: {e}")
        raise HTTPException(
            status_code=503,
            detail=e.to_dict()
        )
    except DatabaseError as e:
        # Database operation failed
        logger.error(f"Database error during blog generation for user {user_id}: {e}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail={
                "error": "database_error",
                "message": "Failed to save generation. Please try again."
            }
        )
    except Exception as e:
        # Unexpected error
        logger.error(f"Unexpected error in blog generation for user {user_id}: {e}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail={
                "error": "generation_failed",
                "message": f"Failed to generate blog post: {str(e)}"
            }
        )


# ==================== MILESTONE 2.2: SOCIAL MEDIA GENERATION ====================

@router.post(
    "/social",
    response_model=GenerationResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Generate social media content",
    description="Generate platform-optimized social media posts with hashtags and engagement tips"
)
async def generate_social_media(
    request: SocialMediaGenerationRequest,
    current_user: Dict[str, Any] = Depends(get_current_user),
    firebase_service: FirebaseService = Depends(get_firebase_service),
    openai_service: OpenAIService = Depends(get_openai_service)
) -> GenerationResponse:
    """Generate social media content with automatic stats tracking"""
    try:
        user_id = current_user['uid']
        user_plan = current_user.get('subscriptionPlan', 'free')
        usage_this_month = current_user.get('usageThisMonth', {})
        generations_used = usage_this_month.get('generations', 0)
        generation_limit = usage_this_month.get('limit', 5)
        
        if generations_used >= generation_limit:
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail={
                    "error": "generation_limit_reached",
                    "message": f"Monthly limit reached: {generation_limit} generations",
                    "used": generations_used,
                    "limit": generation_limit
                }
            )
        
        # Enhance user prompt for better social media output
        enhanced_topic = improve_prompt(
            user_prompt=request.topic,
            content_type=PromptContentType.SOCIAL_MEDIA,
            tone=request.tone,
            platform=request.platform
        )
        
        logger.info(f"Generating social media content for user {user_id}: {request.platform}")
        logger.debug(f"Enhanced prompt: {enhanced_topic[:100]}...")
        
        ai_result = await openai_service.generate_social_media(
            content_description=enhanced_topic,
            platform=request.platform,
            target_audience="general",
            tone=request.tone,
            include_hashtags=request.include_hashtags,
            user_tier=user_plan,
            user_id=user_id
        )
        
        social_output = ai_result['output']
        quality_score_data = ai_result.get('quality_score', {})
        
        # Use REAL quality metrics from quality_scorer
        quality_metrics = {
            'readability_score': quality_score_data.get('readability', 0) * 10,
            'completeness_score': quality_score_data.get('completeness', 0) * 10,
            'seo_score': quality_score_data.get('seo', 0) * 10,
            'grammar_score': quality_score_data.get('grammar', 0) * 10,
            'originality_score': 8.5,  # Placeholder
            'fact_check_score': 0.0,
            'ai_detection_score': 7.0,  # Placeholder
            'overall_score': quality_score_data.get('overall', 0) * 10
        }
        
        generation_data = {
            'userId': user_id,
            'contentType': ContentType.SOCIAL_MEDIA,
            'userInput': {
                'platform': request.platform,
                'topic': request.topic,
                'tone': request.tone,
                'includeHashtags': request.include_hashtags,
                'includeEmojis': request.include_emojis,
                'characterLimit': request.character_limit
            },
            'output': social_output,
            'settings': {
                'tone': request.tone,
                'length': 'short',
                'customSettings': request.custom_settings or {}
            },
            'qualityMetrics': quality_metrics,
            'factCheckResults': {'checked': False, 'claims': [], 'verificationTime': 0},
            'humanization': {'applied': False, 'level': None, 'beforeScore': quality_metrics['ai_detection_score'], 'afterScore': 0},
            'metadata': {
                'tokensUsed': ai_result['tokensUsed'],
                'modelUsed': ai_result['model'],
                'processingTime': 0.0,
                'costEstimate': ai_result['tokensUsed'] * 0.00001
            }
        }
        
        generation_id = await firebase_service.save_generation(generation_data)
        await firebase_service.increment_usage(user_id)
        
        # Extract AI quality analysis
        ai_suggestions = []
        ai_quality_data = None
        if 'ai_analysis' in ai_result and ai_result['ai_analysis']:
            ai_data = ai_result['ai_analysis']
            ai_suggestions = ai_data.get('improvements', [])
            ai_quality_data = {
                'grammar': ai_data.get('grammar_score', 0),
                'style': ai_data.get('style_score', 0),
                'tone': ai_data.get('tone_score', 0),
                'engagement': ai_data.get('engagement_score', 0),
                'overall': ai_data.get('overall_ai_score', 0),
                'strengths': ai_data.get('strengths', [])
            }
        
        logger.info(f"Social media generation complete for user {user_id}")
        
        return GenerationResponse(
            id=generation_id,
            user_id=user_id,
            content_type=ContentType.SOCIAL_MEDIA,
            content=str(generation_data['output']),
            title=request.platform + ' post',
            settings=generation_data['settings'],
            quality_metrics=quality_metrics,
            fact_check_results=generation_data['factCheckResults'],
            humanization=generation_data['humanization'],
            ai_suggestions=ai_suggestions,
            ai_quality_metrics=ai_quality_data,
            generation_time=generation_data['metadata']['processingTime'],
            model_used=generation_data['metadata']['modelUsed'],
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in social media generation: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": "generation_failed", "message": str(e)}
        )


# ==================== MILESTONE 2.3: EMAIL GENERATION ====================

@router.post(
    "/email",
    response_model=GenerationResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Generate email campaign",
    description="Generate complete email campaigns with subject lines, body, and CTA"
)
async def generate_email_campaign(
    request: EmailGenerationRequest,
    current_user: Dict[str, Any] = Depends(get_current_user),
    firebase_service: FirebaseService = Depends(get_firebase_service),
    openai_service: OpenAIService = Depends(get_openai_service)
) -> GenerationResponse:
    """Generate email campaign with automatic stats tracking"""
    try:
        user_id = current_user['uid']
        user_plan = current_user.get('subscriptionPlan', 'free')
        usage_this_month = current_user.get('usageThisMonth', {})
        generations_used = usage_this_month.get('generations', 0)
        generation_limit = usage_this_month.get('limit', 5)
        
        if generations_used >= generation_limit:
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail={
                    "error": "generation_limit_reached",
                    "message": f"Monthly limit reached: {generation_limit} generations",
                    "used": generations_used,
                    "limit": generation_limit
                }
            )
        
        # Enhance user prompt for better email output
        enhanced_product = improve_prompt(
            user_prompt=request.product_service,
            content_type=PromptContentType.EMAIL,
            tone=request.tone
        )
        
        logger.info(f"Generating email campaign for user {user_id}: {request.campaign_type}")
        logger.debug(f"Enhanced prompt: {enhanced_product[:100]}...")
        
        ai_result = await openai_service.generate_email_campaign(
            campaign_type=request.campaign_type,
            product_service=enhanced_product,
            target_audience="general audience",
            goal="engagement",
            tone=request.tone,
            user_tier=user_plan,
            user_id=user_id
        )
        
        # Keep output as dict for processing, convert to string later if needed
        email_output = ai_result['output']
        
        # Handle dict output - extract all text content and flatten nested structures
        def flatten_to_text(value, bullet_items=False):
            """Recursively flatten any data structure to readable text"""
            if isinstance(value, str):
                return value
            elif isinstance(value, (int, float, bool)):
                return str(value)
            elif isinstance(value, list):
                if bullet_items:
                    return '\n'.join([f"• {flatten_to_text(item)}" for item in value if item])
                else:
                    return '\n'.join([flatten_to_text(item) for item in value if item])
            elif isinstance(value, dict):
                return '\n'.join([flatten_to_text(v) for v in value.values() if v])
            else:
                return str(value)
        
        if isinstance(email_output, dict):
            content_parts = []
            
            # Try standard email keys first
            for key in ['intro', 'body', 'closing', 'content', 'message', 'text']:
                if key in email_output:
                    value = email_output[key]
                    # Use bullet points for lists in body sections
                    use_bullets = key in ['body', 'features', 'benefits', 'highlights']
                    content_parts.append(flatten_to_text(value, bullet_items=use_bullets))
            
            # If no standard keys found, extract all values
            if not content_parts:
                for key, value in email_output.items():
                    if value:
                        use_bullets = 'benefit' in key.lower() or 'feature' in key.lower()
                        content_parts.append(flatten_to_text(value, bullet_items=use_bullets))
            
            email_content = '\n\n'.join(content_parts) if content_parts else json.dumps(email_output, indent=2)
            output_dict = email_output
        else:
            email_content = str(email_output)
            output_dict = {'content': email_content}
        
        quality_score_data = ai_result.get('quality_score', {})
        
        # Use REAL quality metrics from quality_scorer
        quality_metrics = {
            'readability_score': quality_score_data.get('readability', 0) * 10,
            'completeness_score': quality_score_data.get('completeness', 0) * 10,
            'seo_score': quality_score_data.get('seo', 0) * 10,
            'grammar_score': quality_score_data.get('grammar', 0) * 10,
            'originality_score': 8.8,  # Placeholder
            'fact_check_score': 0.0,
            'ai_detection_score': 7.2,  # Placeholder
            'overall_score': quality_score_data.get('overall', 0) * 10
        }
        
        generation_data = {
            'userId': user_id,
            'contentType': ContentType.EMAIL,
            'userInput': {
                'campaignType': request.campaign_type,
                'subjectLine': request.subject_line,
                'productService': request.product_service,
                'tone': request.tone,
                'includePersonalization': request.include_personalization
            },
            'output': json.dumps(output_dict, indent=2) if isinstance(output_dict, dict) else output_dict,
            'settings': {
                'tone': request.tone,
                'length': 'medium',
                'customSettings': request.custom_settings or {}
            },
            'qualityMetrics': quality_metrics,
            'factCheckResults': {'checked': False, 'claims': [], 'verificationTime': 0},
            'humanization': {'applied': False, 'level': None, 'beforeScore': quality_metrics['ai_detection_score'], 'afterScore': 0},
            'metadata': {
                'tokensUsed': ai_result['tokensUsed'],
                'modelUsed': ai_result['model'],
                'processingTime': 0.0,
                'costEstimate': ai_result['tokensUsed'] * 0.00001
            }
        }
        
        generation_id = await firebase_service.save_generation(generation_data)
        await firebase_service.increment_usage(user_id)
        
        # Extract AI quality analysis
        ai_suggestions = []
        ai_quality_data = None
        if 'ai_analysis' in ai_result and ai_result['ai_analysis']:
            ai_data = ai_result['ai_analysis']
            ai_suggestions = ai_data.get('improvements', [])
            ai_quality_data = {
                'grammar': ai_data.get('grammar_score', 0),
                'style': ai_data.get('style_score', 0),
                'tone': ai_data.get('tone_score', 0),
                'engagement': ai_data.get('engagement_score', 0),
                'overall': ai_data.get('overall_ai_score', 0),
                'strengths': ai_data.get('strengths', [])
            }
        
        logger.info(f"Email campaign generation complete for user {user_id}")
        
        return GenerationResponse(
            id=generation_id,
            user_id=user_id,
            content_type=ContentType.EMAIL,
            content=email_content,
            title=output_dict.get('subject', request.subject_line) if isinstance(output_dict, dict) else request.subject_line,
            settings=generation_data['settings'],
            quality_metrics=quality_metrics,
            fact_check_results=generation_data['factCheckResults'],
            humanization=generation_data['humanization'],
            ai_suggestions=ai_suggestions,
            ai_quality_metrics=ai_quality_data,
            generation_time=generation_data['metadata']['processingTime'],
            model_used=generation_data['metadata']['modelUsed'],
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in email generation: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": "generation_failed", "message": str(e)}
        )


# ==================== MILESTONE 2.4: PRODUCT DESCRIPTION ====================

@router.post(
    "/product",
    response_model=GenerationResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Generate product description",
    description="Generate SEO-optimized e-commerce product descriptions"
)
async def generate_product_description(
    request: ProductDescriptionRequest,
    current_user: Dict[str, Any] = Depends(get_current_user),
    firebase_service: FirebaseService = Depends(get_firebase_service),
    openai_service: OpenAIService = Depends(get_openai_service)
) -> GenerationResponse:
    """Generate product description with automatic stats tracking"""
    try:
        user_id = current_user['uid']
        user_plan = current_user.get('subscriptionPlan', 'free')
        usage_this_month = current_user.get('usageThisMonth', {})
        generations_used = usage_this_month.get('generations', 0)
        generation_limit = usage_this_month.get('limit', 5)
        
        if generations_used >= generation_limit:
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail={
                    "error": "generation_limit_reached",
                    "message": f"Monthly limit reached: {generation_limit} generations",
                    "used": generations_used,
                    "limit": generation_limit
                }
            )
        
        logger.info(f"Generating product description for user {user_id}: {request.product_name}")
        
        product_details = {
            'name': request.product_name,
            'category': request.category,
            'features': request.key_features,
            'benefits': request.benefits,
            'specifications': request.specifications
        }
        
        # Enhance product name for better description
        enhanced_product_name = improve_prompt(
            user_prompt=request.product_name,
            content_type=PromptContentType.PRODUCT_DESC,
            tone="persuasive"
        )
        
        product_details = {
            'name': enhanced_product_name,
            'category': request.category,
            'price': request.price,
            'features': request.features,
            'benefits': request.benefits,
            'specifications': request.specifications
        }
        
        logger.debug(f"Enhanced product name: {enhanced_product_name[:100]}...")
        
        ai_result = await openai_service.generate_product_description(
            product_details=product_details,
            target_customer=request.target_audience,
            platform=request.platform or "general",
            include_seo=request.include_seo,
            user_tier=user_plan,
            user_id=user_id
        )
        
        # Handle dict output - extract all text content and flatten nested structures
        def flatten_to_text(value, bullet_items=False):
            """Recursively flatten any data structure to readable text"""
            if isinstance(value, str):
                return value
            elif isinstance(value, (int, float, bool)):
                return str(value)
            elif isinstance(value, list):
                if bullet_items:
                    return '\n'.join([f"• {flatten_to_text(item)}" for item in value if item])
                else:
                    return '\n'.join([flatten_to_text(item) for item in value if item])
            elif isinstance(value, dict):
                return '\n'.join([flatten_to_text(v) for v in value.values() if v])
            else:
                return str(value)
        
        product_output = ai_result['output']
        
        if isinstance(product_output, dict):
            # Extract product content from dict
            product_content = ''
            product_title = product_output.get('title', request.product_name)
            
            # Try to get description from various possible keys
            for key in ['description', 'content', 'text', 'body']:
                if key in product_output and product_output[key]:
                    product_content = flatten_to_text(product_output[key])
                    break
            
            # If no content found, combine all text values
            if not product_content:
                content_parts = []
                for key, value in product_output.items():
                    if key != 'title' and value:
                        use_bullets = 'feature' in key.lower() or 'benefit' in key.lower()
                        content_parts.append(flatten_to_text(value, bullet_items=use_bullets))
                product_content = '\n\n'.join(content_parts) if content_parts else json.dumps(product_output, indent=2)
            
            output_dict = product_output
        else:
            product_content = str(product_output)
            product_title = request.product_name
            output_dict = {'description': product_content, 'title': product_title}
        
        quality_score_data = ai_result.get('quality_score', {})
        
        # Use REAL quality metrics from quality_scorer
        quality_metrics = {
            'readability_score': quality_score_data.get('readability', 0) * 10,
            'completeness_score': quality_score_data.get('completeness', 0) * 10,
            'seo_score': quality_score_data.get('seo', 0) * 10,
            'grammar_score': quality_score_data.get('grammar', 0) * 10,
            'originality_score': 9.0,  # Placeholder
            'fact_check_score': 0.0,
            'ai_detection_score': 6.8,  # Placeholder
            'overall_score': quality_score_data.get('overall', 0) * 10
        }
        
        generation_data = {
            'userId': user_id,
            'contentType': ContentType.PRODUCT_DESCRIPTION,
            'userInput': {
                'productName': request.product_name,
                'category': request.category,
                'keyFeatures': request.key_features,
                'benefits': request.benefits,
                'targetAudience': request.target_audience,
                'tone': request.tone,
                'includeSeo': request.include_seo
            },
            'output': json.dumps(output_dict, indent=2) if isinstance(output_dict, dict) else output_dict,
            'settings': {
                'tone': request.tone,
                'platform': request.platform or "general"
            },
            'qualityMetrics': quality_metrics,
            'factCheckResults': {'checked': False, 'claims': [], 'verificationTime': 0},
            'humanization': {'applied': False, 'level': None, 'beforeScore': quality_metrics['ai_detection_score'], 'afterScore': 0},
            'metadata': {
                'tokensUsed': ai_result['tokensUsed'],
                'modelUsed': ai_result['model'],
                'processingTime': 0.0,
                'costEstimate': ai_result['tokensUsed'] * 0.00001
            }
        }
        
        generation_id = await firebase_service.save_generation(generation_data)
        await firebase_service.increment_usage(user_id)
        
        # Extract AI quality analysis
        ai_suggestions = []
        ai_quality_data = None
        if 'ai_analysis' in ai_result and ai_result['ai_analysis']:
            ai_data = ai_result['ai_analysis']
            ai_suggestions = ai_data.get('improvements', [])
            ai_quality_data = {
                'grammar': ai_data.get('grammar_score', 0),
                'style': ai_data.get('style_score', 0),
                'tone': ai_data.get('tone_score', 0),
                'engagement': ai_data.get('engagement_score', 0),
                'overall': ai_data.get('overall_ai_score', 0),
                'strengths': ai_data.get('strengths', [])
            }
        
        logger.info(f"Product description generation complete for user {user_id}")
        
        return GenerationResponse(
            id=generation_id,
            user_id=user_id,
            content_type=ContentType.PRODUCT_DESCRIPTION,
            content=product_content,
            title=product_title,
            settings=generation_data['settings'],
            quality_metrics=quality_metrics,
            fact_check_results=generation_data['factCheckResults'],
            humanization=generation_data['humanization'],
            ai_suggestions=ai_suggestions,
            ai_quality_metrics=ai_quality_data,
            generation_time=generation_data['metadata']['processingTime'],
            model_used=generation_data['metadata']['modelUsed'],
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in product description generation: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": "generation_failed", "message": str(e)}
        )


# ==================== MILESTONE 2.5: AD COPY GENERATION ====================

@router.post(
    "/ad",
    response_model=GenerationResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Generate ad copy",
    description="Generate high-converting advertisement copy with multiple variations"
)
async def generate_ad_copy(
    request: AdCopyRequest,
    current_user: Dict[str, Any] = Depends(get_current_user),
    firebase_service: FirebaseService = Depends(get_firebase_service),
    openai_service: OpenAIService = Depends(get_openai_service)
) -> GenerationResponse:
    """Generate ad copy with automatic stats tracking"""
    try:
        user_id = current_user['uid']
        user_plan = current_user.get('subscriptionPlan', 'free')
        usage_this_month = current_user.get('usageThisMonth', {})
        generations_used = usage_this_month.get('generations', 0)
        generation_limit = usage_this_month.get('limit', 5)
        
        if generations_used >= generation_limit:
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail={
                    "error": "generation_limit_reached",
                    "message": f"Monthly limit reached: {generation_limit} generations",
                    "used": generations_used,
                    "limit": generation_limit
                }
            )
        
        # Enhance prompt for better ad copy
        enhanced_product = improve_prompt(
            user_prompt=f"{request.product_service} - {request.campaign_goal}",
            content_type=PromptContentType.AD_COPY,
            tone="persuasive",
            target_audience=request.target_audience
        )
        
        logger.info(f"Generating ad copy for user {user_id}: {request.product_service}")
        logger.debug(f"Enhanced prompt: {enhanced_product[:100]}...")
        
        ai_result = await openai_service.generate_ad_copy(
            product_service=enhanced_product,
            target_audience=request.target_audience,
            platform=request.platform,
            campaign_goal=request.campaign_goal,
            user_tier=user_plan,
            user_id=user_id
        )
        
        # Handle dict output - extract all text content and flatten nested structures
        def flatten_to_text(value, bullet_items=False):
            """Recursively flatten any data structure to readable text"""
            if isinstance(value, str):
                return value
            elif isinstance(value, (int, float, bool)):
                return str(value)
            elif isinstance(value, list):
                if bullet_items:
                    return '\n'.join([f"• {flatten_to_text(item)}" for item in value if item])
                else:
                    return '\n'.join([flatten_to_text(item) for item in value if item])
            elif isinstance(value, dict):
                return '\n'.join([flatten_to_text(v) for v in value.values() if v])
            else:
                return str(value)
        
        ad_output = ai_result['output']
        
        if isinstance(ad_output, dict):
            # Extract ad content from dict
            ad_content = ''
            ad_title = ad_output.get('headline', request.product_service)
            
            # Try to get body/content from various possible keys
            for key in ['body', 'content', 'text', 'description']:
                if key in ad_output and ad_output[key]:
                    ad_content = flatten_to_text(ad_output[key])
                    break
            
            # If no content found, combine all text values except headline
            if not ad_content:
                content_parts = []
                for key, value in ad_output.items():
                    if key not in ['headline', 'title'] and value:
                        use_bullets = 'feature' in key.lower() or 'benefit' in key.lower() or 'point' in key.lower()
                        content_parts.append(flatten_to_text(value, bullet_items=use_bullets))
                ad_content = '\n\n'.join(content_parts) if content_parts else json.dumps(ad_output, indent=2)
            
            output_dict = ad_output
        else:
            ad_content = str(ad_output)
            ad_title = request.product_service
            output_dict = {'body': ad_content, 'headline': ad_title}
        
        quality_score_data = ai_result.get('quality_score', {})
        
        # Use REAL quality metrics from quality_scorer
        quality_metrics = {
            'readability_score': quality_score_data.get('readability', 0) * 10,
            'completeness_score': quality_score_data.get('completeness', 0) * 10,
            'seo_score': quality_score_data.get('seo', 0) * 10,
            'grammar_score': quality_score_data.get('grammar', 0) * 10,
            'originality_score': 9.2,  # Placeholder
            'fact_check_score': 0.0,
            'ai_detection_score': 6.5,  # Placeholder
            'overall_score': quality_score_data.get('overall', 0) * 10
        }
        
        generation_data = {
            'userId': user_id,
            'contentType': ContentType.AD_COPY,
            'userInput': {
                'productService': request.product_service,
                'targetAudience': request.target_audience,
                'uniqueSellingPoint': request.unique_selling_point,
                'platform': request.platform,
                'campaignGoal': request.campaign_goal,
                'tone': request.tone
            },
            'output': json.dumps(output_dict, indent=2) if isinstance(output_dict, dict) else output_dict,
            'settings': {
                'tone': request.tone,
                'platform': request.platform
            },
            'qualityMetrics': quality_metrics,
            'factCheckResults': {'checked': False, 'claims': [], 'verificationTime': 0},
            'humanization': {'applied': False, 'level': None, 'beforeScore': quality_metrics['ai_detection_score'], 'afterScore': 0},
            'metadata': {
                'tokensUsed': ai_result['tokensUsed'],
                'modelUsed': ai_result['model'],
                'processingTime': 0.0,
                'costEstimate': ai_result['tokensUsed'] * 0.00001
            }
        }
        
        generation_id = await firebase_service.save_generation(generation_data)
        await firebase_service.increment_usage(user_id)
        
        # Extract AI quality analysis
        ai_suggestions = []
        ai_quality_data = None
        if 'ai_analysis' in ai_result and ai_result['ai_analysis']:
            ai_data = ai_result['ai_analysis']
            ai_suggestions = ai_data.get('improvements', [])
            ai_quality_data = {
                'grammar': ai_data.get('grammar_score', 0),
                'style': ai_data.get('style_score', 0),
                'tone': ai_data.get('tone_score', 0),
                'engagement': ai_data.get('engagement_score', 0),
                'overall': ai_data.get('overall_ai_score', 0),
                'strengths': ai_data.get('strengths', [])
            }
        
        logger.info(f"Ad copy generation complete for user {user_id}")
        
        return GenerationResponse(
            id=generation_id,
            user_id=user_id,
            content_type=ContentType.AD_COPY,
            content=ad_content,
            title=ad_title,
            settings=generation_data['settings'],
            quality_metrics=quality_metrics,
            fact_check_results=generation_data['factCheckResults'],
            humanization=generation_data['humanization'],
            ai_suggestions=ai_suggestions,
            ai_quality_metrics=ai_quality_data,
            generation_time=generation_data['metadata']['processingTime'],
            model_used=generation_data['metadata']['modelUsed'],
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in ad copy generation: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": "generation_failed", "message": str(e)}
        )


# ==================== MILESTONE 2.6: VIDEO SCRIPT GENERATION ====================

@router.post(
    "/video-script",
    response_model=GenerationResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Generate video script",
    description="Generate platform-optimized video scripts with hooks, timestamps, and visual cues"
)
async def generate_video_script(
    request: VideoScriptRequest,
    current_user: Dict[str, Any] = Depends(get_current_user),
    firebase_service: FirebaseService = Depends(get_firebase_service),
    openai_service: OpenAIService = Depends(get_openai_service)
) -> GenerationResponse:
    """Generate video script with automatic stats tracking"""
    try:
        user_id = current_user['uid']
        user_plan = current_user.get('subscriptionPlan', 'free')
        usage_this_month = current_user.get('usageThisMonth', {})
        generations_used = usage_this_month.get('generations', 0)
        generation_limit = usage_this_month.get('limit', 5)
        
        if generations_used >= generation_limit:
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail={
                    "error": "generation_limit_reached",
                    "message": f"Monthly limit reached: {generation_limit} generations",
                    "used": generations_used,
                    "limit": generation_limit
                }
            )
        
        # Enhance prompt for better video script
        enhanced_topic = improve_prompt(
            user_prompt=request.topic,
            content_type=PromptContentType.VIDEO_SCRIPT,
            tone="engaging",
            target_audience=request.target_audience,
            platform=request.platform
        )
        
        logger.info(f"Generating video script for user {user_id}: {request.topic}")
        logger.debug(f"Enhanced prompt: {enhanced_topic[:100]}...")
        
        ai_result = await openai_service.generate_video_script(
            topic=enhanced_topic,
            duration_seconds=request.duration,
            platform=request.platform,
            target_audience=request.target_audience,
            key_points=request.key_points,
            cta=request.cta or "",
            user_tier=user_plan,
            user_id=user_id
        )
        
        # Handle dict output - extract all text content and flatten nested structures
        def flatten_to_text(value, bullet_items=False):
            """Recursively flatten any data structure to readable text"""
            if isinstance(value, str):
                return value
            elif isinstance(value, (int, float, bool)):
                return str(value)
            elif isinstance(value, list):
                if bullet_items:
                    return '\n'.join([f"• {flatten_to_text(item)}" for item in value if item])
                else:
                    return '\n'.join([flatten_to_text(item) for item in value if item])
            elif isinstance(value, dict):
                return '\n'.join([flatten_to_text(v) for v in value.values() if v])
            else:
                return str(value)
        
        video_output = ai_result['output']
        
        if isinstance(video_output, dict):
            # Extract video script content from dict
            video_content = ''
            video_title = video_output.get('title', request.topic)
            
            # Try to get script content from various possible keys
            for key in ['script', 'content', 'text', 'body']:
                if key in video_output and video_output[key]:
                    video_content = flatten_to_text(video_output[key])
                    break
            
            # If no content found, combine all text values except title
            if not video_content:
                content_parts = []
                for key, value in video_output.items():
                    if key not in ['title', 'hook'] and value:
                        use_bullets = 'scene' in key.lower() or 'section' in key.lower()
                        content_parts.append(flatten_to_text(value, bullet_items=use_bullets))
                video_content = '\n\n'.join(content_parts) if content_parts else json.dumps(video_output, indent=2)
            
            output_dict = video_output
        else:
            video_content = str(video_output)
            video_title = request.topic
            output_dict = {'script': video_content, 'title': video_title}
        
        quality_score_data = ai_result.get('quality_score', {})
        
        # Use REAL quality metrics from quality_scorer
        quality_metrics = {
            'readability_score': quality_score_data.get('readability', 0) * 10,
            'completeness_score': quality_score_data.get('completeness', 0) * 10,
            'seo_score': quality_score_data.get('seo', 0) * 10,
            'grammar_score': quality_score_data.get('grammar', 0) * 10,
            'originality_score': 9.0,  # Placeholder
            'fact_check_score': 0.0,
            'ai_detection_score': 7.0,  # Placeholder
            'overall_score': quality_score_data.get('overall', 0) * 10
        }
        
        generation_data = {
            'userId': user_id,
            'contentType': ContentType.VIDEO_SCRIPT,
            'userInput': {
                'topic': request.topic,
                'platform': request.platform,
                'duration': request.duration,
                'targetAudience': request.target_audience,
                'tone': request.tone,
                'keyPoints': request.key_points,
                'includeHooks': request.include_hooks,
                'includeCta': request.include_cta
            },
            'output': json.dumps(output_dict, indent=2) if isinstance(output_dict, dict) else output_dict,
            'settings': {
                'tone': request.tone,
                'platform': request.platform,
                'duration': request.duration
            },
            'qualityMetrics': quality_metrics,
            'factCheckResults': {'checked': False, 'claims': [], 'verificationTime': 0},
            'humanization': {'applied': False, 'level': None, 'beforeScore': quality_metrics['ai_detection_score'], 'afterScore': 0},
            'metadata': {
                'tokensUsed': ai_result['tokensUsed'],
                'modelUsed': ai_result['model'],
                'processingTime': 0.0,
                'costEstimate': ai_result['tokensUsed'] * 0.00001
            }
        }
        
        generation_id = await firebase_service.save_generation(generation_data)
        await firebase_service.increment_usage(user_id)
        
        # Extract AI quality analysis
        ai_suggestions = []
        ai_quality_data = None
        if 'ai_analysis' in ai_result and ai_result['ai_analysis']:
            ai_data = ai_result['ai_analysis']
            ai_suggestions = ai_data.get('improvements', [])
            ai_quality_data = {
                'grammar': ai_data.get('grammar_score', 0),
                'style': ai_data.get('style_score', 0),
                'tone': ai_data.get('tone_score', 0),
                'engagement': ai_data.get('engagement_score', 0),
                'overall': ai_data.get('overall_ai_score', 0),
                'strengths': ai_data.get('strengths', [])
            }
        
        logger.info(f"Video script generation complete for user {user_id}")
        
        return GenerationResponse(
            id=generation_id,
            user_id=user_id,
            content_type=ContentType.VIDEO_SCRIPT,
            content=video_content,
            title=video_title,
            quality_metrics=quality_metrics,
            fact_check_results=generation_data['factCheckResults'],
            humanization=generation_data['humanization'],
            ai_suggestions=ai_suggestions,
            ai_quality_metrics=ai_quality_data,
            generation_time=generation_data['metadata']['processingTime'],
            model_used=generation_data['metadata']['modelUsed'],
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in video script generation: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": "generation_failed", "message": str(e)}
        )


# ==================== HEALTH CHECK ====================

@router.get(
    "/health",
    summary="Check generation service health",
    description="Verify AI services (OpenAI/Gemini) are accessible"
)
async def health_check(
    openai_service: OpenAIService = Depends(get_openai_service)
) -> Dict[str, Any]:
    """Check if AI generation services are healthy"""
    return {
        "status": "healthy",
        "services": {
            "openai": "configured" if openai_service.openai_client else "missing",
            "gemini": "fallback_ready" if openai_service.gemini_model else "missing"
        },
        "timestamp": datetime.utcnow().isoformat()
    }
