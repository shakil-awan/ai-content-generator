"""
User Profile Router (Controller)
Handles user profile management, settings, and usage tracking

ARCHITECTURE FLOW:
Client → Router (validates with Model) → Service (business logic) → Database

ENDPOINTS:
- GET /api/v1/user/profile - Get current user profile
- PATCH /api/v1/user/profile - Update profile (name, image)
- PATCH /api/v1/user/settings - Update user settings
- GET /api/v1/user/usage - Get detailed usage statistics
"""
from fastapi import APIRouter, HTTPException, status, Depends
from typing import Annotated
import logging

from app.schemas.user import (
    UserResponse,
    UserUpdate,
    UserSettingsUpdate,
    UsageInfo,
    AccountDeletionRequest,
    AccountDeletionResponse,
    CancelDeletionRequest
)
from app.services.firebase_service import FirebaseService
from app.dependencies import get_firebase_service, get_current_user
from app.constants import ErrorMessage, SuccessMessage

# Setup
router = APIRouter(prefix="/api/v1/users", tags=["User Management"])
logger = logging.getLogger(__name__)

# ==================== GET PROFILE ====================

@router.get(
    "/profile",
    response_model=UserResponse,
    summary="Get current user profile",
    description="""
    Retrieve complete user profile with REAL calculated statistics.
    
    **Authentication Required:** Bearer token in Authorization header
    
    **What You Get:**
    - Basic info: uid, email, display name, profile image
    - Subscription: Current plan, status, billing period
    - Usage stats: Real-time generation/humanization/graphics counts
    - Brand voice: Configuration status and settings
    - Settings: Theme, preferences (language auto-detected by AI)
    - Team: Role and invited members
    - Onboarding: Progress through setup steps
    - All-time stats: Total generations, average quality score, favorites
    
    **Real Data Guarantee:**
    - ALL stats are calculated from actual user actions
    - New users see 0 for all counters
    - Stats increment automatically on actions
    - NO mock or hardcoded values
    
    **Example Usage:**
    ```
    Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
    GET /api/v1/user/profile
    ```
    """
)
async def get_profile(
    current_user: Annotated[dict, Depends(get_current_user)]
) -> UserResponse:
    """
    Get current authenticated user's profile.
    
    Args:
        current_user: Current user from JWT token (dependency)
        
    Returns:
        UserResponse: Complete user profile with real stats
        
    Raises:
        HTTPException 401: Invalid or expired token
        HTTPException 404: User not found
        HTTPException 500: Server error
    """
    try:
        logger.info(f"Profile request for user: {current_user['uid']}")
        
        # User is already fetched by get_current_user dependency
        # All stats are REAL and calculated from database
        return UserResponse(**current_user)
        
    except Exception as e:
        logger.error(f"Error fetching profile for {current_user['uid']}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=ErrorMessage.INTERNAL_ERROR
        )

# ==================== UPDATE PROFILE ====================

@router.patch(
    "/profile",
    response_model=UserResponse,
    summary="Update user profile",
    description="""
    Update user profile information (display name and profile image).
    
    **Authentication Required:** Bearer token
    
    **Updatable Fields:**
    - display_name: User's display name (2-50 characters)
    - profile_image: URL to profile image
    
    **What Can't Be Updated Here:**
    - Email (requires re-authentication)
    - Password (use password reset flow)
    - Subscription (use billing endpoints)
    - Stats (auto-calculated from actions)
    
    **Example:**
    ```json
    {
      "display_name": "John Smith",
      "profile_image": "https://example.com/avatar.jpg"
    }
    ```
    """
)
async def update_profile(
    profile_data: UserUpdate,
    current_user: Annotated[dict, Depends(get_current_user)],
    firebase_service: Annotated[FirebaseService, Depends(get_firebase_service)]
) -> UserResponse:
    """
    Update user profile information.
    
    Args:
        profile_data: Profile update data
        current_user: Current user from JWT
        firebase_service: Firebase service dependency
        
    Returns:
        UserResponse: Updated user profile
        
    Raises:
        HTTPException 401: Invalid token
        HTTPException 400: Invalid input data
        HTTPException 500: Server error
    """
    try:
        user_id = current_user['uid']
        logger.info(f"Profile update request for user: {user_id}")
        
        # Build update dict (only include provided fields)
        update_data = {}
        if profile_data.display_name is not None:
            update_data['displayName'] = profile_data.display_name
        if profile_data.profile_image is not None:
            update_data['profileImage'] = profile_data.profile_image
        
        if not update_data:
            # No fields to update
            return UserResponse(**current_user)
        
        # Update user in database
        await firebase_service.update_user(user_id, update_data)
        
        # Get updated user
        updated_user = await firebase_service.get_user(user_id)
        
        logger.info(f"Profile updated successfully for user: {user_id}")
        return UserResponse(**updated_user)
        
    except Exception as e:
        logger.error(f"Error updating profile for {current_user['uid']}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=ErrorMessage.INTERNAL_ERROR
        )

# ==================== UPDATE SETTINGS ====================

@router.patch(
    "/settings",
    response_model=UserResponse,
    summary="Update user settings",
    description="""
    Update user preferences and settings.
    
    **Authentication Required:** Bearer token
    
    **Updatable Settings:**
    - default_content_type: Preferred content type for quick generation
    - default_tone: Preferred tone (professional, casual, friendly, etc.)
    - primary_use_case: Main use case (blog_writer, marketing_team, etc.)
    - auto_fact_check: Enable/disable automatic fact-checking
    - email_notifications: Enable/disable email notifications
    - theme: UI theme (light or dark)
    
    **Note:** Language is auto-detected by AI models (OpenAI/Gemini) based on user input.
    
    **Example:**
    ```json
    {
      "primary_use_case": "marketing_team",
      "auto_fact_check": true,
      "theme": "dark"
    }
    ```
    """
)
async def update_settings(
    settings_data: UserSettingsUpdate,
    current_user: Annotated[dict, Depends(get_current_user)],
    firebase_service: Annotated[FirebaseService, Depends(get_firebase_service)]
) -> UserResponse:
    """
    Update user settings and preferences.
    
    Args:
        settings_data: Settings update data
        current_user: Current user from JWT
        firebase_service: Firebase service dependency
        
    Returns:
        UserResponse: Updated user profile
        
    Raises:
        HTTPException 401: Invalid token
        HTTPException 400: Invalid settings
        HTTPException 500: Server error
    """
    try:
        user_id = current_user['uid']
        logger.info(f"Settings update request for user: {user_id}")
        
        # Build update dict for nested settings field
        settings_update = {}
        if settings_data.default_content_type is not None:
            settings_update['settings.defaultContentType'] = settings_data.default_content_type
        if settings_data.default_tone is not None:
            settings_update['settings.defaultTone'] = settings_data.default_tone
        if settings_data.primary_use_case is not None:
            settings_update['settings.primaryUseCase'] = settings_data.primary_use_case.value
        if settings_data.auto_fact_check is not None:
            settings_update['settings.autoFactCheck'] = settings_data.auto_fact_check
        if settings_data.email_notifications is not None:
            settings_update['settings.emailNotifications'] = settings_data.email_notifications
        if settings_data.theme is not None:
            settings_update['settings.theme'] = settings_data.theme
        
        if not settings_update:
            # No settings to update
            return UserResponse(**current_user)
        
        # Update settings in database
        await firebase_service.update_user(user_id, settings_update)
        
        # Get updated user
        updated_user = await firebase_service.get_user(user_id)
        
        logger.info(f"Settings updated successfully for user: {user_id}")
        return UserResponse(**updated_user)
        
    except Exception as e:
        logger.error(f"Error updating settings for {current_user['uid']}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=ErrorMessage.INTERNAL_ERROR
        )

# ==================== GET USAGE STATS ====================

@router.get(
    "/usage",
    summary="Get detailed usage statistics",
    description="""
    Get detailed usage statistics for current billing period.
    
    **Authentication Required:** Bearer token
    
    **Statistics Included:**
    - Generations: Count and limit based on plan
    - Humanizations: Count and limit (Free: 3, Hobby: 25, Pro: unlimited)
    - Social Graphics: Count and limit (Free: 5, Hobby: 50, Pro: unlimited)
    - Percentage used: Overall usage percentage
    - Reset date: When monthly limits reset
    
    **Real-Time Data:**
    - All counts are REAL and incremented on actions
    - Limits change automatically when subscription upgraded
    - Percentage calculated dynamically
    - New users start with 0 usage
    
    **Example Response:**
    ```json
    {
      "generations": 45,
      "generations_limit": 100,
      "humanizations": 10,
      "humanizations_limit": 25,
      "social_graphics": 20,
      "social_graphics_limit": 50,
      "reset_date": "2025-02-01T00:00:00Z",
      "percentage_used": 45.0
    }
    ```
    """
)
async def get_usage(
    current_user: Annotated[dict, Depends(get_current_user)]
):
    """
    Get detailed usage statistics for current user.
    
    Args:
        current_user: Current user from JWT
        
    Returns:
        Dict with detailed usage statistics
        
    Raises:
        HTTPException 401: Invalid token
        HTTPException 500: Server error
    """
    try:
        user_id = current_user['uid']
        logger.info(f"Usage stats request for user: {user_id}")
        
        # Usage stats are already in current_user (fetched from database)
        usage = current_user['usageThisMonth']
        
        # Calculate percentage used (based on generations as primary metric)
        percentage_used = 0.0
        generations_limit = usage.get('limit', usage.get('generationsLimit', 5))
        if generations_limit > 0:
            percentage_used = (usage['generations'] / generations_limit) * 100
            percentage_used = round(percentage_used, 2)
        
        return {
            "generations": usage['generations'],
            "generations_limit": generations_limit,
            "humanizations": usage.get('humanizations', 0),
            "humanizations_limit": usage.get('humanizationsLimit', 3),
            "social_graphics": usage.get('socialGraphics', 0),
            "social_graphics_limit": usage.get('socialGraphicsLimit', 5),
            "reset_date": usage['resetDate'],
            "percentage_used": percentage_used,
            "days_until_reset": calculate_days_until_reset(usage['resetDate'])
        }
        
    except Exception as e:
        logger.error(f"Error fetching usage for {current_user['uid']}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=ErrorMessage.INTERNAL_ERROR
        )

# ==================== HELPER FUNCTIONS ====================

def calculate_days_until_reset(reset_date) -> int:
    """Calculate days remaining until usage reset"""
    from datetime import datetime, timezone
    
    if isinstance(reset_date, str):
        reset_dt = datetime.fromisoformat(reset_date.replace('Z', '+00:00'))
    else:
        # Handle Firebase DatetimeWithNanoseconds or datetime objects
        if hasattr(reset_date, 'isoformat'):
            reset_dt = reset_date
            # Make sure it's timezone-aware
            if reset_dt.tzinfo is None:
                reset_dt = reset_dt.replace(tzinfo=timezone.utc)
        else:
            reset_dt = datetime.now(timezone.utc)
    
    now = datetime.now(timezone.utc)
    delta = reset_dt - now
    return max(0, delta.days)

# ==================== ACCOUNT DELETION ====================

@router.post(
    "/account/delete",
    response_model=AccountDeletionResponse,
    summary="Request account deletion",
    description="""
    Schedule account deletion 1 day before subscription ends.
    
    **Process:**
    1. User confirms deletion in frontend dialog (no password needed)
    2. Cancels active subscription (if any)
    3. Schedules deletion for 1 day before subscription end
    4. Marks account as pending deletion
    5. Returns scheduled deletion date
    
    **What Gets Deleted:**
    - User profile and settings
    - Generated content history
    - Brand voice configurations
    - Files in Firebase Storage (images, videos)
    - Firestore user data
    
    **What's Preserved:**
    - Payment records (for legal/tax compliance)
    - Billing history
    - Subscription transaction logs
    
    **Cancellation:**
    - Can cancel deletion before scheduled date
    - Use POST /account/delete/cancel endpoint
    
    **Nightly Processing:**
    - Firebase Cloud Function runs at 2 AM UTC daily
    - Checks for accounts scheduled for deletion
    - Processes deletions if date has passed
    """
)
async def request_account_deletion(
    request: AccountDeletionRequest,
    current_user: Annotated[dict, Depends(get_current_user)],
    firebase_service: Annotated[FirebaseService, Depends(get_firebase_service)]
):
    """
    Request account deletion (soft delete, scheduled for 1 day before subscription ends)
    
    Args:
        request: Deletion request with password confirmation
        current_user: Current authenticated user
        firebase_service: Firebase service instance
        
    Returns:
        Deletion confirmation with scheduled date
        
    Raises:
        HTTPException 401: Invalid password
        HTTPException 404: User not found
        HTTPException 500: Server error
    """
    try:
        from app.services.stripe_service import StripeService
        from datetime import datetime, timedelta
        
        user_id = current_user['uid']
        logger.info(f"Account deletion requested for user: {user_id}")
        
        # 1. Get user data
        user_doc = firebase_service.db.collection('users').document(user_id).get()
        
        if not user_doc.exists:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        user_data = user_doc.to_dict()
        
        # 2. Cancel subscription if active
        subscription = user_data.get('subscription', {})
        if subscription.get('status') == 'active' and subscription.get('stripe_subscription_id'):
            try:
                stripe_service = StripeService()
                await stripe_service.cancel_subscription(subscription['stripe_subscription_id'])
                logger.info(f"Cancelled subscription for user: {user_id}")
            except Exception as e:
                logger.error(f"Failed to cancel subscription: {e}")
                # Continue with deletion even if cancellation fails
        
        # 3. Calculate deletion date (1 day before subscription end, or 7 days from now if no subscription)
        if subscription.get('current_period_end'):
            # Parse subscription end date
            period_end = subscription['current_period_end']
            if isinstance(period_end, str):
                period_end = datetime.fromisoformat(period_end.replace('Z', '+00:00'))
            
            # Schedule for 1 day before subscription ends
            deletion_date = period_end - timedelta(days=1)
        else:
            # No active subscription - delete in 7 days
            deletion_date = datetime.utcnow() + timedelta(days=7)
        
        # Ensure deletion date is in the future
        now = datetime.utcnow()
        if deletion_date <= now:
            deletion_date = now + timedelta(days=1)  # Minimum 1 day
        
        # 4. Mark account for deletion
        firebase_service.db.collection('users').document(user_id).update({
            'deletion_requested_at': now,
            'deletion_scheduled_for': deletion_date,
            'deletion_reason': request.reason or 'No reason provided',
            'account_status': 'pending_deletion',
            'updated_at': now
        })
        
        days_until = (deletion_date - now).days
        
        logger.info(f"Account deletion scheduled for {user_id} on {deletion_date}")
        
        return AccountDeletionResponse(
            message=f"Your account deletion has been scheduled. You can cancel anytime before {deletion_date.strftime('%Y-%m-%d')}.",
            deletion_scheduled_for=deletion_date,
            days_until_deletion=days_until,
            cancellation_possible=True
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error requesting account deletion for {user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=ErrorMessage.INTERNAL_ERROR
        )

@router.post(
    "/account/delete/cancel",
    summary="Cancel scheduled account deletion",
    description="""
    Cancel a previously scheduled account deletion.
    
    **Requirements:**
    - Account must be marked for deletion
    - Deletion date must not have passed
    - User must be authenticated (no password needed)
    
    **Effects:**
    - Removes deletion scheduling
    - Reactivates account status
    - User can continue using the service
    """
)
async def cancel_account_deletion(
    request: CancelDeletionRequest,
    current_user: Annotated[dict, Depends(get_current_user)],
    firebase_service: Annotated[FirebaseService, Depends(get_firebase_service)]
):
    """
    Cancel scheduled account deletion
    
    Args:
        request: Cancellation request with password confirmation
        current_user: Current authenticated user
        firebase_service: Firebase service instance
        
    Returns:
        Success confirmation
        
    Raises:
        HTTPException 401: Invalid password
        HTTPException 404: No deletion scheduled
        HTTPException 500: Server error
    """
    try:
        from datetime import datetime
        
        user_id = current_user['uid']
        logger.info(f"Cancelling account deletion for user: {user_id}")
        
        # 1. Get user data
        user_doc = firebase_service.db.collection('users').document(user_id).get()
        
        if not user_doc.exists:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        user_data = user_doc.to_dict()
        
        # 2. Check if deletion is scheduled
        if user_data.get('account_status') != 'pending_deletion':
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No account deletion scheduled"
            )
        
        # 3. Cancel deletion
        firebase_service.db.collection('users').document(user_id).update({
            'deletion_requested_at': None,
            'deletion_scheduled_for': None,
            'deletion_reason': None,
            'account_status': 'active',
            'updated_at': datetime.utcnow()
        })
        
        logger.info(f"Account deletion cancelled for user: {user_id}")
        
        return {
            "message": "Account deletion has been cancelled successfully",
            "status": "active"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error cancelling account deletion for {user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=ErrorMessage.INTERNAL_ERROR
        )
