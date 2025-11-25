# 🎯 FASTAPI BEST PRACTICES & API DESIGN GUIDE
## For Your AI Content Generator Project

---

## PART 1: FASTAPI BEST PRACTICES (PRODUCTION-READY)

### 1.1 Async/Await Rules (CRITICAL)

**✅ DO: Use `async def` for I/O operations**
```python
# ✅ CORRECT - Use async for API calls, DB queries
@app.post("/api/generate/content")
async def generate_content(request: GenerationRequest):
    # This is I/O bound (API call to OpenAI)
    result = await openai_service.generate(...)
    return result

# ✅ CORRECT - Use async for Firebase operations
async def save_to_firestore(uid: str, data: dict):
    # This is I/O bound (database operation)
    self._db.collection("users").document(uid).set(data)
    return data
```

**❌ DON'T: Use `async def` for CPU-heavy operations**
```python
# ❌ WRONG - Don't do heavy computation in async
@app.post("/api/generate")
async def heavy_computation():
    # Machine learning, complex math, heavy loops
    for i in range(1000000):
        result = expensive_calculation(i)  # BLOCKS EVENT LOOP!
    return result

# ✅ CORRECT - Use background tasks for heavy work
from fastapi import BackgroundTasks

@app.post("/api/generate")
async def create_task(background_tasks: BackgroundTasks):
    background_tasks.add_task(heavy_computation)
    return {"status": "Processing..."}
```

**✅ DO: Use async-friendly libraries**
```python
# ✅ CORRECT - Async libraries
import httpx  # Async HTTP client
import aiofiles  # Async file operations

@app.post("/api/generate")
async def use_async_libraries():
    async with httpx.AsyncClient() as client:
        response = await client.post("https://api.openai.com/...")
    return response

# ❌ WRONG - Blocking libraries
import requests  # BLOCKS event loop!

@app.post("/api/generate")
async def dont_use_blocking():
    response = requests.post("...")  # DON'T!
    return response
```

### 1.2 Dependency Injection Best Practices

**✅ DO: Chain dependencies for reusability**
```python
# ✅ CORRECT - Dependency chain
from fastapi import Depends

async def get_current_user(token: str = Depends(oauth2_scheme)) -> dict:
    user = await firebase_service.verify_token(token)
    return user

async def get_active_subscription(
    user: dict = Depends(get_current_user)
) -> dict:
    if user["subscription"]["status"] != "active":
        raise HTTPException(status_code=403, detail="No active subscription")
    return user["subscription"]

@app.get("/api/premium")
async def premium_feature(
    subscription: dict = Depends(get_active_subscription)
):
    return {"access": True}

# ❌ WRONG - Repeated logic
@app.get("/api/premium")
async def premium_feature_wrong(token: str):
    user = await firebase_service.verify_token(token)
    if user["subscription"]["status"] != "active":
        raise HTTPException(status_code=403)
    # Repeat same checks in every endpoint!
```

**✅ DO: Cache dependency results**
```python
# ✅ CORRECT - Dependency calls are cached per request
@app.get("/api/user/profile")
async def profile(user: dict = Depends(get_current_user)):
    # get_current_user is called ONCE per request
    # If called multiple times in same request, cached result is used
    return user

# ✅ CORRECT - Use lightweight dependencies
async def get_query_params(skip: int = 0, limit: int = 10):
    # Light, non-blocking dependencies are ideal
    return {"skip": skip, "limit": limit}
```

### 1.3 Error Handling Patterns

**✅ DO: Use custom exceptions + exception handlers**
```python
# ✅ CORRECT - Centralized error handling
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

class GenerationException(Exception):
    def __init__(self, message: str, status_code: int = 400):
        self.message = message
        self.status_code = status_code

app = FastAPI()

@app.exception_handler(GenerationException)
async def generation_exception_handler(request: Request, exc: GenerationException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": exc.message,
            "status_code": exc.status_code,
            "path": str(request.url),
        }
    )

@app.post("/api/generate")
async def generate(request: GenerationRequest):
    if not is_valid(request):
        raise GenerationException("Invalid input", 400)
    # Handle once, centralized!

# ❌ WRONG - Repeated error handling
@app.post("/api/generate-v2")
async def generate_v2(request: GenerationRequest):
    if not is_valid(request):
        return JSONResponse(status_code=400, content={"error": "..."})  # Repeated!
```

### 1.4 Pydantic Validation Best Practices

**✅ DO: Validate with Pydantic, not manual code**
```python
from pydantic import BaseModel, Field, EmailStr, validator

class GenerationRequest(BaseModel):
    contentType: str = Field(..., min_length=1, max_length=50)
    userInput: str = Field(..., min_length=10, max_length=5000)
    tone: str = Field("professional", pattern="^(professional|casual|creative)$")
    
    @validator('userInput')
    def validate_input(cls, v):
        if len(v.split()) < 5:
            raise ValueError('Input must have at least 5 words')
        return v

@app.post("/api/generate")
async def generate(request: GenerationRequest):
    # Pydantic validates EVERYTHING automatically!
    # Invalid data never reaches your function
    return await generate_content(request)

# ❌ WRONG - Manual validation
from fastapi import HTTPException

@app.post("/api/generate")
async def generate_wrong(request: dict):
    # Manual validation scattered everywhere
    if 'contentType' not in request:
        raise HTTPException(400, "Missing contentType")
    if len(request['userInput']) < 10:
        raise HTTPException(400, "Input too short")
    # Repeat in every endpoint!
```

### 1.5 Response Models Best Practices

**✅ DO: Use response models for documentation**
```python
from pydantic import BaseModel
from typing import List

class GenerationResponse(BaseModel):
    id: str
    content: str
    tokens: int
    createdAt: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "id": "gen_123",
                "content": "Generated blog post...",
                "tokens": 1500,
                "createdAt": "2024-01-15T10:30:00Z"
            }
        }

@app.post("/api/generate", response_model=GenerationResponse)
async def generate(request: GenerationRequest) -> GenerationResponse:
    # Response is automatically validated against model
    # Auto-documented in Swagger UI with example
    return GenerationResponse(...)

# ❌ WRONG - No response model
@app.post("/api/generate")
async def generate_wrong(request: dict):
    # No validation, no documentation
    # Client doesn't know what to expect
    return {"result": "..."}
```

### 1.6 Background Tasks for Long Operations

**✅ DO: Use background tasks for non-critical operations**
```python
from fastapi import BackgroundTasks
import asyncio

def send_email_notification(email: str, message: str):
    # Runs in background after response sent
    # Doesn't block user
    import smtplib
    # Send email...

@app.post("/api/generate")
async def generate(
    request: GenerationRequest,
    background_tasks: BackgroundTasks,
    user: dict = Depends(get_current_user)
):
    # Generate content immediately
    content = await openai_service.generate(request)
    
    # Send email in background (doesn't wait)
    background_tasks.add_task(
        send_email_notification,
        user["email"],
        f"Your content is ready!"
    )
    
    # Return immediately to user
    return {"content": content, "status": "ready"}

# ❌ WRONG - Blocking on non-critical tasks
@app.post("/api/generate")
async def generate_wrong(request: GenerationRequest):
    content = await openai_service.generate(request)
    
    # WAITS for email to send before responding!
    await send_email_blocking(...)  # User waits unnecessarily
    
    return {"content": content}
```

### 1.7 Logging Best Practices

**✅ DO: Use structured logging**
```python
import structlog
from app.utils.logger import get_logger

logger = get_logger(__name__)

@app.post("/api/generate")
async def generate(request: GenerationRequest):
    logger.info(
        "generation_started",
        content_type=request.contentType,
        input_length=len(request.userInput),
    )
    
    try:
        result = await openai_service.generate(request)
        logger.info("generation_success", tokens=result.tokens)
        return result
    except Exception as e:
        logger.error(
            "generation_failed",
            error=str(e),
            content_type=request.contentType,
            exc_info=True,
        )
        raise

# ❌ WRONG - Print statements
@app.post("/api/generate")
async def generate_wrong(request: GenerationRequest):
    print("Generating content...")  # No timestamp, no context
    result = await openai_service.generate(request)
    print(f"Done: {result}")  # Unstructured
    return result
```

### 1.8 Rate Limiting & Throttling

**✅ DO: Implement rate limiting**
```python
from slowapi import Limiter
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

@app.post("/api/generate")
@limiter.limit("100/minute")
async def generate(request: GenerationRequest, request: Request):
    # Max 100 requests per minute per IP
    return await generate_content(request)

# ✅ OR: Implement user-based rate limiting
@app.post("/api/generate")
async def generate_with_user_limit(
    request: GenerationRequest,
    user: dict = Depends(get_current_user)
):
    # Check user's subscription tier for rate limit
    limit = RATE_LIMITS[user["subscription"]["plan"]]
    
    current_usage = await usage_service.get_minute_usage(user["uid"])
    if current_usage >= limit:
        raise HTTPException(429, "Rate limit exceeded")
    
    result = await generate_content(request)
    await usage_service.increment_usage(user["uid"])
    return result
```

---

## PART 2: API ENDPOINT DESIGN

### 2.1 RESTful Principles

**✅ DO: Follow REST conventions**
```python
from fastapi import APIRouter

router = APIRouter(prefix="/api", tags=["Content"])

# ✅ CORRECT - RESTful endpoints
@router.post("/generations")
async def create_generation(request: GenerationRequest):
    """Create new generation - POST (create resource)"""
    pass

@router.get("/generations")
async def list_generations(skip: int = 0, limit: int = 10):
    """List all generations - GET (retrieve resources)"""
    pass

@router.get("/generations/{generation_id}")
async def get_generation(generation_id: str):
    """Get single generation - GET (retrieve specific resource)"""
    pass

@router.put("/generations/{generation_id}")
async def update_generation(generation_id: str, request: UpdateRequest):
    """Update generation - PUT (full update)"""
    pass

@router.patch("/generations/{generation_id}")
async def partial_update_generation(generation_id: str, request: PatchRequest):
    """Partial update - PATCH (partial update)"""
    pass

@router.delete("/generations/{generation_id}")
async def delete_generation(generation_id: str):
    """Delete generation - DELETE (remove resource)"""
    pass

# ❌ WRONG - Non-RESTful
@router.get("/generate_content")  # Should be POST
@router.get("/get_all_generations")  # Should be GET /generations
@router.get("/delete_generation")  # DELETE should not be GET!
```

### 2.2 Status Code Best Practices

**✅ DO: Use appropriate HTTP status codes**
```python
from fastapi import HTTPException, status

# ✅ 200 OK - Success, return data
@app.get("/api/generations", status_code=status.HTTP_200_OK)
async def list(): return [...]

# ✅ 201 Created - Resource created
@app.post("/api/generations", status_code=status.HTTP_201_CREATED)
async def create(): return created_resource

# ✅ 204 No Content - Success, no response body
@app.delete("/api/generations/{id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete(): pass

# ✅ 400 Bad Request - Invalid input
if not validate(data):
    raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invalid input")

# ✅ 401 Unauthorized - Not authenticated
if not user:
    raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Not authenticated")

# ✅ 403 Forbidden - Authenticated but not authorized
if user["subscription"]["plan"] == "free":
    raise HTTPException(status.HTTP_403_FORBIDDEN, "Premium only")

# ✅ 404 Not Found - Resource doesn't exist
if not resource:
    raise HTTPException(status.HTTP_404_NOT_FOUND, "Not found")

# ✅ 409 Conflict - Resource already exists
if email_exists:
    raise HTTPException(status.HTTP_409_CONFLICT, "Email already registered")

# ✅ 429 Too Many Requests - Rate limit exceeded
if rate_limit_exceeded:
    raise HTTPException(status.HTTP_429_TOO_MANY_REQUESTS, "Rate limit")

# ✅ 500 Internal Server Error - Server error
# (FastAPI handles this automatically for unhandled exceptions)
```

### 2.3 API Versioning Strategy

**✅ DO: Version your API for backwards compatibility**
```python
from fastapi import APIRouter

# v1 endpoints
v1_router = APIRouter(prefix="/api/v1", tags=["v1"])

@v1_router.post("/generations")
async def create_generation_v1(request: GenerationRequestV1):
    """Version 1 endpoint"""
    pass

# v2 endpoints (improved, breaking changes)
v2_router = APIRouter(prefix="/api/v2", tags=["v2"])

@v2_router.post("/generations")
async def create_generation_v2(request: GenerationRequestV2):
    """Version 2 endpoint with new features"""
    pass

# Include both versions
app.include_router(v1_router)
app.include_router(v2_router)

# ✅ Deprecation headers
from fastapi import Response

@v1_router.post("/generations")
async def create_v1(response: Response):
    response.headers["Deprecation"] = "true"
    response.headers["Sunset"] = "Sun, 01 Jan 2025 00:00:00 GMT"
    response.headers["Link"] = '</api/v2/generations>; rel="successor-version"'
    pass
```

---

## PART 3: FIREBASE + FASTAPI INTEGRATION PATTERNS

### 3.1 Firestore Query Patterns

**✅ DO: Use efficient Firestore queries**
```python
from firebase_admin import firestore

db = firestore.client()

# ✅ CORRECT - Efficient queries
async def get_user_generations(uid: str, limit: int = 10):
    # Index on (userId, createdAt)
    docs = (
        db.collection("generations")
        .where("userId", "==", uid)
        .order_by("createdAt", direction=firestore.Query.DESCENDING)
        .limit(limit)
        .stream()
    )
    return [{"id": doc.id, **doc.to_dict()} for doc in docs]

# ✅ CORRECT - Pagination
async def get_generations_paginated(uid: str, page: int = 1, page_size: int = 20):
    offset = (page - 1) * page_size
    
    docs = (
        db.collection("generations")
        .where("userId", "==", uid)
        .order_by("createdAt", direction=firestore.Query.DESCENDING)
        .offset(offset)
        .limit(page_size)
        .stream()
    )
    return [{"id": doc.id, **doc.to_dict()} for doc in docs]

# ✅ CORRECT - Batch updates (efficient)
def batch_update_generations(updates: dict):
    batch = db.batch()
    for gen_id, new_data in updates.items():
        doc_ref = db.collection("generations").document(gen_id)
        batch.update(doc_ref, new_data)
    batch.commit()

# ❌ WRONG - Inefficient queries
async def all_generations():
    # DON'T query all documents without user filter!
    docs = db.collection("generations").stream()
    return [{"id": doc.id, **doc.to_dict()} for doc in docs]

# ❌ WRONG - N+1 queries
async def get_users_and_generations(user_ids: list):
    results = []
    for uid in user_ids:
        # Query database for EACH user (N+1 problem!)
        gens = await get_user_generations(uid)
        results.append(gens)
    return results
```

### 3.2 Real-time Listener Pattern

**✅ DO: Use real-time listeners for live data**
```python
from firebase_admin import firestore
import asyncio

async def listen_to_user_usage(uid: str, callback):
    """Real-time usage updates"""
    
    def on_snapshot(docs, changes, read_time):
        for doc in docs:
            user_data = doc.to_dict()
            asyncio.run(callback(user_data))
    
    db.collection("users").document(uid).on_snapshot(on_snapshot)

# In your endpoint
async def get_usage_stream(user: dict = Depends(get_current_user)):
    async def usage_updated(data):
        yield {
            "used": data["usageThisMonth"]["generations"],
            "limit": data["subscription"]["generationsPerMonth"],
        }
    
    await listen_to_user_usage(user["uid"], usage_updated)

# WebSocket endpoint for real-time updates
@app.websocket("/ws/usage/{user_id}")
async def websocket_usage(websocket: WebSocket, user_id: str):
    await websocket.accept()
    
    async def send_update(data):
        await websocket.send_json(data)
    
    await listen_to_user_usage(user_id, send_update)
```

---

## PART 4: TESTING YOUR FASTAPI APP

**✅ DO: Write tests for all endpoints**
```python
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

@pytest.fixture
def auth_token():
    """Fixture to get test auth token"""
    return "test_token_123"

def test_health_check():
    """Test health endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

@pytest.mark.asyncio
async def test_generate_content(auth_token):
    """Test content generation"""
    response = client.post(
        "/api/generate/content",
        headers={"Authorization": f"Bearer {auth_token}"},
        json={
            "contentType": "blog",
            "userInput": "Write about machine learning"
        }
    )
    assert response.status_code == 200
    assert "content" in response.json()

@pytest.mark.asyncio
async def test_rate_limit(auth_token):
    """Test rate limiting"""
    for i in range(101):
        response = client.post(
            "/api/generate/content",
            headers={"Authorization": f"Bearer {auth_token}"},
            json={"contentType": "blog", "userInput": "Test" * 10}
        )
    
    # 101st request should be rate limited
    assert response.status_code == 429
```

---

## PART 5: DEPLOYMENT CHECKLIST

Before deploying to production:

**Security:**
- [ ] Remove DEBUG mode
- [ ] Set strong JWT secret
- [ ] Enable HTTPS only
- [ ] Set proper CORS origins
- [ ] Rate limit endpoints
- [ ] Validate all inputs
- [ ] Never expose error details

**Performance:**
- [ ] Use connection pooling
- [ ] Enable caching
- [ ] Optimize database queries
- [ ] Set proper pagination limits
- [ ] Use background tasks for long operations

**Monitoring:**
- [ ] Setup error tracking (Sentry)
- [ ] Configure logging
- [ ] Monitor API response times
- [ ] Track database performance
- [ ] Monitor rate limits

**Testing:**
- [ ] 80%+ code coverage
- [ ] Integration tests pass
- [ ] Load testing (100+ concurrent users)
- [ ] Security audit

---

## SUMMARY

**FastAPI Best Practices for Your Project:**
1. ✅ Use async/await for I/O operations
2. ✅ Chain dependencies for reusability
3. ✅ Handle errors centrally with custom exceptions
4. ✅ Validate with Pydantic, not manual code
5. ✅ Use response models for documentation
6. ✅ Use background tasks for long operations
7. ✅ Implement structured logging
8. ✅ Follow REST conventions
9. ✅ Use appropriate HTTP status codes
10. ✅ Version your API

These practices will make your code **production-ready, scalable, and maintainable**! 🚀
