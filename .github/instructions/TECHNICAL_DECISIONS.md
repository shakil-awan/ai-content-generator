# 🔧 TECHNICAL DECISIONS & IMPLEMENTATION GUIDE
## For AI Assistants & Developers

**Last Updated:** November 24, 2025  
**Project:** Summarly AI Content Generator  
**Status:** Critical Implementation Guidelines

---

## 🎯 CRITICAL DECISIONS

### 1. DATABASE ARCHITECTURE - FIREBASE FIRESTORE

#### ✅ **DECISION: Use JSON-compatible Firestore Structure (Easy Migration)**

**Rationale:**
- Firestore is JSON-based by default
- Easy migration to AWS DynamoDB, MongoDB, PostgreSQL (JSONB)
- No vendor lock-in
- Simple backup/restore

#### 📋 **Firestore Collection Structure (JSON-Compatible)**

```javascript
// users collection
{
  "userId": "auth_uid_12345",
  "email": "user@example.com",
  "displayName": "John Doe",
  "tier": "pro",  // free | hobby | pro | enterprise
  "stripeCustomerId": "cus_xxxxx",
  "stripeSubscriptionId": "sub_xxxxx",
  "subscriptionStatus": "active",  // active | canceled | past_due | trialing
  "createdAt": "2025-11-24T10:00:00Z",
  "updatedAt": "2025-11-24T10:00:00Z",
  "metadata": {
    "onboardingComplete": true,
    "emailVerified": true,
    "lastLoginAt": "2025-11-24T10:00:00Z"
  }
}

// subscriptions collection (separate for easy querying)
{
  "subscriptionId": "sub_xxxxx",
  "userId": "auth_uid_12345",
  "tier": "pro",
  "status": "active",
  "currentPeriodStart": "2025-11-01T00:00:00Z",
  "currentPeriodEnd": "2025-12-01T00:00:00Z",
  "cancelAtPeriodEnd": false,
  "stripePriceId": "price_xxxxx",
  "amount": 2900,  // in cents
  "currency": "usd",
  "paymentMethod": "card",
  "trialEnd": null,
  "metadata": {
    "upgradeFrom": "hobby",
    "promoCode": null
  }
}

// usage_tracking collection (for rate limiting)
{
  "userId": "auth_uid_12345",
  "period": "2025-11",  // YYYY-MM format
  "tier": "pro",
  "limits": {
    "generationsPerMonth": 1000,
    "generationsPerHour": 1000,
    "generationsPerDay": 5000
  },
  "usage": {
    "totalGenerations": 234,
    "blogPosts": 45,
    "socialMedia": 120,
    "emails": 35,
    "productDescriptions": 20,
    "adCopy": 10,
    "videoScripts": 4
  },
  "lastResetAt": "2025-11-01T00:00:00Z",
  "nextResetAt": "2025-12-01T00:00:00Z"
}

// generations collection (content history)
{
  "generationId": "gen_xxxxx",
  "userId": "auth_uid_12345",
  "contentType": "blog",  // blog | social | email | product | ad | video
  "input": {
    "topic": "AI in Healthcare",
    "length": 3000,
    "tone": "professional",
    "targetAudience": "Healthcare professionals"
  },
  "output": {
    "content": "Full generated content here...",
    "wordCount": 3142,
    "metadata": {
      "model": "gpt-4",
      "temperature": 0.7,
      "processingTimeMs": 12500
    }
  },
  "qualityScore": {
    "overall": 0.92,
    "readability": 0.89,
    "grammar": 0.95,
    "originality": 0.88,
    "factCheck": 0.94
  },
  "factChecking": {
    "enabled": true,
    "claimsVerified": 8,
    "claimsPassed": 7,
    "claimsFlagged": 1,
    "citations": [
      {
        "claim": "AI reduces diagnosis time by 40%",
        "source": "Journal of Medical AI, 2024",
        "confidence": 0.95
      }
    ]
  },
  "userRating": 5,  // 1-5 stars, null if not rated
  "status": "completed",  // generating | completed | failed
  "createdAt": "2025-11-24T10:30:00Z",
  "isFavorite": false
}

// payment_events collection (audit log)
{
  "eventId": "evt_xxxxx",
  "userId": "auth_uid_12345",
  "eventType": "subscription.created",  // subscription.created | subscription.updated | payment.succeeded | payment.failed
  "stripeEventId": "evt_stripe_xxxxx",
  "data": {
    // Full Stripe event data (JSON)
  },
  "processed": true,
  "createdAt": "2025-11-24T10:00:00Z"
}
```

#### 🔄 **Migration Strategy (Firestore → AWS/Others)**

```python
# Example migration script (when needed)
import json
import boto3  # For AWS DynamoDB

def migrate_to_dynamodb():
    """Migrate Firestore data to AWS DynamoDB"""
    dynamodb = boto3.resource('dynamodb')
    
    # Export from Firestore
    users = firestore.collection('users').stream()
    
    # Import to DynamoDB
    table = dynamodb.Table('summarly-users')
    for user in users:
        user_data = user.to_dict()
        # Already JSON-compatible!
        table.put_item(Item=user_data)
```

---

### 2. SUBSCRIPTION & RATE LIMITING SYSTEM

#### ✅ **DECISION: Redis + Firestore Hybrid Approach**

**Architecture:**
- **Redis:** Real-time rate limiting (fast, in-memory)
- **Firestore:** Persistent usage tracking & billing data

#### 🔐 **Rate Limiting Implementation**

```python
# backend/app/middleware/rate_limit.py

import redis
from datetime import datetime, timezone
from fastapi import HTTPException, status
from app.services.firebase_service import get_user_subscription

redis_client = redis.Redis(
    host='localhost', 
    port=6379, 
    decode_responses=True
)

# Tier limits (synced with frontend & docs)
TIER_LIMITS = {
    "free": {
        "generations_per_month": 5,
        "generations_per_hour": 5,
        "generations_per_day": 5
    },
    "hobby": {
        "generations_per_month": 100,
        "generations_per_hour": 20,
        "generations_per_day": 50
    },
    "pro": {
        "generations_per_month": 1000,
        "generations_per_hour": 200,
        "generations_per_day": 500
    },
    "enterprise": {
        "generations_per_month": 999999,
        "generations_per_hour": 10000,
        "generations_per_day": 50000
    }
}

async def check_rate_limit(user_id: str) -> dict:
    """
    Check if user has exceeded rate limits
    Returns remaining quota or raises HTTPException
    """
    
    # 1. Get user's current tier from Firestore
    subscription = await get_user_subscription(user_id)
    tier = subscription.get("tier", "free")
    
    # 2. Get tier limits
    limits = TIER_LIMITS[tier]
    
    # 3. Check Redis counters
    now = datetime.now(timezone.utc)
    hour_key = f"rate:{user_id}:hour:{now.strftime('%Y%m%d%H')}"
    day_key = f"rate:{user_id}:day:{now.strftime('%Y%m%d')}"
    month_key = f"rate:{user_id}:month:{now.strftime('%Y%m')}"
    
    # Get current counts
    hour_count = int(redis_client.get(hour_key) or 0)
    day_count = int(redis_client.get(day_key) or 0)
    month_count = int(redis_client.get(month_key) or 0)
    
    # 4. Check limits
    if hour_count >= limits["generations_per_hour"]:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail={
                "error": "RATE_LIMIT_EXCEEDED",
                "limitType": "hourly",
                "limit": limits["generations_per_hour"],
                "current": hour_count,
                "resetAt": get_next_hour_timestamp(),
                "upgradeUrl": "/billing/upgrade"
            }
        )
    
    if day_count >= limits["generations_per_day"]:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail={
                "error": "RATE_LIMIT_EXCEEDED",
                "limitType": "daily",
                "limit": limits["generations_per_day"],
                "current": day_count,
                "resetAt": get_next_day_timestamp(),
                "upgradeUrl": "/billing/upgrade"
            }
        )
    
    if month_count >= limits["generations_per_month"]:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail={
                "error": "RATE_LIMIT_EXCEEDED",
                "limitType": "monthly",
                "limit": limits["generations_per_month"],
                "current": month_count,
                "resetAt": get_next_month_timestamp(),
                "upgradeUrl": "/billing/upgrade"
            }
        )
    
    # 5. Increment counters (atomic operation)
    pipe = redis_client.pipeline()
    pipe.incr(hour_key)
    pipe.expire(hour_key, 3600)  # 1 hour
    pipe.incr(day_key)
    pipe.expire(day_key, 86400)  # 24 hours
    pipe.incr(month_key)
    pipe.expire(month_key, 2592000)  # 30 days
    pipe.execute()
    
    # 6. Also update Firestore for persistent tracking
    await update_firestore_usage(user_id, tier)
    
    # 7. Return remaining quota
    return {
        "allowed": True,
        "tier": tier,
        "remaining": {
            "hour": limits["generations_per_hour"] - hour_count - 1,
            "day": limits["generations_per_day"] - day_count - 1,
            "month": limits["generations_per_month"] - month_count - 1
        },
        "limits": limits
    }

async def update_firestore_usage(user_id: str, tier: str):
    """Update persistent usage tracking in Firestore"""
    from google.cloud import firestore
    
    db = firestore.client()
    now = datetime.now(timezone.utc)
    period = now.strftime('%Y-%m')
    
    usage_ref = db.collection('usage_tracking').document(f"{user_id}_{period}")
    
    # Atomic increment
    usage_ref.set({
        'userId': user_id,
        'period': period,
        'tier': tier,
        'lastUpdatedAt': now.isoformat()
    }, merge=True)
    
    usage_ref.update({
        'usage.totalGenerations': firestore.Increment(1)
    })
```

#### 📊 **Usage Tracking Endpoint**

```python
# backend/app/api/user.py

@router.get("/usage")
async def get_usage_stats(current_user: dict = Depends(get_current_user)):
    """Get user's usage statistics"""
    user_id = current_user["user_id"]
    tier = current_user["tier"]
    
    # Get from Redis (real-time)
    now = datetime.now(timezone.utc)
    hour_count = int(redis_client.get(f"rate:{user_id}:hour:{now.strftime('%Y%m%d%H')}") or 0)
    day_count = int(redis_client.get(f"rate:{user_id}:day:{now.strftime('%Y%m%d')}") or 0)
    month_count = int(redis_client.get(f"rate:{user_id}:month:{now.strftime('%Y%m')}") or 0)
    
    limits = TIER_LIMITS[tier]
    
    return {
        "tier": tier,
        "current": {
            "hour": hour_count,
            "day": day_count,
            "month": month_count
        },
        "limits": limits,
        "remaining": {
            "hour": limits["generations_per_hour"] - hour_count,
            "day": limits["generations_per_day"] - day_count,
            "month": limits["generations_per_month"] - month_count
        },
        "resetAt": {
            "hour": get_next_hour_timestamp(),
            "day": get_next_day_timestamp(),
            "month": get_next_month_timestamp()
        }
    }
```

---

### 3. PAYMENT FAILURE HANDLING

#### ✅ **DECISION: Stripe Webhooks + Graceful Degradation**

**Payment Failure Flow:**

```python
# backend/app/api/billing.py

@router.post("/webhook")
async def stripe_webhook(request: Request):
    """Handle Stripe webhook events"""
    
    payload = await request.body()
    sig_header = request.headers.get('stripe-signature')
    
    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
        )
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid payload")
    except stripe.error.SignatureVerificationError:
        raise HTTPException(status_code=400, detail="Invalid signature")
    
    # Handle different event types
    event_type = event['type']
    data = event['data']['object']
    
    if event_type == 'invoice.payment_failed':
        await handle_payment_failed(data)
    
    elif event_type == 'customer.subscription.deleted':
        await handle_subscription_deleted(data)
    
    elif event_type == 'invoice.payment_succeeded':
        await handle_payment_succeeded(data)
    
    # Log event to Firestore
    await log_payment_event(event)
    
    return {"status": "success"}

async def handle_payment_failed(invoice):
    """
    Handle failed payment
    
    Strategy:
    1. First failure: Send email, retry in 3 days
    2. Second failure: Downgrade to free tier, send urgent email
    3. Keep data for 30 days grace period
    """
    
    customer_id = invoice['customer']
    user = await get_user_by_stripe_customer_id(customer_id)
    
    # Get failure count
    failure_count = await get_payment_failure_count(user['userId'])
    
    if failure_count == 0:
        # First failure - send reminder email
        await send_email(
            to=user['email'],
            subject="Payment Failed - Please Update Payment Method",
            template="payment_failed_reminder",
            data={
                "userName": user['displayName'],
                "amount": invoice['amount_due'] / 100,
                "retryDate": (datetime.now() + timedelta(days=3)).strftime('%B %d, %Y'),
                "updateUrl": f"{settings.FRONTEND_URL}/billing/payment-method"
            }
        )
        
        # Update Firestore
        await db.collection('subscriptions').document(user['userId']).update({
            'status': 'past_due',
            'paymentFailureCount': firestore.Increment(1),
            'lastPaymentFailedAt': datetime.now(timezone.utc).isoformat()
        })
    
    elif failure_count == 1:
        # Second failure - downgrade to free tier but keep data
        await downgrade_to_free_tier(user['userId'], grace_period=True)
        
        await send_email(
            to=user['email'],
            subject="Urgent: Subscription Suspended - Update Payment Method",
            template="payment_failed_urgent",
            data={
                "userName": user['displayName'],
                "gracePeriodDays": 30,
                "updateUrl": f"{settings.FRONTEND_URL}/billing/payment-method"
            }
        )
    
    elif failure_count >= 2:
        # Third failure - cancel subscription, keep data for 30 days
        await cancel_subscription(user['userId'], reason="payment_failed")
        
        await send_email(
            to=user['email'],
            subject="Subscription Cancelled - Data Retained for 30 Days",
            template="subscription_cancelled",
            data={
                "userName": user['displayName'],
                "dataRetentionDays": 30,
                "reactivateUrl": f"{settings.FRONTEND_URL}/billing/reactivate"
            }
        )

async def downgrade_to_free_tier(user_id: str, grace_period: bool = False):
    """Downgrade user to free tier"""
    
    # Update Firestore
    await db.collection('users').document(user_id).update({
        'tier': 'free',
        'previousTier': firestore.ArrayUnion(['pro']),  # For easy upgrade back
        'gracePeriod': grace_period,
        'gracePeriodExpiresAt': (datetime.now(timezone.utc) + timedelta(days=30)).isoformat() if grace_period else None
    })
    
    # Update subscription record
    await db.collection('subscriptions').document(user_id).update({
        'status': 'cancelled',
        'cancelledAt': datetime.now(timezone.utc).isoformat(),
        'cancelReason': 'payment_failed'
    })
    
    # Clear Redis rate limit counters (will be reset to free tier limits)
    # Note: Don't delete old data, just update tier

async def handle_subscription_deleted(subscription):
    """Handle subscription cancellation"""
    customer_id = subscription['customer']
    user = await get_user_by_stripe_customer_id(customer_id)
    
    await db.collection('users').document(user['userId']).update({
        'tier': 'free',
        'subscriptionStatus': 'cancelled'
    })
    
    # Send confirmation email
    await send_email(
        to=user['email'],
        subject="Subscription Cancelled - We're Sorry to See You Go",
        template="subscription_cancelled_confirmation"
    )
```

#### 📧 **Email Templates for Payment Failures**

Store in Firestore or use SendGrid templates:

1. **First Failure:** "Payment Failed - Please Update"
2. **Second Failure:** "Urgent: Subscription Suspended"
3. **Final:** "Subscription Cancelled - Data Retained"

---

### 4. SECURITY CHECKLIST

#### 🔒 **Security Implementation**

```python
# backend/app/middleware/security.py

from fastapi import Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware
import hashlib
import hmac

class SecurityMiddleware(BaseHTTPMiddleware):
    """Custom security middleware"""
    
    async def dispatch(self, request: Request, call_next):
        # 1. Rate limiting per IP (prevent DDoS)
        client_ip = request.client.host
        if await is_ip_rate_limited(client_ip):
            raise HTTPException(status_code=429, detail="Too many requests from this IP")
        
        # 2. Validate API key if present
        api_key = request.headers.get('X-API-Key')
        if api_key:
            if not await validate_api_key(api_key):
                raise HTTPException(status_code=401, detail="Invalid API key")
        
        # 3. Check request size (prevent large payload attacks)
        content_length = request.headers.get('content-length')
        if content_length and int(content_length) > 10 * 1024 * 1024:  # 10MB limit
            raise HTTPException(status_code=413, detail="Payload too large")
        
        response = await call_next(request)
        
        # 4. Security headers
        response.headers['X-Content-Type-Options'] = 'nosniff'
        response.headers['X-Frame-Options'] = 'DENY'
        response.headers['X-XSS-Protection'] = '1; mode=block'
        response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
        
        return response

# Apply in main.py
from app.middleware.security import SecurityMiddleware
app.add_middleware(SecurityMiddleware)
```

#### 🛡️ **Data Exposure Prevention**

```python
# backend/app/schemas/user.py

from pydantic import BaseModel, EmailStr, Field
from typing import Optional

class UserResponse(BaseModel):
    """
    User response model - NEVER expose sensitive data
    
    ❌ DON'T INCLUDE:
    - stripeCustomerId
    - stripeSubscriptionId
    - API keys
    - Firebase UIDs (internal)
    - Payment methods
    """
    userId: str = Field(..., description="Public user ID (hashed)")
    email: EmailStr
    displayName: str
    tier: str
    subscriptionStatus: str
    createdAt: str
    
    # Safe metadata
    onboardingComplete: bool
    emailVerified: bool
    
    class Config:
        # Exclude sensitive fields from responses
        exclude = {
            'stripeCustomerId',
            'stripeSubscriptionId',
            'firebaseUid',
            'internalId'
        }

# Example endpoint
@router.get("/profile", response_model=UserResponse)
async def get_profile(current_user: dict = Depends(get_current_user)):
    """Get user profile - sanitized response"""
    user_data = await db.collection('users').document(current_user['user_id']).get()
    
    # Pydantic automatically excludes sensitive fields
    return UserResponse(**user_data.to_dict())
```

#### 🔐 **Environment Variables Protection**

```python
# backend/app/config.py

# ✅ CORRECT: Use environment variables, NEVER hardcode
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
STRIPE_SECRET_KEY = os.getenv("STRIPE_SECRET_KEY")

# ❌ NEVER DO THIS:
# OPENAI_API_KEY = "sk-xxxxx"  # EXPOSED IN CODE!

# ✅ Validate critical secrets exist
if not OPENAI_API_KEY:
    raise ValueError("OPENAI_API_KEY not set in environment")
```

#### 📝 **Audit Logging**

```python
# Log all sensitive operations
async def log_audit_event(event_type: str, user_id: str, details: dict):
    """Log security-sensitive events"""
    await db.collection('audit_logs').add({
        'eventType': event_type,  # login | api_key_created | payment | data_export
        'userId': user_id,
        'ipAddress': get_client_ip(),
        'userAgent': get_user_agent(),
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'details': details
    })

# Example usage
await log_audit_event(
    event_type='api_key_created',
    user_id=user_id,
    details={'keyName': 'Production API', 'permissions': ['read', 'write']}
)
```

---

### 5. FASTAPI-ONLY AUTHENTICATION (No Direct Firebase Client SDK)

#### ✅ **DECISION: All Auth Through FastAPI**

**Why:**
- Centralized security
- Better rate limiting control
- Audit logging
- Consistent error handling

#### 🔑 **Authentication Flow**

```python
# backend/app/api/auth.py

from fastapi import APIRouter, HTTPException, status
from firebase_admin import auth
from app.schemas.auth import LoginRequest, RegisterRequest, AuthResponse
from app.dependencies import get_current_user

router = APIRouter()

@router.post("/register", response_model=AuthResponse)
async def register(data: RegisterRequest):
    """
    Register new user via FastAPI (not Firebase client SDK)
    """
    try:
        # 1. Create Firebase Auth user
        user = auth.create_user(
            email=data.email,
            password=data.password,
            display_name=data.displayName
        )
        
        # 2. Create Firestore user document
        await db.collection('users').document(user.uid).set({
            'userId': user.uid,
            'email': data.email,
            'displayName': data.displayName,
            'tier': 'free',
            'subscriptionStatus': 'active',
            'createdAt': datetime.now(timezone.utc).isoformat(),
            'onboardingComplete': False,
            'emailVerified': False
        })
        
        # 3. Create initial usage tracking
        period = datetime.now(timezone.utc).strftime('%Y-%m')
        await db.collection('usage_tracking').document(f"{user.uid}_{period}").set({
            'userId': user.uid,
            'period': period,
            'tier': 'free',
            'limits': TIER_LIMITS['free'],
            'usage': {
                'totalGenerations': 0
            },
            'lastResetAt': datetime.now(timezone.utc).isoformat()
        })
        
        # 4. Generate JWT token
        custom_token = auth.create_custom_token(user.uid)
        
        # 5. Send verification email
        await send_verification_email(user.email, user.uid)
        
        return {
            'token': custom_token.decode('utf-8'),
            'user': {
                'userId': user.uid,
                'email': user.email,
                'displayName': data.displayName,
                'tier': 'free'
            }
        }
        
    except auth.EmailAlreadyExistsError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

@router.post("/login", response_model=AuthResponse)
async def login(data: LoginRequest):
    """Login user - returns JWT token"""
    try:
        # Verify credentials (Firebase Admin SDK)
        user = auth.get_user_by_email(data.email)
        
        # Get user data from Firestore
        user_doc = await db.collection('users').document(user.uid).get()
        user_data = user_doc.to_dict()
        
        # Generate custom token
        custom_token = auth.create_custom_token(user.uid)
        
        # Log login event
        await log_audit_event('login', user.uid, {'ipAddress': get_client_ip()})
        
        return {
            'token': custom_token.decode('utf-8'),
            'user': user_data
        }
        
    except auth.UserNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials"
        )

@router.get("/me")
async def get_current_user_info(current_user: dict = Depends(get_current_user)):
    """Get current authenticated user info"""
    user_doc = await db.collection('users').document(current_user['user_id']).get()
    return user_doc.to_dict()
```

#### 🔒 **Protected Endpoint Example**

```python
# All content generation goes through FastAPI with auth
@router.post("/generate/blog")
async def generate_blog(
    request: BlogGenerationRequest,
    current_user: dict = Depends(get_current_user)  # ✅ Auth required
):
    """Generate blog post - requires authentication"""
    
    # 1. Check rate limits
    rate_limit = await check_rate_limit(current_user['user_id'])
    
    # 2. Generate content
    content = await openai_service.generate_blog(request)
    
    # 3. Save to Firestore via FastAPI
    generation_doc = await db.collection('generations').add({
        'userId': current_user['user_id'],
        'contentType': 'blog',
        'input': request.dict(),
        'output': content,
        'createdAt': datetime.now(timezone.utc).isoformat()
    })
    
    return content
```

---

## 📚 SUMMARY FOR AI ASSISTANTS

### When implementing features:

1. **Database:** Use JSON-compatible Firestore structure (easy migration)
2. **Rate Limiting:** Redis (real-time) + Firestore (persistent)
3. **Payment Failures:** 3-strike system with grace period
4. **Security:** Never expose sensitive data, use middleware, audit logging
5. **Authentication:** ALL through FastAPI, no direct Firebase client SDK

### Key Files to Reference:
- `backend/app/middleware/rate_limit.py` - Rate limiting logic
- `backend/app/api/billing.py` - Payment webhook handlers
- `backend/app/middleware/security.py` - Security middleware
- `backend/app/api/auth.py` - Authentication endpoints

---

**Last Updated:** November 24, 2025
