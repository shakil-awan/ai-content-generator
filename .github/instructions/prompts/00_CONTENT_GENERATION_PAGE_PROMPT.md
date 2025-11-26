# 📝 CONTENT GENERATION PAGE - DEVELOPMENT PROMPT

## 🚨 CRITICAL: BUILD THIS FIRST!

**This is the FOUNDATIONAL screen that ALL feature components depend on:**
- Fact-Checking widgets (Prompt 03)
- Quality Guarantee widgets (Prompt 04)
- AI Humanization widgets (Prompt 05)
- Brand Voice integration (Prompt 06)
- Video Script generation (Prompt 07)
- Image Generation (Prompt 08)

**Without this screen, features 03-08 cannot be integrated!**

---

## TASK: Build Unified Content Generation Page

I'm building the **Content Generation Page** for Summarly AI Content Generator (Flutter web app). This is the core screen where users generate all types of content (blog posts, social media, emails, video scripts, etc.) and see results with quality scores, fact-checking, and humanization options.

### 📚 CONTEXT FILES TO READ FIRST:

**CRITICAL - Read these files before starting:**
1. `.github/instructions/FRONTEND_INSTRUCTIONS.md` - Complete development guide with custom widgets, theme, architecture patterns
2. `lib/core/theme/app_theme.dart` (281 lines) - All colors, spacing, border radius constants
3. `lib/core/constants/font_sizes.dart` (211 lines) - Typography system
4. `backend/README.md` - Backend API documentation for content generation endpoints

---

## 📐 PAGE ARCHITECTURE

### Two-Screen Flow:

**Screen 1: Content Generation Form** (`/generate`)
- Content type selector (tabs or dropdown)
- Type-specific form fields
- Generation button with preview

**Screen 2: Content Results** (`/generate/results`)
- Generated content display
- Quality score widget
- Fact-check results panel (if enabled)
- AI humanization button
- Copy, regenerate, save actions
- Export options

---

## 📋 SCREEN 1: CONTENT GENERATION FORM

### Layout Structure:

```
┌─────────────────────────────────────────────────────┐
│ Header: "Generate Content" + User Avatar            │
├─────────────────────────────────────────────────────┤
│                                                     │
│ Content Type Selector (Horizontal Tabs)             │
│ [Blog Post] [Social Media] [Email] [Video] [More▼] │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │                                             │   │
│ │  Dynamic Form Based on Selected Type        │   │
│ │  (See type-specific forms below)            │   │
│ │                                             │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ [Generate Content] 🚀 (PrimaryButton)               │
│ Est. time: 8-12 seconds | Cost: 1 credit           │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

### Content Type Tabs

**Tabs (Desktop - Horizontal):**
```
┌──────────────────────────────────────────────────────┐
│ [📄 Blog Post] [📱 Social] [📧 Email] [🎬 Video] [+] │
└──────────────────────────────────────────────────────┘
```

**Mobile (Dropdown):**
```
┌────────────────────────┐
│ Content Type: [Blog Post ▼] │
└────────────────────────┘
```

**Available Types:**
1. **Blog Post** - Long-form articles (500-3000 words)
2. **Social Media** - Captions for Twitter, LinkedIn, Instagram, Facebook
3. **Email Campaign** - Marketing emails, newsletters
4. **Video Script** - YouTube, TikTok, Instagram, LinkedIn scripts
5. **Product Description** - E-commerce descriptions
6. **Ad Copy** - Google Ads, Facebook Ads
7. **More...** (Future: SEO Meta, Press Release, etc.)

---

### Type 1: Blog Post Form

```
┌──────────────────────────────────────────────┐
│ Blog Post Generator                    📄   │
├──────────────────────────────────────────────┤
│                                              │
│ Blog Title / Topic *                         │
│ ┌──────────────────────────────────────────┐│
│ │ 10 AI Tools for Content Creators         ││
│ └──────────────────────────────────────────┘│
│                                              │
│ Target Word Count                            │
│ [500-1000 ▼] (500-1000, 1000-2000, 2000+)   │
│                                              │
│ Tone / Style                                 │
│ [Professional ▼] (Professional, Casual, etc.)│
│                                              │
│ Target Audience (Optional)                   │
│ ┌──────────────────────────────────────────┐│
│ │ Beginner content creators               ││
│ └──────────────────────────────────────────┘│
│                                              │
│ Key Points to Include (Optional)             │
│ ┌──────────────────────────────────────────┐│
│ │ ChatGPT, Midjourney, Jasper AI           ││
│ └──────────────────────────────────────────┘│
│                                              │
│ SEO Keywords (Optional)                      │
│ ┌──────────────────────────────────────────┐│
│ │ AI tools, content creation, productivity ││
│ └──────────────────────────────────────────┘│
│                                              │
│ Advanced Options ▼                           │
│ ┌──────────────────────────────────────────┐│
│ │ ☑ Auto Fact-Check (adds 10-15s) [PRO]  ││
│ │ ☑ Include Visuals (stock images)       ││
│ │ ☐ Apply Brand Voice: [Select...▼]      ││
│ └──────────────────────────────────────────┘│
│                                              │
│ [Generate Blog Post] 🚀                      │
│ Est. 8-12 seconds | 1 credit                 │
└──────────────────────────────────────────────┘
```

**Form Fields:**
1. **Title/Topic** - CustomTextField (required, 5-200 chars)
2. **Word Count** - Dropdown (500-1000, 1000-2000, 2000-3000)
3. **Tone** - Dropdown (Professional, Casual, Friendly, Formal, Humorous)
4. **Target Audience** - CustomTextField (optional, 5-200 chars)
5. **Key Points** - CustomTextField (optional, comma-separated)
6. **SEO Keywords** - CustomTextField (optional, comma-separated)
7. **Advanced Options** - Expandable section:
   - Auto Fact-Check checkbox (disabled for Free, enabled for Hobby/Pro)
   - Include Visuals checkbox
   - Brand Voice selector (if user has trained voices)

---

### Type 2: Social Media Form

```
┌──────────────────────────────────────────────┐
│ Social Media Post Generator            📱   │
├──────────────────────────────────────────────┤
│                                              │
│ Platform *                                   │
│ [Twitter ▼] (Twitter, LinkedIn, Instagram)   │
│                                              │
│ Topic / Message *                            │
│ ┌──────────────────────────────────────────┐│
│ │ Announcing our new AI feature            ││
│ └──────────────────────────────────────────┘│
│                                              │
│ Tone                                         │
│ [Casual ▼]                                   │
│                                              │
│ Include (check all that apply)               │
│ ☑ Hashtags (5-10)                            │
│ ☑ Emoji                                      │
│ ☑ Call to Action                             │
│                                              │
│ [Generate Post] 🚀                           │
│ Est. 5-8 seconds | 1 credit                  │
└──────────────────────────────────────────────┘
```

---

### Type 3: Email Campaign Form

```
┌──────────────────────────────────────────────┐
│ Email Campaign Generator               📧   │
├──────────────────────────────────────────────┤
│                                              │
│ Email Type *                                 │
│ [Newsletter ▼] (Newsletter, Promo, Welcome)  │
│                                              │
│ Subject Line / Topic *                       │
│ ┌──────────────────────────────────────────┐│
│ │ Weekly AI Updates - November 2025        ││
│ └──────────────────────────────────────────┘│
│                                              │
│ Target Audience                              │
│ ┌──────────────────────────────────────────┐│
│ │ Existing subscribers                     ││
│ └──────────────────────────────────────────┘│
│                                              │
│ Main Message / Offer                         │
│ ┌──────────────────────────────────────────┐│
│ │ Introduce new fact-checking feature      ││
│ └──────────────────────────────────────────┘│
│                                              │
│ Call to Action                               │
│ ┌──────────────────────────────────────────┐│
│ │ Try it free today                        ││
│ └──────────────────────────────────────────┘│
│                                              │
│ Tone                                         │
│ [Friendly ▼]                                 │
│                                              │
│ [Generate Email] 🚀                          │
│ Est. 8-10 seconds | 1 credit                 │
└──────────────────────────────────────────────┘
```

---

### Type 4: Video Script Form

(See Prompt 07 - Video Generation for complete specs)

**Simplified Version:**
```
┌──────────────────────────────────────────────┐
│ Video Script Generator                 🎬   │
├──────────────────────────────────────────────┤
│ Topic * | Platform * | Duration *            │
│ ┌─────────────────────────────────────────┐ │
│ │ 5 AI Tools for Creators                 │ │
│ └─────────────────────────────────────────┘ │
│ [YouTube ▼]  [3 minutes ▼]                   │
│                                              │
│ [Generate Script] 🚀                         │
└──────────────────────────────────────────────┘
```

---

## 📋 SCREEN 2: CONTENT RESULTS PAGE

### Layout Structure:

```
┌─────────────────────────────────────────────────────┐
│ Header: "Generated Content" + [New Generation]      │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ Quality Score Badge: A (82%)          [✓]  │   │
│ ├─────────────────────────────────────────────┤   │
│ │                                             │   │
│ │ Generated Content Display Area              │   │
│ │ (Scrollable, formatted text)                │   │
│ │                                             │   │
│ │ Lorem ipsum dolor sit amet, consectetur     │   │
│ │ adipiscing elit. Sed do eiusmod tempor      │   │
│ │ incididunt ut labore et dolore magna...     │   │
│ │                                             │   │
│ │ [1500 words • 8-minute read]                │   │
│ │                                             │   │
│ ├─────────────────────────────────────────────┤   │
│ │ Actions:                                    │   │
│ │ [📋 Copy] [🔄 Regenerate] [💾 Save] [⬇️ Export]│   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
│ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   │
│ ┃ Quality Score Details (Expandable)          ┃   │
│ ┃ Readability: 85% • Completeness: 90%        ┃   │
│ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛   │
│                                                     │
│ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   │
│ ┃ Fact-Check Results (Expandable) [PRO]       ┃   │
│ ┃ ✓ 3 claims verified • 12.4s verification    ┃   │
│ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛   │
│                                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ 🤖 [Humanize Content] [PRO]                 │   │
│ │    5/25 used this month                     │   │
│ └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

### Results Components:

#### 1. Quality Score Badge (Top-Right)
- Circular badge: 60x60px
- Grade: A+ / A / B / C / D
- Color-coded: Green (A+/A), Blue (B), Yellow (C), Red (D)
- Clickable → Expands quality details

#### 2. Generated Content Display
- White card, rounded corners
- Formatted text with proper spacing
- Syntax highlighting for code (if applicable)
- Word count + estimated read time
- Copy icon button (top-right)

#### 3. Action Buttons Row
- **Copy** - SecondaryButton with icon
- **Regenerate** - SecondaryButton with refresh icon
- **Save** - PrimaryButton with save icon
- **Export** - Dropdown menu:
  - Export as PDF
  - Export as DOCX
  - Export as HTML
  - Export as Markdown

#### 4. Quality Score Details Panel
- Expandable card (collapsed by default)
- Shows 4 metrics: Readability, Completeness, SEO, Grammar
- Each with progress bar and percentage
- See Prompt 04 - Quality Guarantee for full specs

#### 5. Fact-Check Results Panel
- Expandable card (collapsed by default)
- Shows verified/unverified claims
- Only visible if fact-checking was enabled
- See Prompt 03 - Fact-Checking for full specs

#### 6. AI Humanization Section
- Button to trigger humanization
- Quota display (if Hobby tier)
- Only visible for Hobby/Pro users
- See Prompt 05 - AI Humanization for full specs

---

## 🎯 MANDATORY REQUIREMENTS:

### Custom Widgets (NEVER use standard Flutter widgets):
- ✅ **Text**: H1, H2, H3, DisplayText, BodyText, BodyTextLarge, BodyTextSmall, CaptionText (NEVER Text())
- ✅ **Buttons**: PrimaryButton, SecondaryButton, CustomTextButton (NEVER ElevatedButton/OutlinedButton())
- ✅ **Spacing**: Gap(12), Gap(16), Gap(24) (NEVER SizedBox())
- ✅ **Loading**: AdaptiveLoading, SmallLoader
- ✅ **Input**: CustomTextField, CustomDropdown

### Theme Constants (NEVER hardcode):
- ✅ **Colors**: AppTheme.primary, AppTheme.textPrimary, AppTheme.bgPrimary, AppTheme.success, AppTheme.error
- ✅ **Spacing**: AppTheme.spacing8/12/16/24/32
- ✅ **Border Radius**: AppTheme.borderRadiusSM/MD/LG
- ✅ **Fonts**: FontSizes.h1/h2/h3/bodyRegular/bodyLarge/bodySmall

### Architecture:
- ✅ **800-line limit per file** - Split into widgets/
- ✅ **Folder structure**:
  ```
  features/content_generation/
  ├── models/
  │   ├── content_generation_request.dart
  │   ├── content_generation_response.dart
  │   └── content_type.dart (enum)
  ├── controllers/
  │   └── content_generation_controller.dart (GetX)
  ├── views/
  │   ├── content_generation_form_page.dart
  │   └── content_results_page.dart
  ├── widgets/
  │   ├── content_type_tabs.dart
  │   ├── blog_post_form.dart
  │   ├── social_media_form.dart
  │   ├── email_form.dart
  │   ├── video_script_form.dart
  │   ├── content_display_card.dart
  │   ├── action_buttons_row.dart
  │   └── export_menu.dart
  └── services/
      └── content_generation_service.dart
  ```

### State Management with GetX:
```dart
class ContentGenerationController extends GetxController {
  // Observable state
  final selectedContentType = ContentType.blog.obs;
  final isGenerating = false.obs;
  final generatedContent = Rxn<ContentGenerationResponse>();
  final errorMessage = ''.obs;
  
  // Form fields (observable)
  final titleController = TextEditingController();
  final audienceController = TextEditingController();
  // ... more controllers
  
  // Computed
  bool get canGenerate => titleController.text.length >= 5;
  
  // Methods
  Future<void> generateContent() async {
    isGenerating.value = true;
    try {
      final response = await contentGenerationService.generate(
        type: selectedContentType.value,
        title: titleController.text,
        // ... more params
      );
      generatedContent.value = response;
      Get.to(() => ContentResultsPage());
    } catch (e) {
      errorMessage.value = 'Generation failed: $e';
    } finally {
      isGenerating.value = false;
    }
  }
  
  void selectContentType(ContentType type) {
    selectedContentType.value = type;
    // Reset form when switching types
    _resetForm();
  }
}
```

---

## 🔗 INTEGRATION WITH OTHER FEATURES:

### This page MUST support:

1. **Quality Guarantee (Prompt 04)**:
   - Display quality score badge
   - Show quality details panel
   - Auto-regenerate if score < 60%

2. **Fact-Checking (Prompt 03)**:
   - Import `FactCheckResultsPanel` widget
   - Show if `autoFactCheck` was enabled
   - Display verification results

3. **AI Humanization (Prompt 05)**:
   - Import `HumanizeButton` widget
   - Show quota usage
   - Trigger humanization modal

4. **Brand Voice (Prompt 06)**:
   - Add brand voice selector in advanced options
   - Apply selected voice to generation request

5. **Video Scripts (Prompt 07)**:
   - Include video script form as a content type
   - Display video-specific results

---

## 📊 IMPLEMENTATION STEPS:

1. **Read Context Files** (10 min)
2. **Create Folder Structure** (5 min)
3. **Create Data Models** (20 min):
   - ContentType enum
   - ContentGenerationRequest
   - ContentGenerationResponse
4. **Create Controller** (30 min):
   - GetX controller with reactive state
   - Form validation
   - API integration
5. **Create Service** (20 min):
   - API calls to `/api/v1/generate/*` endpoints
6. **Build Form Page** (60 min):
   - Content type tabs
   - Type-specific forms (blog, social, email, video)
   - Generate button with loading state
7. **Build Results Page** (60 min):
   - Content display card
   - Action buttons row
   - Quality score badge
   - Placeholder for fact-check/humanization widgets
8. **Test Navigation** (15 min):
   - Form → Results flow
   - Back navigation
   - New generation button

---

## ✅ SUCCESS CRITERIA:

- [ ] Content generation form page created
- [ ] Content results page created
- [ ] All 4+ content types have forms (blog, social, email, video)
- [ ] Tab/dropdown navigation between types works
- [ ] Form validation works (required fields)
- [ ] Generate button shows loading state
- [ ] Results page displays generated content
- [ ] Copy, Regenerate, Save buttons functional
- [ ] Quality score badge displays (placeholder OK)
- [ ] Placeholders for fact-check/humanization widgets added
- [ ] All files under 800 lines
- [ ] Only custom widgets used
- [ ] Only AppTheme constants used
- [ ] GetX state management implemented
- [ ] Responsive on mobile/tablet/desktop
- [ ] No console errors

---

## 🚨 CRITICAL NOTES:

1. **Build this BEFORE features 03-08** - They all depend on this screen
2. **Use placeholders** for fact-check/quality/humanization widgets initially
3. **Focus on structure** - Feature widgets will be integrated later
4. **API endpoints exist** - See `backend/app/api/v1/generate.py`
5. **Test with mock data** if backend not running

---

**START NOW:** Read FRONTEND_INSTRUCTIONS.md, create folder structure, and build the form page first.
