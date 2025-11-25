"""
Image Generation Router
Handles AI image generation with Flux Schnell (primary) and DALL-E 3 (premium)

COST STRUCTURE:
- Flux Schnell: $0.003/image (all tiers)
- DALL-E 3: $0.040/image (Enterprise only)

ARCHITECTURE FLOW:
    Request → Validate → Generate Image → Save to Firebase Storage → Track Stats → Response
"""
from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field
from datetime import datetime
import logging

from app.dependencies import get_current_user, get_firebase_service
from app.services.image_service import image_service
from app.services.firebase_service import FirebaseService
from app.utils.background_tasks import save_image_to_storage, save_batch_images_to_storage

router = APIRouter(prefix="/api/v1/generate/image", tags=["Image Generation"])
logger = logging.getLogger(__name__)


# ==================== REQUEST/RESPONSE SCHEMAS ====================

class ImageGenerationRequest(BaseModel):
    """Image generation request"""
    prompt: str = Field(..., min_length=3, max_length=1000, description="Image description")
    size: str = Field(default="1024x1024", description="Image size: 1024x1024, 1024x1792, 1792x1024")
    style: str = Field(default="realistic", description="Style: realistic, artistic, illustration, 3d")
    aspect_ratio: str = Field(default="1:1", description="Aspect ratio: 1:1, 16:9, 9:16, 4:3, 3:4")
    enhance_prompt: bool = Field(default=True, description="Auto-enhance prompt with quality keywords")


class MultipleImageRequest(BaseModel):
    """Generate multiple images at once"""
    prompts: List[str] = Field(..., min_items=1, max_items=10, description="List of image prompts")
    size: str = Field(default="1024x1024", description="Image size for all images")
    style: str = Field(default="realistic", description="Style for all images")
    enhance_prompts: bool = Field(default=True, description="Auto-enhance all prompts")


class ImageGenerationResponse(BaseModel):
    """Image generation response"""
    success: bool
    image_url: str
    model: str
    generation_time: float
    cost: float
    size: str
    quality: str
    prompt_used: str
    timestamp: str


class MultipleImageResponse(BaseModel):
    """Multiple image generation response"""
    success: bool
    images: List[ImageGenerationResponse]
    total_cost: float
    total_time: float
    count: int


# ==================== ENDPOINTS ====================

@router.post(
    "",
    response_model=ImageGenerationResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Generate AI image",
    description="""
    Generate high-quality images using Flux Schnell (fast, cheap) or DALL-E 3 (Enterprise only).
    
    **Pricing:**
    - Flux Schnell: $0.003/image (all tiers) - 2-3 seconds
    - DALL-E 3: $0.040/image (Enterprise only) - HD quality
    
    **Features:**
    - Automatic prompt enhancement for better quality
    - Multiple aspect ratios and styles
    - Fast generation (2-5 seconds)
    - Smart model routing based on subscription tier
    
    **Supported Sizes:**
    - 1024x1024 (square)
    - 1024x1792 (portrait)
    - 1792x1024 (landscape)
    
    **Styles:**
    - realistic: Photorealistic images
    - artistic: Painterly, expressive
    - illustration: Clean vector art style
    - 3d: 3D rendered look
    """
)
async def generate_image(
    request: ImageGenerationRequest,
    background_tasks: BackgroundTasks,
    current_user: Dict[str, Any] = Depends(get_current_user),
    firebase_service: FirebaseService = Depends(get_firebase_service)
) -> ImageGenerationResponse:
    """
    Generate single image with AI
    
    Flow:
    1. Check user has graphics quota left
    2. Enhance prompt if requested
    3. Generate image with appropriate model
    4. Save generation metadata to Firestore
    5. Return temporary image URL immediately
    6. Background: Download & upload to Firebase Storage
    7. Background: Update generation with permanent URL
    """
    try:
        user_id = current_user['uid']
        user_plan = current_user.get('subscriptionPlan', 'free')
        
        # Check graphics quota
        usage_this_month = current_user.get('usageThisMonth', {})
        graphics_used = usage_this_month.get('graphics', 0)
        graphics_limit = current_user.get('graphicsLimit', 5)
        
        if graphics_used >= graphics_limit:
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail={
                    "error": "graphics_limit_reached",
                    "message": f"Monthly graphics limit reached: {graphics_limit} images",
                    "used": graphics_used,
                    "limit": graphics_limit
                }
            )
        
        # Enhance prompt if requested
        final_prompt = request.prompt
        if request.enhance_prompt:
            final_prompt = image_service.enhance_image_prompt(
                base_prompt=request.prompt,
                style=request.style,
                quality_keywords=True
            )
            logger.debug(f"Enhanced prompt: {final_prompt[:100]}...")
        
        # Generate image
        logger.info(f"Generating image for user {user_id}: {request.prompt[:50]}...")
        
        result = await image_service.generate_image(
            prompt=final_prompt,
            size=request.size,
            style=request.style,
            user_tier=user_plan,
            aspect_ratio=request.aspect_ratio
        )
        
        # Save generation metadata to Firestore
        generation_data = {
            'userId': user_id,
            'contentType': 'image',
            'userInput': {
                'prompt': request.prompt,
                'enhancedPrompt': final_prompt,
                'size': request.size,
                'style': request.style,
                'aspectRatio': request.aspect_ratio
            },
            'output': result['image_url'],  # Temporary URL
            'imageUrl': result['image_url'],  # Will be updated with permanent URL
            'imageStorageStatus': 'pending',  # pending → uploaded
            'metadata': {
                'model': result['model'],
                'generationTime': result['generation_time'],
                'cost': result['cost'],
                'size': result['size'],
                'quality': result['quality']
            },
            'createdAt': datetime.utcnow(),
            'updatedAt': datetime.utcnow()
        }
        
        generation_id = await firebase_service.save_generation(generation_data)
        
        # Determine file extension from model
        file_extension = "png"  # Flux uses PNG, DALL-E uses PNG
        
        # Schedule background task to save image to permanent storage
        background_tasks.add_task(
            save_image_to_storage,
            image_url=result['image_url'],
            user_id=user_id,
            generation_id=generation_id,
            file_extension=file_extension
        )
        
        # Increment graphics usage
        # await firebase_service.increment_graphics_usage(user_id)
        
        logger.info(f"✅ Image generated: {result['model']} in {result['generation_time']:.2f}s")
        logger.info(f"🔄 Background task scheduled to save image for generation {generation_id}")
        
        return ImageGenerationResponse(
            success=True,
            image_url=result['image_url'],
            model=result['model'],
            generation_time=result['generation_time'],
            cost=result['cost'],
            size=result['size'],
            quality=result['quality'],
            prompt_used=final_prompt,
            timestamp=datetime.utcnow().isoformat()
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Image generation error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": "generation_failed", "message": str(e)}
        )


@router.post(
    "/batch",
    response_model=MultipleImageResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Generate multiple images",
    description="""
    Generate multiple images in parallel for efficiency.
    
    **Limits:**
    - 1-10 images per request
    - Same size/style applied to all
    - Uses available quota
    
    **Use Cases:**
    - Generate variations of same prompt
    - Create multiple assets at once
    - Batch product image generation
    """
)
async def generate_multiple_images(
    request: MultipleImageRequest,
    background_tasks: BackgroundTasks,
    current_user: Dict[str, Any] = Depends(get_current_user),
    firebase_service: FirebaseService = Depends(get_firebase_service)
) -> MultipleImageResponse:
    """
    Generate multiple images in parallel
    
    Flow:
    1. Check user has enough quota
    2. Enhance all prompts if requested
    3. Generate all images in parallel
    4. Save generation metadata to Firestore
    5. Return temporary URLs immediately
    6. Background: Download & upload all to Firebase Storage
    7. Background: Update generations with permanent URLs
    """
    try:
        user_id = current_user['uid']
        user_plan = current_user.get('subscriptionPlan', 'free')
        
        # Check if user has enough quota
        usage_this_month = current_user.get('usageThisMonth', {})
        graphics_used = usage_this_month.get('graphics', 0)
        graphics_limit = current_user.get('graphicsLimit', 5)
        
        required_quota = len(request.prompts)
        if graphics_used + required_quota > graphics_limit:
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail={
                    "error": "insufficient_quota",
                    "message": f"Need {required_quota} images, only {graphics_limit - graphics_used} available",
                    "available": graphics_limit - graphics_used,
                    "required": required_quota
                }
            )
        
        # Enhance prompts if requested
        final_prompts = request.prompts
        if request.enhance_prompts:
            final_prompts = [
                image_service.enhance_image_prompt(prompt, request.style)
                for prompt in request.prompts
            ]
        
        # Generate all images in parallel
        logger.info(f"Generating {len(final_prompts)} images for user {user_id}")
        
        results = await image_service.generate_multiple_images(
            prompts=final_prompts,
            size=request.size,
            style=request.style,
            user_tier=user_plan
        )
        
        # Calculate totals
        total_cost = sum(r['cost'] for r in results)
        total_time = max(r['generation_time'] for r in results) if results else 0
        
        # Save each generation to Firestore and collect IDs
        generation_ids = []
        for i, result in enumerate(results):
            generation_data = {
                'userId': user_id,
                'contentType': 'image',
                'userInput': {
                    'prompt': request.prompts[i],
                    'enhancedPrompt': final_prompts[i],
                    'size': request.size,
                    'style': request.style,
                    'batchIndex': i
                },
                'output': result['image_url'],
                'imageUrl': result['image_url'],
                'imageStorageStatus': 'pending',
                'metadata': {
                    'model': result['model'],
                    'generationTime': result['generation_time'],
                    'cost': result['cost'],
                    'size': result['size'],
                    'quality': result['quality']
                },
                'createdAt': datetime.utcnow(),
                'updatedAt': datetime.utcnow()
            }
            generation_id = await firebase_service.save_generation(generation_data)
            generation_ids.append(generation_id)
        
        # Schedule background task to save all images
        background_tasks.add_task(
            save_batch_images_to_storage,
            images=results,
            user_id=user_id,
            generation_ids=generation_ids,
            file_extension="png"
        )
        
        # Build response
        images = [
            ImageGenerationResponse(
                success=True,
                image_url=r['image_url'],
                model=r['model'],
                generation_time=r['generation_time'],
                cost=r['cost'],
                size=r['size'],
                quality=r['quality'],
                prompt_used=final_prompts[i],
                timestamp=datetime.utcnow().isoformat()
            )
            for i, r in enumerate(results)
        ]
        
        # TODO: Increment graphics usage by len(results)
        
        logger.info(f"✅ Generated {len(results)} images in {total_time:.2f}s (${total_cost:.4f})")
        logger.info(f"🔄 Background task scheduled to save {len(results)} images")
        
        return MultipleImageResponse(
            success=True,
            images=images,
            total_cost=total_cost,
            total_time=total_time,
            count=len(results)
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Batch image generation error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": "batch_generation_failed", "message": str(e)}
        )


@router.get(
    "/models",
    summary="Get available image generation models",
    description="Returns list of available models with pricing and capabilities"
)
async def get_available_models(
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> Dict[str, Any]:
    """Get available image generation models based on user tier"""
    user_plan = current_user.get('subscriptionPlan', 'free')
    
    models = {
        "flux-schnell": {
            "name": "Flux Schnell",
            "provider": "Replicate",
            "cost": 0.003,
            "speed": "2-3 seconds",
            "quality": "high",
            "available": True,
            "tier_required": "free"
        }
    }
    
    # Add DALL-E 3 for Enterprise
    if user_plan == "enterprise":
        models["dall-e-3"] = {
            "name": "DALL-E 3",
            "provider": "OpenAI",
            "cost": 0.040,
            "speed": "10-15 seconds",
            "quality": "premium",
            "available": True,
            "tier_required": "enterprise"
        }
    
    return {
        "models": models,
        "user_tier": user_plan,
        "default_model": "flux-schnell"
    }
