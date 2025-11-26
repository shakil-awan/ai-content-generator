
## TASK: Build Landing Page for Summarly AI Content Generator

I'm building the **Landing Page** for Summarly AI Content Generator (Flutter web app).

### 📚 CONTEXT FILES TO READ FIRST:

**CRITICAL - Read these files before starting:**
1. `.github/instructions/FRONTEND_INSTRUCTIONS.md` - Complete development guide with custom widgets, theme, architecture patterns
2. `lib/core/theme/app_theme.dart` (281 lines) - All colors, spacing, border radius constants
3. `lib/core/constants/font_sizes.dart` (211 lines) - Typography system
4. `docs/features/FRONTEND_MILESTONES.md` (lines 47-283) - Landing Page detailed specifications

---

## 📋 LANDING PAGE SECTIONS (10 Total)

Build the following sections in order:

### Section 1: Hero Section
- **Gradient background** (primary blue #2563EB to light blue)
- **Hero headline**: "Generate **Verified Content** in Minutes" (DisplayText, 60px, bold)
- **Subheadline**: Description about AI-powered content (BodyTextLarge, 18px)
- **CTA Buttons**:
  - "Start For Free" (PrimaryButton with icon)
  - "Watch Demo" (SecondaryButton with play icon)
- **Badge**: "New: AI Detection Bypass 2.0 is Live" (pill shape, accent color)
- **Hero Image**: Dashboard mockup (right side on desktop, below on mobile)
- **Responsive**:
  - Desktop: 60% viewport height, 2-column layout
  - Mobile: Stack vertically, full-width buttons
  - Tablet: 48px headline, adjusted spacing

### Section 2: Trust Bar
- **Text**: "Join 5,000+ content creators" (BodyText, neutral color)
- **Logos**: Jitter, Krisp, Feedly, Draftbit, Hellosign, Grammarly (grayscale, 120px width)
- **Rating**: 4.8/5 stars with "Based on 500+ reviews" (star icons, success color)
- **Layout**: Horizontal on desktop, vertical stack on mobile

### Section 3: Problem/Solution Section
- **2-column layout** (desktop), stacked on mobile
- **Left Column** - "The Problem" (card with error color border):
  - "AI content gets flagged as fake or spam" (X icon, red)
  - "Fact-checking requires hours of manual Google searches" (X icon, red)
  - "Quality is inconsistent and often repetitive" (X icon, red)
- **Right Column** - "The Solution - Summarly" (card with primary color):
  - "Built-in AI Humanizer bypasses detection tools" (✓ icon, green)
  - "Automatic real-time fact-checking against trusted sources" (✓ icon, green)
  - "Quality guarantee: instant rewrite or your money back" (✓ icon, green)

### Section 4: Features Overview
- **Grid**: 4 columns (desktop), 2 (tablet), 1 (mobile)
- **4 Feature Cards**:
  1. **Fact-Checking Layer** - Shield icon (blue), H3 title, description, "Learn More →" link
  2. **AI Detection Bypass** - Lightning icon (red), H3 title, description, "Learn More →" link
  3. **Quality Guarantee** - Checkmark icon (green), H3 title, description, "Learn More →" link
  4. **Multilingual Support** - Globe icon (amber), H3 title, description, "Learn More →" link
- **Card Style**: Shadow, rounded corners (borderRadiusLG), hover lift effect
- **Icons**: Circular colored background, white icon

### Section 5: Content Types Section
- **Grid**: 3 columns (desktop), 2 (tablet), horizontal scroll (mobile)
- **6 Content Type Cards**:
  1. Blog Posts (document icon)
  2. Social Media Captions (hashtag icon)
  3. Email Campaigns (envelope icon)
  4. Product Descriptions (shopping bag icon)
  5. Ad Copy (megaphone icon)
  6. Video Scripts (video camera icon)
- **Each Card**: Preview image (placeholder), type name (H3), example text (BodyTextSmall)

### Section 6: Pricing Preview
- **Grid**: 3 columns (desktop), 1 column (mobile)
- **3 Pricing Cards**:
  
  **Free Plan** ($0/month):
  - 2,000 Words/mo
  - Basic Fact Checking
  - 1 Project Folder
  - Email Support
  - "Get Started" button (SecondaryButton)
  
  **Hobby Plan** ($9/month):
  - 20,000 Words/mo
  - Advanced Fact Checking
  - AI Humanizer
  - Priority Support
  - "Get Started" button (PrimaryButton)
  
  **Pro Plan** ($29/month) - **MOST POPULAR** badge:
  - Unlimited Words
  - Deep Research Mode
  - API Access
  - Dedicated Account Manager
  - "Get Started" button (PrimaryButton)

- **Features**: Checkmarks (success color), feature list (BodyTextSmall)
- **"View Full Comparison Table →"** link below

### Section 7: Testimonials
- **Carousel** with navigation arrows and dots
- **3-4 Testimonial Cards**:
  - Circular avatar (64px)
  - User name (H3), role (CaptionText, neutral color)
  - 5 stars (amber color)
  - Quote text (BodyText)
- **Example**: "Finally, an AI writer I don't have to babysit. The fact-checking feature saves me hours of research time every week." - Sarah Chen, Content Director
- **Auto-play**: 5-second interval, smooth transitions

### Section 8: FAQ Section
- **Accordion** (6-8 questions)
- **Questions**:
  1. "How does the fact-checking work?"
  2. "Can I try it for free?"
  3. "Does the content pass AI detection?"
  4. "Can I cancel anytime?"
  5. "What languages are supported?"
  6. "Is my content stored securely?"
- **Style**: Border bottom, arrow icon (rotates 180° when expanded)
- **Behavior**: First item expanded by default, smooth expand/collapse animation
- **Layout**: Single column, full width (max 800px centered)

### Section 9: Final CTA Section
- **Full-width section** with blue gradient background (matches hero)
- **Heading**: "Ready to create verified content?" (H1, white text)
- **Subheading**: "Join thousands of content creators using Summarly" (BodyTextLarge, white)
- **Button**: "Get Started Free" (large PrimaryButton, white background, primary text)
- **Disclaimer**: "No credit card required" (CaptionText, white/70% opacity)

### Section 10: Footer
- **4-column layout** (desktop), stacked (mobile)
- **Columns**:
  1. **Product**: Features, Pricing, Integrations, Changelog
  2. **Resources**: Blog, Documentation, Community, API Docs
  3. **Legal**: Privacy Policy, Terms of Service, Cookie Policy
  4. **Subscribe**: Email input (CustomTextField) + arrow button
- **Social Icons**: Facebook, Twitter, Instagram, LinkedIn, YouTube (circular, neutral color)
- **Copyright**: "© 2025 Summarly. All rights reserved." (CaptionText, centered on mobile)

---

## 🎯 MANDATORY REQUIREMENTS:

### Custom Widgets (NEVER use standard Flutter widgets):
- ✅ **Text**: H1, H2, H3, DisplayText, BodyText, BodyTextLarge, BodyTextSmall, CaptionText (NEVER Text())
- ✅ **Buttons**: PrimaryButton, SecondaryButton, CustomTextButton (NEVER ElevatedButton/OutlinedButton())
- ✅ **Spacing**: Gap(16), Gap(24), Gap(64) (NEVER SizedBox())
- ✅ **Loading**: AdaptiveLoading, SmallLoader (if needed for lazy loading images)
- ✅ **Input**: CustomTextField (for footer email subscribe)

### Theme Constants (NEVER hardcode):
- ✅ **Colors**: AppTheme.primary, AppTheme.secondary, AppTheme.accent, AppTheme.error, AppTheme.success, AppTheme.textPrimary, AppTheme.textSecondary, AppTheme.border, AppTheme.bgPrimary, AppTheme.bgSecondary
- ✅ **Spacing**: AppTheme.spacing8/16/24/32/48/64
- ✅ **Border Radius**: AppTheme.borderRadiusMD/LG/XL
- ✅ **Fonts**: FontSizes.displayXL/h1/h2/h3/bodyRegular/bodyLarge/bodySmall/captionRegular

### Architecture:
- ✅ **800-line limit per file** - Split into widgets
- ✅ **Barrel files** - Create export files in each folder for clean imports
- ✅ **Folder structure**:
  ```
  features/landing/
  ├── landing.dart (🆕 Feature barrel file - exports all)
  ├── views/
  │   ├── views.dart (🆕 Barrel file)
  │   └── landing_page.dart (~100-150 lines, uses barrel imports)
  ├── controllers/
  │   ├── controllers.dart (🆕 Barrel file)
  │   └── landing_controller.dart (GetX state if needed for carousel/accordion)
  └── widgets/
      ├── widgets.dart (🆕 Barrel file - exports all widgets)
      ├── hero_section.dart (~200 lines)
      ├── trust_bar.dart (~80 lines)
      ├── problem_solution_section.dart (~150 lines)
      ├── features_grid.dart (~200 lines)
      ├── content_types_section.dart (~150 lines)
      ├── pricing_preview.dart (~250 lines)
      ├── testimonials_section.dart (~180 lines)
      ├── faq_section.dart (~150 lines)
      ├── final_cta.dart (~80 lines)
      └── footer.dart (~200 lines)
  ```

### Barrel File Pattern (IMPORTANT):
```dart
// widgets/widgets.dart - Export all widgets
export 'hero_section.dart';
export 'trust_bar.dart';
export 'problem_solution_section.dart';
// ... export all widget files

// controllers/controllers.dart - Export all controllers
export 'landing_controller.dart';

// views/views.dart - Export all views
export 'landing_page.dart';

// landing.dart - Feature-level barrel (exports everything)
export 'controllers/controllers.dart';
export 'views/views.dart';
export 'widgets/widgets.dart';

// Usage in landing_page.dart:
import '../controllers/controllers.dart';  // ✅ Clean
import '../widgets/widgets.dart';          // ✅ Clean

// NOT this:
import '../widgets/hero_section.dart';     // ❌ Avoid
import '../widgets/trust_bar.dart';        // ❌ Avoid
// ... 10 more imports                     // ❌ Avoid
```

### Responsive Design:
- ✅ **Mobile** (< 768px): Single column, full-width buttons, horizontal scroll for content types
- ✅ **Tablet** (768px - 1024px): 2-column grids, adjusted font sizes
- ✅ **Desktop** (> 1024px): Full multi-column layouts, max-width 1440px centered

### State Management (if needed):
- ✅ Create `LandingController` with GetX for:
  - Testimonial carousel state (current index)
  - FAQ accordion state (expanded items)
  - Smooth scroll to sections
- ✅ Use reactive state (.obs)
- ✅ Use Obx() for reactive UI

---

## 📊 PROGRESS TRACKING:

Create `LANDING_PAGE_PROGRESS.md` based on `SCREEN_PROGRESS_TEMPLATE.md` and update it with:
- ✅ / 🔄 / ⏳ for each widget file as you complete them
- Line counts for each file
- Any issues or blockers
- Completion percentage

---

## 🚀 IMPLEMENTATION STEPS:

1. **Read Context Files** (5 min):
   - Read FRONTEND_INSTRUCTIONS.md completely
   - Read app_theme.dart for colors/spacing/borders
   - Read font_sizes.dart for typography
   - Read FRONTEND_MILESTONES.md (Landing Page section)

2. **Create Folder Structure** (2 min):
   - Create features/landing/views/, controllers/, widgets/ folders

3. **Create Controller** (10 min - if needed):
   - Landing controller with carousel/accordion state
   - Methods for navigation, smooth scroll

4. **Create Main Page** (15 min):
   - landing_page.dart with Scaffold
   - SingleChildScrollView with Column
   - Import and arrange all 10 widget sections with Gap() spacing
   - Keep under 150 lines

5. **Create Widget Files** (60 min):
   - Create each section widget (hero_section.dart, trust_bar.dart, etc.)
   - Use custom widgets (H1, H2, BodyText, PrimaryButton, Gap, etc.)
   - Use AppTheme constants for all styling
   - Keep each file under 800 lines (split if needed)

6. **Create Progress File** (5 min):
   - Copy SCREEN_PROGRESS_TEMPLATE.md to LANDING_PAGE_PROGRESS.md
   - Fill in sections and track completion

7. **Test** (10 min):
   - Run app
   - Test responsive layouts (resize window)
   - Verify no console errors
   - Check all custom widgets used correctly

---

## ✅ SUCCESS CRITERIA:

Landing Page is complete when:
- [ ] All 10 sections implemented
- [ ] All files under 800 lines
- [ ] Only custom widgets used (no Text(), SizedBox(), TextField(), ElevatedButton())
- [ ] Only AppTheme constants used (no hardcoded colors/spacing)
- [ ] Responsive on all 3 breakpoints
- [ ] No console errors or warnings
- [ ] LANDING_PAGE_PROGRESS.md shows 100% completion
- [ ] Code follows FRONTEND_INSTRUCTIONS.md patterns

---

**START NOW:** Read FRONTEND_INSTRUCTIONS.md, app_theme.dart, and font_sizes.dart, then begin implementation with the folder structure and controller.
