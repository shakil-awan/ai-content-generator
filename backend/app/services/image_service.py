"""
Image Generation Service
PRIMARY: Replicate Flux Schnell ($0.003/image, 2-3 seconds)
PREMIUM: OpenAI DALL-E 3 ($0.040/image, Enterprise only)

Cost Comparison:
- Flux Schnell: $0.003/image (93% cheaper, 8.5/10 quality)
- DALL-E 3: $0.040/image (Premium quality, Enterprise tier only)

See backend/AI_MODELS_CONFIG.md for full analysis
Updated: November 25, 2025
"""
from typing import Dict, Any, Optional, List
import replicate
from openai import AsyncOpenAI
from app.config import settings
import logging
import asyncio

logger = logging.getLogger(__name__)


class ImageGenerationService:
    """
    Image Generation Service
    PRIMARY: Flux Schnell (fast, cost-effective)
    PREMIUM: DALL-E 3 (Enterprise tier, highest quality)
    """
    _instance: Optional['ImageGenerationService'] = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        # PRIMARY: Replicate Flux Schnell - Fast and cheap
        self.replicate_client = replicate.Client(api_token=settings.REPLICATE_API_KEY)
        self.flux_model = "black-forest-labs/flux-schnell"
        
        # PREMIUM: OpenAI DALL-E 3 - Enterprise only
        self.openai_client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
        self.dalle_model = "dall-e-3"
        
        self.use_premium = False
    
    def _should_use_premium_model(self, user_tier: Optional[str] = None) -> bool:
        """
        Determine if premium DALL-E 3 should be used
        
        Args:
            user_tier: User's subscription tier (free/hobby/pro/enterprise)
        
        Returns:
            bool: True if DALL-E 3 should be used (Enterprise only)
        """
        from app.constants import SubscriptionPlan
        
        # Only Enterprise tier gets DALL-E 3
        return user_tier == SubscriptionPlan.ENTERPRISE
    
    async def generate_image(
        self,
        prompt: str,
        size: str = "1024x1024",
        style: str = "realistic",
        user_tier: Optional[str] = None,
        aspect_ratio: str = "1:1"
    ) -> Dict[str, Any]:
        """
        Generate image with smart model routing
        
        Args:
            prompt: Image description
            size: Image dimensions (1024x1024, 1024x1792, 1792x1024)
            style: Image style (realistic, artistic, illustration, 3d)
            user_tier: User subscription tier
            aspect_ratio: Aspect ratio (1:1, 16:9, 9:16, 4:3, 3:4)
        
        Returns:
            Dict with image_url, model_used, generation_time, cost
        """
        use_premium = self._should_use_premium_model(user_tier)
        
        # Map size to Flux aspect ratios
        aspect_map = {
            "1024x1024": "1:1",
            "1024x1792": "9:16",
            "1792x1024": "16:9",
            "1024x1365": "3:4",
            "1365x1024": "4:3"
        }
        
        flux_aspect_ratio = aspect_map.get(size, aspect_ratio)
        
        if use_premium:
            return await self._generate_with_dalle(prompt, size, style)
        else:
            return await self._generate_with_flux(prompt, flux_aspect_ratio, style)
    
    async def _generate_with_flux(
        self,
        prompt: str,
        aspect_ratio: str = "1:1",
        style: str = "realistic"
    ) -> Dict[str, Any]:
        """
        Generate image with Flux Schnell (fast, cheap)
        
        Args:
            prompt: Image description
            aspect_ratio: 1:1, 16:9, 9:16, 4:3, 3:4
            style: realistic, artistic, illustration, 3d
        
        Returns:
            Dict with image details
        """
        try:
            import time
            start_time = time.time()
            
            # Enhance prompt based on style
            style_prompts = {
                "realistic": "photorealistic, high detail, professional photography",
                "artistic": "artistic, painterly, expressive, creative",
                "illustration": "digital illustration, vector art, clean lines",
                "3d": "3D render, octane render, detailed textures, professional lighting"
            }
            
            enhanced_prompt = f"{prompt}, {style_prompts.get(style, '')}"
            
            logger.info(f"Generating image with Flux Schnell: {prompt[:50]}...")
            
            # Run Flux Schnell model
            output = self.replicate_client.run(
                self.flux_model,
                input={
                    "prompt": enhanced_prompt,
                    "aspect_ratio": aspect_ratio,
                    "output_format": "png",
                    "output_quality": 90,
                    "num_inference_steps": 4  # Fast generation (default for Schnell)
                }
            )
            
            generation_time = time.time() - start_time
            
            # Extract image URL from output
            if isinstance(output, list) and len(output) > 0:
                image_url = str(output[0])
            else:
                image_url = str(output)
            
            logger.info(f"✅ Generated with Flux Schnell in {generation_time:.2f}s")
            
            return {
                'image_url': image_url,
                'model': 'flux-schnell',
                'generation_time': generation_time,
                'cost': 0.003,  # $0.003 per image
                'size': f"~1024px ({aspect_ratio})",
                'quality': 'high'
            }
            
        except Exception as e:
            logger.error(f"❌ Flux Schnell error: {e}")
            # Don't fallback to DALL-E automatically (too expensive)
            raise Exception(f"Image generation failed: {e}")
    
    async def _generate_with_dalle(
        self,
        prompt: str,
        size: str = "1024x1024",
        style: str = "realistic"
    ) -> Dict[str, Any]:
        """
        Generate image with DALL-E 3 (Enterprise only)
        
        Args:
            prompt: Image description
            size: 1024x1024, 1024x1792, 1792x1024
            style: natural (realistic) or vivid (artistic)
        
        Returns:
            Dict with image details
        """
        try:
            import time
            start_time = time.time()
            
            # Map style to DALL-E style parameter
            dalle_style = "vivid" if style in ["artistic", "3d"] else "natural"
            
            logger.info(f"Generating image with DALL-E 3: {prompt[:50]}...")
            
            response = await self.openai_client.images.generate(
                model=self.dalle_model,
                prompt=prompt,
                size=size,
                quality="hd",  # Enterprise gets HD quality
                style=dalle_style,
                n=1
            )
            
            generation_time = time.time() - start_time
            image_url = response.data[0].url
            
            logger.info(f"✅ Generated with DALL-E 3 in {generation_time:.2f}s")
            
            return {
                'image_url': image_url,
                'model': 'dall-e-3',
                'generation_time': generation_time,
                'cost': 0.040,  # $0.040 per HD image
                'size': size,
                'quality': 'hd'
            }
            
        except Exception as e:
            logger.error(f"❌ DALL-E 3 error: {e}")
            raise Exception(f"Premium image generation failed: {e}")
    
    async def generate_multiple_images(
        self,
        prompts: List[str],
        size: str = "1024x1024",
        style: str = "realistic",
        user_tier: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Generate multiple images in parallel
        
        Args:
            prompts: List of image descriptions
            size: Image dimensions
            style: Image style
            user_tier: User subscription tier
        
        Returns:
            List of image result dictionaries
        """
        tasks = [
            self.generate_image(prompt, size, style, user_tier)
            for prompt in prompts
        ]
        
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Filter out exceptions and log errors
        valid_results = []
        for i, result in enumerate(results):
            if isinstance(result, Exception):
                logger.error(f"Failed to generate image {i+1}: {result}")
            else:
                valid_results.append(result)
        
        return valid_results
    
    def enhance_image_prompt(
        self,
        base_prompt: str,
        style: str = "realistic",
        quality_keywords: bool = True
    ) -> str:
        """
        Enhance image prompt with quality keywords for better results
        
        Args:
            base_prompt: User's basic prompt
            style: Desired style
            quality_keywords: Add quality-enhancing keywords
        
        Returns:
            Enhanced prompt string
        """
        quality_keywords_map = {
            "realistic": "photorealistic, highly detailed, professional photography, 4k, sharp focus",
            "artistic": "artistic masterpiece, expressive brushstrokes, vibrant colors, creative composition",
            "illustration": "professional illustration, clean vector art, perfect lines, modern design",
            "3d": "3D rendered, octane render, cinema4d, detailed textures, professional lighting, subsurface scattering"
        }
        
        if quality_keywords:
            enhancement = quality_keywords_map.get(style, "high quality, detailed")
            return f"{base_prompt}, {enhancement}"
        
        return base_prompt


# Singleton instance
image_service = ImageGenerationService()
