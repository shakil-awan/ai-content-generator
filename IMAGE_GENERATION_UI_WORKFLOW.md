# 📱 Image Generation - UI Workflow Guide

## Visual Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    AI Content Generator                      │
│                         Main App                             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                     Content Type Tabs                        │
│  📝 Blog  │  📱 Social  │  📧 Email  │  🎨 AI Image  ← Select│
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                  Single Image Generation Form                │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Describe your image                                │    │
│  │ e.g., Modern office workspace with plants...       │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  Style:  [📷 Realistic] [🎨 Artistic] [✏️ Illustration]    │
│          [🧊 3D Render]                                      │
│                                                              │
│  Ratio:  [1:1 Square] [16:9 Landscape] [9:16 Portrait]     │
│          [4:3 Wide] [3:4 Tall]                              │
│                                                              │
│  [✓] Enhance prompt with quality keywords                   │
│                                                              │
│  Usage: 45/50 images [████████████░░] 90%                   │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │      [✨ Generate Image]                           │    │
│  │      💰 $0.003 | ⏱️ ~2.5s                           │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ 📚 Need multiple images? Try Batch Generate →      │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │                   │
                    ↓                   ↓
        ┌──────────────────┐  ┌──────────────────┐
        │  Single Result   │  │  Batch Modal     │
        │  Display         │  │  Opens           │
        └──────────────────┘  └──────────────────┘
                                        │
                                        ↓
                              ┌───────────────────────────┐
                              │  Batch Generation Modal   │
                              │                           │
                              │  Style: [📷 Realistic]    │
                              │  Ratio: [1:1 Square]      │
                              │                           │
                              │  Prompts (0/10):          │
                              │  ┌─────────────────────┐  │
                              │  │ Prompt 1...      [X]│  │
                              │  │ Prompt 2...      [X]│  │
                              │  │ Prompt 3...      [X]│  │
                              │  └─────────────────────┘  │
                              │  [+ Add Prompt]           │
                              │                           │
                              │  Valid Prompts: 3 images  │
                              │  Estimated Cost: $0.009   │
                              │  Estimated Time: ~3.2s    │
                              │                           │
                              │  [Cancel] [Generate All]  │
                              └───────────────────────────┘
                                        │
                                        ↓
                              ┌───────────────────────────┐
                              │  Progress View            │
                              │  ████████████░░  80%      │
                              │  Image 3 of 3             │
                              │                           │
                              │  ✅ Image 1: Done         │
                              │  ✅ Image 2: Done         │
                              │  ⏳ Image 3: Generating   │
                              │                           │
                              │  [Cancel]                 │
                              └───────────────────────────┘
                                        │
                                        ↓
                              ┌───────────────────────────┐
                              │  Batch Results Gallery    │
                              │  ┌────┐ ┌────┐ ┌────┐    │
                              │  │img1│ │img2│ │img3│    │
                              │  └────┘ └────┘ └────┘    │
                              │                           │
                              │  Generated 3 images!      │
                              │  Total: $0.009 | 3.2s     │
                              │                           │
                              │  [Download All] [Share]   │
                              └───────────────────────────┘
```

---

## Step-by-Step User Journey

### 🎯 Path 1: Single Image Generation

#### Step 1: Access Form
```
User navigates to:
Home → Content Generation → AI Image tab
```

#### Step 2: Fill Form
```
1. Enter prompt (min 10 chars)
   Example: "Modern office workspace with plants and natural lighting"

2. Select style
   - Realistic (default, best for photos)
   - Artistic (creative/painterly)
   - Illustration (vector/clean)
   - 3D (rendered look)

3. Choose aspect ratio
   - 1:1 for Instagram/Facebook
   - 16:9 for YouTube
   - 9:16 for Stories
   - 4:3 for presentations
   - 3:4 for Pinterest

4. Check "Enhance prompt" (recommended)
```

#### Step 3: Generate
```
Click "Generate Image" button

System shows:
┌─────────────────────────────┐
│ Generating...               │
│ ████████████░░░  75%        │
│ Creating image...           │
└─────────────────────────────┘

Takes ~2.5 seconds
```

#### Step 4: View Result
```
Image displays below form:
┌─────────────────────────────┐
│                             │
│     [Generated Image]       │
│                             │
├─────────────────────────────┤
│ Model: Flux Schnell         │
│ Time: 2.3s | Cost: $0.003   │
│ Size: ~1024px (1:1)         │
│ Quality: High               │
│                             │
│ [Download] [Share] [Retry]  │
└─────────────────────────────┘
```

---

### 🚀 Path 2: Batch Image Generation

#### Step 1: Open Batch Modal
```
Click link: "Need multiple images? Try Batch Generate →"

Modal opens with:
- Style selector
- Aspect ratio selector
- Prompt list (empty)
- Add prompt button
```

#### Step 2: Configure Batch
```
1. Select style (applies to all)
   Example: Realistic

2. Choose ratio (applies to all)
   Example: 1:1 Square

3. Add prompts (1-10)
   Click "+ Add Prompt" for each

   Prompt 1: "Modern minimalist living room"
   Prompt 2: "Cozy coffee shop interior"
   Prompt 3: "Professional home office setup"
```

#### Step 3: Review Estimates
```
System calculates:
┌─────────────────────────────┐
│ Valid Prompts: 3 images     │
│ Estimated Cost: $0.009      │
│ Estimated Time: ~3.2s       │
└─────────────────────────────┘

All prompts validated (min 10 chars each)
```

#### Step 4: Generate Batch
```
Click "Generate All" button

Modal switches to progress view:
┌─────────────────────────────┐
│ Generating images...        │
│ ████████████████████  100%  │
│ Image 3 of 3                │
│                             │
│ ✅ Image 1: Done            │
│ ✅ Image 2: Done            │
│ ✅ Image 3: Done            │
│                             │
│ Completed in 3.2s           │
└─────────────────────────────┘

Takes ~3.2 seconds for 3 images
```

#### Step 5: View Results
```
Batch results display in grid:
┌───────────────────────────────────┐
│  Batch Results Gallery            │
│                                   │
│  ┌─────────┐ ┌─────────┐ ┌─────┐│
│  │         │ │         │ │     ││
│  │ Image 1 │ │ Image 2 │ │Img3 ││
│  │         │ │         │ │     ││
│  └─────────┘ └─────────┘ └─────┘│
│                                   │
│  Generated 3 images!              │
│  Total Cost: $0.009               │
│  Total Time: 3.2s                 │
│  Average: 1.07s per image         │
│                                   │
│  [Download All] [Share Gallery]   │
└───────────────────────────────────┘

Each image has:
- Thumbnail preview
- Download button
- Share button
- Prompt text
- Generation details
```

---

## UI Component Hierarchy

```
ImageGenerationForm (Main)
│
├── H2 Title
├── Description Text
│
├── CustomTextField (Prompt Input)
│   └── Character Counter
│
├── StyleSelector
│   ├── Realistic Button
│   ├── Artistic Button
│   ├── Illustration Button
│   └── 3D Render Button
│
├── AspectRatioSelector
│   ├── 1:1 Button
│   ├── 16:9 Button
│   ├── 9:16 Button
│   ├── 4:3 Button
│   └── 3:4 Button
│
├── Advanced Options
│   └── Checkbox (Enhance Prompt)
│
├── ImageQuotaDisplay
│   ├── Progress Bar
│   └── Usage Text (45/50)
│
├── PrimaryButton (Generate Image)
│   ├── Loading State
│   └── Cost/Time Info
│
├── TextButton (Batch Generate Link)
│
├── ImageLoadingWidget
│   ├── Progress Bar
│   └── Status Text
│
├── ImageResultDisplay
│   ├── Image Preview
│   ├── Metadata Display
│   ├── Download Button
│   └── Share Button
│
└── BatchResultsGallery
    ├── Grid Layout
    ├── Image Cards
    └── Batch Actions
```

---

## State Management Flow

```
ImageGenerationController
│
├── Single Generation State
│   ├── prompt: Observable<String>
│   ├── style: Observable<String>
│   ├── aspectRatio: Observable<String>
│   ├── isGenerating: Observable<bool>
│   ├── generationProgress: Observable<double>
│   ├── imageResponse: Observable<ImageResponse?>
│   └── errorMessage: Observable<String>
│
├── Batch Generation State
│   ├── batchPrompts: Observable<List<String>>
│   ├── isBatchGenerating: Observable<bool>
│   ├── batchProgress: Observable<double>
│   ├── currentBatchIndex: Observable<int>
│   ├── batchResults: Observable<List<ImageResponse>>
│   └── errorMessage: Observable<String>
│
├── Quota State
│   ├── imagesUsed: Observable<int>
│   ├── imagesLimit: Observable<int>
│   ├── hasQuota: Computed<bool>
│   └── quotaPercentage: Computed<double>
│
└── Methods
    ├── generateImage()
    ├── generateBatch()
    ├── addBatchPrompt(String)
    ├── removeBatchPrompt(int)
    ├── updateBatchPrompt(int, String)
    ├── clearBatch()
    └── loadQuota()
```

---

## API Flow

```
Frontend                Backend               Replicate
   │                       │                      │
   │  POST /generate/image │                      │
   ├──────────────────────→│                      │
   │                       │                      │
   │                       │  Enhance prompt      │
   │                       │  (add style keywords)│
   │                       │                      │
   │                       │  POST /predictions   │
   │                       ├─────────────────────→│
   │                       │                      │
   │                       │                      │ Generate
   │                       │                      │ with Flux
   │                       │                      │ Schnell
   │                       │                      │
   │                       │  Image URL           │
   │                       │←─────────────────────┤
   │                       │                      │
   │                       │  Upload to Firebase  │
   │                       │  Storage (background)│
   │                       │                      │
   │  ImageResponse        │                      │
   │←──────────────────────┤                      │
   │                       │                      │
   │  Display image        │                      │
   │                       │                      │
```

### Batch Flow
```
Frontend                Backend               Replicate
   │                       │                      │
   │ POST /generate/batch  │                      │
   ├──────────────────────→│                      │
   │                       │                      │
   │                       │  Enhance all prompts │
   │                       │                      │
   │                       │  Parallel requests   │
   │                       │  (asyncio.gather)    │
   │                       │                      │
   │                       ├──┬──┬──┬────────────→│ Generate
   │                       │  │  │  │             │ all images
   │                       │  │  │  │             │ in parallel
   │                       │←─┴──┴──┴─────────────┤
   │                       │                      │
   │                       │  Background uploads  │
   │                       │  to Firebase         │
   │                       │                      │
   │  MultipleImageResponse│                      │
   │←──────────────────────┤                      │
   │                       │                      │
   │  Display gallery      │                      │
   │                       │                      │
```

---

## Error Handling UX

### 1. Invalid Prompt (< 10 chars)
```
┌─────────────────────────────┐
│ Describe your image         │
│ Short                       │
├─────────────────────────────┤
│ 5 / 500 characters          │
│ ⚠️ Minimum 10 required      │
└─────────────────────────────┘

Generate button: DISABLED
```

### 2. Quota Exceeded
```
┌─────────────────────────────┐
│ Usage: 50/50 images 🔴      │
│ [████████████████████] 100% │
└─────────────────────────────┘

┌─────────────────────────────┐
│ ⚠️ Image generation quota   │
│    exceeded. Upgrade to     │
│    continue.                │
│                             │
│    [Upgrade Plan]           │
└─────────────────────────────┘

Generate button: DISABLED
```

### 3. Generation Failed
```
┌─────────────────────────────┐
│ ❌ Error                    │
│                             │
│ Failed to generate image:   │
│ API timeout. Please retry.  │
│                             │
│ [Try Again]                 │
└─────────────────────────────┘

Snackbar appears at bottom:
┌─────────────────────────────┐
│ ⚠️ Generation failed. Retry?│
└─────────────────────────────┘
```

### 4. Network Error
```
Snackbar:
┌─────────────────────────────┐
│ ⚠️ No internet connection   │
│    Check your network       │
└─────────────────────────────┘

Falls back to mock data if available
```

---

## Responsive Layouts

### Desktop (>1200px)
```
┌────────────────────────────────────────────┐
│  Form (50%)      │  Results (50%)          │
│  ┌──────────┐    │  ┌────────────────────┐│
│  │ Prompt   │    │  │                    ││
│  │ Input    │    │  │   Generated        ││
│  └──────────┘    │  │   Image            ││
│  [Styles...]     │  │                    ││
│  [Ratios...]     │  └────────────────────┘│
│  [Generate]      │  [Download] [Share]    │
└────────────────────────────────────────────┘
```

### Tablet (768px-1200px)
```
┌──────────────────────────┐
│  Form (Full Width)       │
│  ┌────────────────────┐  │
│  │ Prompt Input       │  │
│  └────────────────────┘  │
│  [Styles in 2x2 grid]    │
│  [Ratios in row]         │
│  [Generate Button]       │
├──────────────────────────┤
│  Results (Full Width)    │
│  ┌────────────────────┐  │
│  │                    │  │
│  │  Generated Image   │  │
│  │                    │  │
│  └────────────────────┘  │
└──────────────────────────┘
```

### Mobile (<768px)
```
┌──────────────┐
│  Form        │
│ ┌──────────┐ │
│ │ Prompt   │ │
│ │ Input    │ │
│ └──────────┘ │
│ [Styles     ]│
│ [in column  ]│
│ [layout     ]│
│ [Ratios     ]│
│ [scrollable ]│
│ [Generate   ]│
├──────────────┤
│  Result      │
│ ┌──────────┐ │
│ │          │ │
│ │  Image   │ │
│ │          │ │
│ └──────────┘ │
│ [Download ]  │
│ [Share    ]  │
└──────────────┘
```

---

## Accessibility Features

### Keyboard Navigation
```
Tab Order:
1. Prompt input field
2. Style selector buttons (arrow keys to switch)
3. Aspect ratio buttons (arrow keys to switch)
4. Enhance prompt checkbox
5. Generate button
6. Batch generate link
7. Download button (when image ready)
8. Share button (when image ready)
```

### Screen Reader Labels
```
- "Describe your image, text input, required, minimum 10 characters"
- "Select image style, 4 options, currently selected: Realistic"
- "Select aspect ratio, 5 options, currently selected: 1 to 1 square"
- "Generate image button, costs 3 dollars, takes approximately 2.5 seconds"
- "Image generation in progress, 75 percent complete"
- "Generated image, modern office workspace, download available"
```

### Focus Indicators
```
All interactive elements have visible focus rings:
- Blue outline (2px) on keyboard focus
- Increased contrast in focused state
- Clear hover states for mouse users
```

---

## Loading States

### Initial Load
```
[Skeleton placeholders for form fields]
```

### Generating Single Image
```
Progress bar with animated shine effect
Status text updates: "Enhancing prompt..." → "Creating image..." → "Done!"
```

### Generating Batch
```
Modal with per-image status
Each item shows: Queued → Generating → Done
Overall progress bar at top
```

### Saving to Gallery
```
Brief spinner while saving to Firebase
Success snackbar on completion
```

---

**Last Updated**: November 28, 2025  
**UI Version**: v1.5  
**Status**: Fully Implemented & Tested
