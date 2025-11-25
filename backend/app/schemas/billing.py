"""
Billing Schemas - Pydantic Models for Payment and Subscription Operations
Data validation for Stripe integration and subscription management

USAGE PATTERN:
    from app.schemas.billing import CheckoutRequest, SubscriptionResponse
    
    @router.post("/billing/checkout", response_model=CheckoutResponse)
    async def create_checkout(request: CheckoutRequest):
        session = await stripe_service.create_checkout_session(request)
        return CheckoutResponse(**session)
"""
from pydantic import BaseModel, Field, HttpUrl
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum

# ==================== ENUMS ====================

class BillingPlan(str, Enum):
    """Available subscription plans"""
    FREE = "free"
    HOBBY = "hobby"
    PRO = "pro"

class BillingInterval(str, Enum):
    """Billing frequency"""
    MONTHLY = "month"
    YEARLY = "year"

class SubscriptionStatus(str, Enum):
    """Subscription status values"""
    ACTIVE = "active"
    CANCELLED = "cancelled"
    EXPIRED = "expired"
    PAST_DUE = "past_due"
    TRIALING = "trialing"
    INCOMPLETE = "incomplete"

class WebhookEventType(str, Enum):
    """Stripe webhook event types we handle"""
    CHECKOUT_COMPLETED = "checkout.session.completed"
    SUBSCRIPTION_CREATED = "customer.subscription.created"
    SUBSCRIPTION_UPDATED = "customer.subscription.updated"
    SUBSCRIPTION_DELETED = "customer.subscription.deleted"
    INVOICE_PAID = "invoice.payment_succeeded"
    INVOICE_FAILED = "invoice.payment_failed"
    PAYMENT_FAILED = "payment_intent.payment_failed"

# ==================== REQUEST SCHEMAS ====================

class CheckoutRequest(BaseModel):
    """Create Stripe checkout session"""
    plan: str = Field(..., description="Subscription plan to purchase (pro or enterprise)")
    billing_interval: str = Field(
        default="month",
        description="Billing frequency: 'month' or 'year'. Annual plans get 2 months free (17% off)"
    )
    success_url: HttpUrl = Field(..., description="Redirect URL after successful payment")
    cancel_url: HttpUrl = Field(..., description="Redirect URL if payment cancelled")
    
    class Config:
        json_schema_extra = {
            "example": {
                "plan": "pro",
                "billing_interval": "year",
                "success_url": "https://app.example.com/success",
                "cancel_url": "https://app.example.com/cancel"
            }
        }

class SubscriptionUpdateRequest(BaseModel):
    """Update subscription (upgrade/downgrade)"""
    new_plan: BillingPlan
    proration_behavior: str = Field(
        default="create_prorations",
        pattern="^(create_prorations|none|always_invoice)$"
    )

class SubscriptionChangeRequest(BaseModel):
    """Change subscription plan or billing interval with automatic proration"""
    new_plan: str = Field(..., description="New plan: 'pro' or 'enterprise'")
    new_billing_interval: str = Field(..., description="New interval: 'month' or 'year'")
    
    class Config:
        json_schema_extra = {
            "example": {
                "new_plan": "pro",
                "new_billing_interval": "year"
            }
        }

class CancellationRequest(BaseModel):
    """Cancel subscription"""
    reason: Optional[str] = Field(None, max_length=500)
    cancel_at_period_end: bool = Field(
        default=True,
        description="If true, cancel at end of billing period. If false, cancel immediately."
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "reason": "Switching to competitor",
                "cancel_at_period_end": True
            }
        }

# ==================== RESPONSE SCHEMAS ====================

class CheckoutResponse(BaseModel):
    """Stripe checkout session response"""
    session_id: str
    url: str
    expires_at: datetime
    
    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "session_id": "cs_test_123456",
                "url": "https://checkout.stripe.com/c/pay/cs_test_123456",
                "expires_at": "2025-01-24T11:00:00Z"
            }
        }

class SubscriptionChangeResponse(BaseModel):
    """Response after changing subscription plan or billing interval"""
    success: bool
    message: str
    new_plan: str
    new_billing_interval: str
    proration_amount: float = Field(description="Amount charged/credited (negative = credit)")
    next_billing_date: datetime
    
    class Config:
        json_schema_extra = {
            "example": {
                "success": True,
                "message": "Subscription updated to Pro Annual. Prorated charge: $275.50",
                "new_plan": "pro",
                "new_billing_interval": "year",
                "proration_amount": 275.50,
                "next_billing_date": "2026-11-25T00:00:00Z"
            }
        }

class PlanDetails(BaseModel):
    """Subscription plan details"""
    name: str
    price_monthly: float
    price_yearly: float
    generations_limit: int
    humanizations_limit: int
    graphics_limit: int
    features: List[str]
    
    class Config:
        json_schema_extra = {
            "example": {
                "name": "Hobby",
                "price_monthly": 9.0,
                "price_yearly": 90.0,
                "generations_limit": 100,
                "humanizations_limit": 25,
                "graphics_limit": 50,
                "features": [
                    "100 monthly generations",
                    "25 AI humanizations",
                    "50 social graphics",
                    "Basic fact-checking",
                    "Email support"
                ]
            }
        }

class SubscriptionResponse(BaseModel):
    """Current subscription details"""
    plan: BillingPlan
    status: SubscriptionStatus
    current_period_start: datetime
    current_period_end: datetime
    cancel_at_period_end: bool
    cancelled_at: Optional[datetime] = None
    stripe_subscription_id: Optional[str] = None
    stripe_customer_id: Optional[str] = None
    
    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "plan": "hobby",
                "status": "active",
                "current_period_start": "2025-01-01T00:00:00Z",
                "current_period_end": "2025-02-01T00:00:00Z",
                "cancel_at_period_end": False,
                "cancelled_at": None,
                "stripe_subscription_id": "sub_123456",
                "stripe_customer_id": "cus_123456"
            }
        }

class Invoice(BaseModel):
    """Invoice details"""
    id: str
    amount_paid: float
    amount_due: float
    currency: str
    status: str
    invoice_pdf: Optional[str] = None
    created_at: datetime
    period_start: datetime
    period_end: datetime
    
    class Config:
        from_attributes = True

class InvoiceListResponse(BaseModel):
    """List of invoices"""
    invoices: List[Invoice]
    total: int
    has_more: bool

class PaymentMethod(BaseModel):
    """Payment method details"""
    id: str
    type: str  # card, bank_account, etc.
    card_brand: Optional[str] = None
    card_last4: Optional[str] = None
    exp_month: Optional[int] = None
    exp_year: Optional[int] = None
    is_default: bool = False

class BillingPortalResponse(BaseModel):
    """Stripe customer portal session"""
    url: str
    return_url: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "url": "https://billing.stripe.com/p/session/test_123456",
                "return_url": "https://app.example.com/settings/billing"
            }
        }

# ==================== WEBHOOK SCHEMAS ====================

class StripeWebhookEvent(BaseModel):
    """Stripe webhook event payload"""
    id: str
    type: WebhookEventType
    data: Dict[str, Any]
    created: int
    
    class Config:
        json_schema_extra = {
            "example": {
                "id": "evt_123456",
                "type": "customer.subscription.updated",
                "data": {
                    "object": {
                        "id": "sub_123456",
                        "status": "active",
                        "plan": "hobby"
                    }
                },
                "created": 1706097600
            }
        }

class WebhookResponse(BaseModel):
    """Webhook processing response"""
    received: bool = True
    processed: bool
    message: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "received": True,
                "processed": True,
                "message": "Subscription updated successfully"
            }
        }

# ==================== SUBSCRIPTION HISTORY ====================

class SubscriptionEvent(BaseModel):
    """Subscription history event"""
    event_type: str  # upgrade, downgrade, cancel, reactivate
    from_plan: Optional[str] = None
    to_plan: Optional[str] = None
    reason: Optional[str] = None
    created_at: datetime
    
    class Config:
        from_attributes = True

class SubscriptionHistory(BaseModel):
    """Complete subscription history"""
    user_id: str
    events: List[SubscriptionEvent]
    lifetime_value: float
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": "user_123",
                "events": [
                    {
                        "event_type": "upgrade",
                        "from_plan": "free",
                        "to_plan": "hobby",
                        "reason": None,
                        "created_at": "2025-01-01T00:00:00Z"
                    }
                ],
                "lifetime_value": 108.0
            }
        }

# ==================== USAGE TRACKING ====================

class UsageStats(BaseModel):
    """Monthly usage statistics for billing"""
    user_id: str
    month: str  # YYYY-MM format
    generations_count: int
    humanizations_count: int
    graphics_count: int
    overage_charges: float = 0.0
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": "user_123",
                "month": "2025-01",
                "generations_count": 95,
                "humanizations_count": 22,
                "graphics_count": 48,
                "overage_charges": 0.0
            }
        }
