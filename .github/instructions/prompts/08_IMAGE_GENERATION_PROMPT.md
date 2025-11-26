# 🎨 IMAGE GENERATION FEATURE - DEVELOPMENT PROMPT

**Copy this entire prompt into a new chat session with GitHub Copilot**

---

## 🚨 PREREQUISITES: BUILD CONTENT GENERATION PAGE FIRST!

**⚠️ CRITICAL: You MUST build the Content Generation Page BEFORE this feature!**

**Required:**
1. ✅ Complete Prompt `00_CONTENT_GENERATION_PAGE_PROMPT.md` first
2. ✅ Ensure Content Type tabs/selector exists in Content Generation Form
3. ✅ Ensure results page structure exists for displaying images

**Why?** Image Generation is a CONTENT TYPE (like Blog, Social, Email, Video). It integrates INTO the Content Generation Page as a tab/option, NOT a separate page.

---

## TASK: Build AI Image Generation UI

I'm building the **Image Generation Feature** for Summarly AI Content Generator (Flutter web app). This feature has **FULLY WORKING BACKEND** - you're building the perfect UI with mock data that will easily connect to real API later.

### 📚 CONTEXT FILES TO READ FIRST:

**CRITICAL - Read these files before starting:**
1. `.github/instructions/FRONTEND_INSTRUCTIONS.md` - Complete development guide with custom widgets, theme, architecture patterns
2. `lib/core/theme/app_theme.dart` (281 lines) - All colors, spacing, border radius constants
3. `lib/core/constants/font_sizes.dart` (211 lines) - Typography system
4. `docs/features/07_image_generation/IMAGE_GENERATION_UX_SPECS.md` (1086 lines) - Complete UX specifications
5. `docs/features/07_image_generation/07_IMAGE_GENERATION.md` (1285 lines) - Feature overview and backend specs
6. `.github/instructions/prompts/00_CONTENT_GENERATION_PAGE_PROMPT.md` - Content Generation Page specs (MUST be built first)

---

## 🎯 IMPORTANT: Implementation Status

### Backend Status: ✅ FULLY IMPLEMENTED

**What's Working:**
- ✅ **Dual-Model Strategy:**
  - Flux Schnell (Primary): $0.003/image, 2-3 seconds, 8.5/10 quality
  - DALL-E 3 (Enterprise): $0.040/image, 10-15 seconds, 9.5/10 quality
- ✅ **Endpoint:** `POST /api/v1/generate/image` (single image)
- ✅ **Endpoint:** `POST /api/v1/generate/image/batch` (up to 10 images)
- ✅ **4 Styles:** Realistic, Artistic, Illustration, 3D Render
- ✅ **5 Aspect Ratios:** 1:1, 16:9, 9:16, 4:3, 3:4
- ✅ **Prompt Enhancement:** Auto-injects quality keywords (+18% quality)
- ✅ **Firebase Storage:** Permanent CDN URLs for all images
- ✅ **Batch Processing:** Parallel generation (8× faster)
- ✅ **Quota Management:** Per-tier limits with tracking
- ✅ **Performance:** 99.2% success rate, 2.8s avg time

**You are building:** Perfect pixel-perfect UI with mock data. Real API integration comes later.

---

## 🎨 APPROACH: BUILD PERFECT UI WITH MOCK DATA

**Strategy:**
1. **Build complete UI** for single + batch image generation
2. **Use realistic mock data** matching backend response structure
3. **Perfect pixel-perfect design** following design system
4. **Simulate realistic delays** (2-3 seconds for generation)
5. **API integration later** (easy swap when ready)

**Why this approach:**
- ✅ Frontend dev works independently
- ✅ Perfect UI without backend blockers
- ✅ Easy API integration later (2 hours)
- ✅ Design review happens now
- ✅ Complete feature testing

---

## 📍 WHERE DOES THIS APPEAR IN THE APP?

**ARCHITECTURE:**

Image Generation appears in **TWO LOCATIONS:**

### Location 1: Content Generation Page (Primary)
```
App Navigation:
├── Landing Page
├── Auth Pages
├── Dashboard
├── Content Generation Page  ← IMAGE GENERATION HERE
│   └── Content Type Selector:
│       ├── Blog Post
│       ├── Social Media
│       ├── Email Campaign
│       ├── Product Description
│       ├── Ad Copy
│       ├── Video Script
│       └── AI Image  ← THIS TAB/SECTION
│           ├── Prompt: [Describe your image...]
│           ├── Style: [Realistic/Artistic/Illustration/3D]
│           ├── Aspect Ratio: [1:1/16:9/9:16/4:3/3:4]
│           ├── Advanced Options ▼
│           ├── [Generate Image]
│           └── [Batch Generate] (opens modal)
├── My Images (NEW)  ← Image gallery/library
├── Settings
└── Billing
```

### Location 2: My Images Page (Gallery)
- **New sidebar item** for image library
- Grid view of all generated images
- Filter, sort, search capabilities
- Download, delete actions
- Storage quota display

---

## 📋 COMPONENTS TO BUILD (10 Total)

### Component 1: Image Generation Form
**Purpose:** Main form for generating AI images (part of Content Generation page)

**Location in UI:** Content Generation Page → AI Image tab

**Visual:**
```
┌──────────────────────────────────────────────┐
│ Generate AI Image                         🎨 │
├──────────────────────────────────────────────┤
│ Describe your image                          │
│ ┌──────────────────────────────────────────┐│
│ │ Modern office workspace with plants and  ││
│ │ natural lighting                         ││
│ └──────────────────────────────────────────┘│
│                                              │
│ Style                                        │
│ ⚫ Realistic  ⚪ Artistic  ⚪ Illustration    │
│ ⚪ 3D Render                                 │
│                                              │
│ Aspect Ratio                                 │
│ [1:1 Square                              ▼] │
│                                              │
│ Advanced Options ▼                           │
│   ☑ Enhance prompt with quality keywords    │
│   Output: PNG, 90% quality                  │
│   Model: Flux Schnell (Fast & Cost-Effective)│
│                                              │
│ [Generate Image] 🎨                          │
│ Cost: $0.003 | Time: ~2.5 sec | 45 left/mo │
│                                              │
│ Need multiple images? [Batch Generate] →    │
└──────────────────────────────────────────────┘
```

**Elements:**
- **Prompt:** CustomTextField (multiline, 500 chars max)
  - Placeholder: "Describe what you want to see..."
  - Helper: "Be specific for best results"
  
- **Style:** Radio buttons (4 options, single selection)
  - Realistic: "Photo" icon
  - Artistic: "Palette" icon
  - Illustration: "Draw" icon
  - 3D Render: "Cube" icon
  
- **Aspect Ratio:** Dropdown with preview icons
  - 1:1 Square (1024×1024) - Social posts
  - 16:9 Landscape (1792×1024) - YouTube thumbnails
  - 9:16 Portrait (1024×1792) - Instagram stories
  - 4:3 Wide (1365×1024) - Presentations
  - 3:4 Tall (1024×1365) - Pinterest
  
- **Advanced Options:** Expandable section (defaults closed)
  - Enhance prompt checkbox (default: checked)
  - Output format display (read-only)
  - Model info display
  
- **Generate Button:** PrimaryButton with icon
- **Cost Display:** Real-time calculation, shows quota
- **Batch Link:** CustomTextButton to open batch modal

**Validation:**
- Prompt required (min 10 chars)
- Style required (default: realistic)
- Aspect ratio required (default: 1:1)

---

### Component 2: Style Selector Widget
**Purpose:** Visual style picker with previews

**Visual:**
```
┌────────────────────────────────────────┐
│ Style                                  │
├────────────────────────────────────────┤
│ ⚫ Realistic                           │
│    [Preview: Photo-realistic image]   │
│    Best for: Product photos, portraits│
│                                        │
│ ⚪ Artistic                            │
│    [Preview: Painterly image]         │
│    Best for: Creative projects, art   │
│                                        │
│ ⚪ Illustration                        │
│    [Preview: Vector art image]        │
│    Best for: Logos, icons, graphics   │
│                                        │
│ ⚪ 3D Render                           │
│    [Preview: 3D rendered image]       │
│    Best for: Product mockups, concepts│
│                                        │
│ 💡 Tip: Try different styles to find  │
│ the perfect look for your project     │
└────────────────────────────────────────┘
```

**Elements:**
- Radio buttons with preview images
- Style name (BodyTextLarge, bold)
- Preview image (200×150px placeholder)
- Description (BodyTextSmall, gray-600)
- Helper tip at bottom (CaptionText, blue-600)

---

### Component 3: Image Result Display Widget
**Purpose:** Display generated image with metadata

**Location in UI:** Results page after generation

**Visual:**
```
┌────────────────────────────────────────────────┐
│ ✅ Your Image is Ready!                        │
├────────────────────────────────────────────────┤
│                                                │
│ ┌──────────────────────────────────────────┐  │
│ │                                          │  │
│ │        [GENERATED IMAGE PREVIEW]         │  │
│ │          1024×1024 PNG                   │  │
│ │                                          │  │
│ └──────────────────────────────────────────┘  │
│                                                │
│ Prompt Used: "Modern office workspace with    │
│ plants and natural lighting"                   │
│                                                │
│ Details:                                       │
│ • Model: Flux Schnell (Fast & Cost-Effective) │
│ • Style: Realistic                             │
│ • Size: 1024×1024 (Square)                     │
│ • Generation Time: 2.3 seconds                 │
│ • Cost: $0.003                                 │
│                                                │
│ [⬇ Download] [📋 Copy URL] [🔄 Regenerate]   │
│                                                │
│ Enhanced Prompt Used:                          │
│ ┌──────────────────────────────────────────┐  │
│ │ "Modern office workspace with plants and │  │
│ │ natural lighting, photorealistic, highly │  │
│ │ detailed, professional photography, 4k,  │  │
│ │ sharp focus"                             │  │
│ └──────────────────────────────────────────┘  │
│                                                │
│ [Generate Another Image]                       │
└────────────────────────────────────────────────┘
```

**Elements:**
- Success banner: Green-600 background, white text
- Image preview: Max 800px width, auto height, border
- Prompt used: BodyText in bordered box
- Details list: Bullet points with metadata
- Action buttons: Download, Copy URL, Regenerate
- Enhanced prompt: Expandable section showing full prompt
- Generate Another: SecondaryButton

---

### Component 4: Batch Image Generation Modal Widget
**Purpose:** Generate multiple images in parallel

**Location in UI:** Modal overlay triggered by "Batch Generate" button

**Visual:**
```
┌────────────────────────────────────────────────┐
│ 🎨 Batch Image Generation                      │
│ Generate up to 10 images in parallel           │
├────────────────────────────────────────────────┤
│                                                │
│ Image Prompts (1-10)                           │
│                                                │
│ 1. ┌────────────────────────────────────────┐│
│    │ Modern office workspace                ││
│    └────────────────────────────────────────┘│
│    ✓ Generated (2.1s)                         │
│                                                │
│ 2. ┌────────────────────────────────────────┐│
│    │ Tech startup team meeting              ││
│    └────────────────────────────────────────┘│
│    ⏳ Generating... (40%)                     │
│                                                │
│ 3. ┌────────────────────────────────────────┐│
│    │ Creative studio interior               ││
│    └────────────────────────────────────────┘│
│    ⏸ Queued                                   │
│                                                │
│ [+ Add Prompt] (max 10)                        │
│                                                │
│ Style: [Realistic ▼]  Aspect: [1:1 ▼]         │
│                                                │
│ Progress: 1/3 complete                         │
│ ████████████░░░░░░░░░░░░░░ 33%                │
│                                                │
│ Total Cost: $0.009 | Est. Time: 3 seconds     │
│                                                │
│ [Cancel] [Generate All (3 images)]            │
└────────────────────────────────────────────────┘
```

**Elements:**
- Title: H2 with emoji
- Subtitle: BodyTextSmall, gray-600
- Prompt list: Scrollable (max 10 items)
- Each prompt field: CustomTextField + status indicator
- Status icons:
  - ✓ Generated (green checkmark + time)
  - ⏳ Generating (animated spinner + percentage)
  - ⏸ Queued (gray pause icon)
  - ✗ Failed (red X + retry button)
- Add Prompt button: CustomTextButton
- Style/Aspect dropdowns: Side by side
- Progress bar: LinearProgressIndicator (blue-600)
- Progress text: "X/Y complete" (BodyText)
- Cost/Time display: BodyTextSmall, gray-600
- Action buttons: Cancel (SecondaryButton), Generate (PrimaryButton)

---

### Component 5: My Images Gallery Page
**Purpose:** Browse and manage all generated images

**Location in UI:** New "My Images" page in sidebar navigation

**Visual:**
```
┌────────────────────────────────────────────────┐
│ 🎨 My Images                  [+ New Image]   │
├────────────────────────────────────────────────┤
│                                                │
│ Filter: [All ▼]  Sort: [Newest ▼]  🔍 Search │
│                                                │
│ ┌──────────────┬──────────────┬──────────────┐│
│ │ [Thumbnail]  │ [Thumbnail]  │ [Thumbnail]  ││
│ │ Modern office│ Tech startup │ Creative...  ││
│ │ 1024×1024    │ 1792×1024    │ 1024×1792    ││
│ │ Nov 26, 2025 │ Nov 25, 2025 │ Nov 25, 2025 ││
│ │ [⬇] [🗑]    │ [⬇] [🗑]    │ [⬇] [🗑]    ││
│ └──────────────┴──────────────┴──────────────┘│
│                                                │
│ ┌──────────────┬──────────────┬──────────────┐│
│ │ [Thumbnail]  │ [Thumbnail]  │ [Thumbnail]  ││
│ │ Product shot │ Social media │ Blog header  ││
│ │ 1024×1024    │ 1024×1024    │ 1792×1024    ││
│ │ Nov 24, 2025 │ Nov 23, 2025 │ Nov 22, 2025 ││
│ │ [⬇] [🗑]    │ [⬇] [🗑]    │ [⬇] [🗑]    ││
│ └──────────────┴──────────────┴──────────────┘│
│                                                │
│ Storage Used: 87MB / 5GB (Pro tier)            │
│ Images Generated: 45 / 50 this month           │
│                                                │
│ Showing 6 of 143 images  [← 1 2 3 4 ... →]   │
└────────────────────────────────────────────────┘
```

**Elements:**
- Page title: H1 with emoji
- New Image button: PrimaryButton (redirects to generation page)
- Filter dropdown: All / By Style / By Date
- Sort dropdown: Newest / Oldest / Most Popular
- Search field: CustomTextField with search icon
- Image grid: 3 columns desktop, 2 tablet, 1 mobile
- Each card:
  - Thumbnail: 300×300px with hover effect
  - Title: Truncated prompt (max 30 chars)
  - Size: "1024×1024" (BodyTextSmall)
  - Date: "Nov 26, 2025" (CaptionText, gray-600)
  - Actions: Download (⬇) and Delete (🗑) icons on hover
- Storage display: Progress bar + text
- Quota display: "X / Y images" (BodyText)
- Pagination: Page numbers with arrows

---

### Component 6: Image Thumbnail Card Widget
**Purpose:** Reusable card for image gallery

**Visual:**
```
┌──────────────────────┐
│  [IMAGE THUMBNAIL]   │
│                      │
│                      │
├──────────────────────┤
│ Modern office work...│
│ 1024×1024            │
│ Nov 26, 2025         │
│ [⬇] [🗑]            │
└──────────────────────┘

Hover State:
┌──────────────────────┐
│  [IMAGE THUMBNAIL]   │
│  [OVERLAY WITH ZOOM] │
│  ⬇ Download  🗑 Delete│
├──────────────────────┤
│ Modern office work...│
│ 1024×1024            │
│ Nov 26, 2025         │
└──────────────────────┘
```

**Elements:**
- Container: Card with elevation
- Thumbnail: 300×300px, AspectRatio 1:1
- Hover overlay: Semi-transparent black (0.5 opacity)
- Action buttons: Icon buttons on hover
- Title: BodyText, truncated with ellipsis
- Size: BodyTextSmall, gray-600
- Date: CaptionText, gray-600
- Click anywhere: Opens full image modal

**States:**
- Default: Clean card with image
- Hover: Overlay with zoom + actions
- Loading: Skeleton loader or spinner
- Error: Placeholder with error icon

---

### Component 7: Batch Results Gallery Widget
**Purpose:** Display multiple generated images from batch

**Visual:**
```
┌────────────────────────────────────────────────┐
│ ✅ Batch Generation Complete!                  │
│ Successfully generated 5 images in 3.2 seconds │
├────────────────────────────────────────────────┤
│                                                │
│ ┌──────────────┬──────────────┬──────────────┐│
│ │ [Image 1]    │ [Image 2]    │ [Image 3]    ││
│ │ Modern off...│ Tech start...│ Creative...  ││
│ │ 1024×1024    │ 1024×1024    │ 1024×1024    ││
│ │ $0.003       │ $0.003       │ $0.003       ││
│ │ [⬇] [🔄]    │ [⬇] [🔄]    │ [⬇] [🔄]    ││
│ └──────────────┴──────────────┴──────────────┘│
│                                                │
│ ┌──────────────┬──────────────┐               │
│ │ [Image 4]    │ [Image 5]    │               │
│ │ Remote wo... │ Coworking... │               │
│ │ 1024×1024    │ 1024×1024    │               │
│ │ $0.003       │ $0.003       │               │
│ │ [⬇] [🔄]    │ [⬇] [🔄]    │               │
│ └──────────────┴──────────────┘               │
│                                                │
│ Total Cost: $0.015  |  Total Time: 3.2s       │
│                                                │
│ [Download All as ZIP] [Generate More]          │
└────────────────────────────────────────────────┘
```

**Elements:**
- Success banner: Green background, white text
- Stats: Number of images + total time
- Image grid: 3 columns, responsive
- Each image card: Thumbnail, prompt, size, cost, actions
- Action buttons per image: Download (⬇), Regenerate (🔄)
- Summary: Total cost + time (BodyText, gray-600)
- Bulk actions: Download All (PrimaryButton), Generate More (SecondaryButton)

---

### Component 8: Image Quota Display Widget
**Purpose:** Show image generation quota status

**Visual:**
```
┌────────────────────────────────────────┐
│ Image Generation Quota                 │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│ 45 of 50 images used this month        │
│                                        │
│ Resets on Dec 1, 2025                  │
└────────────────────────────────────────┘

Near Limit (>80%):
┌────────────────────────────────────────┐
│ ⚠️ Image Generation Quota              │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│ 48 of 50 images used this month        │
│ Only 2 images remaining!               │
│                                        │
│ Resets on Dec 1, 2025                  │
│ [Upgrade to Pro for 50 images/mo] →   │
└────────────────────────────────────────┘
```

**Elements:**
- Label: "Image Generation Quota" (BodyText, bold)
- Progress bar: LinearProgressIndicator
  - Blue-600 if <80% used
  - Yellow-600 if 80-95% used
  - Red-600 if >95% used
- Usage text: "X of Y images used" (BodyText)
- Warning icon: ⚠️ if >80% used (yellow-600)
- Warning text: "Only X remaining!" (BodyText, yellow-700)
- Reset date: "Resets on..." (CaptionText, gray-600)
- Upgrade button: CustomTextButton (if near limit)

---

### Component 9: Image Generation Loading Widget
**Purpose:** Show generation progress

**Visual:**
```
┌────────────────────────────────────────┐
│ 🎨 Generating Your Image...            │
│                                        │
│ ████████████████████░░░░░░░░░░░░ 60%  │
│                                        │
│ Current Step: Enhancing prompt...      │
│ Estimated time: 2 seconds remaining    │
│                                        │
│ [Cancel Generation]                    │
└────────────────────────────────────────┘
```

**Elements:**
- Title: "Generating Your Image..." (H3)
- Progress bar: LinearProgressIndicator with animation
- Percentage: BodyTextLarge, blue-600, next to bar
- Current step: BodyText (e.g., "Enhancing prompt...", "Creating image...", "Uploading...")
- Time estimate: BodyTextSmall, gray-600
- Cancel button: SecondaryButton

**Progress Steps:**
1. Enhancing prompt... (0-20%)
2. Creating image... (20-90%)
3. Uploading to storage... (90-100%)

---

### Component 10: Aspect Ratio Selector Widget
**Purpose:** Select image dimensions visually

**Visual:**
```
┌────────────────────────────────────────┐
│ Aspect Ratio                           │
├────────────────────────────────────────┤
│ [■] 1:1 Square      Best for: Social  │
│     1024×1024       posts, profile     │
│                                        │
│ [▬] 16:9 Landscape  Best for: YouTube │
│     1792×1024       thumbnails, blogs  │
│                                        │
│ [▮] 9:16 Portrait   Best for: Stories │
│     1024×1792       Instagram, TikTok  │
│                                        │
│ [▭] 4:3 Wide        Best for: Slides  │
│     1365×1024       presentations      │
│                                        │
│ [▯] 3:4 Tall        Best for: Pinterest│
│     1024×1365       pins, posters      │
└────────────────────────────────────────┘
```

**Elements:**
- Label: "Aspect Ratio" (BodyText, bold)
- Radio buttons with visual icons
- Each option:
  - Icon showing aspect ratio shape
  - Ratio label (e.g., "1:1 Square") - BodyTextLarge
  - Dimensions (e.g., "1024×1024") - BodyTextSmall, gray-600
  - Use case (e.g., "Best for: Social posts") - CaptionText, gray-600

---

## 🎯 MANDATORY REQUIREMENTS:

### Custom Widgets (NEVER use standard Flutter widgets):
- ✅ **Text**: H1, H2, H3, BodyText, BodyTextLarge, BodyTextSmall, CaptionText
- ✅ **Buttons**: PrimaryButton, SecondaryButton, CustomTextButton
- ✅ **Input**: CustomTextField, CustomTextFormField
- ✅ **Spacing**: Gap(8), Gap(12), Gap(16), Gap(24)
- ✅ **Loading**: AdaptiveLoading, SmallLoader

### Theme Constants (NEVER hardcode):
- ✅ **Colors**: AppTheme.primary, AppTheme.success, AppTheme.warning, AppTheme.error
- ✅ **Spacing**: AppTheme.spacing8/12/16/24/32
- ✅ **Border Radius**: AppTheme.borderRadiusSM/MD/LG
- ✅ **Fonts**: FontSizes.h2/h3/bodyRegular/bodyLarge/bodySmall/captionRegular

### Architecture:
```
features/image_generation/
├── models/
│   ├── image_request.dart (~80 lines)
│   ├── image_response.dart (~120 lines)
│   ├── batch_request.dart (~100 lines)
│   └── generated_image.dart (~150 lines)
├── controllers/
│   ├── image_generation_controller.dart (~350 lines)
│   └── image_gallery_controller.dart (~250 lines)
├── widgets/
│   ├── image_generation_form.dart (~400 lines)
│   ├── style_selector.dart (~180 lines)
│   ├── image_result_display.dart (~300 lines)
│   ├── batch_generation_modal.dart (~450 lines)
│   ├── my_images_gallery_page.dart (~500 lines)
│   ├── image_thumbnail_card.dart (~200 lines)
│   ├── batch_results_gallery.dart (~300 lines)
│   ├── image_quota_display.dart (~120 lines)
│   ├── image_loading_widget.dart (~100 lines)
│   └── aspect_ratio_selector.dart (~150 lines)
└── services/
    ├── image_generation_service.dart (~200 lines) - Mock data
    └── image_storage_service.dart (~150 lines) - Mock data
```

### Data Models:

```dart
class ImageRequest {
  final String prompt;
  final String style; // realistic, artistic, illustration, 3d
  final String aspectRatio; // 1:1, 16:9, 9:16, 4:3, 3:4
  final bool enhancePrompt;
  
  // Convert to API request format
  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'style': style,
      'aspect_ratio': aspectRatio,
      'enhance_prompt': enhancePrompt,
    };
  }
  
  // Get dimensions from aspect ratio
  String get dimensions {
    switch (aspectRatio) {
      case '1:1': return '1024×1024';
      case '16:9': return '1792×1024';
      case '9:16': return '1024×1792';
      case '4:3': return '1365×1024';
      case '3:4': return '1024×1365';
      default: return '1024×1024';
    }
  }
}

class ImageResponse {
  final String imageUrl;
  final String model; // flux-schnell or dall-e-3
  final double generationTime;
  final double cost;
  final String size;
  final String quality;
  final String? enhancedPrompt;
  
  factory ImageResponse.fromJson(Map<String, dynamic> json) {
    return ImageResponse(
      imageUrl: json['image_url'] ?? '',
      model: json['model'] ?? 'flux-schnell',
      generationTime: (json['generation_time'] ?? 2.5).toDouble(),
      cost: (json['cost'] ?? 0.003).toDouble(),
      size: json['size'] ?? '1024x1024',
      quality: json['quality'] ?? 'high',
      enhancedPrompt: json['enhanced_prompt'],
    );
  }
  
  String get modelDisplay {
    return model == 'flux-schnell' 
        ? 'Flux Schnell (Fast & Cost-Effective)'
        : 'DALL-E 3 (Premium Quality)';
  }
}

class BatchRequest {
  final List<String> prompts;
  final String style;
  final String aspectRatio;
  
  Map<String, dynamic> toJson() {
    return {
      'prompts': prompts,
      'style': style,
      'aspect_ratio': aspectRatio,
    };
  }
  
  int get imageCount => prompts.where((p) => p.isNotEmpty).length;
  double get estimatedCost => imageCount * 0.003;
  double get estimatedTime => 2.5 + (imageCount * 0.2); // Parallel overhead
}

class GeneratedImage {
  final String id;
  final String imageUrl;
  final String prompt;
  final String style;
  final String size;
  final DateTime createdAt;
  final double cost;
  
  factory GeneratedImage.fromJson(Map<String, dynamic> json) { ... }
}
```

### State Management with GetX:

```dart
class ImageGenerationController extends GetxController {
  final imageResponse = Rxn<ImageResponse>();
  final isGenerating = false.obs;
  final generationProgress = 0.0.obs;
  final currentStep = ''.obs;
  final errorMessage = ''.obs;
  
  // Form fields
  final prompt = ''.obs;
  final style = 'realistic'.obs;
  final aspectRatio = '1:1'.obs;
  final enhancePrompt = true.obs;
  
  // Quota
  final imagesUsed = 0.obs;
  final imagesLimit = 50.obs;
  
  // Computed
  bool get canGenerate => prompt.value.length >= 10;
  bool get isNearLimit => (imagesUsed.value / imagesLimit.value) >= 0.8;
  int get imagesRemaining => imagesLimit.value - imagesUsed.value;
  
  // Methods
  Future<void> generateImage() async {
    if (!canGenerate) return;
    
    isGenerating.value = true;
    generationProgress.value = 0.0;
    errorMessage.value = '';
    
    try {
      // Step 1: Enhance prompt
      currentStep.value = 'Enhancing prompt...';
      generationProgress.value = 0.2;
      await Future.delayed(Duration(milliseconds: 500));
      
      // Step 2: Generate image
      currentStep.value = 'Creating image...';
      generationProgress.value = 0.5;
      
      final request = ImageRequest(
        prompt: prompt.value,
        style: style.value,
        aspectRatio: aspectRatio.value,
        enhancePrompt: enhancePrompt.value,
      );
      
      final response = await ImageGenerationService().generateImage(request);
      
      generationProgress.value = 0.9;
      
      // Step 3: Upload
      currentStep.value = 'Uploading to storage...';
      await Future.delayed(Duration(milliseconds: 300));
      
      generationProgress.value = 1.0;
      imageResponse.value = response;
      imagesUsed.value++;
      
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isGenerating.value = false;
      currentStep.value = '';
      generationProgress.value = 0.0;
    }
  }
}
```

### Mock Service Implementation:

```dart
// image_generation_service.dart
class ImageGenerationService {
  // TODO: Replace with real API when backend is ready
  
  Future<ImageResponse> generateImage(ImageRequest request) async {
    // Simulate realistic generation time
    await Future.delayed(Duration(milliseconds: 2500));
    
    // Return mock response
    return ImageResponse(
      imageUrl: 'https://via.placeholder.com/${request.dimensions}/2563EB/FFFFFF?text=${Uri.encodeComponent(request.prompt)}',
      model: 'flux-schnell',
      generationTime: 2.3,
      cost: 0.003,
      size: request.dimensions,
      quality: 'high',
      enhancedPrompt: _enhancePrompt(request.prompt, request.style),
    );
  }
  
  Future<List<ImageResponse>> generateBatch(BatchRequest request) async {
    // Simulate parallel processing (faster than sequential)
    final count = request.imageCount;
    final baseTime = 2500;
    final parallelOverhead = count * 200;
    await Future.delayed(Duration(milliseconds: baseTime + parallelOverhead));
    
    // Generate mock responses for all prompts
    return request.prompts.map((prompt) => ImageResponse(
      imageUrl: 'https://via.placeholder.com/1024x1024/2563EB/FFFFFF?text=${Uri.encodeComponent(prompt)}',
      model: 'flux-schnell',
      generationTime: 2.1 + (0.2 * (prompts.indexOf(prompt))),
      cost: 0.003,
      size: request.aspectRatio == '1:1' ? '1024x1024' : '1792x1024',
      quality: 'high',
    )).toList();
  }
  
  String _enhancePrompt(String prompt, String style) {
    final styleKeywords = {
      'realistic': 'photorealistic, highly detailed, professional photography, 4k, sharp focus',
      'artistic': 'artistic masterpiece, expressive brushstrokes, vibrant colors, creative composition',
      'illustration': 'professional illustration, clean vector art, perfect lines, modern design',
      '3d': '3D rendered, octane render, cinema4d, detailed textures, professional lighting',
    };
    
    return '$prompt, ${styleKeywords[style] ?? styleKeywords['realistic']}';
  }
}

// image_storage_service.dart
class ImageStorageService {
  // Mock image gallery
  final mockImages = <GeneratedImage>[
    GeneratedImage(
      id: '1',
      imageUrl: 'https://via.placeholder.com/1024x1024/2563EB/FFFFFF?text=Modern+Office',
      prompt: 'Modern office workspace with plants',
      style: 'realistic',
      size: '1024×1024',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      cost: 0.003,
    ),
    GeneratedImage(
      id: '2',
      imageUrl: 'https://via.placeholder.com/1792x1024/8B5CF6/FFFFFF?text=Tech+Startup',
      prompt: 'Tech startup team meeting',
      style: 'realistic',
      size: '1792×1024',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      cost: 0.003,
    ),
    // Add more mock images...
  ];
  
  Future<List<GeneratedImage>> getMyImages({
    String? filter,
    String? sort,
    int page = 1,
    int pageSize = 12,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    // Apply filters and sorting
    var images = List<GeneratedImage>.from(mockImages);
    
    // Pagination
    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    
    return images.sublist(start, end.clamp(0, images.length));
  }
  
  Future<void> deleteImage(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    mockImages.removeWhere((img) => img.id == id);
  }
}
```

---

## 📊 IMPLEMENTATION STEPS:

1. **Read Context Files** (10 min)
2. **Create Folder Structure** (3 min)
3. **Create Data Models** (40 min):
   - ImageRequest, ImageResponse, BatchRequest, GeneratedImage

4. **Create Controllers** (60 min):
   - ImageGenerationController (35 min)
   - ImageGalleryController (25 min)

5. **Create Mock Services** (30 min):
   - image_generation_service.dart (20 min)
   - image_storage_service.dart (10 min)

6. **Create Core Widgets** (180 min):
   - image_generation_form.dart (45 min)
   - style_selector.dart (20 min)
   - image_result_display.dart (30 min)
   - batch_generation_modal.dart (50 min)
   - my_images_gallery_page.dart (55 min)

7. **Create Helper Widgets** (90 min):
   - image_thumbnail_card.dart (20 min)
   - batch_results_gallery.dart (30 min)
   - image_quota_display.dart (12 min)
   - image_loading_widget.dart (10 min)
   - aspect_ratio_selector.dart (18 min)

8. **Integrate into Content Generation Page** (20 min)
9. **Create My Images Sidebar Item** (10 min)
10. **Test All UI Flows** (30 min)
11. **Polish & Responsive Design** (30 min)

**Total Time: ~8.5 hours**

---

## ✅ SUCCESS CRITERIA:

Complete Image Generation UI is ready when:

**Single Image Generation:**
- [ ] Form generates mock images successfully
- [ ] Style selector shows 4 options with previews
- [ ] Aspect ratio selector shows 5 options with use cases
- [ ] Advanced options expandable/collapsible
- [ ] Loading shows progress (3 steps)
- [ ] Result displays image beautifully
- [ ] Download button works (placeholder)
- [ ] Copy URL works (mock URL)
- [ ] Regenerate creates new variation

**Batch Generation:**
- [ ] Modal opens from generation form
- [ ] Add/remove prompts (max 10)
- [ ] Shared style/aspect settings
- [ ] Progress shows per-image status
- [ ] All images generate in parallel (simulated)
- [ ] Results gallery displays all images
- [ ] Download all as ZIP (placeholder)

**Image Gallery:**
- [ ] My Images page in sidebar navigation
- [ ] Grid displays mock images (3 cols desktop)
- [ ] Filter/sort/search work correctly
- [ ] Thumbnail cards with hover effects
- [ ] Download/delete actions per image
- [ ] Pagination works (12 per page)
- [ ] Storage quota displays correctly
- [ ] Quota warning at 80%+ usage

**Code Quality:**
- [ ] All files under 800 lines
- [ ] Only custom widgets used
- [ ] Only AppTheme constants used
- [ ] Data models with proper structure
- [ ] Controllers with clean state
- [ ] Mock services with realistic delays
- [ ] Responsive on all breakpoints
- [ ] Loading states for async operations
- [ ] Error states handled gracefully
- [ ] Empty states with helpful messages

**Polish:**
- [ ] Animations smooth (progress, modals)
- [ ] Hover states on interactive elements
- [ ] Focus states for accessibility
- [ ] Tooltips where helpful
- [ ] Icons used appropriately (🎨📷⬇🗑🔄)
- [ ] Consistent spacing throughout
- [ ] Professional appearance

---

## 📝 NOTES:

- **Backend FULLY WORKING** - Dual-model strategy (Flux Schnell + DALL-E 3)
- **Mock data is realistic** - Matches backend response structure exactly
- **Easy API integration** - Just swap mock service (2 hours work)
- **Performance:** 2-3 seconds per image, 99.2% success rate
- **Cost:** $0.003 per image (Flux), $0.040 per image (DALL-E 3 Enterprise)
- **Quota tiers:** Free 5/mo, Pro 50/mo, Enterprise 200/mo
- **Batch processing:** Up to 10 images in parallel (8× faster)
- **Storage:** Firebase CDN URLs, permanent retention (Pro+)

---

## 🎨 MOCK DATA EXAMPLES:

```dart
// Mock single image response
final mockImageResponse = ImageResponse(
  imageUrl: 'https://via.placeholder.com/1024x1024/2563EB/FFFFFF?text=Modern+Office',
  model: 'flux-schnell',
  generationTime: 2.3,
  cost: 0.003,
  size: '1024x1024',
  quality: 'high',
  enhancedPrompt: 'Modern office workspace with plants and natural lighting, photorealistic, highly detailed, professional photography, 4k, sharp focus',
);

// Mock batch responses
final mockBatchResponses = [
  ImageResponse(imageUrl: '...', generationTime: 2.1, cost: 0.003, ...),
  ImageResponse(imageUrl: '...', generationTime: 2.3, cost: 0.003, ...),
  ImageResponse(imageUrl: '...', generationTime: 2.5, cost: 0.003, ...),
];

// Mock gallery images
final mockGalleryImages = [
  GeneratedImage(
    id: '1',
    imageUrl: 'https://via.placeholder.com/1024x1024',
    prompt: 'Modern office workspace',
    style: 'realistic',
    size: '1024×1024',
    createdAt: DateTime.now().subtract(Duration(days: 1)),
    cost: 0.003,
  ),
  // ... more images
];
```

---

**START NOW:** Build all 10 components with perfect pixel-perfect UI and mock data. Real API integration comes later (easy 2-hour task).
