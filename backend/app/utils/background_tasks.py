"""
Background Tasks Utilities
Handle async background operations like image uploads
"""
import logging
from typing import Optional
from app.services.firebase_service import firebase_service

logger = logging.getLogger(__name__)


async def save_image_to_storage(
    image_url: str,
    user_id: str,
    generation_id: str,
    file_extension: str = "png"
) -> None:
    """
    Background task to download and save image to Firebase Storage
    
    This runs after the API response is sent to the user, ensuring:
    1. Fast API response with temporary Replicate URL
    2. Permanent storage of image in Firebase
    3. Updated generation record with permanent URL
    
    Args:
        image_url: Temporary image URL from Replicate/OpenAI
        user_id: User ID for storage organization
        generation_id: Generation ID for tracking
        file_extension: Image file extension
    """
    try:
        logger.info(f"🔄 Background task started: Saving image for generation {generation_id}")
        
        # Upload image to Firebase Storage
        permanent_url = await firebase_service.upload_image_to_storage(
            image_url=image_url,
            user_id=user_id,
            generation_id=generation_id,
            file_extension=file_extension
        )
        
        # Update generation record with permanent URL
        await firebase_service.update_generation_image_url(
            generation_id=generation_id,
            permanent_url=permanent_url
        )
        
        logger.info(f"✅ Background task completed: Image saved for generation {generation_id}")
        
    except Exception as e:
        logger.error(f"❌ Background task failed for generation {generation_id}: {e}", exc_info=True)
        # Don't raise - background task failures shouldn't crash the server
        # The temporary URL will still work for 1 hour


async def save_batch_images_to_storage(
    images: list,
    user_id: str,
    generation_ids: list,
    file_extension: str = "png"
) -> None:
    """
    Background task to save multiple images from batch generation
    
    Args:
        images: List of dicts with 'image_url' and 'generation_id'
        user_id: User ID for storage organization
        generation_ids: List of generation IDs
        file_extension: Image file extension
    """
    try:
        logger.info(f"🔄 Background task started: Saving {len(images)} images for user {user_id}")
        
        for idx, image_data in enumerate(images):
            try:
                image_url = image_data.get('image_url')
                generation_id = generation_ids[idx] if idx < len(generation_ids) else f"batch_{idx}"
                
                # Upload each image
                permanent_url = await firebase_service.upload_image_to_storage(
                    image_url=image_url,
                    user_id=user_id,
                    generation_id=generation_id,
                    file_extension=file_extension
                )
                
                # Update generation record
                await firebase_service.update_generation_image_url(
                    generation_id=generation_id,
                    permanent_url=permanent_url
                )
                
                logger.info(f"✅ Saved image {idx + 1}/{len(images)}")
                
            except Exception as e:
                logger.error(f"Failed to save image {idx + 1}: {e}")
                continue  # Continue with other images
        
        logger.info(f"✅ Background task completed: Batch images saved for user {user_id}")
        
    except Exception as e:
        logger.error(f"❌ Background batch task failed for user {user_id}: {e}", exc_info=True)
