# 🏗️ FEATURE BUILD ORDER - CRITICAL INSTRUCTIONS

## ⚠️ IMPORTANT: Read This Before Building Any Features!

This document explains the **correct order** to build features. Some features are **standalone pages** (can be built independently), while others are **component features** (widgets that integrate into other pages).

---

## 📊 FEATURE DEPENDENCY CHART

```
┌──────────────────────────────────────────────────────────┐
│ STANDALONE PAGES (Build First - No Dependencies)        │
├──────────────────────────────────────────────────────────┤
│ 01. Landing Page                                         │
│ 02. Auth Pages (Sign In / Sign Up)                       │
│ 03. Settings Page (part of Auth system)                  │
│                                                          │
│ ⬇️  BUILD THESE FIRST                                    │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ FOUNDATIONAL PAGE (Required for All Features Below)     │
├──────────────────────────────────────────────────────────┤
│ 00. Content Generation Page                              │
│     - Content form (blog, social, email, video)          │
│     - Content results display                            │
│                                                          │
│ ⬇️  BUILD THIS NEXT (CRITICAL!)                          │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ COMPONENT FEATURES (Integrate into Content Results Page)│
├──────────────────────────────────────────────────────────┤
│ 03. Fact-Checking (widgets)                              │
│ 04. Quality Guarantee (widgets)                          │
│ 05. AI Humanization (widgets)                            │
│ 06. Brand Voice (widgets)                                │
│ 07. Video Generation (forms + widgets)                   │
│ 08. Image Generation (forms + widgets)                   │
│                                                          │
│ ⬇️  BUILD THESE LAST (After Content Gen Page)            │
└──────────────────────────────────────────────────────────┘
```

---

## 🎯 RECOMMENDED BUILD ORDER

### Phase 1: Core Pages (Independent)
**Build these in any order - no dependencies:**

1. ✅ **Prompt 01**: Landing Page (`/`)
   - File: `01_LANDING_PAGE_PROMPT.md`
   - Status: Standalone, no dependencies
   - Hero section, features, pricing, testimonials, footer

2. ✅ **Prompt 02**: Auth Pages (`/signin`, `/signup`)
   - File: `02_AUTH_PAGES_PROMPT.md`
   - Status: Standalone, no dependencies
   - Sign in, sign up, forgot password
   - Includes Settings page skeleton

---

### Phase 2: Content Generation Foundation (CRITICAL!)
**⚠️ Must be built BEFORE Prompts 03-08:**

3. 🚨 **Prompt 00**: Content Generation Page (`/generate`, `/generate/results`)
   - File: `00_CONTENT_GENERATION_PAGE_PROMPT.md`
   - Status: **REQUIRED for all features below**
   - Why critical: All feature widgets integrate into this page
   - Components:
     - Content type selector (blog, social, email, video)
     - Type-specific forms
     - Results display page
     - Action buttons (copy, save, export)
     - Placeholder sections for feature widgets

**❌ DO NOT PROCEED to Phase 3 until this is complete!**

---

### Phase 3: Feature Components (Order Matters)
**Build these AFTER Content Generation Page exists:**

4. **Prompt 04**: Quality Guarantee (Easiest - Start Here)
   - File: `04_QUALITY_GUARANTEE_PROMPT.md`
   - Dependencies: Content Results Page
   - Status: ✅ Backend fully implemented
   - Components: Quality score badge, quality details panel
   - Integration: Displays at top of Content Results Page

5. **Prompt 03**: Fact-Checking
   - File: `03_FACT_CHECK_FEATURE_PROMPT.md`
   - Dependencies: Content Results Page, Settings Page
   - Status: ❌ Backend NOT implemented (use mock data)
   - Components: Settings toggle, fact-check results panel, claim cards
   - Integration: Displays below quality panel in Content Results Page

6. **Prompt 05**: AI Humanization
   - File: `05_AI_HUMANIZATION_PROMPT.md`
   - Dependencies: Content Results Page
   - Status: ✅ Backend fully implemented
   - Components: Humanize button, settings modal, before/after comparison
   - Integration: Button below fact-check panel in Content Results Page

7. **Prompt 06**: Brand Voice
   - File: `06_BRAND_VOICE_PROMPT.md`
   - Dependencies: Content Generation Form, Settings Page
   - Status: ❌ Backend NOT implemented (use mock data)
   - Components: Training modal, voice selector, settings section
   - Integration: Dropdown in Content Generation Form + Settings Page

8. **Prompt 07**: Video Generation
   - File: `07_VIDEO_GENERATION_PROMPT.md`
   - Dependencies: Content Generation Page
   - Status: ✅ Video scripts backend implemented, ❌ Video creation not implemented
   - Components: Video script form, script results display
   - Integration: Tab in Content Generation Page

9. **Prompt 08**: Image Generation
   - File: `08_IMAGE_GENERATION_PROMPT.md`
   - Dependencies: Content Generation Page
   - Status: Backend status unknown
   - Components: Image generation form, image results gallery
   - Integration: Tab in Content Generation Page

---

## 🚫 COMMON MISTAKES TO AVOID

### ❌ Mistake 1: Building Features Before Content Generation Page
**Problem:** 
- Prompts 03-08 say "integrate into Content Generation Results"
- But that page doesn't exist yet!

**Solution:**
- Build Prompt 00 (Content Generation Page) first
- Create placeholder sections for feature widgets
- Then build feature widgets and integrate them

---

### ❌ Mistake 2: Trying to Build Fact-Checking as a Standalone Page
**Problem:**
- Prompt 03 clearly states: "This is NOT a standalone screen"
- It's a component that displays IN the Content Results Page

**Solution:**
- Build widgets only (not a page)
- Import and use in ContentResultsPage
- Show conditionally based on user settings

---

### ❌ Mistake 3: Building Video Generation as a Separate Screen
**Problem:**
- Prompt 07 says "Video is part of Content Generation Page"
- Not a separate navigation item

**Solution:**
- Add "Video Script" as a content type tab/option
- Display video form in Content Generation Form
- Show video results in Content Results Page

---

## 📝 UPDATED PROMPT NOTES

### Changes Made:

1. **Created Prompt 00** - Content Generation Page
   - New file: `00_CONTENT_GENERATION_PAGE_PROMPT.md`
   - Must be built before Prompts 03-08

2. **Updated Prompt 03** - Fact-Checking
   - Added prerequisites section
   - References Prompt 00
   - Clarified integration points
   - Added code examples showing exact placement

3. **No Changes Needed** for Prompts 01-02
   - Landing and Auth pages are standalone
   - No dependencies

---

## 🎯 ACTION PLAN

### If Starting Fresh:
```
Step 1: Build Landing Page (Prompt 01)
Step 2: Build Auth Pages (Prompt 02)
Step 3: Build Content Generation Page (Prompt 00) ← CRITICAL!
Step 4: Build Quality Guarantee (Prompt 04)
Step 5: Build Fact-Checking (Prompt 03)
Step 6: Build AI Humanization (Prompt 05)
Step 7: Build Brand Voice (Prompt 06)
Step 8: Build Video Generation (Prompt 07)
Step 9: Build Image Generation (Prompt 08)
```

### If Content Generation Page Doesn't Exist:
```
Step 1: STOP building feature components (Prompts 03-08)
Step 2: Build Content Generation Page (Prompt 00)
Step 3: Create placeholder sections for feature widgets
Step 4: THEN build feature widgets and integrate
```

### If Content Generation Page Already Exists:
```
Step 1: Verify ContentResultsPage has placeholder sections
Step 2: Build feature widgets (Prompts 03-08 in order)
Step 3: Integrate widgets into ContentResultsPage
Step 4: Test integration
```

---

## 🔍 HOW TO VERIFY PREREQUISITES

### Before Building Prompt 03 (Fact-Checking):

**Check 1: Content Results Page Exists**
```bash
# File should exist:
lib/features/content_generation/views/content_results_page.dart
```

**Check 2: Settings Page Exists**
```bash
# File should exist (from Auth setup):
lib/features/settings/views/settings_page.dart
```

**Check 3: Placeholder Sections Exist**
```dart
// ContentResultsPage should have:
- Quality Score Panel (or placeholder)
- Fact-Check Panel placeholder ← You'll add FactCheckResultsPanel here
- Humanization Button placeholder
```

If any check fails → **Build Prompt 00 first!**

---

## 📞 QUESTIONS?

**Q: Can I build Fact-Checking without Content Generation Page?**
A: No. It has nowhere to display. Build Prompt 00 first.

**Q: Can I build Quality Guarantee before Fact-Checking?**
A: Yes! Quality (Prompt 04) is easier and also needs Content Results Page.

**Q: Can I skip Content Generation Page and build features as standalone?**
A: No. The prompts explicitly state they're components, not pages. You need the parent page.

**Q: What if the backend for a feature isn't ready?**
A: Build the UI with mock data (like Fact-Checking). Backend integration comes later.

**Q: How do I know which features have working backends?**
A: Check the "IMPORTANT" section in each prompt:
- ✅ Quality Guarantee: Backend complete
- ✅ AI Humanization: Backend complete
- ❌ Fact-Checking: Backend not implemented
- ❌ Brand Voice: Backend not implemented
- ✅ Video Scripts: Backend complete
- ❌ Automated Video: Backend not implemented

---

## ✅ SUCCESS CHECKLIST

Before marking this as "understood":

- [ ] I understand Landing + Auth pages are standalone
- [ ] I understand Content Generation Page (Prompt 00) MUST be built first
- [ ] I understand Prompts 03-08 are widgets, not pages
- [ ] I understand the correct build order (Phase 1 → Phase 2 → Phase 3)
- [ ] I will NOT build feature widgets until Content Results Page exists
- [ ] I will use mock data for features with unimplemented backends
- [ ] I will integrate widgets into ContentResultsPage after building them

---

**TLDR: Build Prompt 00 (Content Generation Page) before Prompts 03-08. Those are widgets that go INSIDE the Content Results Page, not standalone pages.**
