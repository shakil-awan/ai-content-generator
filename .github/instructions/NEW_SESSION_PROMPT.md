# 🎯 NEW SCREEN DEVELOPMENT - SESSION PROMPT

**Copy and paste this prompt when starting a new screen in a fresh chat session:**

---

## PROMPT FOR NEW SESSION:

```
I'm developing the [SCREEN_NAME] screen for Summarly AI Content Generator (Flutter app).

**Context Files (read these first):**
1. .github/instructions/FRONTEND_INSTRUCTIONS.md (complete guide with custom widgets, theme, architecture)
2. lib/core/theme/app_theme.dart (colors, spacing, borders)
3. lib/core/constants/font_sizes.dart (typography)

**Task:** Build the [SCREEN_NAME] screen with [X] sections:
1. [Section 1 name and description]
2. [Section 2 name and description]
3. [Section 3 name and description]
(Add more as needed)

**Requirements:**
- Use ONLY custom widgets (H1, H2, BodyText, CustomTextField, PrimaryButton, Gap, etc.)
- Use Gap() for spacing (never SizedBox)
- Use AppTheme constants (never hardcoded colors/spacing)
- Keep files under 800 lines - split into widgets/ folder
- Follow GetX controller pattern with reactive state
- Handle all states: loading (AdaptiveLoading), error (ErrorDisplayWidget), empty (EmptyStateWidget), success
- Responsive design (mobile, tablet, desktop)

**Folder Structure:**
features/[feature_name]/
├── views/[screen]_page.dart (main page, imports widgets)
├── controllers/[screen]_controller.dart (GetX state)
└── widgets/
    ├── [section1]_widget.dart
    ├── [section2]_widget.dart
    └── [section3]_widget.dart

**Track Progress:** Create a progress file based on SCREEN_PROGRESS_TEMPLATE.md

Please:
1. Read the FRONTEND_INSTRUCTIONS.md file
2. Read app_theme.dart and font_sizes.dart
3. Create the controller first
4. Create the main page with state handling
5. Create widget files for each section (keep under 800 lines each)
6. Create a [SCREEN_NAME]_PROGRESS.md file tracking completion

Start by reading the instructions and theme files, then proceed with implementation.
```

---

## EXAMPLE PROMPT (Landing Page):

```
I'm developing the Landing Page screen for Summarly AI Content Generator (Flutter app).

**Context Files (read these first):**
1. .github/instructions/FRONTEND_INSTRUCTIONS.md (complete guide with custom widgets, theme, architecture)
2. lib/core/theme/app_theme.dart (colors, spacing, borders)
3. lib/core/constants/font_sizes.dart (typography)

**Task:** Build the Landing Page with 10 sections:
1. Hero Section - Headline, subheadline, CTA buttons, hero image
2. Trust Bar - Company logos, rating, testimonials count
3. Features Grid - 7 feature cards (Fact-Check, AI Detection Bypass, etc.)
4. How It Works - 3-step process with icons
5. Content Types - Showcase different content formats
6. AI Humanization - Feature highlight with mockup
7. Pricing - 3 pricing tiers (Free, Pro, Enterprise)
8. Testimonials - Customer reviews carousel
9. FAQ - Collapsible questions/answers
10. Footer - Links, social media, newsletter signup

**Requirements:**
- Use ONLY custom widgets (H1, H2, BodyText, CustomTextField, PrimaryButton, Gap, etc.)
- Use Gap() for spacing (never SizedBox)
- Use AppTheme constants (never hardcoded colors/spacing)
- Keep files under 800 lines - split into widgets/ folder
- Follow GetX controller pattern with reactive state
- Handle all states: loading (AdaptiveLoading), error (ErrorDisplayWidget), empty (EmptyStateWidget), success
- Responsive design (mobile, tablet, desktop)

**Folder Structure:**
features/landing/
├── views/landing_page.dart (main page, imports widgets)
├── controllers/landing_controller.dart (GetX state)
└── widgets/
    ├── hero_section.dart
    ├── trust_bar.dart
    ├── features_grid.dart
    ├── how_it_works.dart
    ├── content_types.dart
    ├── ai_humanization.dart
    ├── pricing_section.dart
    ├── testimonials.dart
    ├── faq_section.dart
    └── footer.dart

**Track Progress:** Create LANDING_PAGE_PROGRESS.md based on SCREEN_PROGRESS_TEMPLATE.md

Please:
1. Read the FRONTEND_INSTRUCTIONS.md file
2. Read app_theme.dart and font_sizes.dart
3. Create the controller first
4. Create the main page with SingleChildScrollView and Column layout
5. Create widget files for each section (keep under 800 lines each)
6. Create LANDING_PAGE_PROGRESS.md tracking completion

Start by reading the instructions and theme files, then proceed with implementation.
```

---

## TIPS FOR SUCCESS:

1. **Always start fresh sessions with this prompt** - Ensures context is loaded
2. **Read FRONTEND_INSTRUCTIONS.md** - Contains all patterns and custom widgets
3. **Check theme files** - app_theme.dart and font_sizes.dart for constants
4. **Track progress** - Create a progress file for each screen
5. **Stay under 800 lines** - Split large files into widgets
6. **Use custom widgets** - Never use Text(), TextField(), SizedBox() directly
7. **Use Gap()** - For all spacing needs
8. **Handle all states** - Loading, error, empty, success

---

## PROGRESS TRACKING:

For each screen, create a copy of `SCREEN_PROGRESS_TEMPLATE.md` named:
- `LANDING_PAGE_PROGRESS.md`
- `AUTH_SCREEN_PROGRESS.md`
- `DASHBOARD_PROGRESS.md`
- etc.

Update the progress file after completing each section to track:
- ✅ What's done
- 🔄 What's in progress
- ⏳ What's pending
- 🐛 Any issues or blockers

This helps maintain context across sessions and provides clear status updates.
