"""
User Schemas - Pydantic Models for User Data
Data validation and serialization for user-related operations

USAGE PATTERN:
    from app.schemas.user import UserCreate, UserResponse
    
    # API endpoint receives validated data
    @router.post("/register", response_model=UserResponse)
    async def register(user_data: UserCreate):
        # user_data is already validated by Pydantic
        result = await firebase_service.create_user(user_data.model_dump())
        return UserResponse(**result)
"""
from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum
from app.constants import SubscriptionPlan, SubscriptionStatus

# ==================== ENUMS ====================

class PrimaryUseCase(str, Enum):
    """User's primary use case for content generation"""
    BLOG_WRITER = "blog_writer"
    MARKETING_TEAM = "marketing_team"
    AGENCY = "agency"
    ECOMMERCE = "ecommerce"
    FREELANCER = "freelancer"
    OTHER = "other"

class TeamRole(str, Enum):
    """Team member roles"""
    OWNER = "owner"
    ADMIN = "admin"
    EDITOR = "editor"
    VIEWER = "viewer"

# ==================== INPUT SCHEMAS ====================

class UserCreate(BaseModel):
    """User registration input schema"""
    email: EmailStr
    password: str = Field(min_length=8, description="Minimum 8 characters")
    display_name: Optional[str] = Field(None, min_length=2, max_length=50)
    profile_image: Optional[str] = Field(None, description="URL to profile image")
    
    @field_validator('password')
    @classmethod
    def validate_password_strength(cls, v: str) -> str:
        """Ensure password has at least one letter and one number"""
        if not any(char.isdigit() for char in v):
            raise ValueError('Password must contain at least one number')
        if not any(char.isalpha() for char in v):
            raise ValueError('Password must contain at least one letter')
        return v
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "password": "secure123",
                "display_name": "John Doe"
            }
        }

class LoginRequest(BaseModel):
    """User login credentials"""
    email: EmailStr
    password: str = Field(min_length=8)
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "user@example.com",
                "password": "secure123"
            }
        }

class TokenResponse(BaseModel):
    """JWT token response"""
    access_token: str = Field(..., description="JWT access token (24 hours)")
    refresh_token: str = Field(..., description="JWT refresh token (30 days)")
    token_type: str = Field(default="bearer")
    user: "UserResponse" = Field(..., description="Complete user profile")
    
    class Config:
        json_schema_extra = {
            "example": {
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "token_type": "bearer",
                "user": {
                    "uid": "user123",
                    "email": "user@example.com",
                    "display_name": "John Doe"
                }
            }
        }

class RefreshTokenRequest(BaseModel):
    """Refresh token request"""
    refresh_token: str = Field(..., description="Valid refresh token")
    
    class Config:
        json_schema_extra = {
            "example": {
                "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
            }
        }

class GoogleAuthRequest(BaseModel):
    """Google OAuth authentication request"""
    id_token: str = Field(..., description="Google ID token from Firebase Auth")
    
    class Config:
        json_schema_extra = {
            "example": {
                "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjI3M..."
            }
        }

class UserUpdate(BaseModel):
    """User profile update schema"""
    display_name: Optional[str] = Field(None, min_length=2, max_length=50)
    profile_image: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "display_name": "Jane Smith",
                "profile_image": "https://example.com/image.jpg"
            }
        }

class UserSettingsUpdate(BaseModel):
    """User settings update schema"""
    default_content_type: Optional[str] = None
    default_tone: Optional[str] = None
    primary_use_case: Optional[PrimaryUseCase] = None
    auto_fact_check: Optional[bool] = None
    email_notifications: Optional[bool] = None
    theme: Optional[str] = Field(None, pattern="^(light|dark)$")

class BrandVoice(BaseModel):
    """Brand voice configuration"""
    is_configured: bool = Field(default=False, alias="isConfigured")
    tone: Optional[str] = None
    vocabulary: Optional[str] = None
    samples: List[str] = Field(default_factory=list)
    custom_parameters: Dict[str, Any] = Field(default_factory=dict, alias="customParameters")
    trained_at: Optional[datetime] = Field(None, alias="trainedAt")
    
    class Config:
        populate_by_name = True

class BrandVoiceTraining(BaseModel):
    """Input schema for brand voice training"""
    tone: str = Field(..., description="Desired brand tone (e.g., professional, casual, friendly)")
    vocabulary: str = Field(..., description="Key terms and phrases to use")
    samples: List[str] = Field(..., min_length=3, max_length=10, description="3-10 sample texts")
    custom_parameters: Optional[Dict[str, Any]] = Field(default_factory=dict)
    
    class Config:
        json_schema_extra = {
            "example": {
                "tone": "professional yet friendly",
                "vocabulary": "innovative, cutting-edge, user-centric",
                "samples": [
                    "We're excited to announce our latest feature...",
                    "Our team has been working hard to deliver...",
                    "Experience the future of productivity..."
                ],
                "custom_parameters": {
                    "industry": "tech",
                    "target_audience": "professionals"
                }
            }
        }

class OnboardingStatus(BaseModel):
    """User onboarding progress"""
    completed: bool = False
    current_step: int = Field(default=0, alias="currentStep")
    completed_at: Optional[datetime] = Field(None, alias="completedAt")
    
    class Config:
        populate_by_name = True

class TeamMember(BaseModel):
    """Team member invitation"""
    email: EmailStr
    role: TeamRole
    status: str = "pending"  # pending, accepted, declined
    invited_at: Optional[datetime] = Field(None, alias="invitedAt")
    
    class Config:
        populate_by_name = True

class TeamInfo(BaseModel):
    """Team information"""
    role: TeamRole = TeamRole.OWNER
    invited_members: List[TeamMember] = Field(default_factory=list, alias="invitedMembers")
    
    class Config:
        populate_by_name = True

class AllTimeStats(BaseModel):
    """
    All-time user statistics
    
    IMPORTANT: These are REAL calculated values, NOT mock data.
    - New users start with all values at 0
    - Values auto-increment on user actions via Firebase service
    - Never set manually in application code
    """
    total_generations: int = Field(default=0, alias="totalGenerations")
    total_humanizations: int = Field(default=0, alias="totalHumanizations")
    total_graphics: int = Field(default=0, alias="totalGraphics")
    average_quality_score: float = Field(default=0.0, alias="averageQualityScore")
    favorite_count: int = Field(default=0, alias="favoriteCount")
    
    class Config:
        populate_by_name = True

# ==================== OUTPUT SCHEMAS ====================

class SubscriptionInfo(BaseModel):
    """Subscription details embedded in user response"""
    plan: str = SubscriptionPlan.FREE
    status: str = SubscriptionStatus.ACTIVE
    current_period_start: Optional[datetime] = Field(None, alias="currentPeriodStart")
    current_period_end: Optional[datetime] = Field(None, alias="currentPeriodEnd")
    stripe_subscription_id: Optional[str] = Field(None, alias="stripeSubscriptionId")
    stripe_customer_id: Optional[str] = Field(None, alias="stripeCustomerId")
    cancelled_at: Optional[datetime] = Field(None, alias="cancelledAt")
    
    class Config:
        from_attributes = True
        populate_by_name = True

class UsageInfo(BaseModel):
    """Usage statistics embedded in user response"""
    generations: int = 0
    limit: int = Field(default=5, alias="limit")
    humanizations: int = 0
    humanizations_limit: int = Field(default=3, alias="humanizationsLimit")
    social_graphics: int = Field(default=0, alias="socialGraphics")
    social_graphics_limit: int = Field(default=5, alias="socialGraphicsLimit")
    reset_date: datetime = Field(alias="resetDate")
    percentage_used: float = Field(default=0.0, ge=0, le=100)
    
    class Config:
        from_attributes = True
        populate_by_name = True

class UserSettings(BaseModel):
    """User settings response"""
    default_content_type: Optional[str] = Field(None, alias="defaultContentType")
    default_tone: Optional[str] = Field(None, alias="defaultTone")
    default_language: Optional[str] = Field(default="english", alias="defaultLanguage")
    primary_use_case: Optional[str] = Field(None, alias="primaryUseCase")
    auto_fact_check: bool = Field(default=False, alias="autoFactCheck")
    email_notifications: bool = Field(default=True, alias="emailNotifications")
    theme: str = "light"
    
    class Config:
        populate_by_name = True

class UserResponse(BaseModel):
    """User data returned to client (excludes sensitive data)"""
    uid: str
    email: str
    display_name: str = Field(default="", alias="displayName")
    profile_image: str = Field(default="", alias="profileImage")
    created_at: datetime = Field(alias="createdAt")
    subscription: SubscriptionInfo
    usage_this_month: UsageInfo = Field(alias="usageThisMonth")
    brand_voice: BrandVoice = Field(alias="brandVoice")
    settings: UserSettings
    team: TeamInfo
    onboarding: OnboardingStatus
    all_time_stats: AllTimeStats = Field(alias="allTimeStats")
    
    class Config:
        from_attributes = True
        populate_by_name = True  # Allow both snake_case and camelCase
        json_schema_extra = {
            "example": {
                # NOTE: These are EXAMPLE values for API documentation (Swagger UI) ONLY
                # Real application data is calculated dynamically from user actions
                # New users will have stats starting at 0 and incrementing on actions
                "uid": "user123",
                "email": "user@example.com",
                "display_name": "John Doe",
                "profile_image": "https://example.com/avatar.jpg",
                "created_at": "2025-01-01T00:00:00Z",
                "subscription": {
                    "plan": "hobby",
                    "status": "active",
                    "current_period_end": "2025-02-01T00:00:00Z"
                },
                "usage_this_month": {
                    "generations": 45,  # EXAMPLE: Real value auto-increments on generation
                    "generations_limit": 100,
                    "humanizations": 10,  # EXAMPLE: Real value auto-increments on humanization
                    "humanizations_limit": 25,
                    "social_graphics": 20,  # EXAMPLE: Real value auto-increments on graphic creation
                    "social_graphics_limit": 50,
                    "reset_date": "2025-02-01T00:00:00Z",
                    "percentage_used": 45.0
                },
                "brand_voice": {
                    "is_configured": True,
                    "tone": "professional",
                    "vocabulary": "innovative, user-centric",
                    "samples": [],
                    "custom_parameters": {},
                    "trained_at": "2025-01-15T10:00:00Z"
                },
                "settings": {
                    "default_language": "en",
                    "primary_use_case": "marketing_team",
                    "auto_fact_check": True,
                    "email_notifications": True,
                    "theme": "dark"
                },
                "team": {
                    "role": "owner",
                    "invited_members": []
                },
                "onboarding": {
                    "completed": True,
                    "current_step": 6,
                    "completed_at": "2025-01-02T12:00:00Z"
                },
                "all_time_stats": {
                    # EXAMPLE values - Real values calculated from actual user activity
                    "total_generations": 450,  # Actual: Incremented on each generation
                    "total_humanizations": 120,  # Actual: Incremented on each humanization
                    "total_graphics": 200,  # Actual: Incremented on each graphic creation
                    "average_quality_score": 8.5,  # Actual: Calculated from all generation scores
                    "favorite_count": 35  # Actual: Incremented when user favorites content
                }
            }
        }

class UserListResponse(BaseModel):
    """Paginated list of users (admin only)"""
    users: list[UserResponse]
    total: int
    page: int
    page_size: int
    has_more: bool

# ==================== INTERNAL SCHEMAS ====================

class UserInDB(BaseModel):
    """Complete user document from Firestore (includes password hash)"""
    uid: str
    email: str
    password_hash: str  # Never return this to client
    display_name: str = ""
    profile_image: str = ""
    created_at: datetime
    updated_at: datetime
    subscription: dict
    usage_this_month: dict
    brand_voice: dict
    settings: dict
    team: dict
    onboarding: dict
    all_time_stats: dict
    
    class Config:
        from_attributes = True

# ==================== API REQUEST SCHEMAS ====================

class OnboardingStepUpdate(BaseModel):
    """Update onboarding step"""
    step: int = Field(..., ge=0, le=6, description="Onboarding step (0-6)")

class PrimaryUseCaseUpdate(BaseModel):
    """Set primary use case during onboarding"""
    use_case: PrimaryUseCase

class TeamInvite(BaseModel):
    """Invite team member"""
    email: EmailStr
    role: TeamRole = Field(default=TeamRole.EDITOR)
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "teammate@example.com",
                "role": "editor"
            }
        }

class AccountDeletionRequest(BaseModel):
    """Request account deletion (soft delete, scheduled for subscription end)"""
    reason: Optional[str] = Field(None, max_length=500, description="Optional reason for deletion")
    
    class Config:
        json_schema_extra = {
            "example": {
                "reason": "No longer need the service"
            }
        }

class AccountDeletionResponse(BaseModel):
    """Response for account deletion request"""
    message: str
    deletion_scheduled_for: datetime = Field(..., description="Date when account will be deleted")
    days_until_deletion: int
    cancellation_possible: bool = Field(default=True, description="Can cancel deletion before scheduled date")
    
    class Config:
        json_schema_extra = {
            "example": {
                "message": "Your account deletion has been scheduled",
                "deletion_scheduled_for": "2025-12-31T23:59:59Z",
                "days_until_deletion": 7,
                "cancellation_possible": True
            }
        }

class CancelDeletionRequest(BaseModel):
    """Cancel scheduled account deletion"""
    pass  # No password needed - user is already authenticated
