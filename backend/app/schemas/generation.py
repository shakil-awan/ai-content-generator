"""
Generation Schemas - Pydantic Models for Content Generation
Data validation and serialization for all content generation operations

USAGE PATTERN:
    from app.schemas.generation import BlogGenerationRequest, GenerationResponse
    
    @router.post("/generate/blog", response_model=GenerationResponse)
    async def generate_blog(request: BlogGenerationRequest):
        result = await openai_service.generate_blog_post(request.model_dump())
        return GenerationResponse(**result)
"""
from pydantic import BaseModel, Field, field_validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum

# ==================== ENUMS ====================

class ContentType(str, Enum):
    """Supported content types"""
    BLOG = "blog"
    SOCIAL_MEDIA = "socialMedia"
    EMAIL = "email"
    PRODUCT_DESCRIPTION = "productDescription"
    AD_COPY = "adCopy"
    VIDEO_SCRIPT = "videoScript"

class BlogLength(str, Enum):
    """Blog post length options"""
    SHORT = "short"  # ~500 words
    MEDIUM = "medium"  # ~1000 words
    LONG = "long"  # ~2000+ words

class SocialPlatform(str, Enum):
    """Social media platforms"""
    TWITTER = "twitter"
    LINKEDIN = "linkedin"
    INSTAGRAM = "instagram"
    FACEBOOK = "facebook"
    TIKTOK = "tiktok"

class EmailCampaignType(str, Enum):
    """Email campaign types"""
    PROMOTIONAL = "promotional"
    NEWSLETTER = "newsletter"
    ABANDONED_CART = "abandoned_cart"
    WELCOME = "welcome"
    RE_ENGAGEMENT = "re_engagement"

class VideoScriptPlatform(str, Enum):
    """Video script platforms"""
    YOUTUBE = "youtube"
    TIKTOK = "tiktok"
    INSTAGRAM = "instagram"
    LINKEDIN = "linkedin"

class HumanizationLevel(str, Enum):
    """AI humanization levels"""
    LIGHT = "light"  # Minor adjustments
    BALANCED = "balanced"  # Moderate rewriting (recommended)
    DEEP = "deep"  # Extensive rewriting
    AGGRESSIVE = "aggressive"  # Maximum humanization

class Tone(str, Enum):
    """Content tone options"""
    PROFESSIONAL = "professional"
    CASUAL = "casual"
    FRIENDLY = "friendly"
    FORMAL = "formal"
    HUMOROUS = "humorous"
    INSPIRATIONAL = "inspirational"
    INFORMATIVE = "informative"

# ==================== NESTED MODELS ====================

class QualityMetrics(BaseModel):
    """AI-generated quality scores"""
    readability_score: float = Field(default=0.0, ge=0, le=10)
    originality_score: float = Field(default=0.0, ge=0, le=10)
    grammar_score: float = Field(default=0.0, ge=0, le=10)
    fact_check_score: float = Field(default=0.0, ge=0, le=10)
    ai_detection_score: float = Field(default=0.0, ge=0, le=10, description="Lower = more human-like")
    overall_score: float = Field(default=0.0, ge=0, le=10)

class FactCheckClaim(BaseModel):
    """Individual fact check claim"""
    claim: str
    verified: bool
    source: Optional[str] = None
    confidence: float = Field(ge=0, le=1)

class FactCheckResults(BaseModel):
    """Fact checking results"""
    checked: bool = False
    claims: List[FactCheckClaim] = Field(default_factory=list)
    verification_time: float = 0.0  # seconds

class HumanizationResult(BaseModel):
    """AI humanization tracking"""
    applied: bool = False
    level: Optional[HumanizationLevel] = None
    before_score: float = Field(default=0.0, ge=0, le=10)
    after_score: float = Field(default=0.0, ge=0, le=10)
    detection_api: Optional[str] = None  # Which API was used
    processing_time: float = 0.0  # seconds

class VideoScriptSettings(BaseModel):
    """Video script specific settings"""
    platform: VideoScriptPlatform
    duration: int = Field(..., ge=15, le=600, description="Video duration in seconds")
    include_hooks: bool = True
    include_cta: bool = True

# ==================== BLOG POST SCHEMAS ====================

class BlogGenerationRequest(BaseModel):
    """Blog post generation request"""
    topic: str = Field(..., min_length=3, max_length=200)
    keywords: List[str] = Field(..., min_length=1, max_length=10)
    tone: Tone = Tone.PROFESSIONAL
    length: BlogLength = BlogLength.MEDIUM
    include_seo: bool = True
    include_images: bool = False
    custom_settings: Optional[Dict[str, Any]] = Field(default_factory=dict)
    
    @field_validator('keywords')
    @classmethod
    def validate_keywords(cls, v: List[str]) -> List[str]:
        """Ensure keywords are not empty strings"""
        keywords = [kw.strip() for kw in v if kw.strip()]
        if not keywords:
            raise ValueError('At least one non-empty keyword required')
        return keywords
    
    class Config:
        json_schema_extra = {
            "example": {
                "topic": "The Future of AI in Content Marketing",
                "keywords": ["AI", "content marketing", "automation", "SEO"],
                "tone": "professional",
                "length": "medium",
                "include_seo": True,
                "include_images": False
            }
        }

# ==================== SOCIAL MEDIA SCHEMAS ====================

class SocialMediaGenerationRequest(BaseModel):
    """Social media post generation request"""
    platform: SocialPlatform
    topic: str = Field(..., min_length=3, max_length=200)
    tone: Tone = Tone.CASUAL
    include_hashtags: bool = True
    include_emojis: bool = True
    character_limit: Optional[int] = None
    custom_settings: Optional[Dict[str, Any]] = Field(default_factory=dict)
    
    class Config:
        json_schema_extra = {
            "example": {
                "platform": "twitter",
                "topic": "New product launch announcement",
                "tone": "friendly",
                "include_hashtags": True,
                "include_emojis": True
            }
        }

# ==================== EMAIL SCHEMAS ====================

class EmailGenerationRequest(BaseModel):
    """Email campaign generation request"""
    campaign_type: EmailCampaignType
    subject_line: str = Field(..., min_length=5, max_length=100)
    product_service: str = Field(..., min_length=3, max_length=200)
    tone: Tone = Tone.PROFESSIONAL
    include_personalization: bool = True
    custom_settings: Optional[Dict[str, Any]] = Field(default_factory=dict)
    
    class Config:
        json_schema_extra = {
            "example": {
                "campaign_type": "promotional",
                "subject_line": "Exclusive 20% Off - Limited Time!",
                "product_service": "Premium subscription plan",
                "tone": "friendly",
                "include_personalization": True
            }
        }

# ==================== PRODUCT DESCRIPTION SCHEMAS ====================

class ProductDescriptionRequest(BaseModel):
    """Product description generation request"""
    product_name: str = Field(..., min_length=2, max_length=100)
    category: Optional[str] = Field(None, min_length=2, max_length=100, description="Product category")
    key_features: List[str] = Field(..., min_length=1, max_length=10)
    price: Optional[float] = Field(None, gt=0, description="Product price")
    features: Optional[List[str]] = Field(None, description="Alias for key_features")
    benefits: Optional[List[str]] = Field(None, description="Product benefits")
    specifications: Optional[Dict[str, Any]] = Field(None, description="Technical specifications")
    target_audience: str = Field(..., min_length=5, max_length=200)
    tone: Tone = Tone.PROFESSIONAL
    platform: Optional[str] = Field(None, description="Target platform (e.g., Amazon, Shopify)")
    include_seo: bool = Field(default=True, description="Include SEO optimization")
    include_bullet_points: bool = True
    custom_settings: Optional[Dict[str, Any]] = Field(default_factory=dict)
    
    class Config:
        json_schema_extra = {
            "example": {
                "product_name": "SmartWatch Pro X",
                "category": "Wearable Technology",
                "key_features": ["Heart rate monitoring", "GPS tracking", "Waterproof", "7-day battery"],
                "price": 299.99,
                "benefits": ["Track your fitness goals", "Never miss a notification", "Long battery life"],
                "specifications": {"battery": "7 days", "waterproof": "IP68", "display": "1.4 inch AMOLED"},
                "target_audience": "Fitness enthusiasts and health-conscious individuals",
                "tone": "professional",
                "platform": "Amazon",
                "include_seo": True,
                "include_bullet_points": True
            }
        }

# ==================== AD COPY SCHEMAS ====================

class AdCopyRequest(BaseModel):
    """Ad copy generation request"""
    product_service: str = Field(..., min_length=3, max_length=200)
    target_audience: str = Field(..., min_length=5, max_length=200)
    unique_selling_point: str = Field(..., min_length=5, max_length=300)
    platform: Optional[str] = Field(None, description="Advertising platform (e.g., Google Ads, Facebook, LinkedIn)")
    campaign_goal: Optional[str] = Field(None, description="Campaign objective (e.g., conversions, awareness, engagement)")
    tone: Tone = Tone.PROFESSIONAL
    include_cta: bool = True
    ad_length: str = Field(default="short", pattern="^(short|medium|long)$")
    custom_settings: Optional[Dict[str, Any]] = Field(default_factory=dict)
    
    class Config:
        json_schema_extra = {
            "example": {
                "product_service": "AI-powered content generator",
                "target_audience": "Marketing teams and content creators",
                "unique_selling_point": "Generate high-quality content 10x faster",
                "platform": "Google Ads",
                "campaign_goal": "conversions",
                "tone": "professional",
                "include_cta": True,
                "ad_length": "short"
            }
        }

# ==================== VIDEO SCRIPT SCHEMAS ====================

class VideoScriptRequest(BaseModel):
    """Video script generation request"""
    topic: str = Field(..., min_length=3, max_length=200)
    platform: VideoScriptPlatform
    duration: int = Field(..., ge=15, le=600, description="Duration in seconds")
    target_audience: Optional[str] = Field(None, min_length=5, max_length=200, description="Target audience description")
    key_points: Optional[List[str]] = Field(None, max_items=10, description="Key points to cover in the script")
    cta: Optional[str] = Field(None, max_length=200, description="Call-to-action message")
    tone: Tone = Tone.FRIENDLY
    include_hooks: bool = True
    include_cta: bool = True
    custom_settings: Optional[Dict[str, Any]] = Field(default_factory=dict)
    
    class Config:
        json_schema_extra = {
            "example": {
                "topic": "5 Tips for Better Productivity",
                "platform": "youtube",
                "duration": 300,
                "target_audience": "Young professionals aged 25-35",
                "key_points": ["Morning routines", "Task prioritization", "Digital minimalism"],
                "cta": "Subscribe for more productivity tips!",
                "tone": "friendly",
                "include_hooks": True,
                "include_cta": True
            }
        }

# ==================== HUMANIZATION SCHEMAS ====================

class HumanizationRequest(BaseModel):
    """Request to humanize AI-generated content"""
    generation_id: str = Field(..., description="ID of generation to humanize")
    level: HumanizationLevel = HumanizationLevel.LIGHT
    
    class Config:
        json_schema_extra = {
            "example": {
                "generation_id": "gen_12345",
                "level": "deep"
            }
        }

# ==================== RESPONSE SCHEMAS ====================

class GenerationResponse(BaseModel):
    """Response for content generation"""
    id: str
    user_id: str
    content_type: ContentType
    content: str
    title: Optional[str] = None
    quality_metrics: QualityMetrics
    fact_check_results: FactCheckResults
    humanization: HumanizationResult
    is_content_refresh: bool = False
    original_content_id: Optional[str] = None
    video_script_settings: Optional[VideoScriptSettings] = None
    generation_time: float
    model_used: str
    exported_to: List[str] = Field(default_factory=list)
    is_favorite: bool = False
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "id": "gen_12345",
                "user_id": "user_123",
                "content_type": "blog",
                "content": "# The Future of AI...",
                "title": "The Future of AI in Content Marketing",
                "settings": {
                    "tone": "professional",
                    "language": "en",
                    "length": "medium",
                    "custom_settings": {}
                },
                "quality_metrics": {
                    "readability_score": 8.5,
                    "originality_score": 9.0,
                    "grammar_score": 9.5,
                    "fact_check_score": 8.0,
                    "ai_detection_score": 3.5,
                    "overall_score": 8.7
                },
                "fact_check_results": {
                    "checked": True,
                    "claims": [],
                    "verification_time": 2.5
                },
                "humanization": {
                    "applied": False,
                    "level": None,
                    "before_score": 0.0,
                    "after_score": 0.0,
                    "detection_api": None,
                    "processing_time": 0.0
                },
                "is_content_refresh": False,
                "original_content_id": None,
                "video_script_settings": None,
                "generation_time": 5.2,
                "model_used": "gpt-4o-mini",
                "exported_to": [],
                "is_favorite": False,
                "created_at": "2025-01-24T10:00:00Z",
                "updated_at": "2025-01-24T10:00:00Z"
            }
        }

class GenerationListResponse(BaseModel):
    """Paginated list of generations"""
    generations: List[GenerationResponse]
    total: int
    page: int
    page_size: int
    has_more: bool

class ContentRefreshRequest(BaseModel):
    """Request to refresh/update old content"""
    original_generation_id: str = Field(..., description="ID of content to refresh")
    custom_instructions: Optional[str] = Field(None, max_length=500)
    
    class Config:
        json_schema_extra = {
            "example": {
                "original_generation_id": "gen_12345",
                "custom_instructions": "Update statistics with 2025 data"
            }
        }
