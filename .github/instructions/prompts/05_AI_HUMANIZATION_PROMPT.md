# 🤖 AI HUMANIZATION FEATURE - DEVELOPMENT PROMPT

**Copy this entire prompt into a new chat session with GitHub Copilot**

---

## 🚨 PREREQUISITES: BUILD CONTENT GENERATION PAGE FIRST!

**⚠️ CRITICAL: You MUST build the Content Generation Page BEFORE this feature!**

**Required:**
1. ✅ Complete Prompt `00_CONTENT_GENERATION_PAGE_PROMPT.md` first
2. ✅ Ensure `ContentResultsPage` exists at `lib/features/content_generation/views/content_results_page.dart`
3. ✅ Ensure placeholder sections exist for humanization button

**Why?** Humanization button appears below generated content in the Content Results page. You need that page built first.

---

## TASK: Build AI Humanization UI Components

I'm building the **AI Humanization UI** for Summarly AI Content Generator (Flutter web app). This feature detects AI-generated patterns and rewrites content to bypass AI detection tools (GPTZero, Turnitin, Originality.ai).

### 📚 CONTEXT FILES TO READ FIRST:

**CRITICAL - Read these files before starting:**
1. `.github/instructions/FRONTEND_INSTRUCTIONS.md` - Complete development guide with custom widgets, theme, architecture patterns
2. `lib/core/theme/app_theme.dart` (281 lines) - All colors, spacing, border radius constants
3. `lib/core/constants/font_sizes.dart` (211 lines) - Typography system
4. `docs/features/03_ai_humanization/AI_HUMANIZATION_UX_SPECS.md` (725 lines) - Complete UX specifications
5. `docs/features/03_ai_humanization/03_AI_HUMANIZATION.md` (1445 lines) - Feature overview and backend implementation
6. `.github/instructions/prompts/00_CONTENT_GENERATION_PAGE_PROMPT.md` - Content Generation Page specs (MUST be built first)

---

## 🎯 IMPORTANT: Backend is FULLY IMPLEMENTED

**AI Humanization is ALREADY WORKING on backend:**
- ✅ AI detection scoring (0-100, higher = more AI-like)
- ✅ Three humanization levels: Light, Balanced, Aggressive
- ✅ Before/after comparison with improvement metrics
- ✅ Fact preservation mode (optional)
- ✅ Rate limiting by tier (Free: 5/mo, Hobby: 25/mo, Pro: Unlimited)
- ✅ Monthly + lifetime stats tracking
- ✅ Average improvement: 44.3 points (56.4% reduction)

**You are building UI COMPONENTS ONLY** - Backend returns all data, you just display it beautifully.

---

## 📋 COMPONENTS TO BUILD (7 Total)

### Component 1: Humanize Button Widget
**Purpose:** Primary action button to trigger humanization

**Location in UI:** Content generation result card, below main actions (Copy, Regenerate, Save)

**Visual:**
```
┌─────────────────────────────────────────────┐
│ Generated Blog Post                         │
│ Lorem ipsum dolor sit amet...               │
│                                             │
│ [Copy] [Regenerate] [Save]                 │
│                                             │
│ 🤖 [Humanize Content]                       │
│    5/25 used this month                     │
└─────────────────────────────────────────────┘
```

**Component Specs:**
- Button: SecondaryButton with robot emoji (🤖) icon
- Text: "Humanize Content" (BodyText)
- Quota display: CaptionText below button (gray-600)
- Format: "X/Y used this month" where Y = 5 (Free), 25 (Hobby), "Unlimited" (Pro)

**States:**
- **Enabled**: Hobby/Pro with quota remaining
- **Disabled**: Free tier (show "Upgrade to Hobby" tooltip)
- **Disabled**: Quota exceeded (show "Limit reached" tooltip)
- **Already Humanized**: Hide button or show "Already humanized" badge

**Behavior:**
- Click → Open Humanization Settings Modal
- Tooltip shows upgrade message for Free users

---

### Component 2: Humanization Settings Modal Widget
**Purpose:** Select humanization level and options before processing

**Location in UI:** Modal dialog overlay

**Visual:**
```
┌──────────────────────────────────────────────┐
│ ✕  Humanize AI Content                       │
├──────────────────────────────────────────────┤
│                                              │
│ Humanization Level                           │
│ ○ Light    - Minimal changes                 │
│ ● Balanced - Moderate rewrite (Recommended)  │
│ ○ Aggressive - Maximum humanization          │
│                                              │
│ Options                                      │
│ ☑ Preserve Facts                             │
│   Maintain factual accuracy while humanizing │
│                                              │
│ [Cancel] [Humanize Now]                      │
└──────────────────────────────────────────────┘
```

**Elements:**
1. **Title Bar**:
   - Title: "Humanize AI Content" (H2)
   - Close button (X) on right

2. **Humanization Level** (Radio buttons):
   - **Light**: "Minimal changes" (CaptionText)
   - **Balanced**: "Moderate rewrite (Recommended)" (CaptionText, default selected)
   - **Aggressive**: "Maximum humanization" (CaptionText)
   - Gap(8) between options

3. **Options Section**:
   - Checkbox: "Preserve Facts"
   - Helper text: "Maintain factual accuracy while humanizing" (CaptionText, gray-600)
   - Default: Checked

4. **Action Buttons**:
   - Cancel: SecondaryButton
   - Humanize Now: PrimaryButton
   - Gap(12) between buttons

**Spacing**: Gap(24) between sections, 24px modal padding

---

### Component 3: Humanization Progress Indicator Widget
**Purpose:** Show progress during AI detection and humanization

**Location in UI:** Modal overlay replacing settings modal

**Visual:**
```
┌────────────────────────────────────┐
│ 🔄 Humanizing Your Content         │
│                                    │
│ Step 1: Detecting AI patterns...✓  │
│ Step 2: Rewriting content...      │
│ ●●●●●●○○○○ 60%                    │
│                                    │
│ This may take 8-15 seconds        │
└────────────────────────────────────┘
```

**Elements:**
- Title: "Humanizing Your Content" (H2) with spinner icon
- Step indicators (3 steps):
  - Step 1: "Detecting AI patterns..." (2-3s)
  - Step 2: "Rewriting content..." (5-10s)
  - Step 3: "Analyzing humanized version..." (2-3s)
- Progress bar: LinearProgressIndicator (60% width)
- Percentage: BodyText next to bar
- Time estimate: "This may take 8-15 seconds" (CaptionText, gray-600)

**States:**
- Step active: Regular text with AdaptiveLoading spinner
- Step complete: Green checkmark (✓)
- Step pending: Gray text

**Spacing**: Gap(16) between elements, 24px padding

---

### Component 4: AI Detection Score Display Widget
**Purpose:** Show before/after AI detection scores with improvement

**Location in UI:** Results panel after humanization completes

**Visual:**
```
┌───────────────────────────────────────────────────┐
│ AI Detection Score                                │
│ Before: ████████░░ 85%  →  After: ███░░░░░░░ 28% │
│ Improvement: ↓ 57 points (67.1% reduction)        │
└───────────────────────────────────────────────────┘
```

**Elements:**
1. **Title**: "AI Detection Score" (H3)

2. **Before Score**:
   - Label: "Before:" (BodyText)
   - Progress bar: LinearProgressIndicator (red gradient, 85% filled)
   - Percentage: "85%" (BodyTextLarge, bold, red-600)

3. **Arrow**: "→" between before and after

4. **After Score**:
   - Label: "After:" (BodyText)
   - Progress bar: LinearProgressIndicator (green gradient, 28% filled)
   - Percentage: "28%" (BodyTextLarge, bold, green-600)

5. **Improvement Metric**:
   - Icon: "↓" (down arrow, green)
   - Text: "57 points (67.1% reduction)" (BodyTextLarge, semibold, green-600)

**Score Color Logic:**
```dart
Color getScoreColor(double score) {
  if (score >= 70) return Color(0xFFDC2626); // Red (high AI)
  if (score >= 40) return Color(0xFFD97706); // Yellow (medium AI)
  return Color(0xFF059669); // Green (low AI)
}
```

**Spacing**: Gap(12) between elements, horizontal layout on desktop, vertical on mobile

---

### Component 5: Before/After Comparison Widget
**Purpose:** Side-by-side view of original vs humanized content

**Location in UI:** Expandable section below AI score display

**Visual (Collapsed):**
```
┌───────────────────────────────────────────────────┐
│ [Show Before/After Comparison] ▼                  │
└───────────────────────────────────────────────────┘
```

**Visual (Expanded - Desktop):**
```
┌──────────────────────┬──────────────────────────┐
│ Original (AI: 85%)   │ Humanized (AI: 28%)      │
├──────────────────────┼──────────────────────────┤
│ Artificial           │ AI's completely changing │
│ intelligence is      │ how businesses operate – │
│ transforming the     │ and honestly, it's pretty│
│ business landscape...│ wild to watch...         │
│                      │                          │
│ [Use Original]       │ [Use Humanized] ✓        │
└──────────────────────┴──────────────────────────┘
```

**Elements:**
1. **Toggle Button**: 
   - Text: "Show Before/After Comparison" (CustomTextButton)
   - Icon: ▼ (down) when collapsed, ▲ (up) when expanded

2. **Left Column - Original**:
   - Header: "Original (AI: 85%)" (H3, red-600)
   - Content: Scrollable text (BodyText)
   - Action: "Use Original" button (SecondaryButton)

3. **Right Column - Humanized**:
   - Header: "Humanized (AI: 28%)" (H3, green-600)
   - Content: Scrollable text (BodyText)
   - Action: "Use Humanized" button (PrimaryButton) with checkmark

**Layout:**
- Desktop (>768px): 50/50 split columns with vertical divider
- Mobile (<768px): Stacked vertically or swipeable tabs

**Spacing**: Gap(24) between columns, 16px padding in each column

---

### Component 6: Humanization Results Panel Widget
**Purpose:** Complete results display combining score, comparison, and actions

**Location in UI:** Replaces original content after humanization

**Visual:**
```
┌───────────────────────────────────────────────────┐
│ ✓ Content Humanized Successfully                  │
│                                                    │
│ AI Detection Score                                │
│ Before: ████████░░ 85%  →  After: ███░░░░░░░ 28% │
│ Improvement: ↓ 57 points (67.1% reduction)        │
│                                                    │
│ [Show Before/After Comparison] ▼                  │
│                                                    │
│ [Copy Humanized] [Try Again] [Keep Original]     │
└───────────────────────────────────────────────────┘
```

**Elements:**
1. **Success Banner**:
   - Icon: Green checkmark (✓)
   - Text: "Content Humanized Successfully" (H2, green-600)

2. **AI Detection Score Display** (Component 4)

3. **Before/After Comparison** (Component 5, collapsible)

4. **Action Buttons**:
   - "Copy Humanized": PrimaryButton (copies humanized text to clipboard)
   - "Try Again": SecondaryButton (reopens settings modal with different level)
   - "Keep Original": CustomTextButton (reverts to original content)

**Spacing**: Gap(24) between sections, 24px padding

---

### Component 7: Quota Warning & Exceeded Modals

#### A. Quota Warning Banner Widget
**Purpose:** Warn when approaching monthly limit

**Location in UI:** Above Humanize button

**Visual:**
```
┌─────────────────────────────────────────────┐
│ ⚠️ 23/25 humanizations used this month      │
│ [Upgrade to Pro for unlimited] →           │
└─────────────────────────────────────────────┘
```

**Elements:**
- Warning icon: ⚠️ (yellow)
- Text: "X/Y humanizations used this month" (BodyTextSmall)
- Link: "Upgrade to Pro for unlimited →" (CustomTextButton, primary color)

**Trigger**: Show when usage ≥ 80% of limit (20/25 for Hobby, 4/5 for Free)

**Styling**: Yellow-50 background, yellow-600 border, 12px padding

#### B. Quota Exceeded Modal Widget
**Purpose:** Block humanization when limit reached

**Location in UI:** Modal dialog (instead of settings modal)

**Visual:**
```
┌──────────────────────────────────────────────┐
│ ⚠️  Monthly Limit Reached                    │
├──────────────────────────────────────────────┤
│                                              │
│ You've used all 25 humanizations this month. │
│                                              │
│ Upgrade to Pro for:                          │
│ ✓ Unlimited humanizations                    │
│ ✓ Priority support                           │
│ ✓ Advanced features                          │
│                                              │
│ [View Pricing] [Cancel]                      │
└──────────────────────────────────────────────┘
```

**Elements:**
- Title: "Monthly Limit Reached" (H2) with warning icon
- Body text: "You've used all X humanizations this month" (BodyText)
- Benefits list (3 items with checkmarks)
- Buttons: "View Pricing" (PrimaryButton), "Cancel" (SecondaryButton)

**Spacing**: Gap(16) between elements, 24px padding

---

## 🎯 MANDATORY REQUIREMENTS:

### Custom Widgets (NEVER use standard Flutter widgets):
- ✅ **Text**: H1, H2, H3, DisplayText, BodyText, BodyTextLarge, BodyTextSmall, CaptionText (NEVER Text())
- ✅ **Buttons**: PrimaryButton, SecondaryButton, CustomTextButton (NEVER ElevatedButton/OutlinedButton())
- ✅ **Spacing**: Gap(8), Gap(12), Gap(16), Gap(24) (NEVER SizedBox())
- ✅ **Loading**: AdaptiveLoading, SmallLoader
- ✅ **Input**: Radio buttons (Material), Checkbox (Material)

### Theme Constants (NEVER hardcode):
- ✅ **Colors**: 
  - Success: AppTheme.success or Color(0xFF059669) [Green-600]
  - Warning: AppTheme.warning or Color(0xFFD97706) [Yellow-600]
  - Error: AppTheme.error or Color(0xFFDC2626) [Red-600]
  - Primary: AppTheme.primary [Blue-600]
  - Text: AppTheme.textPrimary, AppTheme.textSecondary
  - Background: AppTheme.bgPrimary, AppTheme.bgSecondary
  - Border: AppTheme.border
  
- ✅ **Spacing**: AppTheme.spacing8/12/16/24/32
- ✅ **Border Radius**: AppTheme.borderRadiusSM/MD/LG
- ✅ **Fonts**: FontSizes.h2/h3/bodyRegular/bodyLarge/bodySmall/captionRegular

### Architecture:
- ✅ **800-line limit per file** - Split large widgets
- ✅ **Folder structure**:
  ```
  features/humanization/
  ├── models/
  │   ├── humanization_result.dart (~120 lines)
  │   └── ai_detection_analysis.dart (~80 lines)
  ├── controllers/
  │   └── humanization_controller.dart (~250 lines)
  ├── widgets/
  │   ├── humanize_button.dart (~100 lines)
  │   ├── humanization_settings_modal.dart (~200 lines)
  │   ├── humanization_progress_indicator.dart (~150 lines)
  │   ├── ai_detection_score_display.dart (~150 lines)
  │   ├── before_after_comparison.dart (~200 lines)
  │   ├── humanization_results_panel.dart (~250 lines)
  │   ├── quota_warning_banner.dart (~80 lines)
  │   └── quota_exceeded_modal.dart (~120 lines)
  └── services/
      └── humanization_service.dart (~150 lines)
  ```

### Data Models:
- ✅ Create `HumanizationResult` model:
  ```dart
  class HumanizationResult {
    final bool applied;
    final String level; // 'light', 'balanced', 'aggressive'
    final double beforeScore; // 0-100
    final double afterScore; // 0-100
    final double improvement;
    final double improvementPercentage;
    final AIDetectionAnalysis beforeAnalysis;
    final AIDetectionAnalysis afterAnalysis;
    final String humanizedContent;
    final String originalContent;
    
    // Computed properties
    String get improvementText => '${improvement.toInt()} points';
    String get improvementPercentageText => '${improvementPercentage.toStringAsFixed(1)}% reduction';
    Color get beforeScoreColor => _getScoreColor(beforeScore);
    Color get afterScoreColor => _getScoreColor(afterScore);
    
    Color _getScoreColor(double score) {
      if (score >= 70) return Color(0xFFDC2626); // Red
      if (score >= 40) return Color(0xFFD97706); // Yellow
      return Color(0xFF059669); // Green
    }
    
    factory HumanizationResult.fromJson(Map<String, dynamic> json) {
      return HumanizationResult(
        applied: json['applied'] ?? false,
        level: json['level'] ?? 'balanced',
        beforeScore: (json['before_score'] ?? 0).toDouble(),
        afterScore: (json['after_score'] ?? 0).toDouble(),
        improvement: (json['improvement'] ?? 0).toDouble(),
        improvementPercentage: (json['improvement_percentage'] ?? 0).toDouble(),
        beforeAnalysis: AIDetectionAnalysis.fromJson(json['before_analysis'] ?? {}),
        afterAnalysis: AIDetectionAnalysis.fromJson(json['after_analysis'] ?? {}),
        humanizedContent: json['humanized_content'] ?? '',
        originalContent: json['original_content'] ?? '',
      );
    }
  }
  
  class AIDetectionAnalysis {
    final double aiScore;
    final double confidence;
    final List<String> indicators;
    final String reasoning;
    
    factory AIDetectionAnalysis.fromJson(Map<String, dynamic> json) {
      return AIDetectionAnalysis(
        aiScore: (json['ai_score'] ?? 0).toDouble(),
        confidence: (json['confidence'] ?? 0).toDouble(),
        indicators: List<String>.from(json['indicators'] ?? []),
        reasoning: json['reasoning'] ?? '',
      );
    }
  }
  ```

### State Management with GetX:
- ✅ Create `HumanizationController` extending GetxController:
  ```dart
  class HumanizationController extends GetxController {
    // Observable state
    final selectedLevel = 'balanced'.obs; // 'light', 'balanced', 'aggressive'
    final preserveFacts = true.obs;
    final isHumanizing = false.obs;
    final currentStep = 0.obs; // 0-2 for progress indicator
    final humanizationResult = Rxn<HumanizationResult>();
    final showComparison = false.obs;
    final errorMessage = ''.obs;
    
    // Quota management
    final humanizationsUsed = 0.obs;
    final humanizationsLimit = 0.obs; // 5 Free, 25 Hobby, -1 Unlimited
    
    // Computed properties
    bool get hasQuota => humanizationsLimit.value == -1 || 
                         humanizationsUsed.value < humanizationsLimit.value;
    bool get isNearLimit => humanizationsLimit.value > 0 && 
                            (humanizationsUsed.value / humanizationsLimit.value) >= 0.8;
    String get quotaText {
      if (humanizationsLimit.value == -1) return 'Unlimited';
      return '${humanizationsUsed.value}/${humanizationsLimit.value} used this month';
    }
    
    // Methods
    Future<void> loadQuota() async { /* Fetch from Firebase */ }
    Future<void> humanizeContent(String generationId) async { /* Call API */ }
    void updateLevel(String level) => selectedLevel.value = level;
    void togglePreserveFacts() => preserveFacts.value = !preserveFacts.value;
    void toggleComparison() => showComparison.value = !showComparison.value;
    void resetState() { /* Clear results */ }
  }
  ```

### API Integration:
- ✅ **Humanization Endpoint**: `POST /api/v1/humanize/{generation_id}`
  - Request:
    ```json
    {
      "level": "balanced",
      "preserve_facts": true
    }
    ```
  
  - Response:
    ```json
    {
      "humanization": {
        "applied": true,
        "level": "balanced",
        "before_score": 85.0,
        "after_score": 28.0,
        "improvement": 57.0,
        "improvement_percentage": 67.1,
        "before_analysis": {
          "ai_score": 85.0,
          "confidence": 0.92,
          "indicators": ["repetitive phrasing", "overly formal"],
          "reasoning": "..."
        },
        "after_analysis": {
          "ai_score": 28.0,
          "confidence": 0.88,
          "indicators": ["natural flow", "conversational tone"],
          "reasoning": "..."
        }
      },
      "output": {
        "humanizedContent": "..."
      }
    }
    ```

- ✅ **Error Handling**: 
  - 402 Payment Required → Quota exceeded
  - 404 Not Found → Generation not found
  - 500 Server Error → Humanization failed

---

## 🎨 DESIGN SPECIFICATIONS:

### Colors (Score-based):
- **High AI (70-100%)**: 
  - Color: Red-600 (#DC2626)
  - Background: Red-50 (#FEF2F2)
  - Gradient: Red-600 to Red-400
  
- **Medium AI (40-69%)**:
  - Color: Yellow-600 (#D97706)
  - Background: Yellow-50 (#FFFBEB)
  - Gradient: Yellow-600 to Yellow-400
  
- **Low AI (0-39%)**:
  - Color: Green-600 (#059669)
  - Background: Green-50 (#F0FDF4)
  - Gradient: Green-600 to Green-400

### Typography:
- Modal title: H2 (20px, semibold)
- Section labels: BodyTextLarge (16px, medium)
- Score values: BodyTextLarge (16px, bold)
- Improvement: BodyTextLarge (16px, semibold, green-600)
- Helper text: CaptionText (12px, regular, gray-600)
- Quota text: CaptionText (11px, regular, gray-600)

### Spacing:
- Modal: 500px width (desktop), 100% (mobile), 24px padding
- Progress bar: 300px × 8px, 4px radius
- Score comparison: Gap(12) between elements
- Side-by-side: Gap(24) between columns
- Button group: Gap(12) between buttons

### Animations:
```dart
// Modal fade in
AnimatedOpacity(
  opacity: _isVisible ? 1.0 : 0.0,
  duration: Duration(milliseconds: 200),
)

// Progress bar fill
AnimatedContainer(
  duration: Duration(milliseconds: 500),
  width: progress * 300,
)

// Score count-up animation
TweenAnimationBuilder<double>(
  duration: Duration(seconds: 1),
  tween: Tween(begin: 0, end: score),
  builder: (context, value, child) => Text('${value.toInt()}%'),
)

// Comparison slide
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  height: _showComparison ? null : 0,
  curve: Curves.easeInOut,
)
```

### Responsive Design:
- **Desktop (>1024px)**: 
  - Modal: 500px centered
  - Comparison: Side-by-side 50/50
  - Progress bar: 300px
  
- **Tablet (768px - 1024px)**:
  - Modal: 80% width
  - Comparison: Side-by-side or tabs
  - Progress bar: 250px
  
- **Mobile (<768px)**:
  - Modal: Full width, 16px margins
  - Comparison: Stacked or swipeable
  - Progress bar: 100% width
  - Buttons: Full width, stacked

---

## 📊 IMPLEMENTATION STEPS:

1. **Read Context Files** (10 min):
   - Read FRONTEND_INSTRUCTIONS.md completely
   - Read app_theme.dart and font_sizes.dart
   - Read AI_HUMANIZATION_UX_SPECS.md (section C, D, E)
   - Read 03_AI_HUMANIZATION.md (how it works)

2. **Create Folder Structure** (2 min):
   - Create features/humanization/models/, controllers/, widgets/, services/ folders

3. **Create Data Models** (20 min):
   - humanization_result.dart
   - ai_detection_analysis.dart
   - Add fromJson methods
   - Add computed properties (improvementText, scoreColors)

4. **Create Controller** (25 min):
   - humanization_controller.dart with GetX
   - Observable state (level, preserveFacts, isHumanizing, etc.)
   - Quota management
   - API call methods

5. **Create Service** (15 min):
   - humanization_service.dart
   - API call to /api/v1/humanize/{id}
   - Error handling
   - Use ApiService from utilities

6. **Create Widgets** (120 min):
   - **humanize_button.dart** (15 min):
     - Button with robot emoji
     - Quota display below
     - Disabled states
     
   - **humanization_settings_modal.dart** (25 min):
     - Radio buttons for levels
     - Preserve facts checkbox
     - Action buttons
     
   - **humanization_progress_indicator.dart** (20 min):
     - 3-step progress display
     - Progress bar with percentage
     - Step status icons
     
   - **ai_detection_score_display.dart** (20 min):
     - Before/after progress bars
     - Score percentages with colors
     - Improvement metric
     
   - **before_after_comparison.dart** (25 min):
     - Expandable toggle
     - Side-by-side columns (desktop)
     - Stacked or tabs (mobile)
     - Action buttons
     
   - **humanization_results_panel.dart** (30 min):
     - Success banner
     - Score display
     - Comparison section
     - Action buttons (Copy, Try Again, Keep Original)
     
   - **quota_warning_banner.dart** (10 min):
     - Warning icon and message
     - Upgrade link
     
   - **quota_exceeded_modal.dart** (15 min):
     - Warning message
     - Benefits list
     - View Pricing button

7. **Create Progress File** (5 min):
   - Create HUMANIZATION_FEATURE_PROGRESS.md
   - Track completion of each widget
   - Note line counts

8. **Test Widgets in Isolation** (25 min):
   - Create test page with all widgets
   - Test with mock data (different score ranges)
   - Test all 3 levels
   - Test quota states (normal, warning, exceeded)
   - Test responsive layouts
   - Test animations

---

## ✅ SUCCESS CRITERIA:

AI Humanization UI is complete when:
- [ ] All 7 widgets implemented
- [ ] All files under 800 lines
- [ ] Only custom widgets used (no Text(), SizedBox())
- [ ] Only AppTheme constants used (no hardcoded colors/spacing)
- [ ] Data models with fromJson and computed properties
- [ ] HumanizationController with GetX reactive state
- [ ] Service layer with API integration
- [ ] All 3 levels selectable (Light, Balanced, Aggressive)
- [ ] Preserve facts checkbox works
- [ ] Progress indicator shows 3 steps
- [ ] Before/after scores display with colors (red/yellow/green)
- [ ] Improvement metric shows points + percentage
- [ ] Comparison expands/collapses smoothly
- [ ] Side-by-side on desktop, stacked on mobile
- [ ] Quota warning shows at 80% usage
- [ ] Quota exceeded modal blocks humanization
- [ ] All animations work smoothly
- [ ] Responsive on all 3 breakpoints
- [ ] No console errors or warnings
- [ ] HUMANIZATION_FEATURE_PROGRESS.md shows 100% completion
- [ ] Code follows FRONTEND_INSTRUCTIONS.md patterns

---

## 🔗 INTEGRATION NOTES:

**These widgets will be used by:**

1. **Content Generation Results Screen** (to be built later):
   - Display `HumanizeButton` below main actions
   - Show `HumanizationResultsPanel` after humanization
   - Display `QuotaWarningBanner` when approaching limit

2. **Dashboard** (optional):
   - Show humanization usage stats
   - Display average improvement metrics

**Example Usage:**
```dart
// In Content Generation Results
Obx(() {
  final controller = Get.find<HumanizationController>();
  
  return Column(
    children: [
      // Original content display
      ContentCard(content: generationResult.content),
      
      Gap(16),
      
      // Quota warning (if near limit)
      if (controller.isNearLimit.value)
        QuotaWarningBanner(
          used: controller.humanizationsUsed.value,
          limit: controller.humanizationsLimit.value,
        ),
      
      // Humanize button
      if (!generationResult.isHumanized)
        HumanizeButton(
          generationId: generationResult.id,
          quota: controller.quotaText,
          hasQuota: controller.hasQuota,
          onPressed: () => _showHumanizationModal(),
        ),
      
      // Results panel (after humanization)
      if (controller.humanizationResult.value != null)
        HumanizationResultsPanel(
          result: controller.humanizationResult.value!,
          onCopy: () => _copyHumanized(),
          onTryAgain: () => _showHumanizationModal(),
          onKeepOriginal: () => _revertToOriginal(),
        ),
    ],
  );
})

// Show settings modal
void _showHumanizationModal() {
  final controller = Get.find<HumanizationController>();
  
  if (!controller.hasQuota) {
    // Show quota exceeded
    showDialog(
      context: context,
      builder: (context) => QuotaExceededModal(
        used: controller.humanizationsUsed.value,
        limit: controller.humanizationsLimit.value,
      ),
    );
  } else {
    // Show settings
    showDialog(
      context: context,
      builder: (context) => HumanizationSettingsModal(
        onHumanize: (level, preserveFacts) async {
          Navigator.pop(context);
          await controller.humanizeContent(generationResult.id);
        },
      ),
    );
  }
}
```

---

## 🧪 TESTING CHECKLIST:

- [ ] Test all 3 levels: Light, Balanced, Aggressive
- [ ] Test preserve facts: enabled and disabled
- [ ] Test progress indicator (3 steps)
- [ ] Test score colors: High AI (red), Medium (yellow), Low (green)
- [ ] Test improvement calculation and display
- [ ] Test before/after comparison expand/collapse
- [ ] Test side-by-side on desktop, stacked on mobile
- [ ] Test quota display: 5/25, 23/25, 25/25, Unlimited
- [ ] Test quota warning banner (shows at 80%)
- [ ] Test quota exceeded modal (blocks at 100%)
- [ ] Test animations (modal fade, progress bar, score count-up)
- [ ] Test responsive layouts (desktop/tablet/mobile)
- [ ] Test copy button (copies humanized text)
- [ ] Test try again button (reopens modal)
- [ ] Test keep original button (reverts)
- [ ] Test with different score ranges (0-39, 40-69, 70-100)
- [ ] Test error states (API failure, timeout)
- [ ] Test accessibility (screen reader, keyboard navigation)

---

## 📝 NOTES:

- **Backend is 100% complete** - You're building UI display only
- Humanization happens **automatically** on button click after level selection
- Average improvement: **44.3 points** (56.4% reduction in AI score)
- Processing time: **8-15 seconds** average
- This is a **MAJOR differentiator** - Only 2 of 6 competitors have this (Summarly + ContentBot)
- **Transparent metrics** build trust - users see exact improvement
- **Fact preservation mode** is unique to Summarly - maintains accuracy
- Free tier: **5/month** → drives upgrades to Hobby (**25/month**) → Pro (**Unlimited**)

---

**START NOW:** Read FRONTEND_INSTRUCTIONS.md, AI_HUMANIZATION_UX_SPECS.md, app_theme.dart, and font_sizes.dart, then begin implementation with folder structure and data models.
