# 🚀 How to Test Image & Video Generation Features

## Quick Navigation Guide

### Method 1: From Landing Page (Recommended)
1. **Start the app** - You'll land on the landing page at `/`
2. **Click "Try Demo"** button in the top navigation bar
3. You'll be taken to the **Home/Dashboard** page at `/home`
4. From there, you'll see two large buttons:
   - **"Content Generation"** - Takes you to `/generate`
   - **"My Images Gallery"** - Takes you to `/my-images`

### Method 2: Direct URL Navigation
You can directly navigate to these URLs in your browser:

- **Home/Dashboard**: `http://localhost:PORT/home`
- **Content Generation**: `http://localhost:PORT/generate`
- **My Images Gallery**: `http://localhost:PORT/my-images`

---

## 🎨 Testing Image Generation

### Access Image Generation:
1. Navigate to `/home` (click "Try Demo" from landing page)
2. Click **"Content Generation"** button
3. You'll see tabs at the top for different content types
4. Click the **"AI Image 🎨"** tab

### Test Single Image Generation:
1. Enter a prompt (minimum 10 characters)
   - Example: "A serene mountain landscape at sunset"
2. Choose a style:
   - 📷 Realistic
   - 🎨 Artistic
   - ✏️ Illustration
   - 🧊 3D Render
3. Choose an aspect ratio:
   - 1:1 Square (1024×1024)
   - 16:9 Landscape (1792×1024)
   - 9:16 Portrait (1024×1792)
   - 4:3 Wide (1365×1024)
   - 3:4 Tall (1024×1365)
4. Click **"Generate Image"**
5. Watch the progress bar (mock 2.5 second delay)
6. View your generated image with:
   - Download button
   - Copy URL button
   - Regenerate button

### Test Batch Generation:
1. On the Image Generation form, scroll down
2. Click **"Need multiple images? Try Batch Generate →"**
3. A modal opens where you can:
   - Add up to 10 different prompts
   - Choose style and aspect ratio for all
   - See estimated cost and time
4. Click **"Generate All"**
5. Watch live progress for each image:
   - ✓ Generated (green)
   - ⏳ Generating (blue)
   - ⏸ Queued (gray)
6. View all results in a grid with bulk download option

### Test My Images Gallery:
1. From `/home`, click **"My Images Gallery"** button
2. Or navigate directly to `/my-images`
3. You'll see:
   - 6 mock sample images in a grid
   - Filter by style dropdown
   - Sort by newest/oldest
   - Search by prompt text
   - Pagination (12 images per page)
   - Storage and quota stats at bottom
4. Hover over images to see quick actions (Download, Delete)
5. Click an image to see full details in a modal

---

## 🎬 Testing Video Generation

### Access Video Generation:
1. Navigate to `/home` (click "Try Demo" from landing page)
2. Click **"Content Generation"** button
3. Click the **"Video Script 🎬"** tab

### Test Video Script Generation:
1. Fill out the form:
   - **Video Title**: Enter a title for your video
   - **Video Purpose**: Choose from dropdown (Tutorial, Review, Explanation, etc.)
   - **Target Duration**: Select length (30s, 1min, 3min, 5min, 10min)
   - **Target Audience**: Describe your audience
   - **Key Points** (optional): Add bullet points
   - **Tone**: Select tone (Professional, Casual, Enthusiastic, etc.)
2. Click **"Generate Video Script"**
3. View the generated script with:
   - Full script text
   - Estimated duration
   - Hook suggestions
   - B-roll suggestions
   - CTA recommendations
   - Download/Copy options

---

## 📍 All Available Routes

| Route | Description | How to Access |
|-------|-------------|---------------|
| `/` | Landing page | Default start page |
| `/home` | Dashboard with feature buttons | Click "Try Demo" in nav bar |
| `/generate` | Content Generation (All types) | Click "Content Generation" from `/home` |
| `/my-images` | Image Gallery | Click "My Images Gallery" from `/home` |
| `/signin` | Sign in page | Click "Sign In" in nav bar |
| `/signup` | Sign up page | Click "Get Started" in nav bar |

---

## 🎯 Quick Test Checklist

### ✅ Image Generation Features to Test:
- [ ] Single image generation with different styles
- [ ] Different aspect ratios
- [ ] Batch generation (up to 10 images)
- [ ] Progress tracking
- [ ] Result display with metadata
- [ ] Download and copy URL
- [ ] Regenerate functionality
- [ ] Quota display and warnings

### ✅ My Images Gallery Features to Test:
- [ ] View 6 sample images
- [ ] Filter by style
- [ ] Sort by newest/oldest
- [ ] Search by prompt
- [ ] Pagination controls
- [ ] Hover effects on cards
- [ ] Click image for details
- [ ] Delete image functionality
- [ ] Storage stats display

### ✅ Video Generation Features to Test:
- [ ] Fill video details form
- [ ] Select video purpose
- [ ] Choose target duration
- [ ] Add key points
- [ ] Generate script
- [ ] View formatted script
- [ ] Download/Copy script
- [ ] Regenerate functionality

---

## 💡 Pro Tips

1. **Start from the Home Page**: Navigate to `/home` to see all features clearly labeled
2. **Use Mock Data**: All services use mock data with realistic delays (2.5s for images)
3. **Check Quota**: Image generation shows 45/50 images used (mock data)
4. **Test Responsive**: Try resizing your browser to see responsive layouts
5. **Look for Tabs**: Content types are tabs at the top of the generation page

---

## 🐛 Troubleshooting

**Can't find the buttons?**
- Make sure you're at `/home` (not landing page `/`)
- Click "Try Demo" in the navigation bar

**Image generation not working?**
- Ensure you're on the "AI Image 🎨" tab
- Enter at least 10 characters in the prompt
- Check that quota isn't exceeded (should show 45/50)

**Video generation not showing?**
- Make sure you're on the "Video Script 🎬" tab
- Fill in at least the required fields (Title, Purpose, Duration, Audience)

**Page not found?**
- Double-check the URL
- Navigate from `/home` using the buttons

---

## 🎨 Visual Guide

```
Landing Page (/)
    │
    ├─→ Click "Try Demo" in nav bar
    │
    ↓
Home/Dashboard (/home)
    │
    ├─→ Click "Content Generation" button
    │   │
    │   ↓
    │   Content Generation Page (/generate)
    │   │
    │   ├─→ Tab: "AI Image 🎨"    → Test Image Generation
    │   ├─→ Tab: "Video Script 🎬" → Test Video Generation
    │   ├─→ Tab: "Blog Post 📄"
    │   ├─→ Tab: "Social Media 📱"
    │   └─→ Tab: "Email 📧"
    │
    └─→ Click "My Images Gallery" button
        │
        ↓
        My Images Gallery (/my-images)
        └─→ View/manage generated images
```

---

**Happy Testing! 🚀**

If you have any questions or issues, the Home page at `/home` is your central hub for accessing all features.
