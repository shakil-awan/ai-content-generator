"""
Content Humanization Router - Milestone 2.3: AI Humanization
Handles AI detection and content humanization with REAL stats tracking

ARCHITECTURE FLOW:
    Request → Router (validate) → Humanization Service (detect + humanize) 
           → Firebase (update generation + increment stats) → Response

STATS INCREMENT PATTERN:
    Every successful humanization automatically increments:
    - usageThisMonth.humanizations++
    - allTimeStats.totalHumanizations++
"""
from fastapi import APIRouter, Depends, HTTPException, status, Path
from typing import Dict, Any
from datetime import datetime
import logging

from app.schemas.generation import (
    HumanizationRequest,
    HumanizationResult,
    ContentType
)
from app.dependencies import get_current_user, get_firebase_service
from app.services.firebase_service import FirebaseService
from app.services.humanization_service import HumanizationService

router = APIRouter(prefix="/api/v1/humanize", tags=["AI Humanization"])
logger = logging.getLogger(__name__)

# Initialize humanization service
humanization_service = HumanizationService()

# ==================== MILESTONE 2.3: CONTENT HUMANIZATION ====================

@router.post(
    "/{generation_id}",
    response_model=HumanizationResult,
    status_code=status.HTTP_200_OK,
    summary="Humanize AI-generated content",
    description="""
    Detect and humanize AI-generated content to make it sound more natural.
    
    **Stats Auto-Increment:**
    - usageThisMonth.humanizations++ (tracks monthly usage)
    - allTimeStats.totalHumanizations++ (lifetime counter)
    
    **Rate Limiting:**
    - Free: 5 humanizations/month
    - Pro: 25 humanizations/month
    - Enterprise: Unlimited
    
    **Humanization Levels:**
    - light: Minimal changes, subtle improvements
    - balanced: Moderate rewrite, natural flow (recommended)
    - aggressive: Heavy rewrite, maximum human-like quality
    
    **Process:**
    1. Retrieve original generation from database
    2. Detect AI score (0-100, higher = more AI-like)
    3. Rewrite content to be more human-like
    4. Re-detect AI score to measure improvement
    5. Update generation with humanized version
    6. Increment usage stats
    7. Return before/after comparison
    
    **Returns:**
    - Original and humanized content
    - AI detection scores before/after
    - Improvement percentage
    - Processing time and cost estimate
    """
)
async def humanize_content(
    generation_id: str = Path(..., description="ID of the generation to humanize"),
    request: HumanizationRequest = None,
    current_user: Dict[str, Any] = Depends(get_current_user),
    firebase_service: FirebaseService = Depends(get_firebase_service)
) -> HumanizationResult:
    """
    Humanize AI-generated content with automatic stats tracking
    
    Flow:
    1. Check if user has humanizations left this month
    2. Retrieve original generation from Firestore
    3. Detect current AI score
    4. Humanize content based on level
    5. Update generation document with humanization data
    6. Increment humanization stats (usageThisMonth.humanizations++)
    7. Increment lifetime stats (allTimeStats.totalHumanizations++)
    8. Return humanization result with before/after comparison
    """
    try:
        user_id = current_user['uid']
        usage_this_month = current_user.get('usageThisMonth', {})
        humanizations_used = usage_this_month.get('humanizations', 0)
        humanization_limit = usage_this_month.get('humanizationsLimit', 5)
        
        # Check if user has humanizations left
        if humanizations_used >= humanization_limit:
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail={
                    "error": "humanization_limit_reached",
                    "message": f"You've reached your monthly limit of {humanization_limit} humanizations. Upgrade to Pro for 25/month or Enterprise for unlimited.",
                    "used": humanizations_used,
                    "limit": humanization_limit,
                    "resetDate": usage_this_month.get('resetDate')
                }
            )
        
        # Get original generation from Firestore
        generation = await firebase_service.get_generation_by_id(generation_id)
        
        if not generation:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "generation_not_found",
                    "message": f"Generation with ID {generation_id} not found"
                }
            )
        
        # Verify user owns this generation
        if generation.get('userId') != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail={
                    "error": "unauthorized",
                    "message": "You don't have permission to humanize this content"
                }
            )
        
        # Check if already humanized
        if generation.get('humanization', {}).get('applied'):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "error": "already_humanized",
                    "message": "This content has already been humanized. Generate new content to humanize again.",
                    "previousScore": generation['humanization'].get('afterScore')
                }
            )
        
        # Extract content to humanize based on content type
        content_type = generation.get('contentType')
        output = generation.get('output', {})
        
        # Get content to humanize based on type
        if content_type == ContentType.BLOG:
            original_content = output.get('content', '')
        elif content_type == ContentType.SOCIAL_MEDIA:
            original_content = output.get('posts', [{}])[0].get('content', '') if isinstance(output.get('posts'), list) else output.get('content', '')
        elif content_type == ContentType.EMAIL:
            body = output.get('body', {})
            original_content = body.get('mainContent', '') if isinstance(body, dict) else str(body)
        elif content_type == ContentType.PRODUCT_DESCRIPTION:
            original_content = output.get('longDescription', output.get('shortDescription', ''))
        elif content_type == ContentType.AD_COPY:
            ad_copies = output.get('adCopies', [])
            original_content = ad_copies[0].get('body', '') if ad_copies else ''
        elif content_type == ContentType.VIDEO_SCRIPT:
            script_parts = output.get('script', [])
            original_content = ' '.join([part.get('content', '') for part in script_parts if isinstance(part, dict)])
        else:
            original_content = str(output)
        
        if not original_content:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "error": "no_content",
                    "message": "No content found to humanize in this generation"
                }
            )
        
        # Get humanization level from request or use default
        level = request.level if request else "balanced"
        preserve_facts = request.preserve_facts if request else True
        
        logger.info(f"Humanizing content for user {user_id}, generation {generation_id}, level: {level}")
        
        # Humanize the content
        humanization_result = await humanization_service.humanize_content(
            content=original_content,
            content_type=content_type,
            level=level,
            preserve_facts=preserve_facts
        )
        
        # Update generation document with humanization data
        humanization_data = {
            'applied': True,
            'level': level,
            'beforeScore': humanization_result['beforeScore'],
            'afterScore': humanization_result['afterScore'],
            'improvement': humanization_result['improvement'],
            'improvementPercentage': humanization_result['improvementPercentage'],
            'detectionApi': humanization_result['detectionApi'],
            'humanizationModel': humanization_result.get('humanizationModel', 'unknown'),
            'processingTime': humanization_result['processingTime'],
            'humanizedAt': datetime.utcnow().isoformat()
        }
        
        # Update the generation's humanized content based on content type
        updated_output = output.copy()
        if content_type == ContentType.BLOG:
            updated_output['humanizedContent'] = humanization_result['humanizedContent']
            # Update main content with humanized version
            updated_output['content'] = humanization_result['humanizedContent']
        elif content_type == ContentType.SOCIAL_MEDIA:
            if isinstance(updated_output.get('posts'), list) and updated_output['posts']:
                updated_output['posts'][0]['humanizedContent'] = humanization_result['humanizedContent']
        elif content_type == ContentType.EMAIL:
            if isinstance(updated_output.get('body'), dict):
                updated_output['body']['humanizedMainContent'] = humanization_result['humanizedContent']
        
        await firebase_service.update_generation(
            generation_id=generation_id,
            updates={
                'humanization': humanization_data,
                'output': updated_output,
                'updatedAt': datetime.utcnow().isoformat()
            }
        )
        
        # ==================== CRITICAL: INCREMENT STATS (REAL, NOT MOCK) ====================
        
        # Increment monthly humanization counter
        await firebase_service.increment_humanization_usage(user_id)
        logger.info(f"Incremented humanizations for user {user_id}: {humanizations_used} -> {humanizations_used + 1}")
        
        # Build response
        response = HumanizationResult(
            generationId=generation_id,
            originalContent=original_content,
            humanizedContent=humanization_result['humanizedContent'],
            beforeScore=humanization_result['beforeScore'],
            afterScore=humanization_result['afterScore'],
            improvement=humanization_result['improvement'],
            improvementPercentage=humanization_result['improvementPercentage'],
            level=level,
            detectionApi=humanization_result['detectionApi'],
            processingTime=humanization_result['processingTime'],
            tokensUsed=humanization_result['tokensUsed'],
            beforeAnalysis=humanization_result.get('beforeAnalysis', {}),
            afterAnalysis=humanization_result.get('afterAnalysis', {}),
            appliedAt=datetime.utcnow()
        )
        
        logger.info(f"Humanization complete for user {user_id}. Score improved: {humanization_result['beforeScore']} → {humanization_result['afterScore']}")
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in content humanization: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "humanization_failed",
                "message": f"Failed to humanize content: {str(e)}"
            }
        )


@router.post(
    "/detect/{generation_id}",
    summary="Detect AI content score",
    description="Check how AI-generated content appears without humanizing it"
)
async def detect_ai_content(
    generation_id: str = Path(..., description="ID of the generation to analyze"),
    current_user: Dict[str, Any] = Depends(get_current_user),
    firebase_service: FirebaseService = Depends(get_firebase_service)
) -> Dict[str, Any]:
    """
    Detect AI score without humanizing
    Useful for checking content before deciding to humanize
    """
    try:
        user_id = current_user['uid']
        
        # Get generation
        generation = await firebase_service.get_generation_by_id(generation_id)
        
        if not generation or generation.get('userId') != user_id:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={"error": "generation_not_found"}
            )
        
        # Extract content
        content_type = generation.get('contentType')
        output = generation.get('output', {})
        
        if content_type == ContentType.BLOG:
            content = output.get('content', '')
        elif content_type == ContentType.SOCIAL_MEDIA:
            posts = output.get('posts', [{}])
            content = posts[0].get('content', '') if posts else ''
        else:
            content = str(output)
        
        # Detect AI score
        detection = await humanization_service.detect_ai_content(content)
        
        return {
            "generationId": generation_id,
            "aiScore": detection['aiScore'],
            "confidence": detection['confidence'],
            "indicators": detection['indicators'],
            "reasoning": detection['reasoning'],
            "detectionApi": detection['detectionApi'],
            "recommendation": "humanize" if detection['aiScore'] > 60 else "looks_good"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error detecting AI content: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": "detection_failed", "message": str(e)}
        )


@router.get(
    "/health",
    summary="Check humanization service health"
)
async def health_check() -> Dict[str, Any]:
    """Check if humanization service is operational"""
    return {
        "status": "healthy",
        "service": "humanization",
        "features": {
            "aiDetection": "enabled",
            "contentRewriting": "enabled",
            "batchProcessing": "enabled"
        },
        "timestamp": datetime.utcnow().isoformat()
    }
