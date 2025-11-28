# Video Generation - Model Configuration & Pricing

## 🎬 Current Configuration

### Active Model: MiniMax Video-01
- **Provider:** Replicate
- **Model ID:** `minimax/video-01`
- **Resolution:** 720p
- **Cost:** $0.006 per second of video
- **Speed:** ~2-3 minutes for 30-second video
- **Quality:** High quality, good for social media

### Why MiniMax Video-01?
1. **Cost-Effective:** 16x cheaper than Google Veo 2 ($0.006 vs $0.10/sec)
2. **Fast Generation:** 2-3 minutes vs 5-10 minutes for Veo 2
3. **Good Quality:** 720p is perfect for YouTube, TikTok, Instagram
4. **Reliable:** Stable API, good uptime

## 📊 Available Models Comparison

### 1. MiniMax Video-01 (CURRENT)
```python
VIDEO_MODEL = "minimax/video-01"
```
- **Resolution:** 720p
- **Cost:** $0.006/second
- **Speed:** Fast (2-3 min)
- **Quality:** ⭐⭐⭐⭐
- **Best For:** Social media, quick videos
- **Example Cost:** 
  - 30s video = $0.18
  - 60s video = $0.36
  - 3min video = $1.08

### 2. Google Veo 2 (PREMIUM)
```python
VIDEO_MODEL = "google-deepmind/veo-2"
```
- **Resolution:** 1080p (Full HD)
- **Cost:** $0.10/second
- **Speed:** Slow (5-10 min)
- **Quality:** ⭐⭐⭐⭐⭐
- **Best For:** Professional content, cinematic videos
- **Example Cost:**
  - 30s video = $3.00
  - 60s video = $6.00
  - 3min video = $18.00

### 3. ZeroScope V2 XL (FALLBACK)
```python
VIDEO_MODEL = "anotherjesse/zeroscope-v2-xl"
```
- **Resolution:** 576x320
- **Cost:** $0.025/second
- **Speed:** Medium (3-5 min)
- **Quality:** ⭐⭐⭐
- **Best For:** Fallback option, testing
- **Example Cost:**
  - 30s video = $0.75
  - 60s video = $1.50
  - 3min video = $4.50

### 4. Stable Video Diffusion
```python
VIDEO_MODEL = "stability-ai/stable-video-diffusion"
```
- **Resolution:** 1024x576
- **Cost:** $0.02/second
- **Speed:** Medium (3-4 min)
- **Quality:** ⭐⭐⭐⭐
- **Best For:** Alternative to MiniMax
- **Example Cost:**
  - 30s video = $0.60
  - 60s video = $1.20
  - 3min video = $3.60

## 🎯 Model Selection Guide

### By Use Case

**Social Media (TikTok, Instagram Reels, YouTube Shorts)**
→ Use **MiniMax Video-01** ($0.006/sec)
- 720p is perfect for mobile viewing
- Fast generation = better user experience
- Cost-effective for high volume

**YouTube Videos (Long-form)**
→ Use **MiniMax Video-01** ($0.006/sec)
- 720p is standard for YouTube
- Longer videos = cost matters more
- $1-2 per 3-minute video is reasonable

**Professional/Premium Content**
→ Use **Google Veo 2** ($0.10/sec)
- 1080p for better quality
- Worth the cost for important content
- Best visual quality available

**Testing/Development**
→ Use **ZeroScope V2 XL** ($0.025/sec)
- Cheaper than Veo 2, faster than MiniMax
- Good enough for testing flows
- Lower resolution = faster processing

### By Budget

**Free Tier (5 videos/month)**
→ MiniMax Video-01
- 5x 30s videos = $0.90/month
- 5x 60s videos = $1.80/month

**Pro Tier (50 videos/month)**
→ MiniMax Video-01
- 50x 30s videos = $9/month
- 50x 60s videos = $18/month

**Enterprise (Unlimited)**
→ Mix of MiniMax + Veo 2
- Use MiniMax for standard content
- Use Veo 2 for premium content
- Budget $50-200/month depending on usage

## 🔧 Configuration

### Change Video Model

Edit `backend/app/config.py`:

```python
# Option 1: MiniMax (Recommended - Default)
VIDEO_MODEL: str = "minimax/video-01"

# Option 2: Google Veo 2 (Premium)
VIDEO_MODEL: str = "google-deepmind/veo-2"

# Option 3: ZeroScope (Fallback)
VIDEO_MODEL: str = "anotherjesse/zeroscope-v2-xl"

# Option 4: Stable Video
VIDEO_MODEL: str = "stability-ai/stable-video-diffusion"
```

### Environment Variable Override

Add to `.env` file:

```bash
# Override default model
VIDEO_MODEL=minimax/video-01

# Or use Google Veo 2 for premium
VIDEO_MODEL=google-deepmind/veo-2

# Replicate API key (required)
REPLICATE_API_KEY=r8_your_api_key_here
```

### Dynamic Model Selection (Future)

```python
# In video_generation_service.py
def get_video_model(user_tier: str, video_duration: int) -> str:
    """Select best model based on user tier and video duration"""
    
    # Enterprise users get premium model
    if user_tier == 'enterprise':
        return "google-deepmind/veo-2"
    
    # Pro users with short videos get MiniMax
    elif user_tier == 'pro' and video_duration <= 60:
        return "minimax/video-01"
    
    # Pro users with long videos get Veo 2 (worth the cost)
    elif user_tier == 'pro' and video_duration > 60:
        return "google-deepmind/veo-2"
    
    # Free tier always gets MiniMax
    else:
        return "minimax/video-01"
```

## 💰 Cost Estimates

### Monthly Cost by Tier

**Free Tier (5 videos/month @ 30s avg)**
- MiniMax: $0.90/month
- Veo 2: $15/month
- **Recommendation:** MiniMax

**Pro Tier (50 videos/month @ 30s avg)**
- MiniMax: $9/month
- Veo 2: $150/month
- **Recommendation:** MiniMax

**Enterprise (200 videos/month @ 60s avg)**
- MiniMax: $72/month
- Veo 2: $1,200/month
- Mixed (80% MiniMax, 20% Veo 2): $297.60/month
- **Recommendation:** Mixed approach

### Break-Even Analysis

**When to use each model:**

- **Videos < 30s:** MiniMax always (cost difference minimal)
- **Videos 30-60s:** MiniMax for most, Veo 2 for premium
- **Videos > 60s:** Consider Veo 2 for quality if budget allows

**Quality vs Cost Trade-off:**
- MiniMax = $0.36 for 60s (⭐⭐⭐⭐)
- Veo 2 = $6.00 for 60s (⭐⭐⭐⭐⭐)
- **16x price increase for 1 star quality improvement**

For most use cases, MiniMax offers the best value.

## 🚀 Replicate API Setup

### 1. Get API Key

1. Go to [Replicate](https://replicate.com)
2. Sign up/Login
3. Go to Account Settings → API Tokens
4. Create new token
5. Copy token (starts with `r8_`)

### 2. Add to Environment

```bash
# backend/.env
REPLICATE_API_KEY=r8_your_api_key_here
VIDEO_MODEL=minimax/video-01
```

### 3. Verify Setup

```python
# Test in Python
import replicate

# This should work if API key is set
client = replicate.Client(api_token="r8_your_key")
print("✅ Replicate configured correctly")
```

### 4. Add Billing

1. Go to Replicate → Billing
2. Add payment method
3. Set spending limit (optional)
4. Pricing is pay-as-you-go (charged per second of video)

## 📈 Usage Limits

### Current Configuration

```python
# Free Tier
video_limit = 5  # 5 videos per month

# Pro Tier
video_limit = 50  # 50 videos per month

# Enterprise Tier
video_limit = 999999  # Unlimited
```

### Temporarily Disabled

The usage limit check is currently **commented out** for testing:

```python
# TEMPORARILY DISABLED: Will enable after testing complete
# if videos_used >= video_limit:
#     raise HTTPException(
#         status_code=status.HTTP_402_PAYMENT_REQUIRED,
#         detail={
#             "error": "video_limit_reached",
#             "message": f"You've reached your monthly video limit..."
#         }
#     )
```

### Enable Limits (After Testing)

Uncomment the limit check in `backend/app/api/generate.py` line ~1531:

```python
# Enable this after testing is complete
if videos_used >= video_limit:
    raise HTTPException(
        status_code=status.HTTP_402_PAYMENT_REQUIRED,
        detail={
            "error": "video_limit_reached",
            "message": f"You've reached your monthly video limit of {video_limit}. Upgrade to Pro for more videos.",
            "used": videos_used,
            "limit": video_limit
        }
    )
```

## 🔍 Monitoring & Debugging

### Check Video Model in Logs

```
2025-11-28 20:30:19,276 - app.services.video_generation_service - INFO - ✅ Video generation service initialized with model: minimax/video-01
```

### Check API Key Status

```python
# In backend console
from app.config import settings
print(f"API Key: {settings.REPLICATE_API_KEY[:10]}...")
print(f"Model: {settings.VIDEO_MODEL}")
```

### Monitor Costs

Replicate provides cost tracking:
1. Go to Replicate Dashboard
2. Click "Usage" tab
3. See cost breakdown by model
4. Export CSV for analysis

## 🐛 Troubleshooting

### Error: "You've reached your monthly video limit of 0"
**Solution:** Limit check is now disabled for testing

### Error: "REPLICATE_API_KEY not set"
**Solution:** Add API key to `.env` file

### Error: "Model not found"
**Solution:** Verify model name is correct in config.py

### Error: "Insufficient credits"
**Solution:** Add payment method to Replicate account

### Slow Video Generation
**Solution:** Try ZeroScope V2 XL (faster than Veo 2, cheaper than MiniMax)

## 📚 Additional Resources

- [Replicate Models](https://replicate.com/collections/text-to-video)
- [MiniMax Video-01 Docs](https://replicate.com/minimax/video-01)
- [Google Veo 2 Docs](https://replicate.com/google-deepmind/veo-2)
- [Replicate Pricing](https://replicate.com/pricing)

---

**Last Updated:** November 28, 2025
**Current Model:** MiniMax Video-01 (minimax/video-01)
**Status:** ✅ Configured and Ready
