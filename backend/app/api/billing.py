"""
Billing Router - Milestone 3: Stripe Payment & Subscription Management
Handles checkout, webhooks, and subscription management with REAL limit updates

ARCHITECTURE FLOW:
    Checkout Request → Create Stripe Session → User pays
                    → Webhook received → Update Firebase subscription
                    → Auto-update usage limits → Response

LIMIT UPDATE PATTERN:
    When user upgrades Free → Pro:
    - usageThisMonth.limit: 5 → 100
    - usageThisMonth.humanizationsLimit: 3 → 25
    - usageThisMonth.socialGraphicsLimit: 5 → 50
"""
from fastapi import APIRouter, Depends, HTTPException, status, Request, Header
from typing import Dict, Any, Optional
from datetime import datetime
import logging

from app.schemas.billing import (
    CheckoutRequest,
    CheckoutResponse,
    SubscriptionResponse,
    SubscriptionChangeRequest,
    SubscriptionChangeResponse,
    WebhookResponse,
    Invoice
)
from app.dependencies import get_current_user, get_firebase_service
from app.services.firebase_service import FirebaseService
from app.services.stripe_service import StripeService
from app.constants import SubscriptionPlan, SubscriptionStatus

router = APIRouter(prefix="/api/v1/billing", tags=["Billing & Subscriptions"])
logger = logging.getLogger(__name__)

# Initialize Stripe service
stripe_service = StripeService()

# ==================== MILESTONE 3.1: STRIPE CHECKOUT ====================

@router.post(
    "/checkout",
    response_model=CheckoutResponse,
    status_code=status.HTTP_200_OK,
    summary="Create Stripe checkout session",
    description="""
    Create a Stripe Checkout session to upgrade subscription.
    
    **Available Tiers:**
    - Pro: $29/month or $290/year (save $58 - 2 months free!)
    - Enterprise: $99/month or $990/year (save $198 - 2 months free!)
    
    **Billing Options:**
    - Monthly: Pay month-to-month, cancel anytime
    - Annual: Pay yearly, get 17% discount (2 months free)
    
    **Flow:**
    1. User selects tier (pro/enterprise) and interval (month/year)
    2. Create Stripe checkout session with selected pricing
    3. Redirect user to Stripe payment page
    4. After payment, webhook updates user subscription
    5. Limits auto-update based on tier (same limits for monthly/yearly)
    
    **Returns:**
    - Checkout session URL (redirect user here)
    - Session ID (for tracking)
    """
)
async def create_checkout_session(
    request: CheckoutRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
) -> CheckoutResponse:
    """
    Create Stripe checkout session for subscription upgrade
    """
    try:
        user_id = current_user['uid']
        user_email = current_user['email']
        
        # Get or create Stripe products and prices
        products = await stripe_service.get_or_create_products()
        
        # Validate plan
        if request.plan not in ['pro', 'enterprise']:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "error": "invalid_plan",
                    "message": "Plan must be 'pro' or 'enterprise'"
                }
            )
        
        # Validate billing interval
        billing_interval = request.billing_interval.lower()
        if billing_interval not in ['month', 'year']:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "error": "invalid_interval",
                    "message": "Billing interval must be 'month' or 'year'"
                }
            )
        
        # Get price ID for selected plan and billing interval
        plan_info = products.get(request.plan)
        if not plan_info:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={"error": "price_not_found", "message": "Price configuration missing"}
            )
        
        # Select monthly or yearly price
        if billing_interval == 'year':
            price_data = plan_info.get('yearly')
        else:
            price_data = plan_info.get('monthly')
        
        if not price_data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={"error": "price_not_found", "message": f"Price for {billing_interval} billing not found"}
            )
        
        price_id = price_data['price_id']
        
        # Success and cancel URLs (convert HttpUrl to string)
        success_url = str(request.success_url)
        cancel_url = str(request.cancel_url)
        
        # Create checkout session
        session = await stripe_service.create_checkout_session(
            user_id=user_id,
            user_email=user_email,
            price_id=price_id,
            tier=request.plan,
            billing_interval=billing_interval,
            success_url=success_url,
            cancel_url=cancel_url
        )
        
        logger.info(f"Checkout session created for user {user_id}: {session['session_id']}")
        
        return CheckoutResponse(
            session_id=session['session_id'],
            url=session['url'],
            expires_at=session['expires_at']
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating checkout session: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": "checkout_failed", "message": str(e)}
        )


@router.post(
    "/subscription/change",
    response_model=SubscriptionChangeResponse,
    status_code=status.HTTP_200_OK,
    summary="Change subscription plan or billing interval",
    description="""
    Switch between monthly and annual billing, or change tier (Pro ↔ Enterprise).
    Stripe automatically handles proration.
    
    **Examples:**
    - Pro Monthly → Pro Annual: Get charged for annual with credit for remaining monthly time
    - Pro Annual → Pro Monthly: Get credit, start monthly billing
    - Pro → Enterprise: Upgrade with proration
    - Enterprise → Pro: Downgrade with credit
    
    **Proration:**
    - If upgrading (annual or higher tier): Charge difference immediately
    - If downgrading: Credit applied to future invoices
    - Stripe calculates fair proration based on time remaining
    
    **Response includes:**
    - Proration amount (positive = charged, negative = credited)
    - Next billing date
    - New plan details
    """
)
async def change_subscription(
    request: SubscriptionChangeRequest,
    current_user: Dict[str, Any] = Depends(get_current_user),
    firebase_service: FirebaseService = Depends(get_firebase_service)
) -> SubscriptionChangeResponse:
    """
    Change subscription plan or billing interval with automatic proration
    """
    try:
        user_id = current_user['uid']
        subscription = current_user.get('subscription', {})
        
        # Check if user has active subscription
        stripe_subscription_id = subscription.get('stripeSubscriptionId')
        if not stripe_subscription_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "error": "no_subscription",
                    "message": "No active subscription found. Please subscribe first."
                }
            )
        
        # Validate new plan
        if request.new_plan not in ['pro', 'enterprise']:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={"error": "invalid_plan", "message": "Plan must be 'pro' or 'enterprise'"}
            )
        
        # Validate new billing interval
        if request.new_billing_interval not in ['month', 'year']:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={"error": "invalid_interval", "message": "Billing interval must be 'month' or 'year'"}
            )
        
        # Get products and prices
        products = await stripe_service.get_or_create_products()
        
        # Get new price ID
        plan_info = products.get(request.new_plan)
        if not plan_info:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={"error": "price_not_found", "message": "Price configuration missing"}
            )
        
        # Select monthly or yearly price
        if request.new_billing_interval == 'year':
            price_data = plan_info.get('yearly')
        else:
            price_data = plan_info.get('monthly')
        
        if not price_data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={"error": "price_not_found", "message": f"Price for {request.new_billing_interval} billing not found"}
            )
        
        new_price_id = price_data['price_id']
        
        # Update subscription in Stripe
        result = await stripe_service.update_subscription(
            subscription_id=stripe_subscription_id,
            new_price_id=new_price_id,
            new_tier=request.new_plan,
            new_billing_interval=request.new_billing_interval
        )
        
        # Update Firebase with new subscription details
        subscription_update = {
            'plan': request.new_plan,
            'currentPeriodEnd': result['current_period_end']
        }
        await firebase_service.update_subscription(user_id, subscription_update)
        
        # Calculate proration amount
        proration_amount = result.get('proration_amount', 0.0) / 100  # Convert cents to dollars
        
        logger.info(f"Changed subscription for user {user_id}: {request.new_plan} {request.new_billing_interval}")
        
        return SubscriptionChangeResponse(
            success=True,
            message=result['message'],
            new_plan=request.new_plan,
            new_billing_interval=request.new_billing_interval,
            proration_amount=proration_amount,
            next_billing_date=result['current_period_end']
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error changing subscription: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": "change_failed", "message": str(e)}
        )


# ==================== MILESTONE 3.2: STRIPE WEBHOOK HANDLER ====================

@router.post(
    "/webhook",
    response_model=WebhookResponse,
    status_code=status.HTTP_200_OK,
    summary="Handle Stripe webhook events",
    description="""
    Receive and process Stripe webhook events.
    
    **Handled Events:**
    - checkout.session.completed: New subscription → Update user tier + limits
    - customer.subscription.updated: Plan change → Update limits
    - customer.subscription.deleted: Cancellation → Downgrade to Free
    - invoice.payment_succeeded: Successful payment
    - invoice.payment_failed: Failed payment
    
    **Auto Limit Updates:**
    ```python
    Free → Pro:
        generations: 5 → 100
        humanizations: 3 → 25
        graphics: 5 → 50
    
    Pro → Enterprise:
        generations: 100 → 999999 (unlimited)
        humanizations: 25 → 999999
        graphics: 50 → 999999
    ```
    """
)
async def stripe_webhook(
    request: Request,
    stripe_signature: str = Header(None, alias="stripe-signature"),
    firebase_service: FirebaseService = Depends(get_firebase_service)
) -> WebhookResponse:
    """
    Handle Stripe webhook events and update user subscriptions
    
    CRITICAL: This endpoint auto-updates user limits based on plan
    """
    try:
        # Get raw body for signature verification
        payload = await request.body()
        
        if not stripe_signature:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Missing stripe-signature header"
            )
        
        # Verify webhook signature
        event = await stripe_service.verify_webhook_signature(
            payload=payload,
            signature=stripe_signature
        )
        
        # Process webhook event
        result = await stripe_service.handle_webhook_event(event)
        
        if result['status'] == 'ignored':
            return WebhookResponse(
                success=True,
                eventType=event['type'],
                message=f"Event ignored: {result.get('reason')}"
            )
        
        # Extract user_id and action
        user_id = result.get('user_id')
        action = result.get('action')
        
        if not user_id:
            return WebhookResponse(
                success=True,
                eventType=event['type'],
                message="No user_id found in metadata"
            )
        
        # ==================== UPDATE USER SUBSCRIPTION & LIMITS ====================
        
        if action in ['subscription_created', 'subscription_updated']:
            subscription_id = result.get('subscription_id')
            customer_id = result.get('customer_id')
            tier = result.get('tier', 'pro')
            
            # Determine new limits based on tier
            if tier == 'pro':
                new_limits = {
                    'generations': 100,
                    'humanizations': 25,
                    'socialGraphics': 50
                }
                plan = SubscriptionPlan.PRO
            elif tier == 'enterprise':
                new_limits = {
                    'generations': 999999,  # Unlimited
                    'humanizations': 999999,
                    'socialGraphics': 999999
                }
                plan = SubscriptionPlan.ENTERPRISE
            else:
                new_limits = {
                    'generations': 5,
                    'humanizations': 3,
                    'socialGraphics': 5
                }
                plan = SubscriptionPlan.FREE
            
            # Get subscription details from Stripe
            subscription_data = await stripe_service.get_subscription(subscription_id)
            
            if subscription_data:
                # Update user subscription in Firebase
                subscription_update = {
                    'plan': plan,
                    'status': SubscriptionStatus.ACTIVE,
                    'currentPeriodStart': subscription_data['current_period_start'],
                    'currentPeriodEnd': subscription_data['current_period_end'],
                    'stripeSubscriptionId': subscription_id,
                    'stripeCustomerId': customer_id or subscription_data.get('customer'),
                    'cancelledAt': None
                }
                
                await firebase_service.update_subscription(user_id, subscription_update)
                
                # Update usage limits
                await firebase_service.update_usage_limits(user_id, new_limits)
                
                logger.info(f"Updated user {user_id} to {tier}: limits={new_limits}")
        
        elif action == 'subscription_cancelled':
            # Downgrade to Free tier
            subscription_update = {
                'plan': SubscriptionPlan.FREE,
                'status': SubscriptionStatus.CANCELLED,
                'cancelledAt': datetime.utcnow()
            }
            
            free_limits = {
                'generations': 5,
                'humanizations': 3,
                'socialGraphics': 5
            }
            
            await firebase_service.update_subscription(user_id, subscription_update)
            await firebase_service.update_usage_limits(user_id, free_limits)
            
            logger.info(f"Downgraded user {user_id} to Free tier")
        
        return WebhookResponse(
            success=True,
            eventType=event['type'],
            message=f"Successfully processed {action}",
            userId=user_id
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error processing webhook: {e}", exc_info=True)
        # Return 200 to acknowledge receipt (Stripe will retry on 4xx/5xx)
        return WebhookResponse(
            success=False,
            eventType=event.get('type', 'unknown') if 'event' in locals() else 'unknown',
            message=f"Error: {str(e)}"
        )


# ==================== MILESTONE 3.3: SUBSCRIPTION MANAGEMENT ====================

@router.get(
    "/subscription",
    response_model=SubscriptionResponse,
    summary="Get current subscription details"
)
async def get_subscription(
    current_user: Dict[str, Any] = Depends(get_current_user),
    firebase_service: FirebaseService = Depends(get_firebase_service)
) -> SubscriptionResponse:
    """Get user's current subscription details"""
    try:
        subscription = current_user.get('subscription', {})
        usage = current_user.get('usageThisMonth', {})
        
        # Get Stripe subscription details if exists
        stripe_subscription_id = subscription.get('stripeSubscriptionId')
        cancel_at_period_end = False
        
        if stripe_subscription_id:
            stripe_sub = await stripe_service.get_subscription(stripe_subscription_id)
            if stripe_sub:
                cancel_at_period_end = stripe_sub.get('cancel_at_period_end', False)
        
        # Parse dates safely
        period_start = subscription.get('currentPeriodStart')
        period_end = subscription.get('currentPeriodEnd')
        cancelled = subscription.get('cancelledAt')
        
        # Helper to safely parse dates
        def parse_date(date_value):
            if not date_value:
                return None
            if isinstance(date_value, datetime):
                return date_value
            if isinstance(date_value, str):
                try:
                    return datetime.fromisoformat(date_value.replace('Z', '+00:00'))
                except:
                    return None
            # Handle Firebase DatetimeWithNanoseconds
            if hasattr(date_value, 'isoformat'):
                return date_value
            return None
        
        return SubscriptionResponse(
            plan=subscription.get('plan', 'free'),
            status=subscription.get('status', 'active'),
            current_period_start=parse_date(period_start) or datetime.now(),
            current_period_end=parse_date(period_end) or datetime.now(),
            cancel_at_period_end=cancel_at_period_end,
            cancelled_at=parse_date(cancelled),
            stripe_customer_id=subscription.get('stripeCustomerId'),
            stripe_subscription_id=subscription.get('stripeSubscriptionId')
        )
        
    except Exception as e:
        logger.error(f"Error getting subscription: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": "fetch_failed", "message": str(e)}
        )


@router.post(
    "/cancel",
    summary="Cancel subscription"
)
async def cancel_subscription(
    current_user: Dict[str, Any] = Depends(get_current_user),
    firebase_service: FirebaseService = Depends(get_firebase_service)
) -> Dict[str, Any]:
    """Cancel user's subscription (at end of billing period)"""
    try:
        subscription = current_user.get('subscription', {})
        stripe_subscription_id = subscription.get('stripeSubscriptionId')
        
        if not stripe_subscription_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={"error": "no_subscription", "message": "No active subscription to cancel"}
            )
        
        # Cancel subscription in Stripe (at period end)
        result = await stripe_service.cancel_subscription(
            subscription_id=stripe_subscription_id,
            at_period_end=True
        )
        
        logger.info(f"Cancelled subscription for user {current_user['uid']}")
        
        return {
            "success": True,
            "message": "Subscription will cancel at end of billing period",
            "cancelAtPeriodEnd": result['cancel_at_period_end'],
            "currentPeriodEnd": subscription.get('currentPeriodEnd')
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error cancelling subscription: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": "cancel_failed", "message": str(e)}
        )


@router.get(
    "/invoices",
    response_model=list[Invoice],
    summary="List payment invoices"
)
async def list_invoices(
    current_user: Dict[str, Any] = Depends(get_current_user),
    limit: int = 10
) -> list[Invoice]:
    """List user's payment invoices"""
    try:
        subscription = current_user.get('subscription', {})
        stripe_customer_id = subscription.get('stripeCustomerId')
        
        if not stripe_customer_id:
            return []
        
        invoices = await stripe_service.list_invoices(
            customer_id=stripe_customer_id,
            limit=limit
        )
        
        return [Invoice(**inv) for inv in invoices]
        
    except Exception as e:
        logger.error(f"Error listing invoices: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": "fetch_failed", "message": str(e)}
        )


@router.post(
    "/portal",
    summary="Get customer portal URL"
)
async def get_customer_portal(
    current_user: Dict[str, Any] = Depends(get_current_user),
    return_url: str = "http://localhost:3000/billing"
) -> Dict[str, str]:
    """
    Get Stripe customer portal URL for self-service management
    
    Portal allows users to:
    - Update payment method
    - View invoices
    - Cancel subscription
    """
    try:
        subscription = current_user.get('subscription', {})
        stripe_customer_id = subscription.get('stripeCustomerId')
        
        if not stripe_customer_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={"error": "no_customer", "message": "No Stripe customer found"}
            )
        
        portal_url = await stripe_service.create_customer_portal_session(
            customer_id=stripe_customer_id,
            return_url=return_url
        )
        
        return {"url": portal_url}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating portal session: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": "portal_failed", "message": str(e)}
        )


@router.get(
    "/health",
    summary="Check billing service health"
)
async def health_check() -> Dict[str, Any]:
    """Check if Stripe billing service is operational"""
    try:
        # Test Stripe API connection by getting products
        products = await stripe_service.get_or_create_products()
        
        return {
            "status": "healthy",
            "service": "billing",
            "stripe": "connected",
            "products": {
                "pro": bool(products.get('pro')),
                "enterprise": bool(products.get('enterprise'))
            },
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "service": "billing",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat()
        }
