# 🚀 LOCAL API TESTING GUIDE - Step by Step

**For Flutter Developer Testing APIs Locally Before Deployment**

---

## 📋 OVERVIEW

This guide will help you:
1. ✅ Start the backend API server locally (FastAPI on localhost:8000)
2. ✅ Setup Postman for API testing
3. ✅ Test all authentication and content generation endpoints
4. ✅ Verify changes work correctly before deployment

**Estimated Time: 15-20 minutes**

---

## 🔧 STEP 1: VERIFY ENVIRONMENT SETUP

### 1.1 Check if Python venv exists

```bash
cd /Users/muhammadshakil/Projects/ai_content_generator/backend
ls -la .venv
```

**If .venv exists:** ✅ Skip to Step 1.2
**If .venv does NOT exist:** Run this:

```bash
python3 -m venv .venv
```

### 1.2 Activate Python virtual environment

```bash
source .venv/bin/activate
```

You should see `(.venv)` in your terminal prompt.

### 1.3 Install dependencies

```bash
pip install -r requirements.txt
```

This installs FastAPI, Pydantic, Firebase, OpenAI, Gemini, etc.

### 1.4 Verify .env file has API keys

```bash
cat .env | grep -E "OPENAI_API_KEY|GEMINI_API_KEY|FIREBASE_PROJECT_ID"
```

**Required API keys:**
- ✅ `OPENAI_API_KEY=sk-...` (your OpenAI key)
- ✅ `GEMINI_API_KEY=...` (your Gemini key)
- ✅ `FIREBASE_PROJECT_ID=...` (your Firebase project)

**If missing:** Edit `.env` file and add your API keys.

---

## 🚀 STEP 2: START THE API SERVER LOCALLY

### 2.1 Start FastAPI server

Open a terminal and run:

```bash
cd /Users/muhammadshakil/Projects/ai_content_generator/backend
source .venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Expected Output:**
```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Started server process
INFO:     Application startup complete.
```

### 2.2 Verify server is running

Open your browser and visit:
- **API Docs (Swagger):** http://localhost:8000/docs
- **Health Check:** http://localhost:8000/health

You should see the interactive API documentation.

**✅ Keep this terminal open** - the server needs to stay running!

---

## 📮 STEP 3: SETUP POSTMAN

### 3.1 Download and Install Postman

**If not installed:**
1. Go to: https://www.postman.com/downloads/
2. Download Postman for macOS
3. Install and open Postman

### 3.2 Import the Postman Collection

**Option A: Import from file (Recommended)**
1. Open Postman
2. Click **"Import"** button (top left)
3. Click **"Upload Files"**
4. Select: `/Users/muhammadshakil/Projects/ai_content_generator/backend/postman_collection.json`
5. Click **"Import"**

You should see **"AI Content Generator API"** collection in the left sidebar.

**Option B: Import from URL**
1. Click **"Import"**
2. Paste: `http://localhost:8000/openapi.json`
3. Click **"Import"**

### 3.3 Create Postman Environment

1. Click **"Environments"** tab (left sidebar)
2. Click **"Create Environment"**
3. Name it: **"Local Testing"**
4. Add these variables:

| Variable | Initial Value | Current Value |
|----------|--------------|---------------|
| `base_url` | `http://localhost:8000` | `http://localhost:8000` |
| `access_token` | (leave empty) | (leave empty) |
| `user_id` | (leave empty) | (leave empty) |

5. Click **"Save"**
6. Select **"Local Testing"** environment from dropdown (top right)

---

## 🔐 STEP 4: TEST AUTHENTICATION

### 4.1 Register a New User

**Request:**
- **Method:** `POST`
- **URL:** `{{base_url}}/api/v1/auth/register`
- **Body (JSON):**

```json
{
  "email": "test@example.com",
  "password": "TestPassword123!",
  "full_name": "Test User",
  "phone_number": "+923001234567"
}
```

**Click "Send"**

**Expected Response (201 Created):**
```json
{
  "message": "User registered successfully",
  "user_id": "abc123xyz",
  "email": "test@example.com"
}
```

**✅ Copy the `user_id`** - you'll need it later!

### 4.2 Login and Get Access Token

**Request:**
- **Method:** `POST`
- **URL:** `{{base_url}}/api/v1/auth/login`
- **Body (JSON):**

```json
{
  "email": "test@example.com",
  "password": "TestPassword123!"
}
```

**Click "Send"**

**Expected Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "user_id": "abc123xyz",
    "email": "test@example.com",
    "full_name": "Test User"
  }
}
```

**✅ IMPORTANT: Copy the `access_token`**

### 4.3 Save Access Token to Environment

1. Go to **"Environments"** → **"Local Testing"**
2. Set `access_token` variable to the token you just copied
3. Set `user_id` variable to the user_id you got from registration
4. Click **"Save"**

**Now all your requests will automatically use this token!**

---

## 📝 STEP 5: TEST CONTENT GENERATION ENDPOINTS

### 5.1 Setup Authorization Header

For all content generation endpoints:
1. Go to **"Authorization"** tab
2. Type: **Bearer Token**
3. Token: `{{access_token}}`

This will automatically use the token from your environment.

---

### 5.2 Test Product Description Generation

**Request:**
- **Method:** `POST`
- **URL:** `{{base_url}}/api/v1/generate/product-description`
- **Headers:** Authorization: Bearer {{access_token}}
- **Body (JSON):**

```json
{
  "product_name": "Wireless Bluetooth Headphones",
  "category": "Electronics",
  "price": 99.99,
  "key_features": [
    "Active Noise Cancellation",
    "40-hour battery life",
    "Premium sound quality"
  ],
  "benefits": [
    "Immersive audio experience",
    "All-day comfort",
    "Travel-friendly"
  ],
  "target_audience": "Music lovers and travelers",
  "tone": "professional",
  "word_count": 150
}
```

**Click "Send"**

**Expected Response (200 OK):**
```json
{
  "content": "Experience premium audio with our Wireless Bluetooth Headphones...",
  "word_count": 152,
  "generation_time": 2.3,
  "metadata": {
    "model_used": "gemini-2.0-flash-exp",
    "tone": "professional",
    "cache_hit": false
  }
}
```

**✅ Verify:**
- Response is in English (or language of the input)
- Content is relevant to the product
- Word count is close to requested

---

### 5.3 Test Multilingual Content (Auto-Detection)

**Test Arabic:**
- **URL:** `{{base_url}}/api/v1/generate/blog-post`
- **Body (JSON):**

```json
{
  "topic": "الذكاء الاصطناعي في التعليم",
  "keywords": ["تعليم", "تكنولوجيا"],
  "tone": "informative",
  "word_count": 200
}
```

**Expected:** Response should be in **Arabic** automatically! ✅

**Test Spanish:**
```json
{
  "topic": "Beneficios del marketing digital",
  "keywords": ["marketing", "redes sociales"],
  "tone": "persuasive",
  "word_count": 200
}
```

**Expected:** Response should be in **Spanish** automatically! ✅

---

### 5.4 Test Social Media Post Generation

**Request:**
- **Method:** `POST`
- **URL:** `{{base_url}}/api/v1/generate/social-media-post`
- **Body (JSON):**

```json
{
  "topic": "New AI features in our app",
  "platform": "instagram",
  "tone": "casual",
  "include_hashtags": true,
  "include_emojis": true,
  "character_limit": 280
}
```

**Expected Response:**
```json
{
  "content": "🚀 Exciting news! We just launched AI-powered content generation...",
  "character_count": 275,
  "hashtags": ["#AI", "#ContentCreation", "#Innovation"],
  "platform_optimized": true
}
```

---

### 5.5 Test Ad Copy Generation

**Request:**
- **Method:** `POST`
- **URL:** `{{base_url}}/api/v1/generate/ad-copy`
- **Body (JSON):**

```json
{
  "product_service": "Premium Coffee Subscription",
  "target_audience": "Coffee enthusiasts aged 25-45",
  "unique_selling_point": "Ethically sourced, freshly roasted beans delivered monthly",
  "platform": "facebook",
  "campaign_goal": "conversions",
  "tone": "persuasive",
  "character_limit": 150
}
```

**Expected Response:**
```json
{
  "headline": "Wake Up to Premium Coffee Every Month",
  "body": "Discover ethically sourced, freshly roasted beans...",
  "cta": "Start Your Coffee Journey",
  "character_count": 148
}
```

---

### 5.6 Test Email Content Generation

**Request:**
- **Method:** `POST`
- **URL:** `{{base_url}}/api/v1/generate/email-content`
- **Body (JSON):**

```json
{
  "subject": "Welcome to Our Premium Service",
  "purpose": "Welcome new subscribers",
  "target_audience": "New premium subscribers",
  "key_points": [
    "Thank them for subscribing",
    "Explain premium benefits",
    "Provide next steps"
  ],
  "tone": "friendly",
  "word_count": 200
}
```

---

### 5.7 Test Video Script Generation

**Request:**
- **Method:** `POST`
- **URL:** `{{base_url}}/api/v1/generate/video-script`
- **Body (JSON):**

```json
{
  "topic": "5 AI Tools for Content Creators",
  "duration_minutes": 3,
  "target_audience": "Content creators and marketers",
  "key_points": [
    "AI writing assistants",
    "Image generation tools",
    "Video editing automation"
  ],
  "tone": "casual",
  "cta": "Try our AI platform today",
  "include_b_roll_suggestions": true
}
```

---

### 5.8 Test Podcast Script Generation

**Request:**
- **Method:** `POST`
- **URL:** `{{base_url}}/api/v1/generate/podcast-script`
- **Body (JSON):**

```json
{
  "topic": "The Future of AI in Business",
  "duration_minutes": 15,
  "number_of_hosts": 2,
  "style": "interview",
  "key_points": [
    "AI adoption trends",
    "Business automation",
    "Ethical considerations"
  ],
  "tone": "conversational"
}
```

---

## 🖼️ STEP 6: TEST IMAGE GENERATION

### 6.1 Generate Single Image

**Request:**
- **Method:** `POST`
- **URL:** `{{base_url}}/api/v1/generate/image`
- **Body (JSON):**

```json
{
  "prompt": "A modern minimalist office workspace with a laptop and coffee",
  "style": "photorealistic",
  "aspect_ratio": "16:9",
  "model": "flux-schnell"
}
```

**Expected Response:**
```json
{
  "image_url": "https://storage.googleapis.com/...",
  "prompt": "A modern minimalist office workspace...",
  "model_used": "flux-schnell",
  "generation_time": 5.2
}
```

**✅ Copy the `image_url` and paste it in your browser to view the image!**

### 6.2 Generate Multiple Image Variations

**Request:**
- **Method:** `POST`
- **URL:** `{{base_url}}/api/v1/generate/image/multiple`
- **Body (JSON):**

```json
{
  "prompt": "Futuristic AI assistant logo, tech startup",
  "style": "digital-art",
  "count": 3,
  "aspect_ratio": "1:1"
}
```

**Expected Response:**
```json
{
  "images": [
    {"url": "https://...", "variation": 1},
    {"url": "https://...", "variation": 2},
    {"url": "https://...", "variation": 3}
  ],
  "total_generated": 3
}
```

---

## 👤 STEP 7: TEST USER ENDPOINTS

### 7.1 Get Current User Profile

**Request:**
- **Method:** `GET`
- **URL:** `{{base_url}}/api/v1/user/me`
- **Headers:** Authorization: Bearer {{access_token}}

**Expected Response:**
```json
{
  "user_id": "abc123xyz",
  "email": "test@example.com",
  "full_name": "Test User",
  "subscription_tier": "free",
  "credits_remaining": 100
}
```

### 7.2 Get User Generation History

**Request:**
- **Method:** `GET`
- **URL:** `{{base_url}}/api/v1/user/history?limit=10`

**Expected Response:**
```json
{
  "history": [
    {
      "id": "gen_123",
      "type": "product-description",
      "created_at": "2025-11-25T10:30:00Z",
      "content_preview": "Experience premium audio..."
    }
  ],
  "total": 1
}
```

---

## 💳 STEP 8: TEST BILLING ENDPOINTS (OPTIONAL)

### 8.1 Get Subscription Plans

**Request:**
- **Method:** `GET`
- **URL:** `{{base_url}}/api/v1/billing/plans`

**Expected Response:**
```json
{
  "plans": [
    {
      "name": "Free",
      "price": 0,
      "credits_per_month": 100
    },
    {
      "name": "Hobby",
      "price": 9.99,
      "credits_per_month": 500
    },
    {
      "name": "Pro",
      "price": 29.99,
      "credits_per_month": 2000
    }
  ]
}
```

---

## ✅ STEP 9: VERIFICATION CHECKLIST

After testing, verify these work correctly:

- [ ] ✅ Server starts without errors
- [ ] ✅ User registration works
- [ ] ✅ User login returns access token
- [ ] ✅ Access token works for authenticated endpoints
- [ ] ✅ Product description generation works
- [ ] ✅ Blog post generation works
- [ ] ✅ Social media post generation works
- [ ] ✅ Ad copy generation works
- [ ] ✅ Email content generation works
- [ ] ✅ Video script generation works
- [ ] ✅ Podcast script generation works
- [ ] ✅ Image generation works (single)
- [ ] ✅ Image generation works (multiple)
- [ ] ✅ Multilingual auto-detection works (Arabic, Spanish, etc.)
- [ ] ✅ User profile endpoint works
- [ ] ✅ Generation history endpoint works

---

## 🐛 TROUBLESHOOTING

### Problem: Server won't start

**Solution:**
```bash
# Check if port 8000 is already in use
lsof -ti:8000 | xargs kill -9

# Restart server
source .venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Problem: "Authentication failed" error

**Solution:**
1. Make sure you copied the full access token
2. Check token is set in Postman environment
3. Token expires after 24 hours - login again to get new token

### Problem: "API key not configured" error

**Solution:**
```bash
# Verify .env file has API keys
cat .env | grep -E "OPENAI_API_KEY|GEMINI_API_KEY"

# If empty, add your keys to .env file
```

### Problem: Firebase error

**Solution:**
```bash
# Check firebase-service-account.json exists
ls -la /Users/muhammadshakil/Projects/ai_content_generator/assets/firebase-service-account.json
```

### Problem: "Module not found" error

**Solution:**
```bash
# Reinstall dependencies
source .venv/bin/activate
pip install -r requirements.txt
```

---

## 📱 STEP 10: INTEGRATE WITH FLUTTER APP

Once local testing is complete:

### 10.1 Update Flutter API Base URL

In your Flutter app, update the API base URL to:
```dart
const String baseUrl = 'http://localhost:8000';
```

**For iOS Simulator:** Use `http://localhost:8000`
**For Android Emulator:** Use `http://10.0.2.2:8000`

### 10.2 Test from Flutter App

1. Start the FastAPI server (keep it running)
2. Run your Flutter app
3. Test registration/login from the app
4. Test content generation from the app
5. Verify responses display correctly in UI

---

## 🚀 NEXT STEPS AFTER LOCAL TESTING

Once everything works locally:

1. ✅ Commit your changes to Git
2. ✅ Deploy backend to production (Fly.io or similar)
3. ✅ Update Flutter app with production API URL
4. ✅ Test on production environment
5. ✅ Deploy Flutter app to App Store / Play Store

---

## 📞 NEED HELP?

**Common Issues:**
- Port already in use → Kill process on port 8000
- API keys missing → Add to .env file
- Token expired → Login again to get new token
- Firebase errors → Check service account JSON file

**View API Documentation:**
- Swagger UI: http://localhost:8000/docs
- OpenAPI JSON: http://localhost:8000/openapi.json

---

## 📄 SUMMARY

**What You Accomplished:**
1. ✅ Started FastAPI server locally (localhost:8000)
2. ✅ Imported Postman collection for API testing
3. ✅ Tested authentication (register, login, get token)
4. ✅ Tested all 7 content generation endpoints
5. ✅ Tested image generation (single and multiple)
6. ✅ Verified multilingual auto-detection works
7. ✅ Tested user profile and history endpoints

**Your Backend is Production-Ready!** 🎉

Now you can integrate these APIs into your Flutter app with confidence.

---

**Last Updated:** November 25, 2025
**API Version:** v1
**Backend Status:** ✅ Production Ready
