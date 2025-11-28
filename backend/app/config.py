"""
Application Configuration
Manages environment variables and settings
"""
from pydantic_settings import BaseSettings
from typing import List
import os
from pathlib import Path

class Settings(BaseSettings):
    """Application settings loaded from environment variables"""
    
    # Environment
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    
    # API Configuration
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8000
    API_PREFIX: str = "/api/v1"
    
    # CORS
    CORS_ORIGINS: List[str] = ["*"]  # TODO: Restrict in production
    
    # AI Service API Keys
    # PRIMARY: Gemini 2.5 Flash ($0.10/$0.40 per 1M tokens) - 75% cheaper than GPT-4o-mini
    # FALLBACK: GPT-4o-mini ($0.15/$0.60 per 1M tokens) - for quality backup
    # See: backend/AI_MODELS_CONFIG.md for full decision rationale
    GEMINI_API_KEY: str = ""  # PRIMARY for text generation
    OPENAI_API_KEY: str = ""  # FALLBACK only
    ANTHROPIC_API_KEY: str = ""  # Future use
    REPLICATE_API_KEY: str = ""  # For Flux Schnell image generation ($0.003/image)
    
    # Video Generation API
    VIDEO_API_PROVIDER: str = "replicate"  # Options: replicate, runpod, stabilityai
    VIDEO_API_KEY: str = ""  # Video generation API key (defaults to REPLICATE_API_KEY)
    VIDEO_API_URL: str = "https://api.replicate.com/v1/predictions"
    # VIDEO_MODEL: str = "google-deepmind/veo-2"  # Google Veo 2 (1080p, best quality, $0.10/sec)
    VIDEO_MODEL: str = "minimax/video-01"  # MiniMax Video-01 (720p, fast, $0.006/sec)
    # VIDEO_MODEL: str = "anotherjesse/zeroscope-v2-xl"  # ZeroScope (older, fallback)
    VIDEO_MAX_DURATION: int = 300  # Max video duration in seconds (5 minutes)
    
    # Model Selection - Centralized Configuration (can be overridden via .env)
    # All models upgraded to Gemini 2.5 (November 2025)
    PRIMARY_TEXT_MODEL: str = "gemini-2.5-flash"  # Primary for all text (1M tokens context)
    FALLBACK_TEXT_MODEL: str = "gpt-4o-mini"  # Fallback on errors
    PREMIUM_TEXT_MODEL: str = "gemini-2.5-pro"  # Premium/Enterprise tier (2M tokens context)
    PRIMARY_IMAGE_MODEL: str = "flux-schnell"  # black-forest-labs/flux-schnell via Replicate
    PREMIUM_IMAGE_MODEL: str = "dall-e-3"  # Enterprise tier only
    
    # Fact-Checking APIs
    WOLFRAM_ALPHA_API_KEY: str = ""
    GOOGLE_SCHOLAR_API_KEY: str = ""
    
    # Google Custom Search (for AI fact-checking)
    GOOGLE_SEARCH_API_KEY: str = ""  # 100 free queries/day, then $5/1000
    GOOGLE_SEARCH_ENGINE_ID: str = ""  # Custom Search Engine ID
    
    # Firebase Configuration
    FIREBASE_PROJECT_ID: str = ""
    FIREBASE_PRIVATE_KEY_PATH: str = ""
    FIREBASE_STORAGE_BUCKET: str = ""
    
    # Stripe Configuration
    STRIPE_SECRET_KEY: str = ""
    STRIPE_PUBLIC_KEY: str = ""  # Added: Public key for frontend
    STRIPE_WEBHOOK_SECRET: str = ""
    STRIPE_PRICE_ID_PRO: str = ""
    STRIPE_PRICE_ID_ENTERPRISE: str = ""
    
    # JWT Configuration
    JWT_SECRET_KEY: str = "your-secret-key-change-in-production"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRATION_MINUTES: int = 60 * 24  # 24 hours
    
    # Redis Configuration (for rate limiting & caching)
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_PASSWORD: str = ""  # Optional: Redis password
    REDIS_DB: int = 0
    ENABLE_CACHE: bool = True  # Master cache toggle
    
    # Rate Limiting
    RATE_LIMIT_ENABLED: bool = True
    FREE_TIER_LIMIT_HOURLY: int = 10
    FREE_TIER_LIMIT_DAILY: int = 50
    HOBBY_TIER_LIMIT_HOURLY: int = 100
    HOBBY_TIER_LIMIT_DAILY: int = 500
    PRO_TIER_LIMIT_HOURLY: int = 1000
    PRO_TIER_LIMIT_DAILY: int = 5000
    
    # Content Generation Limits
    MAX_BLOG_POST_LENGTH: int = 5000
    MAX_SOCIAL_MEDIA_LENGTH: int = 2200
    MAX_EMAIL_LENGTH: int = 1000
    MAX_PRODUCT_DESC_LENGTH: int = 500
    MAX_AD_COPY_LENGTH: int = 150
    
    # Quality Thresholds
    MIN_QUALITY_SCORE: float = 0.7
    AUTO_REGENERATE_THRESHOLD: float = 0.6  # Auto-regenerate with fallback model if below this
    
    # Caching Configuration (for cost optimization)
    ENABLE_PROMPT_CACHING: bool = True  # Gemini caching = 90% discount on cached tokens
    CACHE_TTL_SYSTEM_PROMPTS: int = 604800  # 7 days for system prompts
    CACHE_TTL_USER_PROMPTS: int = 86400  # 24 hours for user prompts
    CACHE_TTL_GENERATIONS: int = 3600  # 1 hour for generated content
    
    # Cost Tracking Configuration
    ENABLE_COST_TRACKING: bool = True  # Track AI generation costs
    COST_TRACKING_DB_COLLECTION: str = "ai_cost_tracking"  # Firestore collection
    
    # Cost per token (in USD per 1M tokens)
    # Gemini 2.0 Flash
    GEMINI_2_0_INPUT_COST: float = 0.10  # $0.10 per 1M input tokens
    GEMINI_2_0_OUTPUT_COST: float = 0.40  # $0.40 per 1M output tokens
    GEMINI_2_0_CACHED_COST: float = 0.01  # $0.01 per 1M cached tokens (90% discount)
    
    # Gemini 2.5 Flash (Premium)
    GEMINI_2_5_INPUT_COST: float = 0.15
    GEMINI_2_5_OUTPUT_COST: float = 0.60
    GEMINI_2_5_CACHED_COST: float = 0.015
    
    # GPT-4o-mini (Fallback)
    GPT4O_MINI_INPUT_COST: float = 0.15
    GPT4O_MINI_OUTPUT_COST: float = 0.60
    
    # Image Models
    FLUX_SCHNELL_COST: float = 0.003  # $0.003 per image
    DALLE3_COST: float = 0.040  # $0.040 per image (HD)
    
    # Logging
    LOG_LEVEL: str = "INFO"
    
    # Sentry (Error Monitoring)
    SENTRY_DSN: str = ""
    
    class Config:
        env_file = os.path.join(Path(__file__).parent.parent, ".env")
        case_sensitive = True

# Initialize settings
settings = Settings()


# ==================== Model Configuration Constants ====================
class ModelConfig:
    """
    Centralized model configuration - Single source of truth for all AI models
    Similar to frontend ApiEndpoints pattern for consistency
    
    Usage:
        from app.config import ModelConfig
        
        # Use in services
        model_name = ModelConfig.GEMINI_FLASH
        client = genai.Client(model=model_name)
    
    Benefits:
        - Easy to update models across entire application
        - Type-safe model references
        - Clear model hierarchy (standard vs premium)
        - Environment-based overrides via .env
    """
    
    # ==================== Text Generation Models ====================
    # Standard Models (All Tiers)
    GEMINI_FLASH: str = settings.PRIMARY_TEXT_MODEL  # "gemini-2.5-flash"
    GPT_4O_MINI: str = settings.FALLBACK_TEXT_MODEL  # "gpt-4o-mini"
    
    # Premium Models (Pro/Enterprise Only)
    GEMINI_PRO: str = settings.PREMIUM_TEXT_MODEL  # "gemini-2.5-pro"
    
    # ==================== Image Generation Models ====================
    FLUX_SCHNELL: str = settings.PRIMARY_IMAGE_MODEL  # "flux-schnell"
    DALLE_3: str = settings.PREMIUM_IMAGE_MODEL  # "dall-e-3"
    
    # ==================== Model Aliases for Specific Use Cases ====================
    # Content Generation
    BLOG_MODEL: str = GEMINI_FLASH  # Can use GEMINI_PRO for premium
    SOCIAL_MEDIA_MODEL: str = GEMINI_FLASH
    EMAIL_MODEL: str = GEMINI_FLASH
    VIDEO_SCRIPT_MODEL: str = GEMINI_FLASH  # Can use GEMINI_PRO for long videos
    
    # Quality & Analysis
    HUMANIZATION_MODEL: str = GEMINI_FLASH
    FACT_CHECK_MODEL: str = GEMINI_FLASH
    QUALITY_ANALYZER_MODEL: str = GEMINI_FLASH
    
    # ==================== Model Selection Helpers ====================
    @staticmethod
    def get_text_model(user_tier: str = "free", content_complexity: str = "standard") -> str:
        """
        Get appropriate text model based on user tier and content complexity
        
        Args:
            user_tier: User subscription tier (free, hobby, pro, enterprise)
            content_complexity: Content complexity (standard, premium)
        
        Returns:
            Model name string
        """
        # Enterprise/Pro users with complex content get premium model
        if user_tier in ["enterprise", "pro"] and content_complexity == "premium":
            return ModelConfig.GEMINI_PRO
        
        # Everyone else gets standard model
        return ModelConfig.GEMINI_FLASH
    
    @staticmethod
    def get_image_model(user_tier: str = "free") -> str:
        """
        Get appropriate image model based on user tier
        
        Args:
            user_tier: User subscription tier
        
        Returns:
            Model name string
        """
        if user_tier == "enterprise":
            return ModelConfig.DALLE_3
        
        return ModelConfig.FLUX_SCHNELL
    
    # ==================== Model Context Limits ====================
    GEMINI_FLASH_CONTEXT: int = 1_000_000  # 1M tokens
    GEMINI_PRO_CONTEXT: int = 2_000_000  # 2M tokens
    GPT_4O_MINI_CONTEXT: int = 128_000  # 128K tokens
    
    # ==================== Model Pricing (per 1M tokens) ====================
    GEMINI_FLASH_COST_INPUT: float = 0.075  # $0.075 per 1M input tokens
    GEMINI_FLASH_COST_OUTPUT: float = 0.30  # $0.30 per 1M output tokens
    GEMINI_PRO_COST_INPUT: float = 1.25  # $1.25 per 1M input tokens
    GEMINI_PRO_COST_OUTPUT: float = 5.00  # $5.00 per 1M output tokens
    FLUX_SCHNELL_COST: float = 0.003  # $0.003 per image
    DALLE_3_COST: float = 0.040  # $0.040 per image


# Validate critical settings
def validate_settings():
    """Validate that critical settings are configured"""
    required_for_production = [
        "OPENAI_API_KEY",
        "FIREBASE_PROJECT_ID",
        "STRIPE_SECRET_KEY"
    ]
    
    if settings.ENVIRONMENT == "production":
        missing = []
        for setting in required_for_production:
            if not getattr(settings, setting):
                missing.append(setting)
        
        if missing:
            raise ValueError(f"Missing required settings for production: {', '.join(missing)}")

# Run validation
if settings.ENVIRONMENT != "development":
    validate_settings()
