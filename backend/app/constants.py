"""
Application Constants
Centralized configuration for Firestore collections, limits, and app-wide constants
"""

# ==================== FIRESTORE COLLECTIONS ====================
class Collections:
    """Firestore collection names"""
    USERS = "users"
    GENERATIONS = "generations"
    FACT_CHECK_CACHE = "factCheckCache"
    SUBSCRIPTIONS = "subscriptions"
    API_KEYS = "apiKeys"
    AUDIT_LOGS = "auditLogs"

# ==================== SUBSCRIPTION PLANS ====================
class SubscriptionPlan:
    """Subscription tier names"""
    FREE = "free"
    HOBBY = "hobby"
    PRO = "pro"
    ENTERPRISE = "enterprise"

class SubscriptionStatus:
    """Subscription status values"""
    ACTIVE = "active"
    CANCELLED = "cancelled"
    EXPIRED = "expired"
    PAST_DUE = "past_due"
    TRIALING = "trialing"

# ==================== USAGE LIMITS ====================
class UsageLimits:
    """Monthly generation limits per plan"""
    # Content generation limits
    FREE_GENERATIONS = 5
    HOBBY_GENERATIONS = 100
    PRO_GENERATIONS = 1000
    ENTERPRISE_GENERATIONS = 10000
    
    # AI Humanization limits
    FREE_HUMANIZATIONS = 3
    HOBBY_HUMANIZATIONS = 25
    PRO_HUMANIZATIONS = 999999  # Unlimited (represented as large number)
    ENTERPRISE_HUMANIZATIONS = 999999
    
    # Social media graphics limits
    FREE_GRAPHICS = 5
    HOBBY_GRAPHICS = 50
    PRO_GRAPHICS = 999999  # Unlimited
    ENTERPRISE_GRAPHICS = 999999
    
    # Hourly rate limits (for Redis)
    FREE_HOURLY = 10
    HOBBY_HOURLY = 100
    PRO_HOURLY = 1000
    ENTERPRISE_HOURLY = 5000
    
    # Daily rate limits
    FREE_DAILY = 50
    HOBBY_DAILY = 500
    PRO_DAILY = 5000
    ENTERPRISE_DAILY = 50000

# ==================== CONTENT TYPES ====================
class ContentType:
    """Available content generation types"""
    BLOG = "blog"
    SOCIAL_MEDIA = "socialMedia"
    EMAIL = "email"
    PRODUCT_DESCRIPTION = "productDescription"
    AD_COPY = "adCopy"
    VIDEO_SCRIPT = "videoScript"

# ==================== SOCIAL MEDIA PLATFORMS ====================
class SocialPlatform:
    """Supported social media platforms"""
    LINKEDIN = "linkedin"
    TWITTER = "twitter"
    INSTAGRAM = "instagram"
    TIKTOK = "tiktok"
    FACEBOOK = "facebook"

# ==================== EMAIL CAMPAIGN TYPES ====================
class EmailCampaignType:
    """Email campaign categories"""
    NEWSLETTER = "newsletter"
    PROMOTIONAL = "promotional"
    ANNOUNCEMENT = "announcement"
    NURTURE = "nurture"
    REENGAGEMENT = "reengagement"
    ABANDONED_CART = "abandoned_cart"
    WELCOME = "welcome"

# ==================== VIDEO SCRIPT PLATFORMS ====================
class VideoScriptPlatform:
    """Video script target platforms"""
    YOUTUBE = "youtube"
    TIKTOK = "tiktok"
    INSTAGRAM = "instagram"
    LINKEDIN = "linkedin"

# ==================== HUMANIZATION LEVELS ====================
class HumanizationLevel:
    """AI content humanization levels"""
    LIGHT = "light"  # Minor adjustments, faster
    DEEP = "deep"  # Extensive rewriting, more human-like

# ==================== PRIMARY USE CASES ====================
class PrimaryUseCase:
    """User's primary use case for content generation"""
    BLOG_WRITER = "blog_writer"
    MARKETING_TEAM = "marketing_team"
    AGENCY = "agency"
    ECOMMERCE = "ecommerce"
    FREELANCER = "freelancer"
    OTHER = "other"

# ==================== SUPPORTED LANGUAGES ====================
class Language:
    """Supported content generation languages"""
    ENGLISH = "en"
    SPANISH = "es"
    FRENCH = "fr"
    GERMAN = "de"
    ITALIAN = "it"
    PORTUGUESE = "pt"
    DUTCH = "nl"
    JAPANESE = "ja"
    CHINESE = "zh"

# ==================== QUALITY THRESHOLDS ====================
class QualityThresholds:
    """Content quality score thresholds"""
    EXCELLENT = 90
    GOOD = 75
    ACCEPTABLE = 60
    POOR = 40
    UNUSABLE = 0

# ==================== FACT CHECK CONFIDENCE ====================
class FactCheckConfidence:
    """Fact-checking confidence levels"""
    HIGH = 95  # Green flag
    MEDIUM = 60  # Yellow flag
    LOW = 0  # Red flag

# ==================== USER ROLES ====================
class UserRole:
    """User roles for team management"""
    OWNER = "owner"
    ADMIN = "admin"
    EDITOR = "editor"
    VIEWER = "viewer"

# ==================== HTTP STATUS CODES ====================
class StatusCode:
    """Common HTTP status codes"""
    OK = 200
    CREATED = 201
    BAD_REQUEST = 400
    UNAUTHORIZED = 401
    FORBIDDEN = 403
    NOT_FOUND = 404
    TOO_MANY_REQUESTS = 429
    INTERNAL_ERROR = 500

# ==================== ERROR MESSAGES ====================
class ErrorMessage:
    """Standardized error messages"""
    UNAUTHORIZED = "Authentication required"
    FORBIDDEN = "You don't have permission to access this resource"
    NOT_FOUND = "Resource not found"
    RATE_LIMIT_EXCEEDED = "Rate limit exceeded. Please upgrade your plan or try again later."
    USAGE_LIMIT_EXCEEDED = "Monthly generation limit reached. Please upgrade your plan."
    INVALID_INPUT = "Invalid input data"
    INTERNAL_ERROR = "An internal error occurred. Please try again later."
    PAYMENT_FAILED = "Payment processing failed"
    SUBSCRIPTION_EXPIRED = "Your subscription has expired"

# ==================== SUCCESS MESSAGES ====================
class SuccessMessage:
    """Standardized success messages"""
    USER_CREATED = "User account created successfully"
    LOGIN_SUCCESS = "Login successful"
    GENERATION_COMPLETE = "Content generated successfully"
    SUBSCRIPTION_CREATED = "Subscription created successfully"
    SUBSCRIPTION_CANCELLED = "Subscription cancelled successfully"
    PROFILE_UPDATED = "Profile updated successfully"

# ==================== AI MODEL NAMES ====================
class AIModel:
    """AI model identifiers"""
    GPT4O_MINI = "gpt-4o-mini"
    GPT4O = "gpt-4o"
    GEMINI_2_5_FLASH = "gemini-2.5-flash"
    GEMINI_2_5_PRO = "gemini-2.5-pro"
    CLAUDE_3_SONNET = "claude-3-sonnet"

# ==================== CACHE DURATIONS (seconds) ====================
class CacheDuration:
    """Redis cache TTL values"""
    ONE_MINUTE = 60
    FIVE_MINUTES = 300
    ONE_HOUR = 3600
    ONE_DAY = 86400
    ONE_WEEK = 604800
    ONE_MONTH = 2592000

# ==================== FILE SIZE LIMITS ====================
class FileSizeLimit:
    """Maximum file sizes in bytes"""
    PROFILE_IMAGE = 5 * 1024 * 1024  # 5MB
    DOCUMENT_UPLOAD = 10 * 1024 * 1024  # 10MB
    BRAND_VOICE_SAMPLE = 1 * 1024 * 1024  # 1MB

# ==================== REGEX PATTERNS ====================
class RegexPattern:
    """Common regex patterns for validation"""
    EMAIL = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    PASSWORD = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$'  # Min 8 chars, 1 letter, 1 number
    URL = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    PHONE = r'^\+?1?\d{9,15}$'
