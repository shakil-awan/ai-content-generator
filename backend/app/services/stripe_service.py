"""
Stripe Service - Payment & Subscription Management
Handles all Stripe operations for billing and subscriptions

ARCHITECTURE FLOW:
    Request → Router (validate) → Stripe Service (API calls)
           → Firebase (update subscription + limits) → Response

SUBSCRIPTION TIERS:
    - Free: 5 generations, 3 humanizations/month (no payment)
    - Pro: 100 generations, 25 humanizations/month ($29/month)
    - Enterprise: Unlimited everything ($99/month)
"""
from typing import Dict, Any, Optional
import stripe
from stripe import error as stripe_error
from app.config import settings
from app.exceptions import (
    StripeAPIError,
    PaymentMethodError,
    SubscriptionNotFoundError,
    InsufficientFundsError,
    InvalidAPIKeyError,
    NetworkError
)
import logging
from datetime import datetime, timezone

logger = logging.getLogger(__name__)

# Initialize Stripe with secret key
stripe.api_key = settings.STRIPE_SECRET_KEY

class StripeService:
    """Service for handling Stripe payment operations"""
    
    _instance: Optional['StripeService'] = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        if not hasattr(self, 'initialized'):
            self.initialized = True
            logger.info("Stripe service initialized")
    
    def _handle_stripe_error(self, e: Exception, operation: str) -> None:
        """
        Convert Stripe exceptions to custom app exceptions
        Provides consistent error handling across all Stripe operations
        """
        if isinstance(e, stripe_error.CardError):
            # Card declined (insufficient funds, fraud, etc)
            decline_code = e.error.decline_code
            if decline_code == "insufficient_funds":
                raise InsufficientFundsError()
            else:
                raise PaymentMethodError(f"Card declined: {e.error.message}")
        
        elif isinstance(e, stripe_error.InvalidRequestError):
            # Invalid parameters (subscription not found, invalid ID, etc)
            error_msg = str(e)
            if "No such subscription" in error_msg or "No such customer" in error_msg:
                # Extract ID from error message
                raise SubscriptionNotFoundError(e.param or "unknown")
            raise StripeAPIError("InvalidRequestError", error_msg, e.code)
        
        elif isinstance(e, stripe_error.AuthenticationError):
            # Invalid API key
            logger.critical(f"Stripe authentication failed during {operation}: {e}")
            raise InvalidAPIKeyError("Stripe")
        
        elif isinstance(e, stripe_error.APIConnectionError):
            # Network error connecting to Stripe
            logger.error(f"Stripe connection error during {operation}: {e}")
            raise NetworkError("Stripe", str(e))
        
        elif isinstance(e, stripe_error.RateLimitError):
            # Too many requests
            from app.exceptions import RateLimitError
            logger.warning(f"Stripe rate limit hit during {operation}")
            raise RateLimitError(service="Stripe", retry_after=60)
        
        elif isinstance(e, stripe_error.StripeError):
            # Generic Stripe error
            logger.error(f"Stripe error during {operation}: {e}")
            raise StripeAPIError(
                stripe_error_type=type(e).__name__,
                message=str(e),
                code=getattr(e, 'code', None)
            )
        
        else:
            # Unexpected error
            logger.error(f"Unexpected error during {operation}: {e}", exc_info=True)
            raise
    
    # ==================== PRODUCT & PRICE MANAGEMENT ====================
    
    async def get_or_create_products(self) -> Dict[str, Any]:
        """
        Get or create subscription products and prices
        
        Returns dict with product and price IDs for Pro and Enterprise tiers
        Free tier doesn't need a product (no payment)
        """
        try:
            # Check if products already exist
            products = stripe.Product.list(active=True, limit=10)
            
            pro_product = None
            enterprise_product = None
            
            for product in products.data:
                if product.name == "Pro Plan":
                    pro_product = product
                elif product.name == "Enterprise Plan":
                    enterprise_product = product
            
            # Create Pro product if doesn't exist
            if not pro_product:
                pro_product = stripe.Product.create(
                    name="Pro Plan",
                    description="100 generations, 25 humanizations per month. Perfect for content creators and small teams.",
                    metadata={
                        'tier': 'pro',
                        'generations_limit': '100',
                        'humanizations_limit': '25',
                        'graphics_limit': '50'
                    }
                )
                logger.info(f"Created Pro product: {pro_product.id}")
            
            # Create Enterprise product if doesn't exist
            if not enterprise_product:
                enterprise_product = stripe.Product.create(
                    name="Enterprise Plan",
                    description="Unlimited generations and humanizations. For agencies and large teams.",
                    metadata={
                        'tier': 'enterprise',
                        'generations_limit': 'unlimited',
                        'humanizations_limit': 'unlimited',
                        'graphics_limit': 'unlimited'
                    }
                )
                logger.info(f"Created Enterprise product: {enterprise_product.id}")
            
            # Get or create prices for both monthly and yearly billing
            # Pro Plan: $29/month or $290/year (save $58 = 2 months free)
            pro_price_monthly = await self._get_or_create_price(
                product_id=pro_product.id,
                amount=2900,  # $29.00/month
                interval='month',
                tier='pro'
            )
            
            pro_price_yearly = await self._get_or_create_price(
                product_id=pro_product.id,
                amount=29000,  # $290.00/year (10 months price for 12 months)
                interval='year',
                tier='pro'
            )
            
            # Enterprise Plan: $99/month or $990/year (save $198 = 2 months free)
            enterprise_price_monthly = await self._get_or_create_price(
                product_id=enterprise_product.id,
                amount=9900,  # $99.00/month
                interval='month',
                tier='enterprise'
            )
            
            enterprise_price_yearly = await self._get_or_create_price(
                product_id=enterprise_product.id,
                amount=99000,  # $990.00/year (10 months price for 12 months)
                interval='year',
                tier='enterprise'
            )
            
            return {
                'pro': {
                    'product_id': pro_product.id,
                    'monthly': {
                        'price_id': pro_price_monthly.id,
                        'amount': 2900,
                        'currency': 'usd',
                        'interval': 'month'
                    },
                    'yearly': {
                        'price_id': pro_price_yearly.id,
                        'amount': 29000,
                        'currency': 'usd',
                        'interval': 'year'
                    }
                },
                'enterprise': {
                    'product_id': enterprise_product.id,
                    'monthly': {
                        'price_id': enterprise_price_monthly.id,
                        'amount': 9900,
                        'currency': 'usd',
                        'interval': 'month'
                    },
                    'yearly': {
                        'price_id': enterprise_price_yearly.id,
                        'amount': 99000,
                        'currency': 'usd',
                        'interval': 'year'
                    }
                }
            }
            
        except Exception as e:
            logger.error(f"Error managing products: {e}", exc_info=True)
            raise
    
    async def _get_or_create_price(
        self,
        product_id: str,
        amount: int,
        interval: str,
        tier: str
    ) -> stripe.Price:
        """Get existing price or create new one"""
        try:
            # List prices for this product
            prices = stripe.Price.list(product=product_id, active=True)
            
            # Look for matching price
            for price in prices.data:
                if (price.unit_amount == amount and 
                    price.recurring.interval == interval):
                    return price
            
            # Create new price if not found
            price = stripe.Price.create(
                product=product_id,
                unit_amount=amount,
                currency='usd',
                recurring={'interval': interval},
                metadata={'tier': tier}
            )
            
            logger.info(f"Created {tier} price: {price.id}")
            return price
            
        except Exception as e:
            logger.error(f"Error managing price: {e}")
            raise
    
    # ==================== CHECKOUT ====================
    
    async def create_checkout_session(
        self,
        user_id: str,
        user_email: str,
        price_id: str,
        tier: str,
        billing_interval: str,
        success_url: str,
        cancel_url: str
    ) -> Dict[str, Any]:
        """
        Create Stripe Checkout session for subscription
        
        Args:
            user_id: User's Firebase UID
            user_email: User's email
            price_id: Stripe price ID (monthly or yearly)
            tier: Subscription tier (pro/enterprise)
            billing_interval: 'month' or 'year'
            success_url: Redirect URL after successful payment
            cancel_url: Redirect URL if payment cancelled
        
        Returns:
            Dict with checkout session URL and session ID
        """
        try:
            # Get or create Stripe customer
            customer = await self._get_or_create_customer(user_id, user_email)
            
            # Create checkout session
            session = stripe.checkout.Session.create(
                customer=customer.id,
                mode='subscription',
                payment_method_types=['card'],
                line_items=[{
                    'price': price_id,
                    'quantity': 1
                }],
                success_url=success_url + '?session_id={CHECKOUT_SESSION_ID}',
                cancel_url=cancel_url,
                allow_promotion_codes=True,
                billing_address_collection='auto',
                metadata={
                    'user_id': user_id,
                    'tier': tier,
                    'billing_interval': billing_interval
                },
                subscription_data={
                    'metadata': {
                        'user_id': user_id,
                        'tier': tier,
                        'billing_interval': billing_interval
                    }
                }
            )
            
            logger.info(f"Created checkout session for user {user_id}: {session.id}")
            
            return {
                'session_id': session.id,
                'url': session.url,
                'customer_id': customer.id,
                'expires_at': datetime.fromtimestamp(session.expires_at) if session.expires_at else datetime.utcnow()
            }
            
        except Exception as e:
            logger.error(f"Error creating checkout session: {e}", exc_info=True)
            raise
    
    async def _get_or_create_customer(
        self,
        user_id: str,
        email: str
    ) -> stripe.Customer:
        """Get existing Stripe customer or create new one"""
        try:
            # Search for existing customer by metadata
            customers = stripe.Customer.list(email=email, limit=1)
            
            if customers.data:
                return customers.data[0]
            
            # Create new customer
            customer = stripe.Customer.create(
                email=email,
                metadata={'user_id': user_id}
            )
            
            logger.info(f"Created Stripe customer for user {user_id}: {customer.id}")
            return customer
            
        except Exception as e:
            self._handle_stripe_error(e, "customer_creation")
            raise  # Unreachable, but makes type checker happy
    
    # ==================== WEBHOOK HANDLING ====================
    
    async def verify_webhook_signature(
        self,
        payload: bytes,
        signature: str
    ) -> stripe.Event:
        """
        Verify Stripe webhook signature
        
        Args:
            payload: Raw request body
            signature: Stripe signature from header
        
        Returns:
            Verified Stripe event
        """
        try:
            event = stripe.Webhook.construct_event(
                payload,
                signature,
                settings.STRIPE_WEBHOOK_SECRET
            )
            return event
        except stripe.error.SignatureVerificationError as e:
            logger.error(f"Webhook signature verification failed: {e}")
            raise
    
    async def handle_webhook_event(
        self,
        event: stripe.Event
    ) -> Dict[str, Any]:
        """
        Process Stripe webhook events
        
        Handles:
        - checkout.session.completed: New subscription created
        - customer.subscription.updated: Subscription changed
        - customer.subscription.deleted: Subscription cancelled
        - invoice.payment_succeeded: Payment successful
        - invoice.payment_failed: Payment failed
        """
        event_type = event['type']
        data = event['data']['object']
        
        logger.info(f"Processing webhook: {event_type}")
        
        # Extract user_id from metadata
        user_id = data.get('metadata', {}).get('user_id')
        
        if not user_id:
            logger.warning(f"No user_id in webhook metadata for event {event_type}")
            return {'status': 'ignored', 'reason': 'no_user_id'}
        
        result = {'status': 'processed', 'event_type': event_type, 'user_id': user_id}
        
        try:
            if event_type == 'checkout.session.completed':
                # New subscription created
                subscription_id = data.get('subscription')
                customer_id = data.get('customer')
                tier = data.get('metadata', {}).get('tier', 'pro')
                
                result['subscription_id'] = subscription_id
                result['customer_id'] = customer_id
                result['tier'] = tier
                result['action'] = 'subscription_created'
                
            elif event_type == 'customer.subscription.updated':
                # Subscription updated (plan change, renewal, etc)
                subscription_id = data.get('id')
                status = data.get('status')
                tier = data.get('metadata', {}).get('tier')
                
                result['subscription_id'] = subscription_id
                result['status'] = status
                result['tier'] = tier
                result['action'] = 'subscription_updated'
                
            elif event_type == 'customer.subscription.deleted':
                # Subscription cancelled
                subscription_id = data.get('id')
                
                result['subscription_id'] = subscription_id
                result['action'] = 'subscription_cancelled'
                
            elif event_type == 'invoice.payment_succeeded':
                # Payment successful
                subscription_id = data.get('subscription')
                amount_paid = data.get('amount_paid')
                
                result['subscription_id'] = subscription_id
                result['amount_paid'] = amount_paid
                result['action'] = 'payment_succeeded'
                
            elif event_type == 'invoice.payment_failed':
                # Payment failed
                subscription_id = data.get('subscription')
                
                result['subscription_id'] = subscription_id
                result['action'] = 'payment_failed'
            
            return result
            
        except Exception as e:
            logger.error(f"Error processing webhook {event_type}: {e}", exc_info=True)
            return {'status': 'error', 'error': str(e)}
    
    # ==================== SUBSCRIPTION MANAGEMENT ====================
    
    async def get_subscription(
        self,
        subscription_id: str
    ) -> Optional[Dict[str, Any]]:
        """Get subscription details from Stripe"""
        try:
            subscription = stripe.Subscription.retrieve(subscription_id)
            
            return {
                'id': subscription.id,
                'customer': subscription.customer,
                'status': subscription.status,
                'current_period_start': datetime.fromtimestamp(subscription.current_period_start, tz=timezone.utc),
                'current_period_end': datetime.fromtimestamp(subscription.current_period_end, tz=timezone.utc),
                'cancel_at_period_end': subscription.cancel_at_period_end,
                'cancelled_at': datetime.fromtimestamp(subscription.canceled_at, tz=timezone.utc) if subscription.canceled_at else None,
                'tier': subscription.metadata.get('tier'),
                'price_id': subscription['items']['data'][0]['price']['id'] if subscription['items']['data'] else None
            }
            
        except stripe.error.InvalidRequestError:
            return None
        except Exception as e:
            logger.error(f"Error retrieving subscription: {e}")
            raise
    
    async def update_subscription(
        self,
        subscription_id: str,
        new_price_id: str,
        new_tier: str,
        new_billing_interval: str
    ) -> Dict[str, Any]:
        """
        Update subscription to new plan/interval with automatic proration
        
        Args:
            subscription_id: Stripe subscription ID
            new_price_id: New Stripe price ID
            new_tier: New tier (pro/enterprise)
            new_billing_interval: New interval (month/year)
        
        Returns:
            Dict with updated subscription details and proration info
        """
        try:
            # Get current subscription
            current_sub = stripe.Subscription.retrieve(subscription_id)
            
            # Get the subscription item ID (first item)
            subscription_item_id = current_sub['items']['data'][0].id
            
            # Update subscription with new price
            # Stripe automatically calculates proration
            updated_sub = stripe.Subscription.modify(
                subscription_id,
                items=[{
                    'id': subscription_item_id,
                    'price': new_price_id,
                }],
                proration_behavior='create_prorations',  # Auto-calculate proration
                metadata={
                    'user_id': current_sub.metadata.get('user_id'),
                    'tier': new_tier,
                    'billing_interval': new_billing_interval
                }
            )
            
            # Get the latest invoice to see proration amount
            latest_invoice = stripe.Invoice.list(
                subscription=subscription_id,
                limit=1
            ).data
            
            proration_amount = 0
            if latest_invoice:
                # Sum up proration line items
                for line in latest_invoice[0].lines.data:
                    if line.proration:
                        proration_amount += line.amount
            
            logger.info(f"Updated subscription {subscription_id} to {new_tier} {new_billing_interval}")
            
            return {
                'subscription_id': updated_sub.id,
                'status': updated_sub.status,
                'current_period_end': datetime.fromtimestamp(updated_sub.current_period_end, tz=timezone.utc),
                'proration_amount': proration_amount,
                'message': f"Subscription updated to {new_tier.title()} {new_billing_interval}ly. Proration: ${abs(proration_amount)/100:.2f}"
            }
            
        except Exception as e:
            logger.error(f"Error updating subscription: {e}", exc_info=True)
            raise
    
    async def cancel_subscription(
        self,
        subscription_id: str,
        at_period_end: bool = True
    ) -> Dict[str, Any]:
        """
        Cancel subscription
        
        Args:
            subscription_id: Stripe subscription ID
            at_period_end: If True, cancels at end of billing period.
                         If False, cancels immediately.
        """
        try:
            if at_period_end:
                # Cancel at end of billing period
                subscription = stripe.Subscription.modify(
                    subscription_id,
                    cancel_at_period_end=True
                )
                logger.info(f"Subscription {subscription_id} will cancel at period end")
            else:
                # Cancel immediately
                subscription = stripe.Subscription.delete(subscription_id)
                logger.info(f"Subscription {subscription_id} cancelled immediately")
            
            return {
                'id': subscription.id,
                'status': subscription.status,
                'cancel_at_period_end': subscription.cancel_at_period_end,
                'cancelled_at': datetime.fromtimestamp(subscription.canceled_at, tz=timezone.utc) if subscription.canceled_at else None
            }
            
        except Exception as e:
            logger.error(f"Error cancelling subscription: {e}")
            raise
    
    async def create_customer_portal_session(
        self,
        customer_id: str,
        return_url: str
    ) -> str:
        """
        Create customer portal session for self-service management
        
        Returns portal URL where customer can:
        - Update payment method
        - View invoices
        - Cancel subscription
        """
        try:
            session = stripe.billing_portal.Session.create(
                customer=customer_id,
                return_url=return_url
            )
            
            logger.info(f"Created portal session for customer {customer_id}")
            return session.url
            
        except Exception as e:
            logger.error(f"Error creating portal session: {e}")
            raise
    
    async def list_invoices(
        self,
        customer_id: str,
        limit: int = 10
    ) -> list[Dict[str, Any]]:
        """List customer invoices"""
        try:
            invoices = stripe.Invoice.list(
                customer=customer_id,
                limit=limit
            )
            
            return [{
                'id': inv.id,
                'amount_due': inv.amount_due,
                'amount_paid': inv.amount_paid,
                'currency': inv.currency,
                'status': inv.status,
                'created': datetime.fromtimestamp(inv.created, tz=timezone.utc),
                'invoice_pdf': inv.invoice_pdf,
                'hosted_invoice_url': inv.hosted_invoice_url
            } for inv in invoices.data]
            
        except Exception as e:
            logger.error(f"Error listing invoices: {e}")
            raise

# Singleton instance
stripe_service = StripeService()
