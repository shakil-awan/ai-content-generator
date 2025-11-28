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
            
            # Run Flux Schnell model with optimized parameters
            # go_fast=True: Uses fp8 quantization for 2-3x speed boost
            # output_format="webp": Smaller files, better compression
            # megapixels=1: ~1024px images (adjusts based on aspect ratio)
            output = self.replicate_client.run(
                self.flux_model,
                input={
                    "prompt": enhanced_prompt,
                    "aspect_ratio": aspect_ratio,
                    "output_format": "webp",
                    "output_quality": 90,  # High quality (80-100 recommended)
                    "num_inference_steps": 4,  # Optimal for Schnell
                    "go_fast": True,  # Enable fp8 optimization
                    "megapixels": "1",  # ~1024px (1MP) - must be string
                    "num_outputs": 1  # Single image
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
        user_tier: Optional[str] = None,
        aspect_ratio: str = "1:1"
    ) -> List[Dict[str, Any]]:
        """
        Generate multiple images efficiently using Flux Schnell's num_outputs
        
        OPTIMIZATION: Flux Schnell supports num_outputs (1-4 per call)
        - For 1-4 images: Single API call
        - For 5+ images: Batch into groups of 4
        
        Args:
            prompts: List of image descriptions (or variations of same prompt)
            size: Image dimensions
            style: Image style
            user_tier: User subscription tier
            aspect_ratio: Aspect ratio for all images
        
        Returns:
            List of image result dictionaries
        """
        use_premium = self._should_use_premium_model(user_tier)
        
        # For DALL-E (no num_outputs support), generate sequentially
        if use_premium:
            tasks = [
                self.generate_image(prompt, size, style, user_tier, aspect_ratio)
                for prompt in prompts
            ]
            results = await asyncio.gather(*tasks, return_exceptions=True)
        else:
            # For Flux Schnell, optimize with num_outputs
            results = await self._generate_batch_with_flux(
                prompts, aspect_ratio, style
            )
        
        # Filter out exceptions and log errors
        valid_results = []
        for i, result in enumerate(results):
            if isinstance(result, Exception):
                logger.error(f"Failed to generate image {i+1}: {result}")
            else:
                valid_results.append(result)
        
        return valid_results
    
    async def _generate_batch_with_flux(
        self,
        prompts: List[str],
        aspect_ratio: str = "1:1",
        style: str = "realistic"
    ) -> List[Dict[str, Any]]:
        """
        Generate multiple images efficiently using Flux num_outputs parameter
        Batches prompts into groups of 4 (max num_outputs)
        
        Rate Limit Handling:
        - With <$5 credit: 6 requests/min with burst of 1
        - Implements 12 second delay between requests (60s / 5 requests = 12s)
        - Retries on 429 errors with exponential backoff
        
        Args:
            prompts: List of prompts
            aspect_ratio: Aspect ratio
            style: Image style
        
        Returns:
            List of image results
        """
        import time
        import asyncio
        
        # Enhance all prompts
        style_prompts = {
            "realistic": "photorealistic, high detail, professional photography",
            "artistic": "artistic, painterly, expressive, creative",
            "illustration": "digital illustration, vector art, clean lines",
            "3d": "3D render, octane render, detailed textures, professional lighting"
        }
        style_suffix = style_prompts.get(style, "")
        
        enhanced_prompts = [f"{p}, {style_suffix}" for p in prompts]
        
        # For single prompt, generate multiple variations
        if len(prompts) == 1 and len(enhanced_prompts) > 0:
            # User wants variations of same prompt
            num_variations = min(len(prompts), 4)
            logger.info(f"Generating {num_variations} variations of single prompt")
            
            start_time = time.time()
            output = await self._run_with_retry(
                prompt=enhanced_prompts[0],
                aspect_ratio=aspect_ratio,
                num_outputs=num_variations
            )
            generation_time = time.time() - start_time
            
            # Parse multiple outputs
            image_urls = output if isinstance(output, list) else [output]
            
            return [
                {
                    'image_url': str(url),
                    'model': 'flux-schnell',
                    'generation_time': generation_time / len(image_urls),
                    'cost': 0.003,
                    'size': f"~1024px ({aspect_ratio})",
                    'quality': 'high'
                }
                for url in image_urls
            ]
        
        # For multiple different prompts, generate with rate limiting
        # Rate limit: 6 req/min = 1 req per 10 seconds, use 12s to be safe
        DELAY_BETWEEN_REQUESTS = 12  # seconds
        
        results = []
        for i, prompt in enumerate(enhanced_prompts):
            try:
                # Add delay before each request (except the first)
                if i > 0:
                    logger.info(f"⏳ Waiting {DELAY_BETWEEN_REQUESTS}s before next request (rate limit protection)...")
                    await asyncio.sleep(DELAY_BETWEEN_REQUESTS)
                
                start_time = time.time()
                logger.info(f"Generating image {i+1}/{len(enhanced_prompts)}: {prompt[:50]}...")
                
                output = await self._run_with_retry(
                    prompt=prompt,
                    aspect_ratio=aspect_ratio,
                    num_outputs=1
                )
                
                generation_time = time.time() - start_time
                image_url = output[0] if isinstance(output, list) else output
                
                results.append({
                    'image_url': str(image_url),
                    'model': 'flux-schnell',
                    'generation_time': generation_time,
                    'cost': 0.003,
                    'size': f"~1024px ({aspect_ratio})",
                    'quality': 'high'
                })
                logger.info(f"✅ Image {i+1}/{len(enhanced_prompts)} generated successfully")
                
            except Exception as e:
                logger.error(f"Failed to generate image for prompt '{prompt[:50]}': {e}")
                results.append(e)
        
        return results
    
    async def _run_with_retry(
        self,
        prompt: str,
        aspect_ratio: str,
        num_outputs: int,
        max_retries: int = 3
    ):
        """
        Run Flux model with retry logic for rate limit errors
        
        Args:
            prompt: Enhanced prompt
            aspect_ratio: Image aspect ratio
            num_outputs: Number of images to generate
            max_retries: Maximum retry attempts
        
        Returns:
            Generated image URL(s)
        """
        import asyncio
        import time
        from replicate.exceptions import ReplicateError
        
        for attempt in range(max_retries):
            try:
                output = self.replicate_client.run(
                    self.flux_model,
                    input={
                        "prompt": prompt,
                        "aspect_ratio": aspect_ratio,
                        "output_format": "webp",
                        "output_quality": 90,
                        "num_inference_steps": 4,
                        "go_fast": True,
                        "megapixels": "1",
                        "num_outputs": num_outputs
                    }
                )
                return output
                
            except ReplicateError as e:
                # Check if it's a rate limit error (429)
                if hasattr(e, 'status') and e.status == 429:
                    if attempt < max_retries - 1:
                        # Extract wait time from error message if available
                        wait_time = 15  # Default 15 seconds
                        if 'resets in' in str(e.detail):
                            # Try to extract wait time from error message
                            import re
                            match = re.search(r'resets in ~?(\d+)s', str(e.detail))
                            if match:
                                wait_time = int(match.group(1)) + 2  # Add 2s buffer
                        
                        logger.warning(f"⚠️ Rate limited (429), waiting {wait_time}s before retry {attempt + 2}/{max_retries}...")
                        await asyncio.sleep(wait_time)
                        continue
                    else:
                        logger.error(f"❌ Rate limit exceeded after {max_retries} attempts")
                        raise
                else:
                    # Non-rate-limit error, don't retry
                    raise
            except Exception as e:
                # Other errors, don't retry
                raise
        
        raise Exception(f"Failed to generate image after {max_retries} attempts")
    
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
