# 🔍 FACT-CHECKING FEATURE - DEVELOPMENT PROMPT

**Copy this entire prompt into a new chat session with GitHub Copilot**

---

## 🚨 PREREQUISITES: BUILD CONTENT GENERATION PAGE FIRST!

**⚠️ CRITICAL: You MUST build the Content Generation Page BEFORE this feature!**

**Required:**
1. ✅ Complete Prompt `00_CONTENT_GENERATION_PAGE_PROMPT.md` first
2. ✅ Ensure `ContentResultsPage` exists at `lib/features/content_generation/views/content_results_page.dart`
3. ✅ Ensure Settings Page exists (created with Auth pages)

**Why?** Fact-checking widgets integrate INTO the Content Results page. You need that page built first.

---

## TASK: Build Fact-Checking Feature Components

I'm building the **Fact-Checking Feature** for Summarly AI Content Generator (Flutter web app). This is a **reusable component system** that integrates into multiple screens (Content Generation results, Settings page).

### 📚 CONTEXT FILES TO READ FIRST:

**CRITICAL - Read these files before starting:**
1. `.github/instructions/FRONTEND_INSTRUCTIONS.md` - Complete development guide with custom widgets, theme, architecture patterns
2. `lib/core/theme/app_theme.dart` (281 lines) - All colors, spacing, border radius constants
3. `lib/core/constants/font_sizes.dart` (211 lines) - Typography system
4. `docs/features/01_fact_checking/FACT_CHECKING_UX_SPECS.md` (547 lines) - Complete UX specifications
5. `docs/features/01_fact_checking/01_FACT_CHECKING.md` - Feature overview and backend API specs
6. `.github/instructions/prompts/00_CONTENT_GENERATION_PAGE_PROMPT.md` - Content Generation Page specs (MUST be built first)

---

## 🎯 IMPORTANT: This is NOT a Standalone Screen

**Fact-checking is a FEATURE COMPONENT that appears in:**
1. **Settings Page** → Toggle to enable/disable auto fact-checking + confidence threshold slider
2. **Content Generation Results Page** → Fact-check results panel showing verified/unverified claims (see Prompt 00)
3. **Future: Content Editor** → Inline highlighting of claims (optional advanced feature)

**You are building REUSABLE WIDGETS**, not full pages. These widgets will be imported and used by other screens.

---

## 📋 COMPONENTS TO BUILD (7 Total)

### Component 1: Fact-Check Settings Section Widget
**Purpose:** Display in Settings page to control fact-checking preferences

**Location in UI:** Settings Page → Content Generation Preferences section

**Features:**
- **Auto Fact-Check Toggle**:
  - Switch widget (Material/Cupertino adaptive)
  - Label: "Auto Fact-Check Content"
  - Helper text: "Automatically verify factual claims in generated content"
  - Badge: "PRO FEATURE" (accent color, pill shape)
  - Disabled for Free tier users (show tooltip "Upgrade to Hobby")
  - Enabled for Hobby/Pro tier users

- **Confidence Threshold Slider** (only visible when toggle is ON):
  - Range: 50% - 95%
  - Default: 70%
  - Step: 5%
  - Label: "Confidence Threshold"
  - Helper text: "Only show claims with [X]% or higher confidence"
  - Real-time preview of selected percentage

- **Quota Display** (only for Hobby tier):
  - Text: "Quota: 7/10 fact-checks used this month"
  - Progress bar showing usage
  - "Upgrade to Pro for unlimited" link

- **Layout**: Column with Gap(16) spacing between elements

---

### Component 2: Fact-Check Results Panel Widget
**Purpose:** Display fact-check results after content generation

**Location in UI:** Content Generation Results screen, below generated content

**States:**

**A. Collapsed State (default):**
```
┌────────────────────────────────────────────────┐
│ ✓ Fact-Check Complete (3 claims verified)     │
│   Verification time: 12.4s                     │
│   ▼ View Details                               │
└────────────────────────────────────────────────┘
```

**B. Expanded State:**
Shows list of claim cards (see Component 3)

**C. Loading State:**
```
┌────────────────────────────────────────────────┐
│ ⏳ Verifying facts... (3 of 5 claims)          │
│   [Progress bar: 60%]                          │
└────────────────────────────────────────────────┘
```

**D. Empty State (no claims found):**
```
┌────────────────────────────────────────────────┐
│ ✓ Fact-Check Complete                          │
│   No verifiable claims detected                │
│   (This content appears opinion-based)         │
└────────────────────────────────────────────────┘
```

**E. Error State:**
```
┌────────────────────────────────────────────────┐
│ ⚠ Fact-Check Failed                            │
│   Unable to verify claims                      │
│   [Retry] [Skip Fact-Check]                    │
└────────────────────────────────────────────────┘
```

**Features:**
- ExpansionPanel or custom expandable card
- Summary shows: total claims, verification time
- Green checkmark icon for success, red warning for errors
- Smooth expand/collapse animation

---

### Component 3: Claim Card Widget
**Purpose:** Display individual verified/unverified claim with confidence score

**Visual Design:**

**Verified Claim (≥70% confidence):**
```
┌────────────────────────────────────────────┐
│ "Python was created by Guido van Rossum    │
│  in 1991"                                  │
│                                            │
│ Status: ✓ VERIFIED                         │
│ Confidence: ████████░░ 85%                 │
│ Source: Wikipedia - Python (programming)   │
│ [View Source →]                            │
└────────────────────────────────────────────┘
```
- Border: 2px solid Green-600 (#059669)
- Background: Green-50 (#F0FDF4)

**Medium Confidence (50-69%):**
```
┌────────────────────────────────────────────┐
│ "Global AI market expected to reach        │
│  $190B by 2025"                            │
│                                            │
│ Status: ⚠ PARTIALLY VERIFIED               │
│ Confidence: █████░░░░░ 55%                 │
│ Source: Multiple conflicting estimates     │
│ [View Sources]                             │
└────────────────────────────────────────────┘
```
- Border: 2px solid Yellow-600 (#D97706)
- Background: Yellow-50 (#FFFBEB)

**Unverified Claim (<50%):**
```
┌────────────────────────────────────────────┐
│ "AI will replace all jobs by 2030"         │
│                                            │
│ Status: ✗ UNVERIFIED                       │
│ Confidence: ██░░░░░░░░ 20%                 │
│ Source: No credible source found           │
│ [Manually Verify] [Remove Claim]           │
└────────────────────────────────────────────┘
```
- Border: 2px solid Red-600 (#DC2626)
- Background: Red-50 (#FEF2F2)

**Elements:**
- Claim text: BodyText, Gray-900, max 3 lines (show more if needed)
- Status row: Icon + label (H3 or BodyTextLarge)
- Confidence bar: LinearProgressIndicator with percentage label
- Source link: CustomTextButton (blue, opens in new tab)
- Action buttons: SecondaryButton for "Manually Verify", "Remove Claim"

**Spacing:** Gap(12) between elements, 16px padding inside card

---

### Component 4: Confidence Bar Widget
**Purpose:** Visual progress bar showing confidence percentage

**Visual:**
```
Confidence: ████████░░ 85%
```

**Colors by confidence level:**
- 70-100%: Green-600 (#059669)
- 50-69%: Yellow-600 (#D97706)
- 0-49%: Red-600 (#DC2626)

**Implementation:**
- LinearProgressIndicator (Flutter widget)
- Value: confidence / 100 (0.0 - 1.0)
- Height: 8px
- Rounded corners (borderRadiusSM)
- Percentage label to the right: BodyText, medium weight

---

### Component 5: Quota Display Widget
**Purpose:** Show fact-check usage for Hobby tier users

**Visual:**
```
┌─────────────────────────────────────────┐
│ Fact-Check Quota                        │
│ ████████░░░░░░ 7/10 used this month     │
│ [Upgrade to Pro for unlimited →]        │
└─────────────────────────────────────────┘
```

**Elements:**
- Title: "Fact-Check Quota" (H3)
- Progress bar: LinearProgressIndicator showing 7/10 (70%)
- Text: "7/10 used this month" (BodyText, textSecondary)
- Upgrade link: CustomTextButton (primary color)

**Colors:**
- 0-50% used: Green-600
- 51-80% used: Yellow-600
- 81-100% used: Red-600

**Only visible for Hobby tier users**

---

### Component 6: Quota Exceeded Modal Widget
**Purpose:** Show when user reaches monthly quota limit

**Visual:**
```
┌─────────────────────────────────────────┐
│          Quota Limit Reached             │
│                                          │
│  You've used all 10 fact-checks this    │
│  month. Upgrade to Pro for unlimited    │
│  fact-checking.                          │
│                                          │
│  [Upgrade to Pro]  [Continue Without]   │
└─────────────────────────────────────────┘
```

**Elements:**
- Title: "Quota Limit Reached" (H2)
- Body text: BodyText, center aligned
- Two buttons:
  - PrimaryButton: "Upgrade to Pro" → Navigate to pricing page
  - SecondaryButton: "Continue Without" → Generate without fact-check
- Modal background: Semi-transparent overlay
- Card: White, shadow, rounded corners

---

### Component 7: Fact-Check Loading Indicator Widget
**Purpose:** Show progress during fact-checking process

**Visual:**
```
┌────────────────────────────────────────┐
│ ⏳ Verifying facts...                  │
│    Checking claim 3 of 5               │
│    ████████░░░░░░░░░░ 60%              │
└────────────────────────────────────────┘
```

**Elements:**
- Icon: AdaptiveLoading or hourglass icon
- Title: "Verifying facts..." (H3)
- Progress text: "Checking claim 3 of 5" (BodyTextSmall)
- Progress bar: LinearProgressIndicator
- Updates in real-time as claims are verified

---

## 🎯 MANDATORY REQUIREMENTS:

### Custom Widgets (NEVER use standard Flutter widgets):
- ✅ **Text**: H1, H2, H3, DisplayText, BodyText, BodyTextLarge, BodyTextSmall, CaptionText (NEVER Text())
- ✅ **Buttons**: PrimaryButton, SecondaryButton, CustomTextButton (NEVER ElevatedButton/OutlinedButton())
- ✅ **Spacing**: Gap(12), Gap(16), Gap(24) (NEVER SizedBox())
- ✅ **Loading**: AdaptiveLoading, SmallLoader
- ✅ **Input**: CustomTextField (for settings)

### Theme Constants (NEVER hardcode):
- ✅ **Colors**: 
  - Success: AppTheme.success or Color(0xFF059669) [Green-600]
  - Warning: AppTheme.warning or Color(0xFFD97706) [Yellow-600]
  - Error: AppTheme.error or Color(0xFFDC2626) [Red-600]
  - Text: AppTheme.textPrimary, AppTheme.textSecondary
  - Background: AppTheme.bgPrimary, AppTheme.bgSecondary
  - Border: AppTheme.border
  - Primary: AppTheme.primary
  - Accent: AppTheme.accent
  
- ✅ **Spacing**: AppTheme.spacing8/12/16/24/32
- ✅ **Border Radius**: AppTheme.borderRadiusSM/MD/LG
- ✅ **Fonts**: FontSizes.h2/h3/bodyRegular/bodyLarge/bodySmall/captionRegular

### Architecture:
- ✅ **800-line limit per file** - Split large widgets
- ✅ **Folder structure**:
  ```
  features/fact_checking/
  ├── models/
  │   ├── fact_check_results.dart (~80 lines) - Data models
  │   └── fact_check_claim.dart (~60 lines)
  ├── controllers/
  │   └── fact_check_controller.dart (~200 lines) - GetX controller
  ├── widgets/
  │   ├── fact_check_settings_section.dart (~150 lines)
  │   ├── fact_check_results_panel.dart (~200 lines)
  │   ├── claim_card.dart (~150 lines)
  │   ├── confidence_bar.dart (~80 lines)
  │   ├── quota_display.dart (~100 lines)
  │   ├── quota_exceeded_modal.dart (~120 lines)
  │   └── fact_check_loading.dart (~80 lines)
  └── services/
      └── fact_check_service.dart (~150 lines) - API calls
  ```

### State Management with GetX:
- ✅ Create `FactCheckController` extending GetxController:
  ```dart
  class FactCheckController extends GetxController {
    // Observable state
    final isFactCheckEnabled = false.obs;
    final confidenceThreshold = 70.obs; // 50-95%
    final factCheckResults = Rxn<FactCheckResults>(); // nullable
    final isLoading = false.obs;
    final currentClaim = 0.obs; // For progress tracking
    final totalClaims = 0.obs;
    final errorMessage = ''.obs;
    final quotaUsed = 0.obs; // For Hobby tier
    final quotaLimit = 10.obs; // Hobby tier limit
    
    // Computed properties
    bool get hasQuotaRemaining => quotaUsed.value < quotaLimit.value;
    double get quotaPercentage => quotaUsed.value / quotaLimit.value;
    bool get isQuotaExceeded => quotaUsed.value >= quotaLimit.value;
    
    // Methods
    Future<void> loadSettings() async { /* Load from Firebase */ }
    Future<void> saveSettings() async { /* Save to Firebase */ }
    Future<void> checkQuota() async { /* Check usage */ }
    void toggleFactCheck(bool enabled) { /* Update setting */ }
    void updateConfidenceThreshold(double value) { /* Update threshold */ }
    Future<FactCheckResults> verifyContent(String content) async { /* Call API */ }
    void showQuotaExceededModal() { /* Show modal */ }
  }
  ```

### Data Models:
- ✅ Create `FactCheckResults` model:
  ```dart
  class FactCheckResults {
    final bool checked;
    final List<FactCheckClaim> claims;
    final double verificationTime; // seconds
    
    FactCheckResults({
      required this.checked,
      required this.claims,
      required this.verificationTime,
    });
    
    factory FactCheckResults.fromJson(Map<String, dynamic> json) {
      return FactCheckResults(
        checked: json['checked'] ?? false,
        claims: (json['claims'] as List?)
            ?.map((c) => FactCheckClaim.fromJson(c))
            .toList() ?? [],
        verificationTime: (json['verificationTime'] ?? 0).toDouble(),
      );
    }
  }
  ```

- ✅ Create `FactCheckClaim` model:
  ```dart
  class FactCheckClaim {
    final String claim;
    final bool verified;
    final String? source;
    final double confidence; // 0.0 - 1.0
    
    FactCheckClaim({
      required this.claim,
      required this.verified,
      this.source,
      required this.confidence,
    });
    
    // Getters
    String get confidencePercentage => '${(confidence * 100).toInt()}%';
    Color get statusColor {
      if (confidence >= 0.70) return Color(0xFF059669); // Green
      if (confidence >= 0.50) return Color(0xFFD97706); // Yellow
      return Color(0xFFDC2626); // Red
    }
    String get statusLabel {
      if (confidence >= 0.70) return 'VERIFIED';
      if (confidence >= 0.50) return 'PARTIALLY VERIFIED';
      return 'UNVERIFIED';
    }
    IconData get statusIcon {
      if (confidence >= 0.70) return Icons.check_circle;
      if (confidence >= 0.50) return Icons.warning;
      return Icons.cancel;
    }
    
    factory FactCheckClaim.fromJson(Map<String, dynamic> json) {
      return FactCheckClaim(
        claim: json['claim'] ?? '',
        verified: json['verified'] ?? false,
        source: json['source'],
        confidence: (json['confidence'] ?? 0.0).toDouble(),
      );
    }
  }
  ```

### API Integration:
- ✅ **Backend Endpoint**: `POST /api/v1/generate/blog` (or any content endpoint)
  - Request includes: `autoFactCheck: true` from user settings
  - Response includes: `factCheckResults` object
  
- ✅ **Response Format**:
  ```json
  {
    "content": "Generated content...",
    "factCheckResults": {
      "checked": true,
      "claims": [
        {
          "claim": "Python was created in 1991",
          "verified": true,
          "source": "Wikipedia - Python (programming language)",
          "confidence": 0.85
        }
      ],
      "verificationTime": 12.4
    }
  }
  ```

- ✅ **Settings Endpoint**: `GET/PUT /api/v1/user/settings`
  - Get/update: `autoFactCheck`, `confidenceThreshold`

- ✅ **Quota Endpoint**: `GET /api/v1/user/quota/fact-check`
  - Response: `{ "used": 7, "limit": 10, "tier": "hobby" }`

---

## 🎨 DESIGN SPECIFICATIONS:

### Colors (Status-based):
- **Verified (≥70%)**: 
  - Border: Green-600 (#059669)
  - Background: Green-50 (#F0FDF4)
  - Icon: Green-600
  
- **Medium (50-69%)**:
  - Border: Yellow-600 (#D97706)
  - Background: Yellow-50 (#FFFBEB)
  - Icon: Yellow-600
  
- **Unverified (<50%)**:
  - Border: Red-600 (#DC2626)
  - Background: Red-50 (#FEF2F2)
  - Icon: Red-600

### Typography:
- Panel title: H2 (20px, semibold)
- Claim text: BodyText (14px, regular)
- Status label: H3 (16px, medium)
- Confidence %: BodyTextLarge (16px, medium)
- Source link: BodyTextSmall (13px, regular)
- Helper text: CaptionText (12px, regular)

### Spacing:
- Card padding: 16px (AppTheme.spacing16)
- Gap between claims: Gap(12)
- Gap between sections: Gap(24)
- Border radius: AppTheme.borderRadiusMD (8px)
- Card shadow: Medium elevation

### Responsive Design:
- **Desktop (>1024px)**: 
  - Fact-check panel: Max-width 800px
  - Claim cards: 2 columns if many claims
  
- **Tablet (768px - 1024px)**:
  - Single column layout
  - Full-width claim cards
  
- **Mobile (<768px)**:
  - Collapsed by default
  - Claim text: Max 2 lines, "Show more" button
  - Action buttons: Stack vertically

---

## 📊 IMPLEMENTATION STEPS:

1. **Read Context Files** (10 min):
   - Read FRONTEND_INSTRUCTIONS.md completely
   - Read app_theme.dart and font_sizes.dart
   - Read FACT_CHECKING_UX_SPECS.md (section C, D, E)
   - Read 01_FACT_CHECKING.md (API specs)

2. **Create Folder Structure** (2 min):
   - Create features/fact_checking/models/, controllers/, widgets/, services/ folders

3. **Create Data Models** (15 min):
   - fact_check_results.dart
   - fact_check_claim.dart
   - Add fromJson, toJson methods
   - Add computed properties (confidencePercentage, statusColor, statusLabel)

4. **Create Controller** (25 min):
   - fact_check_controller.dart with GetX
   - Observable state for settings, results, loading
   - Methods for loadSettings, saveSettings, verifyContent
   - Quota management methods

5. **Create Service** (20 min):
   - fact_check_service.dart
   - API calls to backend endpoints
   - Error handling
   - Use ApiService from utilities

6. **Create Widgets** (90 min):
   - **fact_check_settings_section.dart** (20 min):
     - Toggle switch with badge
     - Confidence threshold slider
     - Quota display (conditional)
     
   - **confidence_bar.dart** (10 min):
     - LinearProgressIndicator with color based on confidence
     - Percentage label
     
   - **claim_card.dart** (20 min):
     - Card with border color based on confidence
     - Status icon + label
     - Confidence bar
     - Source link
     - Action buttons
     
   - **fact_check_results_panel.dart** (25 min):
     - ExpansionPanel or custom expandable
     - Summary (collapsed state)
     - List of claim cards (expanded state)
     - Loading, empty, error states
     
   - **quota_display.dart** (10 min):
     - Progress bar showing usage
     - Text label
     - Upgrade link
     
   - **quota_exceeded_modal.dart** (15 min):
     - Dialog/Modal with overlay
     - Title, body text
     - Two buttons (Upgrade, Continue)
     
   - **fact_check_loading.dart** (10 min):
     - AdaptiveLoading
     - Progress text
     - Progress bar

7. **Create Progress File** (5 min):
   - Create FACT_CHECK_FEATURE_PROGRESS.md
   - Track completion of each widget
   - Note line counts

8. **Test Widgets in Isolation** (20 min):
   - Create test page that displays all widgets
   - Test with mock data
   - Verify responsive layouts
   - Test loading, empty, error states

---

## ✅ SUCCESS CRITERIA:

Fact-checking feature is complete when:
- [ ] All 7 widgets implemented
- [ ] All files under 800 lines
- [ ] Only custom widgets used (no Text(), SizedBox(), TextField())
- [ ] Only AppTheme constants used (no hardcoded colors/spacing)
- [ ] Data models with fromJson/toJson methods
- [ ] FactCheckController with GetX reactive state
- [ ] Service layer with API integration
- [ ] All 3 status types work (verified, medium, unverified)
- [ ] Confidence bar colors change based on percentage
- [ ] Quota display only shows for Hobby tier
- [ ] Quota exceeded modal shows when limit reached
- [ ] Loading states work smoothly
- [ ] Empty state displays when no claims found
- [ ] Error state displays with retry button
- [ ] Responsive on all 3 breakpoints
- [ ] Settings toggle saves to Firebase
- [ ] Source links open in new tab
- [ ] No console errors or warnings
- [ ] FACT_CHECK_FEATURE_PROGRESS.md shows 100% completion
- [ ] Code follows FRONTEND_INSTRUCTIONS.md patterns

---

## 🔗 INTEGRATION NOTES:

**These widgets will be used by:**

1. **Settings Page** (should already exist from Auth setup):
   - Import `FactCheckSettingsSection` widget
   - Place in "Content Generation Preferences" section
   - Connect to `FactCheckController`

2. **Content Generation Results Page** (MUST be built first - see Prompt 00):
   - **Location**: `lib/features/content_generation/views/content_results_page.dart`
   - Import `FactCheckResultsPanel` widget
   - Display below generated content card
   - Pass `factCheckResults` from API response
   - Show loading state during verification
   - **Integration Point**: After quality score widget, before humanization button

3. **Dashboard** (optional future enhancement):
   - Show quota usage widget
   - Link to settings page

**Example Usage:**

```dart
// ============================================
// In Settings Page (settings_page.dart)
// ============================================
import '../../fact_checking/widgets/fact_check_settings_section.dart';
import '../../fact_checking/controllers/fact_check_controller.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          H2('Content Generation Preferences'),
          Gap(16),
          
          // Fact-Check Settings Section
          Obx(() {
            final controller = Get.find<FactCheckController>();
            return FactCheckSettingsSection(
              isEnabled: controller.isFactCheckEnabled.value,
              confidenceThreshold: controller.confidenceThreshold.value,
              quotaUsed: controller.quotaUsed.value,
              quotaLimit: controller.quotaLimit.value,
              userTier: 'hobby', // Get from user controller
              onToggle: controller.toggleFactCheck,
              onThresholdChange: controller.updateConfidenceThreshold,
            );
          }),
          
          Gap(24),
          // Other settings sections...
        ],
      ),
    );
  }
}

// ============================================
// In Content Results Page (content_results_page.dart)
// ============================================
import '../../fact_checking/widgets/fact_check_results_panel.dart';
import '../../fact_checking/controllers/fact_check_controller.dart';

class ContentResultsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final contentController = Get.find<ContentGenerationController>();
    final factCheckController = Get.find<FactCheckController>();
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Generated content display card
            ContentDisplayCard(
              content: contentController.generatedContent.value!.content,
              qualityScore: contentController.generatedContent.value!.qualityScore,
            ),
            
            Gap(16),
            
            // Action buttons (Copy, Regenerate, Save, Export)
            ActionButtonsRow(),
            
            Gap(24),
            
            // Quality Score Details Panel (from Quality Guarantee feature)
            QualityDetailsPanel(
              qualityScore: contentController.generatedContent.value!.qualityScore,
            ),
            
            Gap(16),
            
            // ===== FACT-CHECK RESULTS PANEL (THIS FEATURE) =====
            Obx(() {
              final factCheckResults = contentController.generatedContent.value?.factCheckResults;
              
              // Only show if fact-checking was enabled for this generation
              if (factCheckResults == null || !factCheckResults.checked) {
                return SizedBox.shrink();
              }
              
              return FactCheckResultsPanel(
                results: factCheckResults,
                isLoading: factCheckController.isLoading.value,
                onRetry: () => factCheckController.verifyContent(
                  contentController.generatedContent.value!.content,
                ),
              );
            }),
            
            Gap(16),
            
            // AI Humanization Button (from AI Humanization feature)
            HumanizeButton(),
            
            Gap(32),
          ],
        ),
      ),
    );
  }
}
```

**Where to add in ContentResultsPage:**
```
┌─────────────────────────────────────────────────────┐
│ Generated Content Card                              │
│ [Quality Badge: A (82%)]                            │
│ Lorem ipsum dolor sit amet...                       │
│ [Copy] [Regenerate] [Save] [Export]                 │
└─────────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────┐
│ Quality Score Details (Expandable)                  │
│ Readability: 85% • Completeness: 90%                │
└─────────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────┐
│ ⬇️ INSERT FACT-CHECK RESULTS PANEL HERE ⬇️          │
│                                                     │
│ ✓ Fact-Check Complete (3 claims verified)          │
│   Verification time: 12.4s                          │
│   ▼ View Details                                    │
└─────────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────┐
│ 🤖 [Humanize Content] [PRO]                         │
│    5/25 used this month                             │
└─────────────────────────────────────────────────────┘
```

---

## 🧪 TESTING CHECKLIST:

- [ ] Test with 0 claims (empty state)
- [ ] Test with 1 claim (single card)
- [ ] Test with 10+ claims (scrollable list)
- [ ] Test all confidence levels: 95%, 70%, 65%, 50%, 35%, 10%
- [ ] Test loading state (simulated delay)
- [ ] Test error state (network failure)
- [ ] Test quota display: 0/10, 5/10, 10/10
- [ ] Test quota exceeded modal
- [ ] Test settings toggle (enable/disable)
- [ ] Test confidence slider (50% to 95%)
- [ ] Test source links (open new tab)
- [ ] Test on mobile (iPhone), tablet (iPad), desktop (Chrome)
- [ ] Test dark mode (if implemented)
- [ ] Test with screen reader (accessibility)
- [ ] Test keyboard navigation

---

**START NOW:** Read FRONTEND_INSTRUCTIONS.md, FACT_CHECKING_UX_SPECS.md, app_theme.dart, and font_sizes.dart, then begin implementation with folder structure and data models.

---

## 📝 NOTES:

- This feature is **NOT IMPLEMENTED on backend yet** - you'll be building the UI/frontend widgets only
- Backend API may return mock data initially
- Fact-checking adds 10-15 seconds to content generation time
- This is a **CRITICAL differentiator** - only Writesonic has basic fact-checking, we have multi-source verification
- Free tier: NO fact-checking
- Hobby tier: 10 fact-checks/month
- Pro tier: UNLIMITED fact-checking
