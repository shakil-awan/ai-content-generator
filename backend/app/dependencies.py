"""
Shared Dependencies
Dependency injection for FastAPI endpoints
"""
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional, Annotated
import jwt

from app.config import settings
from app.services.firebase_service import FirebaseService
from app.services.auth_service import AuthService
from app.services.openai_service import OpenAIService
from app.services.humanization_service import HumanizationService
from app.services.stripe_service import StripeService
from app.services.video_generation_service import VideoGenerationService

# Singleton instances
_firebase_service: Optional[FirebaseService] = None
_auth_service: Optional[AuthService] = None
_openai_service: Optional[OpenAIService] = None
_humanization_service: Optional[HumanizationService] = None
_stripe_service: Optional[StripeService] = None
_video_service: Optional[VideoGenerationService] = None

def get_firebase_service() -> FirebaseService:
    """
    Get or create Firebase service instance (singleton pattern).
    Used as dependency injection in API endpoints.
    
    Returns:
        FirebaseService: Initialized Firebase service
    """
    global _firebase_service
    if _firebase_service is None:
        _firebase_service = FirebaseService()
    return _firebase_service

def get_auth_service() -> AuthService:
    """
    Get or create Auth service instance (singleton pattern).
    Handles password hashing and JWT token management.
    
    Returns:
        AuthService: Initialized auth service
    """
    global _auth_service
    if _auth_service is None:
        _auth_service = AuthService()
    return _auth_service

def get_openai_service() -> OpenAIService:
    """
    Get or create OpenAI service instance (singleton pattern).
    Handles AI content generation with OpenAI/Gemini.
    
    Returns:
        OpenAIService: Initialized OpenAI service
    """
    global _openai_service
    if _openai_service is None:
        _openai_service = OpenAIService()
    return _openai_service

def get_humanization_service() -> HumanizationService:
    """
    Get or create Humanization service instance (singleton pattern).
    Handles AI content detection and humanization.
    
    Returns:
        HumanizationService: Initialized humanization service
    """
    global _humanization_service
    if _humanization_service is None:
        _humanization_service = HumanizationService()
    return _humanization_service

def get_stripe_service() -> StripeService:
    """
    Get or create Stripe service instance (singleton pattern).
    Handles payment and subscription management.
    
    Returns:
        StripeService: Initialized Stripe service
    """
    global _stripe_service
    if _stripe_service is None:
        _stripe_service = StripeService()
    return _stripe_service

def get_video_generation_service() -> VideoGenerationService:
    """
    Get or create Video Generation service instance (singleton pattern).
    Handles video generation from scripts using Replicate API.
    
    Returns:
        VideoGenerationService: Initialized video generation service
    """
    global _video_service
    if _video_service is None:
        _video_service = VideoGenerationService()
    return _video_service

# HTTP Bearer token security
security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    firebase_service: FirebaseService = Depends(get_firebase_service)
) -> dict:
    """
    Validate JWT token and return FULL current user from database
    Used as dependency in protected endpoints
    
    Returns complete user document with REAL stats (not mock)
    """
    import logging
    logger = logging.getLogger(__name__)
    
    token = credentials.credentials
    logger.info(f"🔐 Authenticating request with token: {token[:20]}...")
    
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM]
        )
        user_id = payload.get("user_id")
        logger.info(f"📝 JWT decoded successfully. user_id from token: {user_id}")
        
        if not user_id:
            logger.error("❌ No user_id found in JWT payload")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication credentials"
            )
        
        # Fetch full user from database (includes REAL stats)
        logger.info(f"📥 Fetching user from database: {user_id}")
        user = await firebase_service.get_user(user_id)
        if not user:
            logger.error(f"❌ User not found in database: {user_id}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found"
            )
        
        logger.info(f"✅ User authenticated: uid={user.get('uid')}, email={user.get('email')}")
        
        return user
    
    except jwt.ExpiredSignatureError as e:
        logger.error(f"❌ JWT token expired: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired"
        )
    except jwt.InvalidTokenError as e:
        logger.error(f"❌ Invalid JWT token: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )
    except HTTPException:
        # Re-raise HTTPExceptions as-is
        raise
    except Exception as e:
        logger.error(f"❌ Unexpected authentication error: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Authentication error: {str(e)}"
        )

async def get_optional_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(HTTPBearer(auto_error=False))
) -> Optional[dict]:
    """
    Optional authentication - returns None if no token provided
    Used for endpoints that work with or without authentication
    """
    if not credentials:
        return None
    
    return await get_current_user(credentials)
