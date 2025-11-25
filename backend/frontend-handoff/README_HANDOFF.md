# 🚀 API Handoff Package - Frontend Integration

**Package Date:** November 25, 2025  
**API Version:** 1.0  
**Status:** Production Ready ✅

---

## 📦 Package Contents

This package contains everything the frontend team needs to integrate with the backend API:

```
backend/
├── API_HANDOFF.md              # Complete developer guide
├── openapi.json                # OpenAPI 3.0 specification
├── postman_collection.json     # Postman collection (ready to import)
├── API_TESTING_GUIDE.md        # Testing examples
├── .env.example                # Environment variables template
└── requirements.txt            # Python dependencies (if running locally)
```

---

## 🎯 Quick Start for Frontend Developers

### Option 1: Use Remote Backend (Recommended)

If the backend is deployed, simply use the production URL:

```typescript
const API_BASE_URL = 'https://api.yourapp.com';

// All requests go to this URL
fetch(`${API_BASE_URL}/api/v1/auth/login`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email, password })
});
```

### Option 2: Run Backend Locally

If you need to run the backend on your machine:

```bash
# 1. Clone repository
git clone <repo-url>
cd backend

# 2. Create virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Set up environment (get .env from backend team)
cp .env.example .env
# Edit .env with provided API keys

# 5. Run server
python -m uvicorn app.main:app --reload --port 8001

# Server will be available at: http://localhost:8001
```

---

## 📚 Available Documentation

### 1. Interactive Documentation (Best for Exploration)

**Swagger UI:** `http://localhost:8001/docs`
- Try all endpoints directly in browser
- See request/response schemas
- Test with your JWT token
- Copy curl commands

**ReDoc:** `http://localhost:8001/redoc`
- Beautiful, readable documentation
- Better for learning API structure

### 2. Developer Guide (Best for Implementation)

**File:** `API_HANDOFF.md`

Contains:
- Authentication flow with examples
- All 28 endpoints explained
- TypeScript interfaces
- Error handling
- Common use cases
- Rate limiting info

### 3. OpenAPI Specification (Best for Code Generation)

**File:** `openapi.json`

Use with:
- **Swagger Codegen** - Generate TypeScript/Dart client
- **OpenAPI Generator** - Generate SDK for any language
- **Postman** - Import and test
- **VS Code REST Client** - Test directly in editor

### 4. Postman Collection (Best for Testing)

**File:** `postman_collection.json`

**How to use:**
1. Open Postman
2. Click "Import" → Select `postman_collection.json`
3. Create environment variables:
   - `BASE_URL` = `http://localhost:8001`
   - `TOKEN` = (will be set automatically after login)
4. Run "Login" request → Token auto-saved
5. Try any endpoint!

---

## 🔐 Authentication Implementation

### Step 1: Login Flow

```typescript
// Login function
async function login(email: string, password: string) {
  const response = await fetch('http://localhost:8001/api/v1/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password })
  });
  
  if (!response.ok) {
    throw new Error('Login failed');
  }
  
  const data = await response.json();
  
  // Store tokens securely
  localStorage.setItem('access_token', data.access_token);
  localStorage.setItem('refresh_token', data.refresh_token);
  
  return data.user;
}
```

### Step 2: Authenticated Requests

```typescript
// API helper
async function apiRequest(endpoint: string, options: RequestInit = {}) {
  const token = localStorage.getItem('access_token');
  
  const response = await fetch(`http://localhost:8001${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
      ...options.headers
    }
  });
  
  // Handle token expiry
  if (response.status === 401) {
    await refreshToken();
    return apiRequest(endpoint, options); // Retry
  }
  
  return response.json();
}

// Use it
const profile = await apiRequest('/api/v1/users/profile');
```

### Step 3: Token Refresh

```typescript
async function refreshToken() {
  const refreshToken = localStorage.getItem('refresh_token');
  
  const response = await fetch('http://localhost:8001/api/v1/auth/refresh', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refresh_token: refreshToken })
  });
  
  const data = await response.json();
  localStorage.setItem('access_token', data.access_token);
  return data.access_token;
}
```

---

## 🎨 Example: Complete Feature Implementation

### Feature: Generate and Humanize Blog Post

```typescript
// 1. Generate blog post
async function generateBlog(topic: string) {
  const generation = await apiRequest('/api/v1/generate/blog', {
    method: 'POST',
    body: JSON.stringify({
      topic,
      tone: 'professional',
      length: 'medium',
      keywords: ['AI', 'technology']
    })
  });
  
  return generation;
}

// 2. Check AI detection score
async function detectAI(generationId: string) {
  const detection = await apiRequest(
    `/api/v1/humanize/detect/${generationId}`,
    { method: 'POST' }
  );
  
  return detection.aiScore; // 0-100
}

// 3. Humanize if needed
async function humanizeContent(generationId: string) {
  const result = await apiRequest(
    `/api/v1/humanize/${generationId}`,
    {
      method: 'POST',
      body: JSON.stringify({
        level: 'balanced',
        preserve_facts: true
      })
    }
  );
  
  return result;
}

// Complete workflow
async function createHumanizedBlog(topic: string) {
  // Generate
  const blog = await generateBlog(topic);
  console.log('Generated:', blog.id);
  
  // Check AI score
  const aiScore = await detectAI(blog.id);
  console.log('AI Score:', aiScore);
  
  // Humanize if score is high
  if (aiScore > 70) {
    const humanized = await humanizeContent(blog.id);
    console.log('Improvement:', humanized.improvement);
    return humanized;
  }
  
  return blog;
}
```

---

## ⚠️ Important Notes for Frontend Team

### 1. Rate Limiting

- Free tier: 5 generations/month, 3 humanizations/month
- API returns `402 Payment Required` when limit reached
- Show upgrade prompt to user

### 2. Error Handling

Always handle these cases:
- `401` - Token expired → Refresh token
- `402` - Limit reached → Show upgrade modal
- `429` - Rate limit → Wait and retry
- `500` - Server error → Show error message

### 3. Environment Variables

```typescript
// config.ts
export const API_CONFIG = {
  BASE_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8001',
  TIMEOUT: 30000, // 30 seconds
  RETRY_ATTEMPTS: 3
};
```

### 4. Loading States

Some endpoints take time:
- Blog generation: 10-15 seconds
- Humanization: 30-45 seconds (makes 3 API calls)
- Show loading indicators!

### 5. Webhook Handling (Stripe)

After payment, user is redirected to success URL.
Subscription is updated automatically via webhook.
Frontend should:
1. Show success message
2. Refresh user data
3. Show new limits

---

## 🧪 Testing Checklist

Before deploying frontend:

- [ ] Can register new user
- [ ] Can login and get token
- [ ] Can generate blog post
- [ ] Can humanize content
- [ ] Can view usage stats
- [ ] Can create checkout session
- [ ] Handles token expiry gracefully
- [ ] Shows error messages properly
- [ ] Loading states work
- [ ] Can logout

---

## 📞 Support & Questions

### Common Questions

**Q: What's the token expiry time?**
A: 24 hours. Use refresh token to get new access token.

**Q: How to handle rate limits?**
A: API returns `402` with details. Show upgrade modal.

**Q: Can I test without API keys?**
A: Contact backend team for test API keys.

**Q: What's the difference between OpenAI and Gemini?**
A: Backend automatically switches to Gemini when OpenAI hits limits. Transparent to frontend.

**Q: How do I test Stripe payments?**
A: Use Stripe test cards: `4242 4242 4242 4242` (any future expiry/CVC)

### Getting Help

1. **Check Swagger UI first:** http://localhost:8001/docs
2. **Read API_HANDOFF.md** for detailed examples
3. **Import Postman collection** to test endpoints
4. **Contact backend team** for API keys or issues

---

## 🎉 Ready to Start!

1. ✅ Import `postman_collection.json` into Postman
2. ✅ Read `API_HANDOFF.md` for implementation examples
3. ✅ Get API keys from backend team
4. ✅ Start building!

**Happy coding!** 🚀

---

*Last updated: November 25, 2025*
