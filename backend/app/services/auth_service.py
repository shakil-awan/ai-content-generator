"""
Authentication Service
Handles password hashing, JWT token generation, and token verification

RESPONSIBILITIES:
- Hash and verify passwords using bcrypt
- Generate JWT access tokens
- Generate and validate refresh tokens
- Token expiration management
"""
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
import bcrypt
from jose import JWTError, jwt
import logging

from app.config import settings
from app.constants import ErrorMessage

logger = logging.getLogger(__name__)


class AuthService:
    """Authentication service for password and JWT management"""
    
    def __init__(self):
        self.jwt_secret = settings.JWT_SECRET_KEY
        self.jwt_algorithm = settings.JWT_ALGORITHM
        self.access_token_expire_minutes = settings.JWT_EXPIRATION_MINUTES
        self.refresh_token_expire_days = 30  # Refresh tokens last 30 days
    
    # ==================== PASSWORD MANAGEMENT ====================
    
    def hash_password(self, password: str) -> str:
        """
        Hash a plain password using bcrypt.
        
        Args:
            password: Plain text password
            
        Returns:
            str: Hashed password
            
        Example:
            >>> auth_service = AuthService()
            >>> hashed = auth_service.hash_password("secure123")
            >>> # Returns: "$2b$12$..."
        """
        # Bcrypt has a 72-byte limit, truncate if necessary
        password_bytes = password.encode('utf-8')
        if len(password_bytes) > 72:
            password_bytes = password_bytes[:72]
        
        # Generate salt and hash
        salt = bcrypt.gensalt(rounds=12)
        hashed = bcrypt.hashpw(password_bytes, salt)
        return hashed.decode('utf-8')
    
    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        """
        Verify a plain password against a hashed password.
        
        Args:
            plain_password: Plain text password from user
            hashed_password: Hashed password from database
            
        Returns:
            bool: True if passwords match, False otherwise
            
        Example:
            >>> auth_service.verify_password("secure123", hashed)
            True
        """
        # Bcrypt has a 72-byte limit, truncate if necessary
        password_bytes = plain_password.encode('utf-8')
        if len(password_bytes) > 72:
            password_bytes = password_bytes[:72]
        
        # Hash from DB should be string, convert to bytes
        if isinstance(hashed_password, str):
            hashed_password = hashed_password.encode('utf-8')
        
        return bcrypt.checkpw(password_bytes, hashed_password)
    
    # ==================== JWT TOKEN GENERATION ====================
    
    def create_access_token(
        self,
        user_id: str,
        email: str,
        subscription_plan: str = "free"
    ) -> str:
        """
        Generate JWT access token for authenticated user.
        
        Token contains:
        - user_id: Unique user identifier
        - email: User email
        - tier: Subscription plan (for rate limiting)
        - exp: Expiration timestamp
        - iat: Issued at timestamp
        
        Args:
            user_id: User's unique ID
            email: User's email address
            subscription_plan: User's subscription tier
            
        Returns:
            str: JWT access token
            
        Example:
            >>> token = auth_service.create_access_token(
            ...     user_id="user123",
            ...     email="user@example.com",
            ...     subscription_plan="hobby"
            ... )
            >>> # Returns: "eyJhbGciOiJIUzI1NiIs..."
        """
        now = datetime.utcnow()
        expire = now + timedelta(minutes=self.access_token_expire_minutes)
        
        payload = {
            "user_id": user_id,
            "email": email,
            "tier": subscription_plan,
            "type": "access",
            "exp": expire,
            "iat": now
        }
        
        token = jwt.encode(
            payload,
            self.jwt_secret,
            algorithm=self.jwt_algorithm
        )
        
        logger.info(f"Access token created for user: {user_id}")
        return token
    
    def create_refresh_token(self, user_id: str, email: str) -> str:
        """
        Generate JWT refresh token for long-term authentication.
        
        Refresh tokens last 30 days and can be used to get new access tokens.
        
        Args:
            user_id: User's unique ID
            email: User's email address
            
        Returns:
            str: JWT refresh token
            
        Example:
            >>> refresh = auth_service.create_refresh_token(
            ...     user_id="user123",
            ...     email="user@example.com"
            ... )
        """
        now = datetime.utcnow()
        expire = now + timedelta(days=self.refresh_token_expire_days)
        
        payload = {
            "user_id": user_id,
            "email": email,
            "type": "refresh",
            "exp": expire,
            "iat": now
        }
        
        token = jwt.encode(
            payload,
            self.jwt_secret,
            algorithm=self.jwt_algorithm
        )
        
        logger.info(f"Refresh token created for user: {user_id}")
        return token
    
    # ==================== TOKEN VERIFICATION ====================
    
    def verify_token(self, token: str, token_type: str = "access") -> Optional[Dict[str, Any]]:
        """
        Verify and decode JWT token.
        
        Args:
            token: JWT token string
            token_type: Expected token type ("access" or "refresh")
            
        Returns:
            Optional[Dict]: Token payload if valid, None if invalid
            
        Raises:
            JWTError: If token is invalid or expired
            
        Example:
            >>> payload = auth_service.verify_token(token, "access")
            >>> if payload:
            ...     user_id = payload["user_id"]
        """
        try:
            payload = jwt.decode(
                token,
                self.jwt_secret,
                algorithms=[self.jwt_algorithm]
            )
            
            # Verify token type
            if payload.get("type") != token_type:
                logger.warning(f"Invalid token type: expected {token_type}, got {payload.get('type')}")
                return None
            
            return payload
            
        except jwt.ExpiredSignatureError:
            logger.warning("Token has expired")
            return None
        except JWTError as e:
            logger.warning(f"Token verification failed: {e}")
            return None
    
    # ==================== AUTHENTICATION ====================
    
    async def authenticate_user(
        self,
        email: str,
        password: str,
        user_data: Dict[str, Any]
    ) -> bool:
        """
        Authenticate user with email and password.
        
        Args:
            email: User's email
            password: Plain text password
            user_data: User document from database
            
        Returns:
            bool: True if authentication successful, False otherwise
            
        Example:
            >>> user = await firebase_service.get_user_by_email(email)
            >>> if auth_service.authenticate_user(email, password, user):
            ...     # Login successful
        """
        if not user_data:
            logger.warning(f"Authentication failed - user not found: {email}")
            return False
        
        # Verify password (check both field names for compatibility)
        password_hash = user_data.get("passwordHash") or user_data.get("password")
        if not password_hash:
            logger.error(f"No password hash found for user: {email}")
            return False
        
        if not self.verify_password(password, password_hash):
            logger.warning(f"Authentication failed - invalid password: {email}")
            return False
        
        logger.info(f"Authentication successful: {email}")
        return True
    
    def create_token_response(
        self,
        user_id: str,
        email: str,
        subscription_plan: str
    ) -> Dict[str, str]:
        """
        Create complete token response with both access and refresh tokens.
        
        Args:
            user_id: User's unique ID
            email: User's email
            subscription_plan: User's subscription tier
            
        Returns:
            Dict with access_token, refresh_token, token_type
            
        Example:
            >>> tokens = auth_service.create_token_response(
            ...     user_id="user123",
            ...     email="user@example.com",
            ...     subscription_plan="hobby"
            ... )
            >>> # Returns: {
            ...     "access_token": "eyJ...",
            ...     "refresh_token": "eyJ...",
            ...     "token_type": "bearer"
            ... }
        """
        access_token = self.create_access_token(user_id, email, subscription_plan)
        refresh_token = self.create_refresh_token(user_id, email)
        
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer"
        }
