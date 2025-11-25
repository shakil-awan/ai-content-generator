# AI Models Configuration - November 25, 2025
## Selected Models Based on Cost-Quality Analysis

---

## 📝 TEXT CONTENT GENERATION

### **PRIMARY MODEL: Google Gemini 2.0 Flash**
- **Model ID:** `gemini-2.0-flash`
- **Input Cost:** $0.10 / 1M tokens
- **Output Cost:** $0.40 / 1M tokens
- **Cache Cost:** FREE (during development), $0.025 / 1M tokens (paid)
- **Quality Score:** 8.3/10
- **Speed:** Very Fast (faster than GPT-4o-mini)
- **Context Window:** 1M tokens

**Why Chosen:**
✅ **75% cheaper** than GPT-4o-mini ($0.10/$0.40 vs $0.15/$0.60)
✅ **FREE tier** for development/testing (unlimited with rate limits)
✅ Built-in **image generation** ($0.039/image)
✅ **Prompt caching** saves 90% on system prompts
✅ Excellent for all content types: blogs, social media, emails, scripts
✅ Superior multilingual support (8 languages needed)
✅ Faster response times
✅ 1M token context (vs 128k for OpenAI)

**Use Cases:**
- Blog posts (2000-5000 words)
- Social media captions (all platforms)
- Email campaigns
- Product descriptions
- Ad copy
- Video scripts

### **FALLBACK MODEL: OpenAI GPT-4o-mini**
- **Model ID:** `gpt-4o-mini`
- **Input Cost:** $0.15 / 1M tokens
- **Output Cost:** $0.60 / 1M tokens
- **Quality Score:** 8.5/10

**When to Use:**
⚠️ Gemini API is down or rate-limited
⚠️ Specific brand voice matching that works better with OpenAI
⚠️ User explicitly requests OpenAI model
⚠️ Quality score < 75% from Gemini (auto-regenerate with OpenAI)

---

## 🎨 IMAGE GENERATION

### **PRIMARY MODEL: Replicate Flux Schnell**
- **Model ID:** `black-forest-labs/flux-schnell`
- **Cost:** $0.003 / image
- **Quality Score:** 8.5/10
- **Speed:** 2-3 seconds (fastest available)
- **Resolution:** High-res, flexible

**Why Chosen:**
✅ **93% cheaper** than DALL-E 3 ($0.003 vs $0.040)
✅ **Excellent quality** for social media graphics (8.5/10)
✅ **Fastest generation** (2-3 seconds)
✅ Open-source, reliable availability
✅ Great for: quote cards, carousel posts, thumbnails, social graphics

**Monthly Cost Projection:**
- 5,000 images = $15 (vs $200 with DALL-E 3)

### **SECONDARY MODEL: Gemini 2.0 Flash (Built-in)**
- **Model ID:** `gemini-2.0-flash` (image generation mode)
- **Cost:** $0.039 / image (1024x1024)
- **Quality Score:** 8.3/10

**When to Use:**
⚠️ Need text + image in single API call
⚠️ Prefer unified billing/tracking
⚠️ Flux Schnell API unavailable

### **PREMIUM MODEL: OpenAI DALL-E 3**
- **Model ID:** `dall-e-3`
- **Cost:** $0.040 / image (1024x1024), $0.080 (1024x1792)
- **Quality Score:** 9.5/10

**When to Use:**
⚠️ Enterprise tier users only
⚠️ Premium image requests (charge user $0.50, profit $0.46)
⚠️ Photorealistic requirements

---

## 🎥 VIDEO GENERATION

### **STATUS: NOT IMPLEMENTED (Phase 2)**

**Decision:** Hold off on video generation for 6-12 months

**Reasoning:**
❌ **Too expensive:** $0.018-0.10 per second = $0.54-$3.00 for 30-second video
❌ **Quality concerns:** User feedback shows "AI slop" issues
❌ **Low ROI:** Users not willing to pay premium for AI video yet
❌ **Not MVP critical:** Text + Images sufficient for launch

**Current Solution:**
✅ Provide **video script generation** (already implemented with Gemini 2.0 Flash)
✅ Guide users to use Canva/CapCut/InVideo for actual video creation
✅ Position as "AI-generated scripts" rather than "AI-generated videos"

**Revisit When:**
- Prices drop below $0.01/second
- Quality improves significantly (9.0+ score)
- User demand justifies cost

**Potential Models (Future):**
- Google Veo 3 Fast: $0.030/sec
- Replicate Wan 2.1 (480p): $0.018/sec

---

## 💰 COST COMPARISON (100K Generations/Month)

### **Current Setup (GPT-4o-mini + Gemini fallback):**
- Blog posts (40K): $102
- Social media (30K): $5.70
- Email (20K): $9
- Other (10K): $3
- **TOTAL: $119.70/month**

### **New Setup (Gemini 2.0 Flash primary + Flux Schnell):**
- Blog posts (40K): $66
- Social media (30K): $3.90
- Email (20K): $3.30
- Video scripts (10K): $8.30
- Images (5K): $15
- **TOTAL: $96.50/month**

### **Savings: $23.20/month (19.4%) + Image generation added**
### **Annual Savings: $278.40**

---

## ⚡ OPTIMIZATION STRATEGIES

### **1. Prompt Caching (90% discount)**
- Cache system prompts for each content type
- Gemini: $0.025/1M cached tokens vs $0.10 regular
- Save 75% on repeated prompts

### **2. Smart Routing**
```python
Priority Order:
1. Gemini 2.0 Flash (90% of requests)
2. GPT-4o-mini (fallback, 10%)
3. Gemini 2.5 Flash (Enterprise tier, complex content)
```

### **3. Quality-Based Auto-Regeneration**
- If quality score < 0.75 → Auto-regenerate with GPT-4o-mini
- User never sees poor output
- Cost absorbed only when needed

### **4. Batch Processing (Future)**
- Gemini Batch API: 50% cost reduction
- For non-urgent generations
- Process overnight

---

## 📊 MODEL SELECTION LOGIC

```
IF user_tier == "enterprise" AND content_type == "blog" AND word_count > 3000:
    → Gemini 2.5 Flash (premium quality)

ELIF content_type == "image":
    IF user_tier == "enterprise" OR premium_request:
        → DALL-E 3
    ELSE:
        → Flux Schnell

ELSE:
    → Gemini 2.0 Flash (default for all text)
    
FALLBACK (on error):
    → GPT-4o-mini
```

---

## 🔄 IMPLEMENTATION MILESTONES

### **Milestone 1: Core Model Integration** ✅ IN PROGRESS
- [ ] Update config.py with Gemini 2.0 Flash settings
- [ ] Modify openai_service.py to prioritize Gemini 2.0 Flash
- [ ] Add Replicate API for Flux Schnell
- [ ] Create smart routing function

### **Milestone 2: Prompt Optimization**
- [ ] Research best prompt enhancement techniques
- [ ] Create prompt improvement templates
- [ ] Implement prompt pre-processing system
- [ ] Test with user rough prompts

### **Milestone 3: Caching & Performance**
- [ ] Implement Gemini prompt caching
- [ ] Add quality scoring system
- [ ] Create auto-regeneration logic
- [ ] Monitor cost savings

### **Milestone 4: Testing & Validation**
- [ ] A/B test Gemini vs GPT-4o-mini quality
- [ ] Validate cost savings
- [ ] User acceptance testing
- [ ] Performance benchmarks

---

## 📝 NOTES FOR FUTURE UPDATES

### **When to Reconsider Models:**
1. If Gemini pricing increases significantly
2. If GPT-4o-mini drops below $0.10 input
3. If new models offer better cost/quality ratio
4. If user feedback shows quality issues

### **Monitoring Metrics:**
- Average generation cost per content type
- Quality scores (aim for >8.0)
- API response times (aim for <2s)
- Error rates (<1%)
- User satisfaction ratings

### **Alternative Models to Watch:**
- Anthropic Claude 3.5 Sonnet (if pricing drops)
- DeepSeek V3.2 (good value but slower)
- OpenAI GPT-5 nano (when released, pricing TBD)

---

**Last Updated:** November 25, 2025  
**Next Review:** February 2026 (3 months) or when major pricing changes occur
