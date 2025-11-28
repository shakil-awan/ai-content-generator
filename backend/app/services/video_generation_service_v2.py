"""
Video Generation Service V2 - Production Ready
Optimized for best quality video generation using Google Veo 3-Fast

IMPORTANT DURATION CONSTRAINTS:
    ⚠️ Veo-3-fast ONLY accepts: 4, 6, or 8 second clips
    - User requests for 30s, 60s, etc. are approximated
    - Example: 30s request → 5 clips of 6s = 30s total
    - Example: 60s request → 10 clips of 6s = 60s total
    - System automatically distributes into valid clip durations

RESEARCH FINDINGS:
    ✅ Google Veo 3-Fast: BEST CHOICE (Current)
        - Synchronized native audio (dialogue, SFX, ambient)
        - Superior prompt understanding
        - Realistic physics and motion
        - 720p/1080p at 24 FPS
        - 4, 6, or 8 second durations (STRICT)
        - Reference image support (up to 3 images)
        - Frame-to-frame generation
        - Scene extension capability
        - Cost: ~$0.24 per 6s clip
        - Official Google model (always on, predictable pricing)
    
    🥈 Paid Alternatives (Better Quality):
        - Veo 3 (standard): Slower but higher quality than fast version
        - MiniMax Hailuo 2.3: Great for realistic human motion, 6-10s, 768p/1080p
        - Luma Ray 2: High quality, flexible durations, expensive
        - OpenAI Sora: Advanced physics, multi-shot, requires org verification
    
    💰 Free/Cheaper Alternatives (Lower Quality):
        ⚠️ Note: Free models on Replicate are LIMITED and may have queues
        - Wan-Video 2.5: Open source, 4-10s clips, lower quality
          Model: wan-video/wan-2.5-t2v-fast
          Durations: More flexible (4-10s range)
          Cost: FREE but slower, lower quality
        - CogVideoX: Open source Chinese model, 2-6s clips
          Cost: FREE but limited availability
        
        🔍 Recommendation: Stick with Veo-3-fast for production
        - Best quality-to-cost ratio (~$0.24/clip)
        - Reliable uptime and speed
        - Native audio generation
        - Professional results
    
ARCHITECTURE:
    Script → Enhanced Prompt Builder → Veo 3.1 API → Async Polling → Video URL
    
PROMPT OPTIMIZATION:
    ✅ Camera movements (dolly in, pan, tilt, static)
    ✅ Lighting descriptions (warm, dramatic, natural)
    ✅ Audio cues (dialogue, SFX, ambient sounds)
    ✅ Scene composition and framing
    ✅ Visual style and aesthetic
    ✅ Realistic physics considerations
    
COST OPTIMIZATION:
    💰 BUDGET MODE ACTIVE:
    - Currently using Zeroscope: ~$0.06 per 3s video (CHEAP!)
    - Remaining budget: $9.98
    - TODO: Upgrade to Veo-3-fast when budget allows
    
    Future pricing (Veo-3-fast):
    - ~$0.24 per 6s video (4x more expensive but better quality)
    - Native audio generation
    - Professional results
"""
import logging
import time
import httpx
import json
from typing import Dict, Any, Optional, List
from datetime import datetime
import asyncio

from app.config import settings
from app.exceptions import AIServiceError, AITimeoutError

logger = logging.getLogger(__name__)


class VideoGenerationServiceV2:
    """Production-ready video generation service"""
    
    # ⚙️ BUDGET MODE CONFIGURATION
    # Set to False when ready to upgrade to premium model
    BUDGET_MODE = True  # 💰 Conserving $9.98 remaining credits
    
    # Budget model configuration (Zeroscope)
    BUDGET_MODEL = "anotherjesse/zeroscope-v2-xl"  # ~$0.06 per 3s video
    BUDGET_VERSION = "9f747673945c62801b13b84701c783929c0ee784e4748ec062204894dda1a351"
    
    # Premium model configuration (Veo-3-fast) - Activate when BUDGET_MODE = False
    PREMIUM_MODEL = "google/veo-3-fast"  # ~$0.24 per 6s video (4x cost, better quality)
    PREMIUM_VERSION = "368d4063e21ecf73746b8e6d27989837d97ba07b5eca43a4e5488c852e10c2ec"
    
    # Select active model based on budget mode
    CURRENT_MODEL = BUDGET_MODEL if BUDGET_MODE else PREMIUM_MODEL
    CURRENT_VERSION = BUDGET_VERSION if BUDGET_MODE else PREMIUM_VERSION
    
    # Platform-specific video configurations
    # Zeroscope: Uses frames (24 frames @ 8fps = 3s per clip)
    # TODO: When upgrading to Veo-3-fast, use [4, 6, 8] durations
    VALID_DURATIONS = [3, 6, 9]  # Zeroscope constraint (24, 48, 72 frames @ 8fps)
    
    PLATFORM_CONFIGS = {
        'youtube': {
            'aspect_ratio': '16:9',
            'resolution': '1080p',
            'fps': 24,
            'max_clip_duration': 8,  # Prefer 6-8s for quality
            'preferred_clip_duration': 6,
            'style_hints': 'cinematic, high-quality, professional',
            'camera_hints': 'smooth camera movements, varied angles'
        },
        'tiktok': {
            'aspect_ratio': '9:16',
            'resolution': '1080p',
            'fps': 24,
            'max_clip_duration': 6,  # TikTok prefers shorter clips
            'preferred_clip_duration': 6,
            'style_hints': 'vertical format, engaging, dynamic, fast-paced',
            'camera_hints': 'quick cuts, energetic camera work'
        },
        'instagram': {
            'aspect_ratio': '1:1',
            'resolution': '1080p',
            'fps': 24,
            'max_clip_duration': 6,
            'preferred_clip_duration': 6,
            'style_hints': 'aesthetic, vibrant, visually appealing',
            'camera_hints': 'smooth transitions, centered composition'
        },
        'linkedin': {
            'aspect_ratio': '16:9',
            'resolution': '1080p',
            'fps': 24,
            'max_clip_duration': 8,
            'preferred_clip_duration': 6,
            'style_hints': 'professional, clean, corporate',
            'camera_hints': 'static or slow camera movements, professional framing'
        }
    }
    
    # Video style presets
    STYLE_PRESETS = {
        'modern': {
            'visual': 'modern, clean, minimalist aesthetic with good lighting',
            'camera': 'smooth dolly shots and steady pans',
            'lighting': 'natural bright lighting with soft shadows'
        },
        'cinematic': {
            'visual': 'cinematic quality, film-like with rich colors and depth',
            'camera': 'professional camera work with dynamic angles and movements',
            'lighting': 'dramatic lighting with strong contrast and color grading'
        },
        'animated': {
            'visual': 'stylized animated look with smooth motion',
            'camera': 'animated camera movements, creative transitions',
            'lighting': 'vibrant, even lighting suitable for animation style'
        },
        'minimal': {
            'visual': 'minimalist, simple, clean aesthetic',
            'camera': 'static shots or minimal camera movement',
            'lighting': 'soft, even lighting with minimal shadows'
        },
        'documentary': {
            'visual': 'realistic, authentic documentary style',
            'camera': 'handheld camera feel with natural movements',
            'lighting': 'natural lighting, realistic color palette'
        }
    }
    
    def __init__(self):
        """Initialize video generation service with Replicate API"""
        self.api_key = settings.REPLICATE_API_KEY
        self.api_base_url = "https://api.replicate.com/v1"
        
        if not self.api_key:
            logger.error("❌ REPLICATE_API_KEY not configured")
            raise ValueError("REPLICATE_API_KEY is required for video generation")
        
        logger.info(f"💰 Video Generation Service V2 - BUDGET MODE (Zeroscope)")
        logger.info(f"📌 TODO: Upgrade to Veo-3-fast when budget allows")
    
    async def generate_video_from_script(
        self,
        script_content: str,
        visual_descriptions: List[str],
        duration: int,
        platform: str = "youtube",
        video_style: str = "modern",
        include_captions: bool = True,
        use_fast_model: bool = False,
        resolution: str = "1080p"
    ) -> Dict[str, Any]:
        """
        Generate video from script using Google Veo 3.1
        
        Args:
            script_content: Complete script text with narration
            visual_descriptions: List of scene-by-scene visual descriptions
            duration: Target video duration in seconds (will be split into clips)
            platform: Target platform (youtube, tiktok, instagram, linkedin)
            video_style: Visual style preset (modern, cinematic, animated, minimal)
            include_captions: Whether to mention captions in prompt
            use_fast_model: Use Veo 3.1 Fast for faster generation (slightly lower quality)
            resolution: Video resolution (720p or 1080p)
        
        Returns:
            {
                'video_clips': [{'url': '...', 'duration': 6, 'scene_index': 0}, ...],
                'total_duration': 60,
                'status': 'completed',
                'processing_time': 120.5,
                'cost': 1.25,
                'metadata': {...}
            }
        """
        start_time = time.time()
        # Using budget-friendly model to conserve credits
        model_name = self.CURRENT_MODEL
        model_version = self.CURRENT_VERSION
        
        logger.info(f"💰 Starting BUDGET video generation with {model_name}")
        logger.info(f"⚠️ Using cheaper model to conserve $9.98 remaining credits")
        logger.info(f"📊 Target: {duration}s {platform} video at {resolution}")
        logger.info(f"🎨 Style: {video_style}")
        logger.info(f"🎞️ Scenes to generate: {len(visual_descriptions)}")
        
        try:
            # Get platform configuration
            platform_config = self.PLATFORM_CONFIGS.get(
                platform,
                self.PLATFORM_CONFIGS['youtube']
            )
            
            # Calculate optimal clip distribution
            clips_config = self._calculate_clip_distribution(
                total_duration=duration,
                num_scenes=len(visual_descriptions),
                max_clip_duration=platform_config['max_clip_duration']
            )
            
            logger.info(f"📐 Will generate {len(clips_config)} clips: {[c['duration'] for c in clips_config]}s")
            
            # Generate video clips
            video_clips = []
            total_cost = 0.0
            
            for i, clip_config in enumerate(clips_config):
                scene_index = clip_config['scene_index']
                clip_duration = clip_config['duration']
                
                logger.info(f"🎬 Generating clip {i+1}/{len(clips_config)} (Scene {scene_index+1}, {clip_duration}s)")
                
                # Build optimized prompt for this clip
                prompt = self._build_optimized_prompt(
                    script_excerpt=self._extract_script_excerpt(script_content, scene_index),
                    visual_description=visual_descriptions[scene_index] if scene_index < len(visual_descriptions) else "",
                    clip_duration=clip_duration,
                    platform_config=platform_config,
                    video_style=video_style,
                    is_first_clip=(i == 0),
                    is_last_clip=(i == len(clips_config) - 1)
                )
                
                # Generate clip
                clip_result = await self._generate_single_clip(
                    prompt=prompt,
                    duration=clip_duration,
                    model=model_version,
                    aspect_ratio=platform_config['aspect_ratio'],
                    resolution=resolution,
                    fps=platform_config['fps']
                )
                
                video_clips.append({
                    'url': clip_result['url'],
                    'duration': clip_duration,
                    'scene_index': scene_index,
                    'prediction_id': clip_result['prediction_id'],
                    'prompt_preview': prompt[:100] + "..."
                })
                
                total_cost += clip_result['cost']
                
                logger.info(f"✅ Clip {i+1} complete: {clip_result['url'][:50]}...")
            
            processing_time = time.time() - start_time
            
            logger.info(f"🎉 Video generation complete!")
            logger.info(f"⏱️ Total time: {processing_time:.1f}s")
            logger.info(f"💰 Total cost: ${total_cost:.2f}")
            logger.info(f"🎞️ Generated {len(video_clips)} clips totaling ~{sum(c['duration'] for c in video_clips)}s")
            
            return {
                'video_clips': video_clips,
                'total_duration': sum(c['duration'] for c in video_clips),
                'status': 'completed',
                'processing_time': processing_time,
                'cost': total_cost,
                'metadata': {
                    'platform': platform,
                    'video_style': video_style,
                    'resolution': resolution,
                    'model': model_name,
                    'num_clips': len(video_clips),
                    'aspect_ratio': platform_config['aspect_ratio'],
                    'include_captions': include_captions
                }
            }
            
        except Exception as e:
            logger.error(f"❌ Video generation failed: {e}", exc_info=True)
            raise AIServiceError(f"Video generation failed: {str(e)}")
    
    async def _generate_single_clip(
        self,
        prompt: str,
        duration: int,
        model: str,
        aspect_ratio: str,
        resolution: str,
        fps: int
    ) -> Dict[str, Any]:
        """Generate a single video clip using Veo 3.1"""
        try:
            # Submit prediction to Replicate
            prediction_id = await self._create_prediction(
                model=model,
                prompt=prompt,
                duration=duration,
                aspect_ratio=aspect_ratio,
                resolution=resolution,
                fps=fps
            )
            
            logger.info(f"📤 Prediction submitted: {prediction_id}")
            
            # Poll for completion with timeout
            video_url = await self._poll_prediction(
                prediction_id=prediction_id,
                timeout=300  # 5 minutes max per clip
            )
            
            # Estimate cost
            cost = self._estimate_clip_cost(duration, resolution)
            
            return {
                'url': video_url,
                'prediction_id': prediction_id,
                'cost': cost
            }
            
        except Exception as e:
            logger.error(f"❌ Clip generation failed: {e}")
            raise
    
    async def _create_prediction(
        self,
        model: str,
        prompt: str,
        duration: int,
        aspect_ratio: str,
        resolution: str,
        fps: int
    ) -> str:
        """Create a prediction on Replicate API"""
        async with httpx.AsyncClient(timeout=30.0) as client:
            headers = {
                "Authorization": f"Token {self.api_key}",
                "Content-Type": "application/json"
            }
            
            # BUDGET MODE: Using Zeroscope (frame-based)
            # Convert duration to frames: duration * fps
            # Zeroscope uses 8 FPS, so 3s = 24 frames
            num_frames = duration * 8  # 3s = 24 frames, 6s = 48 frames
            
            # Build input parameters for Zeroscope (budget model)
            # TODO: Switch to Veo-3-fast params when upgrading
            input_params = {
                "prompt": prompt,
                "num_frames": num_frames,  # Zeroscope uses frames, not duration
                "fps": 8,  # Zeroscope fixed FPS
                "width": 576,  # Zeroscope default width
                "height": 320,  # Zeroscope default height (will be upscaled)
                "num_inference_steps": 50,  # Quality setting (default)
                "guidance_scale": 7.5  # How closely to follow prompt (default)
            }
            
            # Future params for Veo-3-fast upgrade:
            # input_params = {
            #     "prompt": prompt,
            #     "duration": duration,  # 4, 6, or 8 seconds
            #     "aspect_ratio": aspect_ratio,
            #     "resolution": resolution,
            #     "generate_audio": True
            # }
            
            payload = {
                "version": model,
                "input": input_params
            }
            
            logger.debug(f"📤 Creating prediction with params: {input_params}")
            
            response = await client.post(
                f"{self.api_base_url}/predictions",
                headers=headers,
                json=payload
            )
            
            response.raise_for_status()
            result = response.json()
            
            prediction_id = result.get('id')
            if not prediction_id:
                raise AIServiceError("No prediction ID returned from Replicate")
            
            return prediction_id
    
    async def _poll_prediction(
        self,
        prediction_id: str,
        timeout: int = 300
    ) -> str:
        """Poll for prediction completion"""
        start_time = time.time()
        check_interval = 5  # Check every 5 seconds
        
        async with httpx.AsyncClient(timeout=30.0) as client:
            headers = {
                "Authorization": f"Token {self.api_key}"
            }
            
            while (time.time() - start_time) < timeout:
                response = await client.get(
                    f"{self.api_base_url}/predictions/{prediction_id}",
                    headers=headers
                )
                response.raise_for_status()
                
                result = response.json()
                status = result.get('status')
                
                logger.debug(f"📊 Prediction status: {status}")
                
                if status == 'succeeded':
                    output = result.get('output')
                    
                    # Veo 3.1 returns video URL directly or in output field
                    if isinstance(output, str):
                        video_url = output
                    elif isinstance(output, list) and len(output) > 0:
                        video_url = output[0]
                    elif isinstance(output, dict):
                        video_url = output.get('video_url') or output.get('url')
                    else:
                        raise AIServiceError(f"Unexpected output format: {output}")
                    
                    if not video_url:
                        raise AIServiceError("No video URL in output")
                    
                    logger.info(f"✅ Video ready: {video_url[:80]}...")
                    return video_url
                
                elif status == 'failed':
                    error = result.get('error', 'Unknown error')
                    logs = result.get('logs', '')
                    logger.error(f"❌ Prediction failed: {error}")
                    logger.error(f"📋 Logs: {logs}")
                    raise AIServiceError(f"Video generation failed: {error}")
                
                elif status in ['starting', 'processing']:
                    elapsed = time.time() - start_time
                    logger.debug(f"⏳ Processing... ({elapsed:.0f}s elapsed)")
                    await asyncio.sleep(check_interval)
                
                else:
                    logger.warning(f"⚠️ Unknown status: {status}")
                    await asyncio.sleep(check_interval)
            
            raise AITimeoutError(f"Video generation timed out after {timeout}s")
    
    def _build_optimized_prompt(
        self,
        script_excerpt: str,
        visual_description: str,
        clip_duration: int,
        platform_config: Dict,
        video_style: str,
        is_first_clip: bool,
        is_last_clip: bool
    ) -> str:
        """
        Build highly optimized prompt for Veo 3.1
        
        Based on best practices:
        - Be specific about camera angles and movements
        - Describe lighting and mood
        - Mention audio elements explicitly
        - Include cinematic terminology
        - Keep physically plausible
        """
        style_preset = self.STYLE_PRESETS.get(video_style, self.STYLE_PRESETS['modern'])
        
        # Build shot type description
        shot_type = "establishing wide shot" if is_first_clip else "medium shot"
        if is_last_clip:
            shot_type = "close-up final shot"
        
        # Extract key narration from script
        narration_hint = script_excerpt[:150].strip()
        
        # Build comprehensive prompt
        prompt = f"""A {clip_duration}-second {shot_type} video clip.

Visual: {visual_description}

Style: {style_preset['visual']}, {platform_config['style_hints']}

Camera: {style_preset['camera']}, {platform_config['camera_hints']}

Lighting: {style_preset['lighting']}

Audio: Natural ambient sounds matching the scene, with voiceover narration: "{narration_hint}..."

Motion: Realistic physics, smooth natural movement, professional cinematography

Quality: {platform_config['resolution']} at {platform_config['fps']} FPS, {platform_config['aspect_ratio']} aspect ratio"""
        
        return prompt
    
    def _calculate_clip_distribution(
        self,
        total_duration: int,
        num_scenes: int,
        max_clip_duration: int
    ) -> List[Dict[str, int]]:
        """
        Calculate optimal distribution of clips
        
        Strategy:
        - Use only valid durations: 4, 6, or 8 seconds (Veo-3-fast constraint)
        - Prefer 6s clips (best quality/cost balance)
        - Distribute scenes evenly across clips
        - Total duration will be approximated to nearest valid combination
        """
        clips = []
        preferred_duration = 3  # Zeroscope optimal (24 frames @ 8fps)
        
        # Calculate ideal number of clips based on preferred duration
        num_clips = max(num_scenes, (total_duration + preferred_duration - 1) // preferred_duration)
        
        # Calculate target duration per clip
        target_duration_per_clip = total_duration / num_clips
        
        # Build clips using closest valid duration
        remaining_duration = total_duration
        
        for i in range(num_clips):
            # Determine best duration for this clip
            if i == num_clips - 1:
                # Last clip: use what's left (rounded to valid duration)
                ideal_duration = remaining_duration
            else:
                ideal_duration = target_duration_per_clip
            
            # Find closest valid duration (4, 6, or 8)
            clip_duration = min(self.VALID_DURATIONS, 
                              key=lambda x: abs(x - ideal_duration))
            
            # Don't exceed max_clip_duration constraint
            clip_duration = min(clip_duration, max_clip_duration)
            
            # Ensure we have at least one valid duration
            if clip_duration not in self.VALID_DURATIONS:
                clip_duration = 6  # Fallback to preferred
            
            remaining_duration -= clip_duration
            
            # Assign scene index (distribute scenes across clips)
            scene_index = (i * num_scenes) // num_clips
            
            clips.append({
                'duration': clip_duration,
                'scene_index': scene_index
            })
        
        return clips
    
    def _extract_script_excerpt(
        self,
        script_content: str,
        scene_index: int
    ) -> str:
        """Extract relevant script excerpt for a scene"""
        # Split script into rough sections
        sections = script_content.split('\n\n')
        
        if scene_index < len(sections):
            return sections[scene_index]
        else:
            # Return portion based on percentage through script
            total_chars = len(script_content)
            start_pos = int((scene_index / max(scene_index + 1, 1)) * total_chars)
            return script_content[start_pos:start_pos + 300]
    
    def _estimate_clip_cost(
        self,
        duration: int,
        resolution: str
    ) -> float:
        """
        Cost estimation for BUDGET MODE (Zeroscope)
        
        Current: Zeroscope - ~$0.02/second (~$0.06 per 3s clip)
        Future: Veo-3-fast - ~$0.04/second (~$0.24 per 6s clip)
        
        TODO: Update pricing when upgrading to Veo-3-fast
        """
        # Budget model: Zeroscope is ~75% cheaper than Veo
        base_cost_per_second = 0.02  # Zeroscope budget pricing
        cost = duration * base_cost_per_second
        return round(cost, 2)
    
    async def get_prediction_status(
        self,
        prediction_id: str
    ) -> Dict[str, Any]:
        """Get current status of a prediction"""
        async with httpx.AsyncClient(timeout=10.0) as client:
            headers = {
                "Authorization": f"Token {self.api_key}"
            }
            
            response = await client.get(
                f"{self.api_base_url}/predictions/{prediction_id}",
                headers=headers
            )
            response.raise_for_status()
            
            result = response.json()
            
            return {
                'id': prediction_id,
                'status': result.get('status'),
                'created_at': result.get('created_at'),
                'started_at': result.get('started_at'),
                'completed_at': result.get('completed_at'),
                'output': result.get('output'),
                'error': result.get('error'),
                'logs': result.get('logs')
            }


# Singleton instance
_video_service_v2: Optional[VideoGenerationServiceV2] = None


def get_video_generation_service_v2() -> VideoGenerationServiceV2:
    """Get or create video generation service V2 instance"""
    global _video_service_v2
    if _video_service_v2 is None:
        _video_service_v2 = VideoGenerationServiceV2()
    return _video_service_v2
