"""
Authentication Router (Controller)
Handles user registration, login, and token management

ARCHITECTURE FLOW:
Client → Router (validates with Model) → Service (business logic) → Database

ENDPOINTS:
- POST /api/v1/auth/register - User registration
- POST /api/v1/auth/login - User login
- POST /api/v1/auth/refresh - Refresh access token
- POST /api/v1/auth/logout - Logout user
"""
from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Annotated
import logging

from app.schemas.user import UserCreate, UserResponse, LoginRequest, TokenResponse, RefreshTokenRequest, GoogleAuthRequest
from app.services.firebase_service import FirebaseService
from app.services.auth_service import AuthService
from app.dependencies import get_firebase_service, get_auth_service
from app.constants import ErrorMessage, SuccessMessage

# Setup
router = APIRouter(prefix="/api/v1/auth", tags=["Authentication"])
security = HTTPBearer()
logger = logging.getLogger(__name__)

# ==================== REGISTRATION ====================

@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register new user",
    description="""
    Create a new user account with complete profile initialization.
    
    **What happens on registration:**
    1. Validates email and password strength
    2. Creates Firebase Auth user
    3. Creates Firestore user document with:
       - Free plan subscription
       - Usage limits (5 generations, 3 humanizations, 5 graphics)
       - All stats initialized to 0 (NOT mock data)
       - Default settings (English, light theme)
       - Onboarding at step 0
    
    **Real Stats Initialization:**
    - totalGenerations: 0 → Increments on each content generation
    - totalHumanizations: 0 → Increments on AI humanization
    - totalGraphics: 0 → Increments on social graphic creation
    - averageQualityScore: 0.0 → Calculated from generation scores
    - favoriteCount: 0 → Increments when user favorites content
    
    **Returns:** Complete user profile with initialized data
    """
)
async def register(
    user_data: UserCreate,
    firebase_service: Annotated[FirebaseService, Depends(get_firebase_service)],
    auth_service: Annotated[AuthService, Depends(get_auth_service)]
) -> UserResponse:
    """
    Register new user with complete profile initialization.
    
    Args:
        user_data: User registration data (email, password, display_name)
        firebase_service: Firebase service dependency
        auth_service: Auth service dependency
        
    Returns:
        UserResponse: Complete user profile with real stats (all starting at 0)
        
    Raises:
        HTTPException 400: Email already exists
        HTTPException 500: Server error during registration
    """
    try:
        logger.info(f"Registration attempt for email: {user_data.email}")
        
        # Check if user already exists
        existing_user = await firebase_service.get_user_by_email(user_data.email)
        if existing_user:
            raise ValueError(f"User with email {user_data.email} already exists")
        
        # Generate unique user ID
        import uuid
        user_id = str(uuid.uuid4())
        
        # Hash password before storing
        user_dict = user_data.model_dump()
        user_dict['uid'] = user_id
        # Truncate password to 72 bytes for bcrypt compatibility
        password_to_hash = user_data.password[:72] if len(user_data.password.encode('utf-8')) > 72 else user_data.password
        user_dict['password'] = auth_service.hash_password(password_to_hash)
        
        # Create user in Firebase (Auth + Firestore)
        # This initializes ALL fields with real values (stats at 0)
        user = await firebase_service.create_user(user_dict)
        
        logger.info(f"User registered successfully: {user['uid']}")
        
        # TODO: Send welcome email via email_service
        # await email_service.send_welcome_email(user['email'], user['displayName'])
        
        return UserResponse(**user)
        
    except ValueError as e:
        # Email already exists
        logger.warning(f"Registration failed - email exists: {user_data.email}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "error": "email_already_exists",
                "message": f"User with email {user_data.email} already exists. Please use a different email or try logging in.",
                "field": "email"
            }
        )
    except Exception as e:
        logger.error(f"Registration error for {user_data.email}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=ErrorMessage.INTERNAL_ERROR
        )

# ==================== LOGIN ====================

@router.post(
    "/login",
    response_model=TokenResponse,
    summary="User login",
    description="""
    Authenticate user with email and password, return JWT tokens.
    
    **Authentication Flow:**
    1. Validates email format and password
    2. Looks up user in Firestore
    3. Verifies password using bcrypt
    4. Generates JWT access token (24 hours)
    5. Generates JWT refresh token (30 days)
    6. Returns tokens + complete user profile
    
    **Token Usage:**
    - Include access token in Authorization header: `Bearer <token>`
    - Use refresh token to get new access token when expired
    - Both tokens are JWTs signed with HS256
    
    **Returns:**
    - access_token: Use for API requests (expires in 24 hours)
    - refresh_token: Use to get new access token (expires in 30 days)
    - user: Complete user profile with current stats
    """
)
async def login(
    credentials: LoginRequest,
    firebase_service: Annotated[FirebaseService, Depends(get_firebase_service)],
    auth_service: Annotated[AuthService, Depends(get_auth_service)]
) -> TokenResponse:
    """
    Authenticate user and return JWT tokens.
    
    Args:
        credentials: Email and password
        firebase_service: Firebase service dependency
        auth_service: Auth service dependency
        
    Returns:
        TokenResponse: JWT tokens + user profile
        
    Raises:
        HTTPException 401: Invalid credentials
        HTTPException 500: Server error
    """
    try:
        logger.info(f"Login attempt for email: {credentials.email}")
        
        # Get user from database
        user = await firebase_service.get_user_by_email(credentials.email)
        
        if not user:
            logger.warning(f"Login failed - user not found: {credentials.email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={
                    "error": "email_not_found",
                    "message": "No account found with this email address. Please check your email or sign up.",
                    "field": "email"
                }
            )
        
        # Verify password
        if not await auth_service.authenticate_user(
            credentials.email,
            credentials.password,
            user
        ):
            logger.warning(f"Login failed - incorrect password: {credentials.email}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={
                    "error": "incorrect_password",
                    "message": "Incorrect password. Please try again or use 'Forgot Password'.",
                    "field": "password"
                }
            )
        
        # Generate tokens
        tokens = auth_service.create_token_response(
            user_id=user['uid'],
            email=user['email'],
            subscription_plan=user['subscription']['plan']
        )
        
        logger.info(f"Login successful: {credentials.email}")
        
        # Return tokens + user profile
        return TokenResponse(
            access_token=tokens['access_token'],
            refresh_token=tokens['refresh_token'],
            token_type=tokens['token_type'],
            user=UserResponse(**user)
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Login error for {credentials.email}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=ErrorMessage.INTERNAL_ERROR
        )

# ==================== TOKEN REFRESH ====================

@router.post(
    "/refresh",
    summary="Refresh access token",
    description="""
    Get new access token using refresh token.
    
    **When to use:**
    - Access token expired (401 error)
    - Proactive refresh before expiration
    - User returns to app after inactivity
    
    **How it works:**
    1. Validates refresh token signature
    2. Checks token hasn't expired (30 days)
    3. Verifies token type is "refresh"
    4. Generates new access token (24 hours)
    5. Returns new access token
    
    **Security:**
    - Refresh tokens are long-lived (30 days)
    - Access tokens are short-lived (24 hours)
    - If refresh token expires, user must login again
    """
)
async def refresh_token(
    request: RefreshTokenRequest,
    firebase_service: Annotated[FirebaseService, Depends(get_firebase_service)],
    auth_service: Annotated[AuthService, Depends(get_auth_service)]
):
    """
    Generate new access token from refresh token.
    
    Args:
        request: Refresh token
        firebase_service: Firebase service dependency
        auth_service: Auth service dependency
        
    Returns:
        Dict with new access_token
        
    Raises:
        HTTPException 401: Invalid or expired refresh token
        HTTPException 500: Server error
    """
    try:
        logger.info("Token refresh attempt")
        
        # Verify refresh token
        payload = auth_service.verify_token(request.refresh_token, token_type="refresh")
        
        if not payload:
            logger.warning("Token refresh failed - invalid token")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired refresh token"
            )
        
        # Get user to get current subscription plan
        user = await firebase_service.get_user(payload['user_id'])
        
        if not user:
            logger.warning(f"Token refresh failed - user not found: {payload['user_id']}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found"
            )
        
        # Generate new access token
        new_access_token = auth_service.create_access_token(
            user_id=user['uid'],
            email=user['email'],
            subscription_plan=user['subscription']['plan']
        )
        
        logger.info(f"Token refreshed for user: {user['uid']}")
        
        return {
            "access_token": new_access_token,
            "token_type": "bearer"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Token refresh error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=ErrorMessage.INTERNAL_ERROR
        )

# ==================== LOGOUT ====================

@router.post(
    "/logout",
    summary="User logout",
    description="""
    Logout user (client-side token deletion).
    
    **Note:** JWTs are stateless, so server-side logout is optional.
    Client should delete tokens from local storage.
    
    **Optional Enhancement (Future):**
    - Store token blacklist in Redis
    - Check blacklist in token verification
    - Add tokens to blacklist on logout
    """
)
async def logout():
    """
    Logout user.
    
    Currently returns success message.
    Client should delete tokens from storage.
    
    TODO (Optional): Implement token blacklist in Redis
    """
    logger.info("User logout")
    return {
        "message": "Logged out successfully",
        "detail": "Please delete tokens from client storage"
    }

# ==================== TOKEN VERIFICATION ====================

async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(security)],
    firebase_service: Annotated[FirebaseService, Depends(get_firebase_service)]
) -> dict:
    """
    Dependency to get current authenticated user from JWT token.
    
    TODO - Milestone 1.2: Complete implementation
    
    Args:
        credentials: Bearer token from Authorization header
        firebase_service: Firebase service
        
    Returns:
        dict: Current user data
        
    Raises:
        HTTPException 401: Invalid or expired token
    """
    try:
        # Extract token
        token = credentials.credentials
        
        # Verify Firebase ID token
        decoded_token = await firebase_service.verify_firebase_token(token)
        
        if not decoded_token:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=ErrorMessage.UNAUTHORIZED
            )
        
        # Get user from Firestore
        user_id = decoded_token['uid']
        user = await firebase_service.get_user(user_id)
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=ErrorMessage.UNAUTHORIZED
            )
        
        return user
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Token verification error: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=ErrorMessage.UNAUTHORIZED
        )

# ==================== GOOGLE OAUTH ====================

@router.post(
    "/google",
    response_model=TokenResponse,
    summary="Google OAuth login/signup",
    description="""
    Authenticate using Google Sign-In.
    
    **Flow:**
    1. Frontend gets Google ID token from Firebase Auth
    2. Send ID token to this endpoint
    3. Backend verifies token with Firebase
    4. Creates new user if first time, or logs in existing user
    5. Returns JWT access and refresh tokens
    
    **User Creation:**
    - If user doesn't exist by email, creates new account
    - Initializes with Free plan and all stats at 0
    - Uses Google profile data (name, photo)
    
    **Returns:** JWT tokens for API authentication
    """
)
async def google_auth(
    google_data: GoogleAuthRequest,
    firebase_service: Annotated[FirebaseService, Depends(get_firebase_service)],
    auth_service: Annotated[AuthService, Depends(get_auth_service)]
) -> TokenResponse:
    """
    Google OAuth authentication endpoint.
    
    Args:
        google_data: Google ID token from Firebase Auth
        firebase_service: Firebase service dependency
        auth_service: Auth service dependency
        
    Returns:
        TokenResponse: JWT access and refresh tokens
        
    Raises:
        HTTPException 401: Invalid Google token
        HTTPException 500: Server error
    """
    try:
        logger.info("Google OAuth authentication attempt")
        
        # Verify Google ID token with Firebase
        decoded_token = await firebase_service.verify_firebase_token(google_data.id_token)
        
        if not decoded_token:
            logger.warning("Invalid Google ID token")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid Google credentials"
            )
        
        # Extract user info from token
        email = decoded_token.get('email')
        uid = decoded_token.get('uid')
        name = decoded_token.get('name', '')
        photo = decoded_token.get('picture', '')
        
        if not email or not uid:
            logger.error("Missing email or uid in Google token")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid Google token data"
            )
        
        logger.info(f"Google auth for email: {email}")
        
        # Check if user exists by email
        existing_user = await firebase_service.get_user_by_email(email)
        
        if existing_user:
            # Existing user - just login
            logger.info(f"Existing user login via Google: {email}")
            user = existing_user
        else:
            # New user - create account
            logger.info(f"Creating new user via Google: {email}")
            
            user_data = {
                'uid': uid,
                'email': email,
                'displayName': name,
                'photoURL': photo,
                'provider': 'google',
                # No password for Google auth users
                'password': None
            }
            
            # Create user with Firebase service (initializes stats at 0)
            user = await firebase_service.create_user(user_data)
            logger.info(f"New Google user created: {uid}")
        
        # Generate JWT tokens for API authentication
        access_token = auth_service.create_access_token(user['uid'])
        refresh_token = auth_service.create_refresh_token(user['uid'])
        
        logger.info(f"Google auth successful for: {email}")
        
        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            user=UserResponse(**user)
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Google auth error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=ErrorMessage.INTERNAL_ERROR
        )
