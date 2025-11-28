# 🎨 Batch Image Generation - Complete Guide

## Overview

The AI Content Generator supports efficient batch image generation using **Flux Schnell**, optimized for speed, quality, and cost-effectiveness.

## Key Features

### ✨ Single Image Generation
- **Model**: Flux Schnell (black-forest-labs/flux-schnell)
- **Cost**: $0.003 per image
- **Speed**: 2-3 seconds
- **Quality**: High (8.5/10)
- **Format**: WebP (optimized compression)
- **Resolution**: ~1024px (adjusts by aspect ratio)

### 🚀 Batch Image Generation
- **Endpoint**: `POST /api/v1/generate/image/batch`
- **Limit**: 1-10 images per request
- **Parallel Processing**: All images generated concurrently
- **Cost**: $0.003 × number of images
- **Estimated Time**: ~2.5s base + 0.2s per additional image

---

## Optimal Parameters (Backend Optimized)

### Flux Schnell Configuration
```python
{
    "prompt": "enhanced_prompt_with_style_keywords",
    "aspect_ratio": "1:1|16:9|9:16|4:3|3:4",
    "output_format": "webp",           # Smaller files, better compression
    "output_quality": 90,               # High quality (80-100 recommended)
    "num_inference_steps": 4,          # Optimal for Schnell (DO NOT CHANGE)
    "go_fast": True,                   # fp8 quantization for 2-3x speed
    "megapixels": 1,                   # ~1024px images
    "num_outputs": 1                   # Single image (1-4 supported)
}
```

### Why These Parameters?

#### ✅ `go_fast=True`
- Enables fp8 quantization
- **2-3x speed boost** with minimal quality loss
- Recommended by Black Forest Labs for production

#### ✅ `output_format="webp"`
- **30-50% smaller** file sizes vs PNG
- Better compression, same visual quality
- Faster uploads to Firebase Storage

#### ✅ `output_quality=90`
- Sweet spot for quality/size ratio
- Range: 0-100 (80-100 recommended)
- Lower values = smaller files, lower quality

#### ✅ `num_inference_steps=4`
- Optimal for Flux Schnell
- Model is distilled for 4 steps
- Higher values don't improve quality

#### ✅ `megapixels=1`
- ~1024px output (adjusts by aspect ratio)
- 1:1 = 1024×1024
- 16:9 = 1792×1024
- Perfect for social media and web

---

## API Usage

### 1. Single Image Generation

**Endpoint:** `POST /api/v1/generate/image`

**Request:**
```json
{
  "prompt": "Modern office workspace with plants",
  "size": "1024x1024",
  "style": "realistic",
  "aspect_ratio": "1:1",
  "enhance_prompt": true
}
```

**Response:**
```json
{
  "success": true,
  "image_url": "https://replicate.delivery/czjl/...",
  "model": "flux-schnell",
  "generation_time": 2.3,
  "cost": 0.003,
  "size": "~1024px (1:1)",
  "quality": "high",
  "prompt_used": "Modern office workspace with plants, photorealistic, high detail, professional photography",
  "timestamp": "2025-11-28T10:30:00Z"
}
```

### 2. Batch Image Generation

**Endpoint:** `POST /api/v1/generate/image/batch`

**Request:**
```json
{
  "prompts": [
    "Modern minimalist living room",
    "Cozy reading nook with plants",
    "Industrial style kitchen"
  ],
  "size": "1024x1024",
  "style": "realistic",
  "enhance_prompts": true
}
```

**Response:**
```json
{
  "success": true,
  "images": [
    {
      "success": true,
      "image_url": "https://replicate.delivery/...",
      "model": "flux-schnell",
      "generation_time": 2.5,
      "cost": 0.003,
      "size": "~1024px (1:1)",
      "quality": "high",
      "prompt_used": "Modern minimalist living room, photorealistic, high detail, professional photography",
      "timestamp": "2025-11-28T10:30:15Z"
    },
    // ... 2 more images
  ],
  "total_cost": 0.009,
  "total_time": 3.2,
  "count": 3
}
```

---

## Frontend Integration (Flutter)

### Using the Batch Generation UI

#### 1. **Access Batch Generator**
- Navigate to AI Image tab
- Click "Need multiple images? Try Batch Generate →"
- Modal opens with batch interface

#### 2. **Configure Settings**
- Select style: Realistic, Artistic, Illustration, or 3D
- Choose aspect ratio: 1:1, 16:9, 9:16, 4:3, 3:4
- Add 1-10 prompts (minimum 10 characters each)

#### 3. **Add Prompts**
- Click "Add Prompt" button
- Enter description for each image
- Remove unwanted prompts with delete icon
- See live estimates for cost and time

#### 4. **Generate**
- Click "Generate All"
- Watch real-time progress bar
- Each image status updates individually
- Results appear in gallery grid

#### 5. **View Results**
- Images displayed in responsive grid
- Download individual images
- Share or save to gallery

---

## Best Practices

### 🎯 Prompt Engineering

#### ✅ Good Prompts
```
"Professional product photo of a smartwatch on marble surface"
"Cozy coffee shop interior with warm lighting and vintage decor"
"Modern tech startup office with glass walls and collaborative workspace"
"Minimalist bedroom with natural light and plants"
```

#### ❌ Avoid
```
"A picture"  (too vague)
"Photo"  (no context)
"Image of thing"  (not specific)
```

#### 💡 Pro Tips
1. **Be Specific**: Include details about lighting, mood, style
2. **Use Style Keywords**: "photorealistic", "cinematic", "professional"
3. **Describe Composition**: "centered", "closeup", "wide angle"
4. **Add Context**: Mention environment, time of day, atmosphere

### 🎨 Style Selection Guide

#### **Realistic** (Most Popular)
- Best for: Product photos, real estate, professional imagery
- Adds: "photorealistic, high detail, professional photography"
- Examples: Corporate headshots, product showcases, interior design

#### **Artistic**
- Best for: Creative projects, book covers, illustrations
- Adds: "artistic, painterly, expressive, creative"
- Examples: Album art, poster designs, creative portraits

#### **Illustration**
- Best for: Web graphics, icons, infographics
- Adds: "digital illustration, vector art, clean lines"
- Examples: Website heroes, app screenshots, diagrams

#### **3D Render**
- Best for: Product mockups, architectural viz
- Adds: "3D render, octane render, detailed textures, professional lighting"
- Examples: Furniture previews, packaging designs, concept art

### 📐 Aspect Ratio Guide

| Ratio | Size | Best For | Use Cases |
|-------|------|----------|-----------|
| **1:1** | 1024×1024 | Social posts | Instagram, Facebook, LinkedIn posts |
| **16:9** | 1792×1024 | Landscapes | YouTube thumbnails, blog headers |
| **9:16** | 1024×1792 | Stories | Instagram/TikTok stories, mobile ads |
| **4:3** | 1365×1024 | Presentations | PowerPoint, Keynote slides |
| **3:4** | 1024×1365 | Pinterest | Tall pins, product catalogs |

---

## Cost & Performance

### Pricing Breakdown
- **Single Image**: $0.003
- **10 Image Batch**: $0.030
- **Monthly (50 images)**: $0.150
- **Monthly (500 images)**: $1.500

### Performance Metrics
| Batch Size | Time (seconds) | Cost (USD) |
|------------|----------------|------------|
| 1 image | ~2.5s | $0.003 |
| 3 images | ~3.2s | $0.009 |
| 5 images | ~4.0s | $0.015 |
| 10 images | ~5.5s | $0.030 |

### Comparison with Alternatives

| Model | Cost/Image | Speed | Quality | Notes |
|-------|------------|-------|---------|-------|
| **Flux Schnell** | $0.003 | 2-3s | 8.5/10 | ✅ Best value |
| DALL-E 3 | $0.040 | 10-15s | 9.5/10 | Enterprise only |
| Stable Diffusion | Free | 5-10s | 7/10 | Self-hosted |
| Midjourney | $10/mo | 60s | 9/10 | Subscription |

---

## Error Handling

### Common Errors

#### 402 Payment Required
```json
{
  "error": "graphics_limit_reached",
  "message": "Monthly graphics limit reached: 5 images",
  "used": 5,
  "limit": 5
}
```
**Solution**: Upgrade subscription or wait for next billing cycle

#### 422 Unprocessable Entity
```json
{
  "detail": [
    {
      "type": "string_too_short",
      "loc": ["body", "prompt"],
      "msg": "String should have at least 3 characters"
    }
  ]
}
```
**Solution**: Ensure prompt is at least 3 characters

#### 500 Internal Server Error
```json
{
  "error": "generation_failed",
  "message": "Image generation failed: ..."
}
```
**Solution**: Check backend logs, verify API keys

---

## Testing

### Quick Test Script

Create `test_batch_images.py`:

```python
import requests
import json

BASE_URL = "http://localhost:8000"
AUTH_TOKEN = "your_firebase_token_here"

def test_batch_generation():
    """Test batch image generation"""
    
    endpoint = f"{BASE_URL}/api/v1/generate/image/batch"
    headers = {
        "Authorization": f"Bearer {AUTH_TOKEN}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "prompts": [
            "Modern minimalist living room with natural light",
            "Cozy coffee shop interior with vintage decor",
            "Professional home office setup with plants"
        ],
        "style": "realistic",
        "size": "1024x1024",
        "enhance_prompts": True
    }
    
    print("🚀 Testing batch generation...")
    print(f"📝 Generating {len(payload['prompts'])} images")
    
    response = requests.post(endpoint, headers=headers, json=payload, timeout=60)
    
    if response.status_code == 201:
        data = response.json()
        print(f"✅ Success! Generated {data['count']} images")
        print(f"💰 Total cost: ${data['total_cost']:.4f}")
        print(f"⏱️  Total time: {data['total_time']:.2f}s")
        print(f"\n📊 Results:")
        
        for i, img in enumerate(data['images'], 1):
            print(f"\nImage {i}:")
            print(f"  URL: {img['image_url'][:60]}...")
            print(f"  Time: {img['generation_time']:.2f}s")
            print(f"  Cost: ${img['cost']:.4f}")
        
        return True
    else:
        print(f"❌ Error {response.status_code}")
        print(response.text)
        return False

if __name__ == "__main__":
    test_batch_generation()
```

### Run Test
```bash
cd backend
python test_batch_images.py
```

---

## Monitoring & Analytics

### Track Key Metrics
1. **Generation Time**: Average time per image
2. **Success Rate**: Successful generations / total attempts
3. **Cost**: Total spend per month
4. **Usage**: Images per user, per day
5. **Popular Styles**: Most used style presets
6. **Popular Ratios**: Most used aspect ratios

### Recommended Alerts
- Generation time > 10s (performance issue)
- Error rate > 5% (API issue)
- Daily spend > $10 (budget alert)
- Queue depth > 50 (scaling needed)

---

## Advanced Features (Future)

### Planned Enhancements
- [ ] **Image-to-Image**: Upload reference image
- [ ] **Inpainting**: Edit specific areas
- [ ] **Upscaling**: Enhance resolution
- [ ] **Style Transfer**: Apply artistic styles
- [ ] **Background Removal**: Auto remove backgrounds
- [ ] **Batch Templates**: Save prompt collections
- [ ] **Scheduling**: Queue batches for later
- [ ] **Webhooks**: Async completion notifications

---

## Troubleshooting

### Issue: Slow Generation
- ✅ Check `go_fast=True` is enabled
- ✅ Verify network latency
- ✅ Monitor Replicate API status
- ✅ Consider caching common requests

### Issue: Low Quality Images
- ✅ Increase `output_quality` to 95-100
- ✅ Use more descriptive prompts
- ✅ Enable prompt enhancement
- ✅ Choose appropriate style

### Issue: High Costs
- ✅ Review usage analytics
- ✅ Implement rate limiting
- ✅ Add approval workflow
- ✅ Cache similar generations

### Issue: WebP Compatibility
- ✅ Most modern browsers support WebP
- ✅ Add PNG fallback for older browsers
- ✅ Use `<picture>` element with sources
- ✅ Server-side conversion if needed

---

## Resources

### Official Documentation
- [Flux Schnell Model Card](https://huggingface.co/black-forest-labs/FLUX.1-schnell)
- [Replicate API Docs](https://replicate.com/docs)
- [Black Forest Labs](https://blackforestlabs.ai/)

### Community
- [GitHub Issues](https://github.com/black-forest-labs/flux/issues)
- [Replicate Community](https://replicate.com/community)
- [r/StableDiffusion](https://reddit.com/r/StableDiffusion)

---

## Support

For issues or questions:
1. Check this guide
2. Review backend logs
3. Test with single image first
4. Verify API keys and quotas
5. Open GitHub issue with details

---

**Last Updated**: November 28, 2025  
**Backend Version**: v2.0  
**Frontend Version**: v1.5  
**Model**: Flux Schnell (latest)
