"""
Custom Exception Classes for Professional Error Handling

USAGE:
    from app.exceptions import (
        AIServiceError, RateLimitError, DatabaseError
    )
    
    try:
        result = await openai_service.generate()
    except RateLimitError as e:
        # Handle rate limiting (429)
        logger.warning(f"Rate limited: {e}")
        raise HTTPException(429, detail=str(e))
    except AIServiceError as e:
        # Handle AI service errors (500, timeouts, etc)
        logger.error(f"AI error: {e}")
        raise HTTPException(503, detail=str(e))
"""
from typing import Optional, Dict, Any


# ==================== BASE EXCEPTIONS ====================

class AppException(Exception):
    """Base exception for all application errors"""
    def __init__(
        self,
        message: str,
        status_code: int = 500,
        error_code: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None
    ):
        self.message = message
        self.status_code = status_code
        self.error_code = error_code or self.__class__.__name__
        self.details = details or {}
        super().__init__(self.message)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert exception to JSON-serializable dict"""
        return {
            "error": self.error_code,
            "message": self.message,
            "status_code": self.status_code,
            **self.details
        }


# ==================== AI SERVICE EXCEPTIONS ====================

class AIServiceError(AppException):
    """Base exception for AI service errors (OpenAI, Gemini)"""
    def __init__(self, message: str, service: str = "AI", details: Optional[Dict[str, Any]] = None):
        super().__init__(
            message=f"{service} service error: {message}",
            status_code=503,
            error_code="ai_service_unavailable",
            details={"service": service, **(details or {})}
        )


class RateLimitError(AIServiceError):
    """Rate limiting error from AI services (429)"""
    def __init__(
        self,
        service: str,
        retry_after: Optional[int] = None,
        limit: Optional[str] = None
    ):
        details = {}
        if retry_after:
            details["retry_after_seconds"] = retry_after
        if limit:
            details["rate_limit"] = limit
        
        super().__init__(
            message=f"Rate limit exceeded. Please try again later.",
            service=service,
            details=details
        )
        self.status_code = 429
        self.error_code = "rate_limit_exceeded"


class InvalidAPIKeyError(AIServiceError):
    """Invalid or missing API key for external service (401/403)"""
    def __init__(self, service: str):
        super().__init__(
            message=f"Invalid or missing API key for {service}",
            service=service
        )
        self.status_code = 500  # Don't expose auth issues to client
        self.error_code = "service_configuration_error"


class AIModelNotFoundError(AIServiceError):
    """Requested AI model doesn't exist or is deprecated (404)"""
    def __init__(self, model_name: str, service: str):
        super().__init__(
            message=f"Model '{model_name}' not found or deprecated",
            service=service,
            details={"model": model_name}
        )
        self.status_code = 500
        self.error_code = "model_not_available"


class ContentPolicyViolationError(AIServiceError):
    """Content violates AI service policy (400)"""
    def __init__(self, service: str, reason: Optional[str] = None):
        super().__init__(
            message=f"Content violates {service} content policy" + (f": {reason}" if reason else ""),
            service=service,
            details={"reason": reason} if reason else {}
        )
        self.status_code = 400
        self.error_code = "content_policy_violation"


class TokenLimitExceededError(AIServiceError):
    """Request exceeds token limit (400)"""
    def __init__(self, service: str, requested: int, limit: int):
        super().__init__(
            message=f"Token limit exceeded: requested {requested}, limit is {limit}",
            service=service,
            details={
                "requested_tokens": requested,
                "token_limit": limit
            }
        )
        self.status_code = 400
        self.error_code = "token_limit_exceeded"


class AITimeoutError(AIServiceError):
    """AI service request timeout"""
    def __init__(self, service: str, timeout_seconds: int):
        super().__init__(
            message=f"{service} request timed out after {timeout_seconds} seconds",
            service=service,
            details={"timeout_seconds": timeout_seconds}
        )
        self.status_code = 504
        self.error_code = "ai_service_timeout"


# ==================== DATABASE EXCEPTIONS ====================

class DatabaseError(AppException):
    """Base exception for database errors (Firebase, Firestore)"""
    def __init__(self, message: str, operation: str, details: Optional[Dict[str, Any]] = None):
        super().__init__(
            message=f"Database {operation} failed: {message}",
            status_code=500,
            error_code="database_error",
            details={"operation": operation, **(details or {})}
        )


class DocumentNotFoundError(DatabaseError):
    """Document not found in Firestore"""
    def __init__(self, collection: str, document_id: str):
        super().__init__(
            message=f"Document not found: {collection}/{document_id}",
            operation="read",
            details={
                "collection": collection,
                "document_id": document_id
            }
        )
        self.status_code = 404
        self.error_code = "document_not_found"


class DuplicateDocumentError(DatabaseError):
    """Document already exists (duplicate key)"""
    def __init__(self, collection: str, field: str, value: str):
        super().__init__(
            message=f"Document with {field}='{value}' already exists in {collection}",
            operation="create",
            details={
                "collection": collection,
                "field": field,
                "value": value
            }
        )
        self.status_code = 409
        self.error_code = "duplicate_document"


class DatabaseConnectionError(DatabaseError):
    """Failed to connect to database"""
    def __init__(self, details: Optional[str] = None):
        super().__init__(
            message="Failed to connect to database" + (f": {details}" if details else ""),
            operation="connect",
            details={"details": details} if details else {}
        )
        self.status_code = 503
        self.error_code = "database_unavailable"


class TransactionError(DatabaseError):
    """Database transaction failed"""
    def __init__(self, operation: str, reason: str):
        super().__init__(
            message=f"Transaction failed: {reason}",
            operation=operation,
            details={"reason": reason}
        )
        self.error_code = "transaction_failed"


# ==================== PAYMENT EXCEPTIONS ====================

class PaymentError(AppException):
    """Base exception for payment errors (Stripe)"""
    def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
        super().__init__(
            message=f"Payment error: {message}",
            status_code=402,
            error_code="payment_error",
            details=details
        )


class StripeAPIError(PaymentError):
    """Stripe API error (network, authentication, etc)"""
    def __init__(self, stripe_error_type: str, message: str, code: Optional[str] = None):
        super().__init__(
            message=message,
            details={
                "stripe_error_type": stripe_error_type,
                "stripe_code": code
            }
        )
        self.error_code = "stripe_api_error"


class PaymentMethodError(PaymentError):
    """Invalid or declined payment method"""
    def __init__(self, reason: str):
        super().__init__(
            message=f"Payment method error: {reason}",
            details={"reason": reason}
        )
        self.error_code = "payment_method_error"


class SubscriptionNotFoundError(PaymentError):
    """Stripe subscription not found"""
    def __init__(self, subscription_id: str):
        super().__init__(
            message=f"Subscription not found: {subscription_id}",
            details={"subscription_id": subscription_id}
        )
        self.status_code = 404
        self.error_code = "subscription_not_found"


class InsufficientFundsError(PaymentError):
    """Payment declined due to insufficient funds"""
    def __init__(self):
        super().__init__(
            message="Payment declined: insufficient funds",
            details={"decline_reason": "insufficient_funds"}
        )
        self.error_code = "insufficient_funds"


# ==================== STORAGE EXCEPTIONS ====================

class StorageError(AppException):
    """Base exception for storage errors (Firebase Storage)"""
    def __init__(self, message: str, operation: str, details: Optional[Dict[str, Any]] = None):
        super().__init__(
            message=f"Storage {operation} failed: {message}",
            status_code=500,
            error_code="storage_error",
            details={"operation": operation, **(details or {})}
        )


class FileNotFoundError(StorageError):
    """File not found in storage"""
    def __init__(self, file_path: str):
        super().__init__(
            message=f"File not found: {file_path}",
            operation="read",
            details={"file_path": file_path}
        )
        self.status_code = 404
        self.error_code = "file_not_found"


class FileTooLargeError(StorageError):
    """File exceeds size limit"""
    def __init__(self, file_size_mb: float, max_size_mb: float):
        super().__init__(
            message=f"File too large: {file_size_mb}MB (max: {max_size_mb}MB)",
            operation="upload",
            details={
                "file_size_mb": file_size_mb,
                "max_size_mb": max_size_mb
            }
        )
        self.status_code = 413
        self.error_code = "file_too_large"


class InvalidFileTypeError(StorageError):
    """Invalid file type for upload"""
    def __init__(self, file_type: str, allowed_types: list):
        super().__init__(
            message=f"Invalid file type: {file_type}. Allowed: {', '.join(allowed_types)}",
            operation="upload",
            details={
                "file_type": file_type,
                "allowed_types": allowed_types
            }
        )
        self.status_code = 415
        self.error_code = "invalid_file_type"


# ==================== USAGE LIMIT EXCEPTIONS ====================

class UsageLimitError(AppException):
    """Base exception for usage limit errors"""
    def __init__(self, message: str, limit: int, used: int, reset_date: Optional[str] = None):
        details = {
            "limit": limit,
            "used": used
        }
        if reset_date:
            details["reset_date"] = reset_date
        
        super().__init__(
            message=message,
            status_code=429,
            error_code="usage_limit_exceeded",
            details=details
        )


class GenerationLimitError(UsageLimitError):
    """Monthly generation limit exceeded"""
    def __init__(self, limit: int, used: int, reset_date: str, plan: str):
        super().__init__(
            message=f"Monthly generation limit reached ({used}/{limit}). " +
                    f"Upgrade to {'Enterprise' if plan == 'pro' else 'Pro'} for more generations.",
            limit=limit,
            used=used,
            reset_date=reset_date
        )
        self.details["current_plan"] = plan
        self.error_code = "generation_limit_exceeded"


class HumanizationLimitError(UsageLimitError):
    """Monthly humanization limit exceeded"""
    def __init__(self, limit: int, used: int, reset_date: str):
        super().__init__(
            message=f"Monthly humanization limit reached ({used}/{limit}). Upgrade for more humanizations.",
            limit=limit,
            used=used,
            reset_date=reset_date
        )
        self.error_code = "humanization_limit_exceeded"


# ==================== NETWORK EXCEPTIONS ====================

class NetworkError(AppException):
    """Network connectivity error"""
    def __init__(self, service: str, details: Optional[str] = None):
        super().__init__(
            message=f"Network error connecting to {service}" + (f": {details}" if details else ""),
            status_code=503,
            error_code="network_error",
            details={"service": service}
        )


class TimeoutError(AppException):
    """Request timeout"""
    def __init__(self, operation: str, timeout_seconds: int):
        super().__init__(
            message=f"{operation} timed out after {timeout_seconds} seconds",
            status_code=504,
            error_code="request_timeout",
            details={
                "operation": operation,
                "timeout_seconds": timeout_seconds
            }
        )


# ==================== VALIDATION EXCEPTIONS ====================

class ValidationError(AppException):
    """Input validation error"""
    def __init__(self, field: str, message: str, value: Optional[Any] = None):
        details = {"field": field}
        if value is not None:
            details["invalid_value"] = str(value)
        
        super().__init__(
            message=f"Validation error for '{field}': {message}",
            status_code=400,
            error_code="validation_error",
            details=details
        )


# ==================== EXPORT ALL ====================

__all__ = [
    # Base
    "AppException",
    
    # AI Services
    "AIServiceError",
    "RateLimitError",
    "InvalidAPIKeyError",
    "AIModelNotFoundError",
    "ContentPolicyViolationError",
    "TokenLimitExceededError",
    "AITimeoutError",
    
    # Database
    "DatabaseError",
    "DocumentNotFoundError",
    "DuplicateDocumentError",
    "DatabaseConnectionError",
    "TransactionError",
    
    # Payment
    "PaymentError",
    "StripeAPIError",
    "PaymentMethodError",
    "SubscriptionNotFoundError",
    "InsufficientFundsError",
    
    # Storage
    "StorageError",
    "FileNotFoundError",
    "FileTooLargeError",
    "InvalidFileTypeError",
    
    # Usage Limits
    "UsageLimitError",
    "GenerationLimitError",
    "HumanizationLimitError",
    
    # Network
    "NetworkError",
    "TimeoutError",
    
    # Validation
    "ValidationError",
]
