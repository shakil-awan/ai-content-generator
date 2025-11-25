# 🎨 DESIGNER HANDOFF - SUMMARLY UI/UX DESIGN

**Project:** Summarly - AI Content Generator  
**Platform:** Web Application (Primary) + Mobile App (Flutter)  
**Design Tool:** Figma  
**Deadline:** November 25, 2025  
**Version:** 1.0  

---

## 📋 TABLE OF CONTENTS

1. Project Overview
2. Design System Specifications
3. Screen Requirements (20 Screens)
4. Component Library Requirements
5. Mobile App Considerations
6. Email Templates
7. Assets & Resources
8. Deliverables Checklist
9. Design Review Process

---

## 1. 🎯 PROJECT OVERVIEW

### Product Description
Summarly is an AI-powered content generation platform that creates fact-checked, high-quality content with a quality guarantee. It generates 6 types of content: blog posts, social media captions, email campaigns, product descriptions, ad copy, and video scripts.

### Target Audience
- Content creators and bloggers
- Marketing teams and agencies
- E-commerce businesses
- Freelance writers
- Social media managers

### Key Differentiators
1. **Fact-checking layer** - Verifies claims with sources
2. **AI Detection Bypass** - Makes content undetectable by AI scanners
3. **Quality Guarantee** - Free regeneration if unsatisfied
4. **Content Refresh** - Updates old content with new data
5. **Multilingual** - Supports 8 languages

### Design Goals
- **Professional** yet approachable
- **Clean** and uncluttered
- **Modern** with subtle animations
- **Trust-building** (show quality scores, badges, sources)
- **Accessible** (WCAG 2.1 Level AA)

---

## 2. 🎨 DESIGN SYSTEM SPECIFICATIONS

### Color Palette

```css
/* Primary Colors */
--primary-blue: #2563EB;           /* Main brand color */
--primary-blue-hover: #1D4ED8;     /* Hover state */
--primary-blue-light: #DBEAFE;     /* Backgrounds */

/* Secondary Colors */
--secondary-green: #10B981;        /* Success, verified */
--secondary-green-light: #D1FAE5;

/* Accent */
--accent-amber: #F59E0B;           /* Warnings, highlights */
--accent-amber-light: #FEF3C7;

/* Semantic Colors */
--success: #10B981;
--warning: #F59E0B;
--error: #EF4444;
--info: #3B82F6;

/* Neutrals */
--neutral-50: #F9FAFB;             /* Lightest */
--neutral-100: #F3F4F6;
--neutral-200: #E5E7EB;
--neutral-300: #D1D5DB;
--neutral-400: #9CA3AF;
--neutral-500: #6B7280;
--neutral-600: #4B5563;
--neutral-700: #374151;
--neutral-800: #1F2937;
--neutral-900: #111827;             /* Darkest */

/* Text Colors */
--text-primary: #111827;
--text-secondary: #6B7280;
--text-tertiary: #9CA3AF;
--text-inverse: #FFFFFF;

/* Background Colors */
--bg-primary: #FFFFFF;             /* Light mode */
--bg-secondary: #F9FAFB;
--bg-tertiary: #F3F4F6;
--bg-dark-primary: #1F2937;        /* Dark mode */
--bg-dark-secondary: #111827;

/* Border Colors */
--border-light: #E5E7EB;
--border-medium: #D1D5DB;
--border-dark: #9CA3AF;
```

### Typography

**Font Family:**
- Primary: Inter (Google Fonts)
- Monospace: 'Fira Code' or 'JetBrains Mono' (for code/API keys)

**Font Sizes:**
```css
/* Headings */
--text-6xl: 60px;    /* Hero headings */
--text-5xl: 48px;    /* Page titles */
--text-4xl: 36px;    /* Section titles */
--text-3xl: 30px;
--text-2xl: 24px;
--text-xl: 20px;
--text-lg: 18px;

/* Body */
--text-base: 16px;   /* Default body text */
--text-sm: 14px;     /* Small text, labels */
--text-xs: 12px;     /* Captions, helper text */

/* Line Heights */
--leading-tight: 1.25;
--leading-normal: 1.5;
--leading-relaxed: 1.75;

/* Font Weights */
--font-regular: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;
```

**Text Styles to Create in Figma:**
- Display Large (60px, Bold, 1.2 line height)
- Display Medium (48px, Bold, 1.2 line height)
- Heading 1 (36px, SemiBold, 1.3 line height)
- Heading 2 (24px, SemiBold, 1.4 line height)
- Heading 3 (20px, SemiBold, 1.4 line height)
- Body Large (18px, Regular, 1.6 line height)
- Body (16px, Regular, 1.5 line height)
- Body Small (14px, Regular, 1.5 line height)
- Caption (12px, Regular, 1.4 line height)
- Button (16px, SemiBold, 1)

### Spacing System

Use 8px base grid for consistency:
```
4px, 8px, 12px, 16px, 24px, 32px, 40px, 48px, 64px, 80px, 96px, 128px
```

**Common Spacing:**
- Component padding: 16px
- Card padding: 24px
- Section spacing: 64px
- Element gap: 8px or 16px

### Border Radius

```css
--radius-sm: 4px;      /* Small elements */
--radius-md: 8px;      /* Buttons, inputs */
--radius-lg: 12px;     /* Cards, modals */
--radius-xl: 16px;     /* Large cards */
--radius-2xl: 24px;    /* Hero sections */
--radius-full: 9999px; /* Pills, avatars */
```

### Shadows

```css
/* Light Shadows */
--shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
--shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
--shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
--shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1);

/* Colored Shadows (for primary elements) */
--shadow-primary: 0 10px 20px rgba(37, 99, 235, 0.15);
--shadow-success: 0 10px 20px rgba(16, 185, 129, 0.15);
--shadow-error: 0 10px 20px rgba(239, 68, 68, 0.15);
```

### Icons

**Icon Library:** Use [Heroicons](https://heroicons.com/) (consistent with modern design)
- Outline style for most UI elements
- Solid style for filled states, badges
- Icon sizes: 16px, 20px, 24px, 32px

**Custom Icons Needed:**
- Summarly logo (wordmark + icon)
- AI detection badge icon
- Fact-check verified icon
- Quality score icon
- Content type icons (blog, social, email, product, ad, video)

---

## 3. 📱 SCREEN REQUIREMENTS (20 SCREENS)

### PUBLIC SCREENS (No Authentication Required)

---

#### **Screen 1: Landing Page**
**File:** `01_landing_page`

**Purpose:** Convert visitors to signups

**Sections:**

1. **Hero Section** (Full viewport height)
   - Background: Subtle gradient (primary-blue to primary-blue-light)
   - Headline: "Generate Verified Content in Minutes"
   - Subheadline: "The only AI content generator with built-in fact-checking and quality guarantee"
   - CTA Button: "Start Free" (primary, large)
   - Secondary CTA: "Watch Demo" (outlined)
   - Hero Image/Animation: Show content being generated with quality checks

2. **Trust Bar** (Below hero)
   - "Join 5,000+ content creators"
   - Trust badges: Stripe Verified, SOC 2 Compliant, GDPR Compliant
   - Star rating: 4.8/5 with "Based on 500+ reviews"

3. **Problem/Solution** (2-column layout)
   - Left: List of pain points with ❌ icons
     - "AI content gets flagged as fake"
     - "Fact-checking takes hours"
     - "Quality is inconsistent"
   - Right: Our solutions with ✅ icons
     - "Built-in AI humanizer"
     - "Automatic fact-checking"
     - "Quality guarantee or regenerate free"

4. **Features Overview** (4 cards in grid)
   Each card shows:
   - Icon (custom or Heroicon)
   - Feature name
   - 2-3 line description
   - "Learn more" link
   
   Features:
   - Fact-Checking Layer
   - AI Detection Bypass
   - Quality Guarantee
   - Multilingual Support

5. **Content Types** (Horizontal scrollable cards on mobile, grid on desktop)
   6 cards for:
   - Blog Posts
   - Social Media Captions
   - Email Campaigns
   - Product Descriptions
   - Ad Copy
   - Video Scripts
   
   Each shows sample output preview

6. **Pricing Preview** (3 cards)
   - Free: $0/month
   - Hobby: $9/month
   - Pro: $29/month (badge: "Most Popular")
   
   Show top 3-4 features per plan
   CTA: "View Full Pricing"

7. **Social Proof** (Testimonials)
   - 3 testimonial cards with:
     - Avatar
     - Name and role
     - Company
     - Quote
     - Star rating

8. **FAQ Section** (Accordion)
   - 6-8 common questions
   - Expandable answers
   - Clean accordion design

9. **Final CTA Section**
   - "Ready to create verified content?"
   - CTA Button: "Get Started Free"
   - "No credit card required"

10. **Footer**
    - Logo
    - Links: Product, Pricing, Blog, Documentation, API Docs
    - Legal: Privacy Policy, Terms of Service, Cookie Policy
    - Social media icons
    - Newsletter signup form
    - © 2025 Summarly

**Interactions:**
- Smooth scroll between sections
- Hover effects on cards and buttons
- Animated hero elements
- Sticky navigation bar

---

#### **Screen 2: Login Page**
**File:** `02_login`

**Layout:** Split screen (50/50)

**Left Side:**
- Background: Gradient or image
- Summarly logo
- Headline: "Welcome back"
- Subheadline: "Continue creating amazing content"
- Decorative illustration or pattern

**Right Side:**
- Card with login form (centered vertically)
- "Sign in to your account" heading
- Email input field (with icon)
- Password input field (with show/hide toggle)
- "Remember me" checkbox
- "Forgot password?" link (right-aligned)
- "Sign in" button (primary, full width)
- Divider: "Or continue with"
- "Sign in with Google" button (outlined, with Google logo)
- Footer text: "Don't have an account? [Sign up]"

**States to Design:**
- Default
- Focus (input field highlighted)
- Error (show error message below field)
- Loading (button with spinner)
- Success (brief checkmark before redirect)

**Mobile:**
- Single column
- Remove left side illustration
- Show logo at top

---

#### **Screen 3: Signup Page**
**File:** `03_signup`

**Similar layout to Login, but with:**

**Right Side Form:**
- "Create your account" heading
- Full Name input
- Email input
- Password input
- Confirm Password input
- Password strength indicator (progress bar: Weak/Fair/Strong)
  - Red (Weak), Yellow (Fair), Green (Strong)
- "I agree to Terms of Service and Privacy Policy" checkbox
- "Create account" button (primary, full width)
- "Sign up with Google" button
- Footer: "Already have an account? [Log in]"

**Password Requirements** (shown when focused):
- At least 8 characters
- One uppercase letter
- One number
- One special character

---

#### **Screen 4: Forgot Password**
**File:** `04_forgot_password`

**Simple centered card:**
- "Reset your password" heading
- Description: "Enter your email and we'll send you a reset link"
- Email input
- "Send reset link" button
- "Back to login" link

**Success State:**
- Show success message with icon
- "Check your email for reset instructions"
- "Didn't receive? Resend link"

---

### AUTHENTICATED SCREENS

---

#### **Screen 5: Onboarding Flow (6 Steps)**
**File:** `05_onboarding` (create 6 variations)

**Progress Indicator:**
- Show step numbers at top (1 of 6, 2 of 6, etc.)
- Progress bar

**Step 1: Welcome**
- Welcome animation or video (30 sec max)
- "Welcome to Summarly" heading
- 3-4 key benefits listed
- "Get Started" button

**Step 2: Choose Your Plan**
- 3 pricing cards (Free, Hobby, Pro)
- Highlight features
- Annual/Monthly toggle
- "Select Plan" button on each card
- "Skip for now" option (defaults to Free)

**Step 3: What's Your Use Case?** (CRITICAL - NEW)
- "Help us personalize your experience"
- 5 options with large clickable cards:
  - 📝 Blog Writer (solo)
  - 📱 Marketing Team
  - 🏢 Agency
  - 🛒 E-commerce
  - 💼 Freelancer
- Each card has icon, title, description
- Select one, then "Continue"

**Step 4: Train Your Brand Voice (Optional)**
- "Upload 3-5 samples of your writing"
- Drag-and-drop upload area
- Or "Skip this step"
- Shows: Accepted formats (.txt, .pdf, .docx)
- Max size: 5MB per file

**Step 5: Set Your Preferences**
- Default content type (dropdown)
- Default tone (radio buttons: Professional/Casual/Creative)
- Default language (dropdown with flags)
- Email notifications (toggle)
- "Save preferences" button

**Step 6: You're All Set!**
- Success animation (confetti or checkmark)
- "You're ready to create content!"
- Quick tips card (3-4 tips)
- "Start Creating" button (large, primary)

---

#### **Screen 6: Main Dashboard**
**File:** `06_dashboard`

**Layout:** Sidebar + Main Content

**Left Sidebar (Fixed, 240px width):**
- Logo at top
- Navigation items (with icons):
  - Dashboard (selected state highlighted)
  - Generate Content
  - My Library
  - Billing
  - Settings
  - API Docs (if Pro)
  - Help
- User profile card at bottom:
  - Avatar
  - Name
  - Plan badge (Free/Hobby/Pro)
  - Dropdown menu icon

**Top Bar:**
- Search bar (center) - "Search your content..."
- Usage meter widget (right)
  - "45/100 generations used"
  - Circular progress indicator
  - "Upgrade" link if applicable
- Notifications bell icon
- User avatar with dropdown

**Main Content Area:**

1. **Welcome Section**
   - "Hello, [Name]! 👋"
   - Personalized message based on use case

2. **Usage Card** (Prominent)
   - Visual progress bar
   - "45 of 100 generations used this month"
   - "Resets on Dec 1, 2025"
   - "Upgrade for unlimited" button (if not Pro)

3. **Quick Stats** (4 cards in row)
   - Generations This Month (number + trend icon)
   - Avg. Quality Score (percentage + colored gauge)
   - Content Saved (number)
   - Member Since (date)

4. **Quick Actions** (Large buttons with icons)
   - "Generate Blog Post"
   - "Generate Social Caption"
   - "Generate Email"
   - "View All Content Types" button

5. **Recent Generations** (Table/Card List)
   - Shows last 5-10 generations
   - Columns:
     - Preview (first 100 chars)
     - Content Type (badge)
     - Quality Score (colored circle)
     - Date Created
     - Actions (View, Edit, Download icons)
   - "View All" button

6. **Tips & Resources** (Optional sidebar widget)
   - "💡 Did you know?" tip card
   - Link to blog/documentation

**Mobile Layout:**
- Hamburger menu for sidebar
- Stack sections vertically
- Quick stats become 2x2 grid

---

#### **Screen 7: Content Generator**
**File:** `07_generator`

**Layout:** Two-column (Input 40% | Output 60%)

**Left Column: Input Panel**

1. **Content Type Tabs** (Top)
   - Horizontal tabs with icons:
     - Blog Post
     - Social Media
     - Email
     - Product
     - Ad Copy
     - Video Script
   - Active tab highlighted

2. **Input Form** (Changes based on selected type)

**Example: Blog Post Form**
- Topic/Keywords (large text area)
  - Placeholder: "e.g., Machine learning for beginners"
- Desired Length (slider)
  - 1,000 - 5,000 words
  - Show current value
- Target Audience (dropdown)
  - Beginners, Professionals, Executives, Students, General
- Tone (Radio buttons with icons)
  - 😊 Casual
  - 👔 Professional
  - 🎨 Creative
  - 🎓 Academic
- Language (dropdown with flags)
- Advanced Settings (collapsible)
  - Include outline first (toggle)
  - Include images suggestions (toggle)
  - SEO keywords (text input)

3. **Action Buttons**
   - "Generate Content" (primary, large, full width)
   - "Clear Form" (text button)

4. **Usage Info Box**
   - "You have X generations remaining"
   - Progress bar
   - "Upgrade" link

**Right Column: Output Panel**

**Loading State:**
- Skeleton loader animation
- "Generating your content..."
- Estimated time: "About 2 minutes"
- Progress steps:
  - ✓ Creating outline
  - ⏳ Generating content
  - ⏳ Fact-checking
  - ⏳ Quality analysis

**Generated Content Display:**

1. **Content Header**
   - Content type badge
   - Date/time generated
   - Word count
   - Actions row:
     - Copy (icon button)
     - Download (dropdown: PDF, Markdown, Docs, Notion)
     - Favorite (star icon)
     - Share (icon)
     - Regenerate (icon)

2. **Quality Metrics Card** (Prominent at top)
   - Large overall score (85/100 with color)
   - 4 mini gauges:
     - Readability: 78/100
     - Grammar: 95/100
     - Originality: 88/100
     - Fact-Check: 92/100
   - Color-coded (Green >80, Yellow 60-80, Red <60)

3. **AI Detection Score Badge** (NEW - CRITICAL)
   - Large circular gauge (0-100%)
   - Color-coded:
     - Green (85-100%): "Looks Human ✓"
     - Yellow (60-85%): "May be Detected"
     - Red (0-60%): "Likely AI-Generated"
   - If not green: Show "Humanize Content" button

4. **Content Preview**
   - Formatted text display
   - Sections are collapsible if blog post
   - Fact-checked claims highlighted with tooltip
   - Copy icon per section

5. **Fact-Check Results** (Expandable section)
   - List of verified claims
   - Each shows:
     - Claim text
     - Confidence score
     - Sources (clickable links)
     - Flag color (green/yellow/red)

6. **Rating Section**
   - "How satisfied are you with this content?"
   - 5-star rating
   - Optional comment box
   - If rating <3 stars:
     - "Regenerate Free" button appears
     - "What could be better?" options

7. **Export Options** (Bottom)
   - Buttons: PDF | Markdown | Google Docs | Notion
   - "Save to Library" button

**Mobile:**
- Switch to single column
- Input form becomes bottom sheet or separate page
- Output takes full width

---

#### **Screen 8: My Library**
**File:** `08_library`

**Top Section:**
- Page title: "My Content"
- Search bar: "Search your content..."
- Filter bar:
  - Content Type (dropdown multi-select)
  - Date Range (date picker)
  - Quality Score (slider: 0-100)
  - Language (if multilingual)
  - Status (All, Favorites, Archived)
- Sort dropdown: "Sort by: Date (Newest First)"
- View toggle: List view | Grid view

**Content Display:**

**List View:**
- Table with columns:
  - Checkbox (for bulk actions)
  - Preview (first 100 chars)
  - Content Type (icon + badge)
  - Quality Score (colored gauge)
  - Language (flag icon)
  - Date Created
  - Actions (3-dot menu):
    - View
    - Edit
    - Duplicate
    - Download
    - Add to Favorites
    - Archive
    - Delete

**Grid View:**
- Cards (3-4 per row)
- Each card shows:
  - Content preview (truncated)
  - Type badge
  - Quality score
  - Date
  - Favorite star (toggle)
  - Actions menu

**Bulk Actions Toolbar** (appears when items selected):
- "X items selected"
- Export All
- Delete Selected
- Archive Selected
- Add to Favorites

**Empty State:**
- Illustration
- "No content yet"
- "Start generating content to see it here"
- "Generate Now" button

**Pagination:**
- Show 20 items per page
- Page numbers
- Previous/Next buttons

---

#### **Screen 9: Settings**
**File:** `09_settings`

**Layout:** Sidebar tabs + Content area

**Left Sidebar Tabs:**
- Profile
- Brand Voice
- Preferences
- API Keys (Pro/Enterprise)
- Notifications
- Billing
- Account

---

**Tab 1: Profile**
- Avatar section:
  - Current avatar (circular, 120px)
  - "Change Photo" button
  - Upload new image (drag-drop or browse)
  - "Remove" button
- Full Name input
- Email (read-only, with "verified" badge)
- "Save Changes" button

---

**Tab 2: Brand Voice**
- **If Not Configured:**
  - "Train your brand voice for consistent content"
  - Upload section (3-5 samples)
  - "Analyze Writing Style" button
  
- **If Configured:**
  - Summary card:
    - Tone: Professional
    - Vocabulary: Advanced
    - Sentence Structure: Complex
    - Unique Traits: (list)
  - Confidence score gauge
  - Adjustable sliders:
    - Tone Intensity (Conservative ↔ Creative)
    - Formality (Casual ↔ Formal)
    - Complexity (Simple ↔ Technical)
  - "Preview with This Voice" button
  - "Retrain" button
  - "Clear Voice Profile" button

---

**Tab 3: Preferences**
- **Content Defaults:**
  - Default Content Type (dropdown)
  - Default Tone (radio buttons)
  - Default Language (dropdown with flags)
  - Auto-apply Brand Voice (toggle)
  
- **Quality & Checking:**
  - Auto Fact-Check (toggle)
  - Auto Humanize Content (toggle)
  
- **Interface:**
  - Theme (Light/Dark/Auto)
  - Language (UI language)
  
- "Save Preferences" button

---

**Tab 4: API Keys** (Pro/Enterprise only)
- "Create New Key" button
- Table of existing keys:
  - Key Name
  - Key Preview (sum_live_xxx...xxx)
  - Rate Limit
  - Created Date
  - Last Used
  - Status (Active/Inactive toggle)
  - Actions (Copy, Delete)
- "View API Documentation" link

---

**Tab 5: Notifications**
- Email Notifications section:
  - Generation Complete (toggle)
  - Quality Issues Detected (toggle)
  - Usage Warning (80%, 90%, 100%) (toggle)
  - Billing Updates (toggle)
  - New Features (toggle)
  - Weekly Summary (toggle)
  
- Email Frequency:
  - Immediately
  - Daily Digest
  - Weekly Digest
  
- "Save Settings" button

---

**Tab 6: Billing**
- Current Plan card:
  - Plan name with badge
  - Price
  - Billing cycle
  - Next billing date
  - Features list
  - "Change Plan" button
  
- Payment Method:
  - Card ending in **** 1234
  - Expiry: 12/25
  - "Update Payment Method" button
  
- Billing History table:
  - Date
  - Amount
  - Status
  - Download Invoice button

---

**Tab 7: Account**
- **Danger Zone** (red border):
  - Change Password button
  - Login History button
  - Export Data button
  - Delete Account button (with confirmation modal)

---

#### **Screen 10: Pricing/Billing Page**
**File:** `10_pricing`

**Top Section:**
- "Choose the right plan for you"
- Annual/Monthly toggle
  - Show "Save 20%" badge on annual

**Pricing Cards:** (3-4 columns)

**Free Plan:**
- $0/month
- "Forever Free" badge
- Features list (with checkmarks):
  - 5 generations/month
  - All 6 content types
  - Basic fact-checking
  - 3 AI humanizations
- "Current Plan" or "Get Started" button

**Hobby Plan:**
- $9/month or $86/year
- Features:
  - 100 generations/month
  - All content types
  - 25 humanizations
  - Multilingual support
  - 50 social graphics
- "Upgrade to Hobby" button

**Pro Plan:** (Highlighted - "Most Popular" badge)
- $29/month or $279/year
- Features:
  - 1,000 generations/month
  - Unlimited humanizations
  - Unlimited regenerations
  - Content refresh
  - Brand voice training
  - Unlimited graphics
  - API access
  - Priority support
- "Upgrade to Pro" button

**Enterprise:**
- "Custom Pricing"
- Features:
  - Everything in Pro
  - Unlimited generations
  - White-label option
  - Dedicated manager
  - Custom integrations
  - 99.9% SLA
- "Contact Sales" button

**Feature Comparison Table** (Below cards)
- Detailed feature comparison
- All plans side-by-side

**FAQ Section:**
- Accordion with billing questions

---

#### **Screen 11: Content Refresh Analyzer** ⭐ NEW
**File:** `11_content_refresh`

**Layout:** Three-panel

**Left Panel: Input (30%)**
- "Update Old Content" heading
- Three input options (tabs):
  - Paste Content
  - Select from Library
  - Import from URL
- Large text area or selection interface
- "Analyze Content" button (primary)

**Middle Panel: Analysis (30%)**
- "Analysis Results" heading
- Summary card:
  - Total items found
  - Outdated (count, red)
  - Could improve (count, yellow)
  - Still good (count, green)
  - Estimated refresh time
  
- Issues list (scrollable):
  - Each item shows:
    - Issue type badge
    - Description
    - Current text (highlighted)
    - Confidence score
    - Checkbox to include

- "Refresh Selected" button

**Right Panel: Preview (40%)**
- "Suggested Updates" heading
- Track changes view:
  - Deletions (red strikethrough)
  - Additions (green highlight)
  - Side-by-side comparison toggle
- Accept/Reject buttons per change
- "Accept All" button
- "Regenerate Suggestions" button
- "Save Updated Content" button

---

#### **Screen 12: AI Humanizer Interface** ⭐ NEW
**File:** `12_ai_humanizer`

**Layout:** Single panel, top-to-bottom

**Top Section: Current AI Detection Score**
- Large circular gauge (center)
  - Score: 45% (example)
  - Color: Red (high risk)
  - Label: "Likely Detected as AI"
- Detection API badges:
  - GPTZero: 38%
  - Originality.ai: 45%
  - Copyleaks: 52%
- Message: "This content may be flagged by AI detectors"

**Humanization Controls:**
- "Choose Humanization Level" heading
- Two large option cards:
  
  **Light Humanization:**
  - 90% pass rate
  - 15-20 seconds
  - Minimal style changes
  - "Quick & Natural"
  - Radio button
  
  **Deep Humanization:**
  - 98% pass rate
  - 30-45 seconds
  - Comprehensive rewrite
  - "Maximum Protection"
  - Radio button (recommended badge)

- "Humanize Content" button (large, primary)

**Before/After Comparison:**
- Two-column layout
  
  **Left: Original Content**
  - Content preview
  - AI Score badge (45%, red)
  - Word count
  
  **Right: Humanized Content**
  - Updated content preview
  - New AI Score badge (92%, green)
  - Word count
  - Highlighted differences

- Score improvement metric: "+47% more human" (green)

**Actions:**
- "Accept Changes" button
- "Try Different Level" button
- "Regenerate" button

**Progress Modal** (shown during processing):
- Animated spinner
- "Analyzing content..."
- "Rewriting for human tone..."
- "Verifying detection scores..."
- Estimated time remaining

---

#### **Screen 13: Multilingual Dashboard** ⭐ NEW
**File:** `13_multilingual`

**Top Section:**
- "Multilingual Content" heading
- Language selector (dropdown with flags)
  - Shows: Flag, Native name, English name
  - Search functionality
  - "Most Used" section
  - "All Languages" section

**Content Library:**
- Tab navigation:
  - All Languages
  - English
  - Spanish
  - French
  - (etc. for all supported languages)

**Content Cards/Table:**
- Shows:
  - Original language (flag)
  - Target language (flag)
  - Content preview
  - Translation status (Complete/Pending)
  - Quality score
  - Date translated
  - Actions

**Translation Tool Section:**
- Two-panel layout:
  
  **Left: Source**
  - Language indicator
  - Content display
  
  **Right: Translation**
  - Language indicator
  - Translated content
  - Cultural notes (expandable):
    - Local idioms used
    - Cultural adaptations
    - Regional preferences
  
- "Translate to..." button
- Target language selector
- Local SEO panel:
  - Popular keywords
  - Search trends
  - Regional suggestions

---

#### **Screen 14: Video Script Generator** ⭐ NEW
**File:** `14_video_script`

**Layout:** Two-column (Input 40% | Preview 60%)

**Left Column: Input**

1. **Platform Selector** (Large tabs with logos)
   - YouTube (red theme)
   - TikTok (black theme)
   - Instagram Reels (gradient theme)
   - LinkedIn (blue theme)

2. **Video Details Form:**
   - Topic/Title (large input)
   - Duration slider (15 sec - 20 min)
     - Platform recommendations shown
     - "TikTok optimal: 30-60 sec"
   - Target Audience (dropdown)
   - Video Style (dropdown):
     - Educational
     - Entertainment
     - Promotional
     - Tutorial
   - Key Points (bullet list input)
   - Call-to-Action (text input)

3. **Advanced Options** (collapsible):
   - Include Timestamps (toggle)
   - Include B-roll Suggestions (toggle)
   - Optimize for Retention (toggle)
   - Music Mood (dropdown)
   - Pacing (slider: Slow/Medium/Fast)

4. **Generate Script** button (primary)

**Right Column: Script Preview**

**Script Display:**
- Three-column layout:
  - **Timestamp** (left, narrow)
  - **Script Content** (center, wide)
  - **Visual Cues** (right, narrow)

**Script Sections** (color-coded):
- 🎬 **HOOK** (0:00-0:05) - Yellow highlight
  - "Hook Strength: 8/10" badge
- 📖 **Intro** (0:05-0:30)
- 📝 **Main Content** (sections)
- 🎯 **CTA** (last 15 sec) - Green highlight
- 📋 **Outro**

**B-Roll Suggestions:**
- Shown in yellow boxes
- "B-ROLL: [description]"

**Music Cues:**
- 🎵 icons with notes

**Quality Metrics Card:**
- Hook Strength: 8/10
- Retention Score: 85/100
- Engagement Triggers: 12
- Pacing: Optimal

**Additional Outputs Section:**
- **Thumbnail Ideas** (3 cards)
  - Title text suggestions
  - Visual concept
- **Platform Description** (formatted)
- **Hashtags** (copyable chips)
  - #contentcreator #videomarketing etc.
- **Estimated Metrics:**
  - Watch Time Retention graph (line chart)
  - Expected Drop-off points highlighted

**Actions:**
- Copy Full Script
- Copy Section
- Download PDF
- Export to Notion/Docs
- Save to Library

---

#### **Screen 15: Social Media Graphic Generator** ⭐ NEW
**File:** `15_graphic_generator`

**Layout:** Template Gallery + Live Editor

**Top Section:**
- "Create Social Graphics" heading
- Template categories (tabs):
  - Quote Graphics
  - Carousel Posts
  - Infographics
  - Thumbnails
  - Stories

**Template Gallery:**
- Grid of templates (3-4 per row)
- Each template shows:
  - Preview thumbnail
  - Template name
  - Dimensions (1080x1080, etc.)
  - "Use Template" button
- Filters:
  - Platform (Instagram/Twitter/LinkedIn/TikTok)
  - Style (Modern/Minimal/Bold/Elegant)
  - Color Scheme

**Live Canvas Editor** (opens when template selected):

**Left Sidebar: Tools**
1. **Text Controls:**
   - Text input field
   - Font family selector (dropdown)
   - Font size slider
   - Color picker
   - Alignment buttons
   - Bold/Italic/Underline

2. **Brand Colors:**
   - Saved color palette
   - Custom color picker
   - Gradient options
   - "Save to Brand Colors" button

3. **AI Image Generation:**
   - Prompt input: "Describe the image..."
   - Style selector (Realistic/Artistic/Abstract)
   - "Generate Image" button
   - Shows 3 variations

4. **Layout:**
   - Background patterns
   - Overlay opacity slider
   - Element positioning
   - Spacing controls

**Center: Canvas**
- Live preview of design
- Drag-and-drop elements
- Zoom controls
- Grid overlay (toggle)

**Right Sidebar: Export**
- Platform presets (click to export):
  - Instagram Post (1080x1080)
  - Instagram Story (1080x1920)
  - Twitter Post (1200x675)
  - LinkedIn (1200x627)
  - Facebook (1200x630)
  - TikTok (1080x1920)
- "Export All Sizes" button
- Format selector (PNG/JPG/SVG)
- Quality (Standard/High/Ultra)
- "Save to Library" button
- "Create Variations" button (AI generates 3 more)

---

#### **Screen 16: Content Performance Dashboard** ⭐ NEW (Phase 2)
**File:** `16_performance`

**Purpose:** Track published content metrics

**Top Stats Row:**
- 4 cards:
  - Total Views (all-time)
  - Total Engagement
  - Avg. Quality Score
  - Estimated ROI

**Performance Graph:**
- Line/Area chart
- X-axis: Last 30 days
- Y-axis: Views/Engagement
- Multiple lines for content types
- Date range selector

**Top Performing Content:**
- Table showing:
  - Title
  - Type
  - Publish Date
  - Views
  - Engagement Rate
  - Conversion Rate
  - Quality Score
  - Actions (View Details, Update, Republish)

**A/B Test Results** (if applicable):
- Comparison cards:
  - Variant A vs Variant B
  - Winner badge
  - Statistical significance
  - Metrics compared
  - "Apply Winner" button

**ROI Calculator Card:**
- Content Cost (subscription ÷ generations)
- Revenue Generated
- Time Saved
- ROI Percentage (large, color-coded)

**Right Sidebar: Insights**
- Best Posting Times (heatmap)
- Top Content Types (pie chart)
- Trending Topics
- Improvement Suggestions

**Integration Status:**
- Connected platforms badges:
  - Google Analytics ✓
  - WordPress ✓
  - LinkedIn (Connect button)
- Last sync time

---

#### **Screen 17: Batch Operations Center** ⭐ NEW
**File:** `17_batch_operations`

**Purpose:** Handle multiple content pieces efficiently

**Top Toolbar:**
- "Select All" checkbox
- Selected count: "12 items selected"
- Bulk Actions dropdown:
  - Export
  - Delete
  - Archive
  - Add to Favorites
  - Translate
  - Humanize
  - Refresh
  - Share
  - Publish (Phase 2)
- "Apply" button

**Filters:**
- Content Type (multi-select)
- Date Range
- Quality Score
- Language
- Status

**Content Table:**
- Multi-select checkboxes
- Columns:
  - Thumbnail/Icon
  - Title/Preview
  - Type
  - Language (flag)
  - Quality Score
  - Status
  - Date
  - Actions

**Bulk Generation Section:**
- "Create Multiple" button
- Upload CSV option:
  - Template download link
  - CSV format example shown
- Generate up to 50 pieces
- Queue display

**Progress Tracker** (for bulk operations):
- Operation name
- Progress bar (X of Y complete)
- Estimated time remaining
- Details list:
  - Item 1: ✓ Success
  - Item 2: ✓ Success
  - Item 3: ⚠ Warning
  - Item 4: ❌ Failed
- "Cancel" button
- "Download Report" button

---

#### **Screen 18: Admin Dashboard** ⭐ NEW (Enterprise)
**File:** `18_admin_dashboard`

**Purpose:** Team management for enterprise accounts

**Top Stats:**
- 4 cards:
  - Total Team Members
  - Active Users This Month
  - Total Generations
  - Monthly Cost

**User Management Table:**
- Columns:
  - Avatar + Name
  - Email
  - Role (Admin/Editor/Viewer)
  - Last Active
  - Generations Used/Limit
  - Status (Active/Inactive)
  - Actions (Edit, View Activity, Deactivate, Remove)
- "Invite User" button
- Search and filters

**Usage Analytics:**

1. **By Team Member** (Bar chart)
   - Horizontal bars
   - Top 10 users by generation count
   - "View All" link

2. **By Content Type** (Pie chart)
   - Distribution of content types
   - Insights panel

3. **By Time** (Line graph)
   - Daily usage last 30 days
   - Peak hours heatmap
   - Trend analysis

**Permission Management:**
- Role matrix table
- Capabilities per role (checkboxes)
- "Create Custom Role" button
- "Save Changes" button

**API Usage** (if applicable):
- Table of API keys
- Usage by key (bar graph)
- Rate limit status
- "Generate New Key" button

**Activity Log:**
- Recent actions table:
  - Timestamp
  - User
  - Action Type
  - Resource
  - Status
- "Export Audit Log" button
- Date range filter

---

#### **Screen 19: Help/Support**
**File:** `19_help`

**Top Section:**
- "How can we help you?" heading
- Large search bar
  - "Search documentation and FAQs..."
  - Auto-suggest results

**Quick Links Section:**
- 6 large cards:
  - 📖 Documentation
  - 🎥 Video Tutorials
  - 💬 Discord Community
  - 📧 Contact Support
  - 🐛 Report a Bug
  - 💡 Feature Requests

**Popular Articles:**
- List of top 10 helpful articles
- Each shows:
  - Title
  - Category tag
  - Views count
  - "View" link

**FAQ by Category:**
- Accordion sections:
  - Getting Started (5-7 questions)
  - Content Generation (5-7 questions)
  - Billing & Pricing (5-7 questions)
  - Technical Issues (5-7 questions)
  - API & Integrations (5-7 questions)

**Contact Support Form:**
- "Still need help?" heading
- Subject dropdown:
  - Billing Issue
  - Technical Problem
  - Feature Request
  - Account Question
  - Other
- Description textarea
- Attachment option (drag-drop)
- Email (pre-filled)
- "Submit Ticket" button
- Expected response time shown

**Support Status:**
- "Average response time: 4 hours"
- Current status (operational/issues)

---

#### **Screen 20: Mobile App Specific Screens**
**File:** `20_mobile_specific`

**Note:** For Flutter mobile app

**Additional mobile-specific screens:**

1. **Mobile Navigation:**
   - Bottom tab bar (5 tabs):
     - Home (Dashboard icon)
     - Generate (Plus icon in circle)
     - Library (Folder icon)
     - Profile (User icon)
     - More (Menu icon)

2. **Mobile Generator:**
   - Single column flow
   - Content type selection screen (grid)
   - Form fields screen (scrollable)
   - Output screen (dedicated)
   - Swipe gestures for actions

3. **Mobile Content Editor:**
   - Full-screen editor
   - Bottom toolbar
   - Floating action button for actions

4. **Mobile Notifications:**
   - Notification list screen
   - Notification detail screen
   - Settings for push notifications

---

## 4. 🧩 COMPONENT LIBRARY REQUIREMENTS

Create reusable components for consistency:

### Buttons
1. **Primary Button**
   - Default, Hover, Active, Disabled, Loading states
   - Sizes: Small (32px), Medium (40px), Large (48px)
   - Full-width variant

2. **Secondary Button**
   - Same states and sizes as primary
   - Outline style

3. **Text Button**
   - Same states
   - No background

4. **Icon Button**
   - Circular or square
   - With tooltip

### Form Elements
1. **Text Input**
   - Default, Focus, Error, Disabled, Success states
   - With label, helper text, error message
   - Variants: Text, Email, Password, Number, URL
   - With/without icons (prefix, suffix)

2. **Text Area**
   - Same states as input
   - Resizable
   - Character counter

3. **Dropdown/Select**
   - Single select
   - Multi-select
   - With search
   - With icons/flags

4. **Radio Buttons**
   - Vertical and horizontal layouts
   - With descriptions

5. **Checkboxes**
   - Single and group
   - With descriptions

6. **Toggle/Switch**
   - On/Off states
   - With label

7. **Slider**
   - Single value
   - Range
   - With value display

### Content Components
1. **Card**
   - Default card
   - Clickable card (hover state)
   - With image
   - With actions

2. **Badge**
   - Status badges (Success, Warning, Error, Info)
   - Count badges
   - Plan badges (Free, Hobby, Pro, Enterprise)
   - Content type badges

3. **Avatar**
   - Circular
   - Sizes: 24px, 32px, 40px, 64px, 120px
   - With fallback (initials)
   - With status indicator

4. **Progress Bar**
   - Linear
   - Circular
   - With percentage label
   - Color variants

5. **Tabs**
   - Horizontal
   - Vertical
   - With icons
   - Active state indicator

6. **Accordion**
   - Expandable sections
   - With icons
   - Multi-open or single-open

### Feedback Components
1. **Modal/Dialog**
   - Small, Medium, Large sizes
   - With header, content, footer
   - Confirmation modal
   - Form modal

2. **Toast/Snackbar**
   - Success, Error, Warning, Info
   - With action button
   - Auto-dismiss

3. **Alert/Banner**
   - Page-level alerts
   - Inline alerts
   - Dismissible

4. **Loading Indicators**
   - Spinner (multiple sizes)
   - Skeleton loaders
   - Progress bar
   - Full-page loading overlay

5. **Empty States**
   - With illustration
   - With CTA button
   - For each major feature

6. **Error States**
   - 404 Not Found
   - 500 Server Error
   - No Internet Connection
   - Feature-specific errors

### Data Display
1. **Table**
   - Sortable columns
   - Selectable rows
   - Actions column
   - Pagination
   - Empty state

2. **Data Card/Stat Card**
   - Number display
   - Trend indicator (up/down)
   - Comparison value
   - Sparkline chart

3. **Gauge/Meter**
   - Circular gauge (for scores)
   - Linear gauge
   - Color-coded ranges

4. **Charts** (Simple representations)
   - Line chart
   - Bar chart
   - Pie chart
   - Area chart

### Navigation
1. **Breadcrumbs**
   - With separators
   - Clickable links

2. **Pagination**
   - Page numbers
   - Previous/Next
   - Jump to page

3. **Sidebar Navigation**
   - Collapsed/Expanded states
   - Active item indicator
   - With icons
   - Nested items

### Specialized Components
1. **AI Detection Score Badge**
   - Circular gauge
   - Color-coded (red/yellow/green)
   - With label and percentage

2. **Quality Score Display**
   - Multiple mini-gauges
   - Overall score emphasis
   - Hover for details

3. **Fact-Check Indicator**
   - Verified checkmark (green)
   - Warning flag (yellow)
   - Error flag (red)
   - With tooltip showing sources

4. **Language Selector**
   - With flag icons
   - Native language names
   - Search functionality

5. **Upgrade Prompt/CTA**
   - Inline upgrade prompt
   - Modal upgrade prompt
   - Feature comparison table

6. **Usage Meter**
   - Progress ring/bar
   - Used/Total display
   - Reset date
   - Upgrade link

---

## 5. 📱 MOBILE APP CONSIDERATIONS (FLUTTER)

### Design Adaptations for Mobile

**Screen Size Breakpoints:**
- Mobile: 320px - 767px
- Tablet: 768px - 1023px
- Desktop: 1024px+

**Mobile-Specific Changes:**

1. **Navigation:**
   - Bottom navigation bar (5 tabs max)
   - Hamburger menu for secondary items
   - Floating action button for primary action

2. **Layout:**
   - Single column layouts
   - Stack elements vertically
   - Collapsible sections

3. **Touch Targets:**
   - Minimum 44x44px (Apple) or 48x48px (Android)
   - More spacing between interactive elements

4. **Typography:**
   - Slightly larger for readability
   - Reduce font sizes by 1-2px compared to web

5. **Forms:**
   - One input per row
   - Larger input fields
   - Bottom sheets instead of dropdowns
   - Native date/time pickers

6. **Modals:**
   - Full-screen or bottom sheet
   - Avoid small centered modals

7. **Tables:**
   - Convert to cards on mobile
   - Horizontal scroll if necessary
   - Simplified columns

8. **Gestures:**
   - Swipe to delete
   - Pull to refresh
   - Swipe between tabs
   - Pinch to zoom (where applicable)

9. **Content Generator:**
   - Separate screens for input and output
   - Floating "Generate" button
   - Swipeable content type tabs

10. **Dashboard:**
    - Stats become 2x2 grid
    - Hide sidebar (hamburger menu)
    - Compact card designs

---

## 6. 📧 EMAIL TEMPLATES

Design 10 responsive email templates:

### Template Specifications:
- Width: 600px (max)
- Mobile responsive
- Gmail, Outlook, Apple Mail compatible
- Inline CSS (no external stylesheets)
- Use web-safe fonts
- Include plain text version

---

### 1. Welcome Email
**Subject:** Welcome to Summarly! 🎉

**Content:**
- Logo
- "Welcome, [Name]!"
- Brief intro to Summarly
- Quick start guide (3 steps):
  1. Choose content type
  2. Enter your topic
  3. Generate verified content
- "Start Creating" CTA button
- Links to Documentation, Help
- Footer (social links, unsubscribe)

---

### 2. Generation Complete
**Subject:** Your content is ready! ✅

**Content:**
- Logo
- "Your [Content Type] is ready!"
- Content preview (first 200 chars)
- Quality score badge
- "View Full Content" CTA
- "Generate More" button
- Tip of the day
- Footer

---

### 3. Usage Warning (80%)
**Subject:** You've used 80% of your monthly generations

**Content:**
- Logo
- "Heads up! You're running low on generations"
- Usage meter visual (80/100)
- "X generations remaining"
- "Upgrade to Pro for unlimited" CTA
- View pricing button
- Footer

---

### 4. Usage Warning (90%)
**Subject:** 90% of your monthly limit used

**Similar to 80% but more urgent tone:**
- "Only X generations left"
- Upgrade CTA more prominent

---

### 5. Usage Limit Reached (100%)
**Subject:** You've reached your monthly limit

**Content:**
- Logo
- "You've used all your generations for this month"
- "Resets on [Date]"
- Upgrade options (Hobby → Pro)
- Pricing comparison
- "Upgrade Now" CTA (prominent)
- Footer

---

### 6. Upgrade Reminder
**Subject:** Unlock unlimited content with Pro ⭐

**Content:**
- Logo
- "Ready to level up?"
- Current plan vs Pro plan comparison
- Key Pro features:
  - Unlimited generations
  - Unlimited humanizations
  - Content refresh
  - API access
- "Upgrade to Pro" CTA
- "No thanks, I'm happy with [Current Plan]" link
- Footer

---

### 7. Monthly Summary
**Subject:** Your Summarly summary for [Month]

**Content:**
- Logo
- "Here's what you accomplished this month"
- Stats cards:
  - X content pieces generated
  - Avg quality score: X%
  - Most used type: [Type]
  - Time saved: X hours
- "Your best content" (top 3 by quality)
- "Start [Next Month] strong" CTA
- Footer

---

### 8. Password Reset
**Subject:** Reset your Summarly password

**Content:**
- Logo
- "You requested a password reset"
- "Click the button below to reset your password"
- "Reset Password" CTA button
- "This link expires in 1 hour"
- "Didn't request this? Ignore this email"
- Footer

---

### 9. Payment Success
**Subject:** Payment received - Thank you! 💳

**Content:**
- Logo
- "Thank you for your payment!"
- Payment details:
  - Amount: $XX.XX
  - Plan: [Plan Name]
  - Next billing: [Date]
- "Download Invoice" button
- "Manage Billing" button
- Footer

---

### 10. Payment Failed
**Subject:** Payment failed - Action required ⚠️

**Content:**
- Logo
- "We couldn't process your payment"
- "Please update your payment method to continue using Summarly"
- Payment failure reason (if available)
- "Update Payment Method" CTA (prominent, red button)
- "Need help? Contact support"
- Footer

---

## 7. 🎨 ASSETS & RESOURCES

### Images to Source/Create

1. **Illustrations:**
   - Hero section illustration (content generation concept)
   - Empty state illustrations (8 different scenes)
   - Error state illustrations (404, 500, no connection)
   - Success animations (Lottie files)
   - Onboarding illustrations (6 scenes)

2. **Icons:**
   - Content type icons (6 unique icons)
   - Feature icons (10-15 icons)
   - Social media platform logos
   - Payment method icons
   - Status icons (verified, warning, error)

3. **Brand Assets:**
   - Logo (SVG) - "Summarly"
     - Full wordmark
     - Icon only
     - White version
     - Monochrome version
   - Favicon (multiple sizes)
   - App icons (iOS, Android)
   - Social media images (Open Graph)

4. **Patterns & Textures:**
   - Subtle background patterns
   - Gradient overlays
   - Decorative elements

### Stock Photos/Illustrations Sources
- [Undraw](https://undraw.co/) - Free illustrations
- [Storyset](https://storyset.com/) - Animated illustrations
- [Heroicons](https://heroicons.com/) - Icon set
- [Unsplash](https://unsplash.com/) - Stock photos
- [LottieFiles](https://lottiefiles.com/) - Animations

### Design Resources
- Figma Community templates
- Color palette generators
- Spacing/sizing calculators

---
**Good luck! 🎨 Let's create something amazing! 🚀**
