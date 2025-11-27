"""
Summarly AI Content Generator - FastAPI Backend
Main Application Entry Point
"""
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from contextlib import asynccontextmanager
import os
from dotenv import load_dotenv
import logging

from app.config import settings
from app.middleware.logging import setup_logging
from app.utils.redis_client import redis_client
from app.exceptions import AppException
# from app.api import auth, generate, billing, user, api_keys

# Load environment variables
load_dotenv()

# Setup logging
setup_logging()

logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Handle startup and shutdown events"""
    # Startup
    print("🚀 Starting Summarly API...")
    print(f"📍 Environment: {settings.ENVIRONMENT}")
    print(f"🔑 OpenAI: {'✅ Configured' if settings.OPENAI_API_KEY else '❌ Missing'}")
    print(f"🔑 Anthropic: {'✅ Configured' if settings.ANTHROPIC_API_KEY else '❌ Missing'}")
    print(f"🔥 Firebase: {'✅ Configured' if settings.FIREBASE_PROJECT_ID else '❌ Missing'}")
    
    # Initialize Redis
    await redis_client.connect()
    print(f"💾 Redis: {'✅ Connected' if redis_client.client else '⚠️ Firestore fallback'}")
    
    yield
    
    # Shutdown
    print("👋 Shutting down Summarly API...")
    await redis_client.disconnect()

# Initialize FastAPI app
app = FastAPI(
    title="Summarly API",
    description="AI-Powered Content Generation with Fact-Checking - The Only AI Content Generator That Fact-Checks Itself",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# ==================== GLOBAL EXCEPTION HANDLERS ====================

@app.exception_handler(AppException)
async def app_exception_handler(request: Request, exc: AppException):
    """
    Handle all custom application exceptions
    Returns consistent error format with proper status codes
    """
    logger.error(
        f"AppException: {exc.error_code} - {exc.message}",
        extra={
            "error_code": exc.error_code,
            "status_code": exc.status_code,
            "details": exc.details,
            "path": request.url.path
        }
    )
    return JSONResponse(
        status_code=exc.status_code,
        content=exc.to_dict()
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """
    Handle Pydantic validation errors (422)
    Returns user-friendly error messages
    """
    errors = []
    for error in exc.errors():
        field = ".".join(str(x) for x in error["loc"][1:])  # Skip 'body' prefix
        errors.append({
            "field": field,
            "message": error["msg"],
            "type": error["type"]
        })
    
    logger.warning(
        f"Validation error on {request.url.path}",
        extra={"errors": errors}
    )
    
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "error": "validation_error",
            "message": "Request validation failed",
            "details": errors
        }
    )


@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    """
    Catch-all handler for unexpected exceptions
    Prevents exposing internal errors to clients
    """
    logger.exception(
        f"Unhandled exception on {request.url.path}: {exc}",
        exc_info=exc
    )
    
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "error": "internal_server_error",
            "message": "An unexpected error occurred. Please try again later.",
            "request_id": request.headers.get("x-request-id", "unknown")
        }
    )

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint - API health check"""
    return {
        "status": "online",
        "service": "Summarly API",
        "version": "1.0.0",
        "tagline": "The Only AI Content Generator That Fact-Checks Itself",
        "message": "Welcome to Summarly AI Content Generator Backend"
    }

@app.get("/health")
async def health_check():
    """Detailed health check endpoint"""
    return {
        "status": "healthy",
        "environment": settings.ENVIRONMENT,
        "database": {
            "type": "firebase_firestore",
            "configured": bool(settings.FIREBASE_PROJECT_ID)
        },
        "ai_services": {
            "openai": "configured" if settings.OPENAI_API_KEY else "missing",
            "anthropic": "configured" if settings.ANTHROPIC_API_KEY else "missing",
            "gemini": "configured" if settings.GEMINI_API_KEY else "missing"
        },
        "fact_checking": {
            "wolfram_alpha": "configured" if settings.WOLFRAM_ALPHA_API_KEY else "missing",
            "google_scholar": "configured" if settings.GOOGLE_SCHOLAR_API_KEY else "missing"
        },
        "payment": {
            "stripe": "configured" if settings.STRIPE_SECRET_KEY else "missing"
        }
    }

# Include API routers
# Milestone 1.1 & 1.2: Authentication (Register, Login, Refresh)
from app.api import auth
app.include_router(auth.router)

# Milestone 1.3: User Profile Management
from app.api import user
app.include_router(user.router)

# Milestone 2.1-2.2: Content Generation (6 types)
from app.api import generate
app.include_router(generate.router)

# Milestone 2.3: AI Humanization
from app.api import humanize
app.include_router(humanize.router)

# Milestone 3: Billing & Subscriptions (Stripe)
from app.api import billing
app.include_router(billing.router)

# Milestone 3: Image Generation (Flux Schnell + DALL-E 3)
from app.api import images
app.include_router(images.router)

# Milestone 4: Analytics & Cost Tracking
from app.api import analytics
app.include_router(analytics.router)

# Milestone 5: User Feedback & Quality Assurance
from app.api import feedback
app.include_router(feedback.router)

# Quality Scoring API
from app.api import quality
app.include_router(quality.router)
