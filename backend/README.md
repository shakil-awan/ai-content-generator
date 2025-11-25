# Summarly Backend - FastAPI

## 🎯 Project Overview
AI-Powered Content Generation Backend with Fact-Checking
**"The Only AI Content Generator That Fact-Checks Itself"**

## 📊 Current Status (Nov 24, 2025)

### ✅ Implemented & Working:
- **28 API Endpoints** - All routes with `/api/v1` prefix
- **User Registration** - Creates users in Firestore with UUID
- **Firebase Integration** - Real-time data writes confirmed
- **Password Security** - Bcrypt hashing (v4.0.1)
- **JWT Authentication** - Token generation working
- **Google OAuth** - Endpoint ready (needs frontend)
- **Content Generation** - 6 types (blog, social, email, product, ad, video)
- **AI Humanization** - Detection + rewriting (3 endpoints)
- **Stripe Billing** - 7 endpoints with webhook support
- **Stats Tracking** - Real-time counters (start at 0, increment on actions)

### ⚠️ Known Issue:
- **UserResponse Schema**: Field name mismatch (snake_case vs camelCase)
  - Firebase returns: `usageThisMonth`, `allTimeStats`, `brandVoice`
  - Schema expects: `usage_this_month`, `all_time_stats`, `brand_voice`
  - **Impact**: API responses fail validation (but data writes correctly)
  - **Fix**: Update schema field names to match Firebase (5 min task)

### 🧪 Testing Results:
- Users in Firestore: 4 test accounts created
- Server: Running on port 8001 with auto-reload
- Health: All services initialized (Firebase, Redis, Stripe, OpenAI)
- See `API_TESTING_GUIDE.md` for detailed test results

## 📁 Project Structure
```
backend/
├── app/
│   ├── main.py              # FastAPI entry point
│   ├── config.py            # Configuration & environment variables
│   ├── dependencies.py      # Dependency injection
│   │
│   ├── api/                 # API endpoints
│   │   ├── auth.py         # Authentication
│   │   ├── generate.py     # Content generation
│   │   ├── billing.py      # Billing & subscriptions
│   │   ├── user.py         # User management
│   │   └── api_keys.py     # API keys
│   │
│   ├── services/            # Business logic
│   │   ├── firebase_service.py
│   │   ├── openai_service.py
│   │   ├── factcheck_service.py
│   │   ├── quality_service.py
│   │   └── stripe_service.py
│   │
│   ├── schemas/             # Pydantic models
│   ├── models/              # Firestore document structures
│   ├── middleware/          # Middleware (auth, rate limiting, etc.)
│   ├── utils/               # Helper functions
│   └── exceptions/          # Custom exceptions
│
├── tests/                   # Unit & integration tests
├── requirements.txt         # Python dependencies
├── .env.example            # Environment variables template
└── README.md               # This file
```

## 🚀 Setup Instructions

### Prerequisites
- Python 3.10+
- pip
- Virtual environment

### Step-by-Step Setup

#### 1️⃣ Navigate to backend directory
```bash
cd backend
```

#### 2️⃣ Create virtual environment
```bash
python3 -m venv .venv
```

#### 3️⃣ Activate virtual environment
```bash
# On macOS/Linux:
source .venv/bin/activate

# On Windows:
.venv\Scripts\activate
```

#### 4️⃣ Upgrade pip
```bash
pip install --upgrade pip
```

#### 5️⃣ Install dependencies
```bash
pip install -r requirements.txt
```

#### 6️⃣ Setup environment variables
```bash
cp .env.example .env
# Edit .env file with your actual API keys
```

#### 7️⃣ Run development server
```bash
# From backend/ directory:
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Or from project root:
cd ..
uvicorn backend.app.main:app --reload --host 0.0.0.0 --port 8000
```

## 📍 API Endpoints

### Development URLs
- **API Documentation (Swagger):** http://localhost:8000/docs
- **API Documentation (ReDoc):** http://localhost:8000/redoc
- **Health Check:** http://localhost:8000/health

### Planned API Structure
```
POST   /api/v1/auth/register          # User registration
POST   /api/v1/auth/login             # User login
POST   /api/v1/auth/google            # Google OAuth

POST   /api/v1/generate/blog          # Generate blog post
POST   /api/v1/generate/social        # Generate social media content
POST   /api/v1/generate/email         # Generate email campaign
POST   /api/v1/generate/product       # Generate product description
POST   /api/v1/generate/ad            # Generate ad copy
POST   /api/v1/generate/video-script  # Generate video script

GET    /api/v1/user/profile           # Get user profile
PATCH  /api/v1/user/profile           # Update user profile
GET    /api/v1/user/generations       # Get generation history
GET    /api/v1/user/usage             # Get usage statistics

POST   /api/v1/billing/subscribe      # Create subscription
POST   /api/v1/billing/cancel         # Cancel subscription
GET    /api/v1/billing/invoices       # Get invoices
POST   /api/v1/billing/webhook        # Stripe webhook

POST   /api/v1/api-keys/create        # Create API key
GET    /api/v1/api-keys               # List API keys
DELETE /api/v1/api-keys/:id           # Delete API key
```

## 🔧 Development Commands

### Run server with auto-reload
```bash
uvicorn app.main:app --reload
```

### Run server on custom port
```bash
uvicorn app.main:app --reload --port 3000
```

### Run tests
```bash
pytest
```

### Run tests with coverage
```bash
pytest --cov=app tests/
```

### Code formatting (Black)
```bash
black app/
```

### Linting (Flake8)
```bash
flake8 app/
```

### Type checking (MyPy)
```bash
mypy app/
```

## 🔑 Required API Keys

### Essential for MVP
1. **OpenAI** - Content generation
   - Sign up: https://platform.openai.com/
   
2. **Firebase** - Database & Auth
   - Create project: https://console.firebase.google.com/
   - Download service account JSON
   
3. **Stripe** - Payments
   - Sign up: https://dashboard.stripe.com/

### Optional (for enhanced features)
4. **Anthropic (Claude)** - Alternative LLM
5. **Google Gemini** - Alternative LLM
6. **Wolfram Alpha** - Fact-checking
7. **Sentry** - Error monitoring

## 📦 Tech Stack
- **Framework:** FastAPI
- **Server:** Uvicorn
- **Database:** Firebase Firestore
- **Authentication:** Firebase Auth + JWT
- **Payments:** Stripe
- **AI Models:** OpenAI GPT-4, Anthropic Claude, Google Gemini
- **Caching:** Redis
- **Testing:** Pytest
- **Monitoring:** Sentry

## 🐛 Troubleshooting

### Import errors after installing packages
```bash
# Deactivate and reactivate virtual environment
deactivate
source .venv/bin/activate
```

### Port already in use
```bash
# Kill process on port 8000
lsof -ti:8000 | xargs kill -9

# Or use different port
uvicorn app.main:app --reload --port 8001
```

### Firebase connection issues
- Verify `FIREBASE_PROJECT_ID` in `.env`
- Check service account JSON path
- Ensure Firebase Admin SDK is initialized

## 📚 Documentation
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- [OpenAI API](https://platform.openai.com/docs/)
- [Stripe API](https://stripe.com/docs/api)

## 🚢 Deployment
- **Recommended Platforms:** Railway, Render, Google Cloud Run, AWS ECS
- **Environment Variables:** Set all `.env` values in platform settings
- **Database:** Firebase Firestore (already cloud-based)
- **Redis:** Use managed Redis (Redis Cloud, AWS ElastiCache)

## 📝 Development Checklist
- [ ] Setup virtual environment
- [ ] Install dependencies
- [ ] Configure environment variables
- [ ] Test health check endpoint
- [ ] Setup Firebase connection
- [ ] Implement authentication endpoints
- [ ] Implement content generation endpoints
- [ ] Add fact-checking layer
- [ ] Add quality scoring
- [ ] Implement billing integration
- [ ] Write unit tests
- [ ] Deploy to staging

---

**Built with ❤️ for Summarly - The AI Content Generator That Fact-Checks Itself**
