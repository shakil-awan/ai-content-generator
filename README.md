# 🚀 Summarly - AI Content Generator with Fact-Checking

**"The Only AI Content Generator That Fact-Checks Itself"**

AI-powered content generation platform creating fact-checked, high-quality content across 6 formats: blog posts, social media, emails, product descriptions, ad copy, and video scripts.

## 📊 Project Status

**Phase:** Backend Foundation & Setup  
**Started:** November 21, 2025  
**Target Launch:** December 17, 2025  
**Current Progress:** ~30% Backend Complete  

**📋 Track Progress:** [.github/instructions/WORK_PROGRESS.md](./.github/instructions/WORK_PROGRESS.md)  
**📖 Full Specifications:** [.github/instructions/ai_content_generator_blue_print.md](./.github/instructions/ai_content_generator_blue_print.md)

---

## 🎯 Core Features

### Content Types (6 Total)
1. **Long-Form Blog Posts** - 2,000-5,000 words with SEO optimization
2. **Social Media Captions** - LinkedIn, Twitter, Instagram, TikTok
3. **Email Campaigns** - Newsletter, promotional, nurture sequences
4. **Product Descriptions** - E-commerce optimized with benefits
5. **Ad Copy** - Google Ads, Facebook Ads, display ads
6. **Video Scripts** - YouTube, TikTok, Instagram Reels

### Unique Features
- ✅ **Fact-Checking** - Real-time verification with citations
- ✅ **Quality Guarantee** - Free regenerations if below threshold
- ✅ **Multi-AI Models** - OpenAI GPT-4, Google Gemini fallback
- ✅ **Tiered Pricing** - Free (5/mo), Hobby ($9), Pro ($29)

### Current Implementation Status
- ✅ Backend architecture (service layer, schemas, constants)
- ✅ Firebase service (~80% complete)
- ✅ OpenAI service (~60% complete)
- ❌ API endpoints (0/15 built)
- ❌ Authentication system
- ❌ Email notifications
- ❌ Payment webhooks

---

## 🚀 Quick Start

### Backend Setup (Currently Active)

```bash
# 1. Navigate to backend
cd backend

# 2. Activate virtual environment
source .venv/bin/activate  # Already created

# 3. Run development server
uvicorn app.main:app --reload

# 4. Access API Documentation
# Swagger UI: http://localhost:8000/docs
# Health Check: http://localhost:8000/health
```

### Configuration
Edit `backend/.env` with your API keys:
- `OPENAI_API_KEY` - OpenAI API key
- `FIREBASE_PROJECT_ID` - Firebase project ID
- `STRIPE_SECRET_KEY` - Stripe secret key (test mode)
- See `backend/.env.example` for all options

---

## 📚 Documentation

### Essential Docs
- **[📖 Complete Blueprint](./.github/instructions/ai_content_generator_blue_print.md)** - Full product specifications (4000+ lines)
- **[📊 Work Progress](./.github/instructions/WORK_PROGRESS.md)** - Current status, daily updates, task tracking
- **[🎯 Quick Reference](./AI_ASSISTANT_QUICK_REFERENCE.md)** - Technical decisions & setup guide
- **[⚡ Backend Setup](./BACKEND_SETUP.md)** - Quick start commands

### Additional Resources
- `backend/README.md` - Backend-specific documentation
- `backend/ARCHITECTURE_SUMMARY.md` - Architecture overview
- `.github/instructions/TECHNICAL_DECISIONS.md` - Design patterns
- `.github/instructions/PROJECT_INSTRUCTIONS.md` - Coding standards

---

## 🛠️ Tech Stack

**Backend:** FastAPI (Python), Firebase Firestore, Redis, OpenAI GPT-4, Stripe  
**Frontend:** Flutter/Dart (planned)  
**DevOps:** Docker, GitHub Actions (planned)

---

## 📞 Development Notes

**This Week (Nov 25-29):**
- Implementing authentication system
- Building email notification service
- Creating API endpoints for content generation
- Adding rate limiting and error handling

See [WORK_PROGRESS.md](./.github/instructions/WORK_PROGRESS.md) for detailed task breakdown.

---

**Built with FastAPI & Flutter**  
*Last Updated: November 24, 2025*
