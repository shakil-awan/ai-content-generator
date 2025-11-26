# 📑 FEATURE PROMPTS INDEX

## Quick Reference Guide for Building AI Content Generator Features

---

## 🚀 START HERE

**New to the project?** Read these first:
1. 📖 `README_BUILD_ORDER.md` - **CRITICAL**: Understanding build dependencies
2. 📖 `../FRONTEND_INSTRUCTIONS.md` - Development standards and custom widgets
3. 📖 `../../core/theme/app_theme.dart` - Theme constants (colors, spacing, fonts)

---

## 📂 PROMPT FILES BY BUILD ORDER

### Phase 1: Standalone Pages (No Dependencies)

#### ✅ Prompt 01: Landing Page
- **File**: `01_LANDING_PAGE_PROMPT.md`
- **Status**: Standalone, can build anytime
- **Route**: `/`
- **Description**: Hero section, features, pricing, testimonials, footer
- **Estimated Time**: 4-6 hours
- **Dependencies**: None

#### ✅ Prompt 02: Authentication Pages
- **File**: `02_AUTH_PAGES_PROMPT.md`
- **Status**: Standalone, can build anytime
- **Routes**: `/signin`, `/signup`, `/forgot-password`
- **Description**: Sign in, sign up, password reset, Settings page skeleton
- **Estimated Time**: 3-4 hours
- **Dependencies**: None

---

### Phase 2: Foundation (REQUIRED for Phase 3)

#### 🚨 Prompt 00: Content Generation Page
- **File**: `00_CONTENT_GENERATION_PAGE_PROMPT.md`
- **Status**: **MUST BUILD FIRST** before Phase 3
- **Routes**: `/generate`, `/generate/results`
- **Description**: 
  - Content type selector (blog, social, email, video, image)
  - Type-specific generation forms
  - Content results display page
  - Placeholder sections for feature widgets
- **Estimated Time**: 6-8 hours
- **Dependencies**: None
- **⚠️ Critical**: All Phase 3 prompts depend on this!

---

### Phase 3: Feature Components (After Content Gen Page)

#### ✅ Prompt 04: Quality Guarantee (Easiest - Start Here)
- **File**: `04_QUALITY_GUARANTEE_PROMPT.md`
- **Status**: Backend ✅ Complete
- **Description**: Quality score badge, quality details panel
- **Estimated Time**: 2-3 hours
- **Dependencies**: 
  - ✅ Prompt 00 (Content Generation Page)
  - Displays in: `ContentResultsPage`
- **Integration Point**: Top of content card (quality badge)

#### ✅ Prompt 03: Fact-Checking
- **File**: `03_FACT_CHECK_FEATURE_PROMPT.md`
- **Status**: Backend ❌ Not Implemented (use mock data)
- **Description**: Settings toggle, fact-check results panel, claim cards
- **Estimated Time**: 3-4 hours
- **Dependencies**: 
  - ✅ Prompt 00 (Content Generation Page)
  - ✅ Settings Page (from Prompt 02)
  - Displays in: `ContentResultsPage`, Settings Page
- **Integration Point**: Below quality panel, above humanization button

#### ✅ Prompt 05: AI Humanization
- **File**: `05_AI_HUMANIZATION_PROMPT.md`
- **Status**: Backend ✅ Complete
- **Description**: Humanize button, settings modal, before/after comparison
- **Estimated Time**: 3-4 hours
- **Dependencies**: 
  - ✅ Prompt 00 (Content Generation Page)
  - Displays in: `ContentResultsPage`
- **Integration Point**: Below fact-check panel

#### ✅ Prompt 06: Brand Voice
- **File**: `06_BRAND_VOICE_PROMPT.md`
- **Status**: Backend ❌ Not Implemented (recommended to skip)
- **Description**: Training modal, voice selector, settings section
- **Estimated Time**: 4-5 hours (if building)
- **Dependencies**: 
  - ✅ Prompt 00 (Content Generation Form)
  - ✅ Settings Page (from Prompt 02)
  - Displays in: Content Generation Form (advanced options), Settings Page
- **⚠️ Note**: 4-6 weeks of backend work needed, consider skipping

#### ✅ Prompt 07: Video Generation
- **File**: `07_VIDEO_GENERATION_PROMPT.md`
- **Status**: Backend ✅ Video Scripts Complete, ❌ Video Creation Not Implemented
- **Description**: Video script form, script results display
- **Estimated Time**: 4-5 hours
- **Dependencies**: 
  - ✅ Prompt 00 (Content Generation Page)
  - Integrates as: Content type tab in Content Generation Form
- **Integration Point**: Tab in content type selector

#### ✅ Prompt 08: Image Generation
- **File**: `08_IMAGE_GENERATION_PROMPT.md`
- **Status**: Backend ✅ Complete
- **Description**: Image generation form, image results gallery
- **Estimated Time**: 4-5 hours
- **Dependencies**: 
  - ✅ Prompt 00 (Content Generation Page)
  - Integrates as: Content type tab in Content Generation Form
- **Integration Point**: Tab in content type selector

---

## 📊 PROGRESS TRACKER

Use this checklist to track your progress:

### Phase 1: Standalone Pages
- [ ] Landing Page (Prompt 01)
- [ ] Auth Pages (Prompt 02)

### Phase 2: Foundation
- [ ] Content Generation Page (Prompt 00) ← **CRITICAL BLOCKER**

### Phase 3: Feature Components
- [ ] Quality Guarantee (Prompt 04) - Easiest, start here
- [ ] Fact-Checking (Prompt 03)
- [ ] AI Humanization (Prompt 05)
- [ ] Brand Voice (Prompt 06) - Optional, backend not ready
- [ ] Video Generation (Prompt 07)
- [ ] Image Generation (Prompt 08)

---

## 🔍 QUICK REFERENCE

### Backend Status Summary

| Feature | Backend Status | Notes |
|---------|---------------|-------|
| Landing Page | N/A | Static content |
| Auth | ✅ Complete | Firebase Auth |
| Content Gen | ✅ Complete | All content types supported |
| Quality | ✅ Complete | Auto-scoring working |
| Fact-Check | ❌ Not Ready | Use mock data |
| Humanization | ✅ Complete | 3 levels available |
| Brand Voice | ❌ Not Ready | 4-6 weeks estimated |
| Video Scripts | ✅ Complete | All platforms supported |
| Video Creation | ❌ Not Ready | Pictory.ai integration planned |
| Image Gen | ✅ Complete | Flux + DALL-E working |

### Integration Points Summary

| Feature | Where It Appears | Parent Component |
|---------|-----------------|------------------|
| Quality Badge | Content Results (top-right) | `ContentResultsPage` |
| Quality Details | Content Results (below content) | `ContentResultsPage` |
| Fact-Check Settings | Settings Page | Settings Page |
| Fact-Check Results | Content Results (below quality) | `ContentResultsPage` |
| Humanize Button | Content Results (below fact-check) | `ContentResultsPage` |
| Brand Voice Settings | Settings Page | Settings Page |
| Brand Voice Selector | Content Form (advanced) | `ContentGenerationFormPage` |
| Video Script Form | Content Form (video tab) | `ContentGenerationFormPage` |
| Video Results | Content Results | `ContentResultsPage` |
| Image Form | Content Form (image tab) | `ContentGenerationFormPage` |
| Image Gallery | Content Results | `ContentResultsPage` |

---

## 🎯 RECOMMENDED BUILD SEQUENCE

**For maximum efficiency, follow this exact order:**

1. **Week 1**: Landing + Auth Pages
   - Day 1-2: Landing Page (Prompt 01)
   - Day 3-4: Auth Pages (Prompt 02)
   
2. **Week 2**: Content Generation Foundation
   - Day 1-3: Content Generation Page (Prompt 00) ← **CRITICAL**
   - Day 4-5: Quality Guarantee (Prompt 04) - Easy win
   
3. **Week 3**: Core Features
   - Day 1-2: AI Humanization (Prompt 05) - Backend ready
   - Day 3-4: Fact-Checking (Prompt 03) - Use mock data
   - Day 5: Testing + integration fixes
   
4. **Week 4**: Content Types
   - Day 1-2: Video Generation (Prompt 07)
   - Day 3-4: Image Generation (Prompt 08)
   - Day 5: Skip Brand Voice (Prompt 06) unless backend ready

---

## 💡 TIPS FOR SUCCESS

### Before Starting Any Prompt:

1. ✅ Read `README_BUILD_ORDER.md` to understand dependencies
2. ✅ Check prerequisites section at top of prompt
3. ✅ Verify required files exist (ContentResultsPage, Settings, etc.)
4. ✅ Review integration examples in prompt
5. ✅ Read FRONTEND_INSTRUCTIONS.md for custom widgets

### While Building:

- Use ONLY custom widgets (H1, H2, PrimaryButton, etc.)
- Use ONLY AppTheme constants (colors, spacing, fonts)
- Keep files under 800 lines (split into widgets/ if needed)
- Use GetX for state management
- Test on mobile, tablet, desktop

### After Building:

- Integrate widgets into parent pages
- Test all states (loading, success, error, empty)
- Verify responsive design
- Check console for errors

---

## 🆘 TROUBLESHOOTING

### Problem: "ContentResultsPage doesn't exist"
**Solution**: Build Prompt 00 first! That creates the page.

### Problem: "I built Fact-Checking but it has nowhere to display"
**Solution**: You skipped Prompt 00. Build Content Generation Page first.

### Problem: "Backend returns 404 for fact-checking"
**Solution**: Backend not implemented. Use mock data (documented in prompt).

### Problem: "Brand Voice API not responding"
**Solution**: Backend not built (4-6 weeks). Use mock data or skip feature.

### Problem: "File over 800 lines"
**Solution**: Split into smaller files in widgets/ folder.

---

## 📞 NEED HELP?

- Check `README_BUILD_ORDER.md` for dependency issues
- Check `FRONTEND_INSTRUCTIONS.md` for coding standards
- Check individual prompt files for detailed specs
- Review example integration code in prompts

---

**Last Updated**: November 26, 2025
**Total Prompts**: 9 (00-08)
**Estimated Total Time**: 30-40 hours
