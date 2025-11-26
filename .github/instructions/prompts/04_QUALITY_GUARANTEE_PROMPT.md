# ✅ QUALITY GUARANTEE FEATURE - DEVELOPMENT PROMPT

**Copy this entire prompt into a new chat session with GitHub Copilot**

---

## 🚨 PREREQUISITES: BUILD CONTENT GENERATION PAGE FIRST!

**⚠️ CRITICAL: You MUST build the Content Generation Page BEFORE this feature!**

**Required:**
1. ✅ Complete Prompt `00_CONTENT_GENERATION_PAGE_PROMPT.md` first
2. ✅ Ensure `ContentResultsPage` exists at `lib/features/content_generation/views/content_results_page.dart`
3. ✅ Ensure placeholder sections exist for feature widgets

**Why?** Quality widgets display quality scores in the Content Results page. You need that page built first.

---

## TASK: Build Quality Score Display Components

I'm building the **Quality Guarantee UI** for Summarly AI Content Generator (Flutter web app). This displays quality scores AFTER content generation to show users the quality level of AI-generated content.

### 📚 CONTEXT FILES TO READ FIRST:

**CRITICAL - Read these files before starting:**
1. `.github/instructions/FRONTEND_INSTRUCTIONS.md` - Complete development guide with custom widgets, theme, architecture patterns
2. `lib/core/theme/app_theme.dart` (281 lines) - All colors, spacing, border radius constants
3. `lib/core/constants/font_sizes.dart` (211 lines) - Typography system
4. `docs/features/02_quality_guarantee/QUALITY_GUARANTEE_UX_SPECS.md` (649 lines) - Complete UX specifications
5. `docs/features/02_quality_guarantee/02_QUALITY_GUARANTEE.md` (1146 lines) - Feature overview and backend implementation
6. `.github/instructions/prompts/00_CONTENT_GENERATION_PAGE_PROMPT.md` - Content Generation Page specs (MUST be built first)

---

## 🎯 IMPORTANT: Backend is FULLY IMPLEMENTED

**Quality scoring is ALREADY WORKING on backend:**
- ✅ Quality scorer calculates scores (readability, completeness, SEO, grammar)
- ✅ Auto-regeneration happens automatically if score < 60%
- ✅ API returns quality scores in response
- ✅ All content types support quality scoring

**You are building DISPLAY WIDGETS ONLY** - The backend already does all the work. You just need to show the results beautifully.

---

## 📋 COMPONENTS TO BUILD (5 Total)

### Component 1: Quality Score Badge Widget
**Purpose:** Prominent display of overall quality grade

**Location in UI:** Top-right corner of generated content card

**Visual Design:**
```
┌────────────────────────────────────────────┐
│ Generated Content                          │
│                                  ┌────────┐│
│ Lorem ipsum dolor sit amet...    │   A    ││
│ consectetur adipiscing elit...   │ Quality││
│                                  └────────┘│
│ [Copy] [Regenerate] [Save]                 │
└────────────────────────────────────────────┘
```

**Badge Specifications:**
- **Size**: 60×60px circular badge
- **Grade Font**: 24px, bold
- **Label Font**: 10px, medium ("Quality")
- **Border**: 2px solid, grade color
- **Background**: Grade color at 10% opacity

**Grade Colors & Ranges:**
- **A+** (95-100%): Green-700 (#047857) - "Excellent"
- **A** (85-94%): Green-600 (#059669) - "Great"  
- **B** (70-84%): Blue-600 (#2563EB) - "Good"
- **C** (60-69%): Yellow-600 (#D97706) - "Fair"
- **D** (<60%): Red-600 (#DC2626) - "Needs Improvement"

**Behavior:**
- Fade in animation (0.3s) when content loads
- Clickable → Expands quality details panel
- Tooltip on hover: "Quality Score: A (82%)"

---

### Component 2: Quality Details Panel Widget
**Purpose:** Expandable breakdown of quality metrics

**Location in UI:** Below generated content, accordion/expansion panel

**Collapsed State:**
```
┌────────────────────────────────────────────┐
│ ✓ Quality Score: A (82%) ▼ View Details   │
└────────────────────────────────────────────┘
```

**Expanded State:**
```
┌────────────────────────────────────────────────────┐
│ Quality Score Breakdown                    Overall: │
│                                            A (82%)  │
├────────────────────────────────────────────────────┤
│ Readability                        ████████░░ 85%  │
│ Easy to read (8th grade level)                     │
│                                                     │
│ Completeness                       █████████░ 90%  │
│ Well-structured with proper length                 │
│                                                     │
│ SEO Optimization                   ████████░░ 78%  │
│ Good keyword usage, needs more headings            │
│                                                     │
│ Grammar & Style                    ██████████ 95%  │
│ Excellent - no errors detected                     │
├────────────────────────────────────────────────────┤
│ Details:                                           │
│ • Word count: 523 (target: 500)                    │
│ • Flesch-Kincaid score: 72.4                       │
│ • Keyword density: 3.2%                            │
│ • Regenerations: 1                                 │
└────────────────────────────────────────────────────┘
```

**Elements:**
1. **Metric Rows** (4 total):
   - Label: BodyTextLarge (16px, medium)
   - Progress bar: LinearProgressIndicator (200px × 8px)
   - Percentage: BodyTextLarge (16px, bold, colored)
   - Helper text: BodyTextSmall (13px, gray-600)

2. **Details Section**:
   - Bulleted list
   - CaptionText (12px, gray-600)
   - Shows: word count, Flesch-Kincaid, keyword density, regeneration count

**Spacing**: Gap(16) between metrics, Gap(24) before details section

---

### Component 3: Quality Metric Row Widget
**Purpose:** Reusable widget for each quality dimension

**Visual:**
```
Readability                        ████████░░ 85%
Easy to read (8th grade level)
```

**Props:**
- `label`: String (e.g., "Readability")
- `score`: double (0.0 - 1.0)
- `helperText`: String (e.g., "Easy to read")
- `color`: Color (based on score)

**Layout:**
- Row with label on left, score on right
- Progress bar below (full width)
- Helper text below bar

**Color Logic:**
```dart
Color getMetricColor(double score) {
  if (score >= 0.85) return Color(0xFF059669); // Green-600
  if (score >= 0.70) return Color(0xFF2563EB); // Blue-600
  if (score >= 0.60) return Color(0xFFD97706); // Yellow-600
  return Color(0xFFDC2626); // Red-600
}
```

---

### Component 4: Auto-Regeneration Indicator Widget
**Purpose:** Show progress during content generation with quality check

**Location in UI:** Modal/overlay during generation process

**Visual States:**

**State 1: Initial Generation**
```
┌────────────────────────────────────┐
│  🔄 Generating Your Content        │
│                                    │
│  ●●●●●●○○○○ 60%                   │
│                                    │
│  Analyzing quality...              │
└────────────────────────────────────┘
```

**State 2: Low Quality Detected (Regenerating)**
```
┌────────────────────────────────────┐
│  🔄 Generating Your Content        │
│                                    │
│  ●●●●●●●●○○ 80%                   │
│                                    │
│  ⚠️ Quality below target (Score: D)│
│  Regenerating with premium model...│
│                                    │
│  Attempt 2 of 2                    │
└────────────────────────────────────┘
```

**State 3: Complete**
```
┌────────────────────────────────────┐
│  ✓ Content Generated               │
│                                    │
│  Quality Score: A (82%)            │
│                                    │
│  [View Content]                    │
└────────────────────────────────────┘
```

**Elements:**
- AdaptiveLoading spinner
- Progress bar (LinearProgressIndicator)
- Status text: H3 or BodyTextLarge
- Warning icon (⚠️) for regeneration
- Attempt counter (CaptionText)

**Behavior:**
- Shows during API call
- Updates in real-time if backend supports progress events
- Auto-dismisses when complete
- Smooth transitions between states

---

### Component 5: Quality History Card Widget
**Purpose:** Display quality scores in generation history list

**Location in UI:** History/Saved Generations page

**Visual:**
```
┌───────────────────────────────────────────────┐
│ Blog Post: "10 Tips for..."          [A] 85% │
│ Nov 26, 2025 • 523 words • 1 regeneration     │
│ [View] [Edit] [Delete]                        │
└───────────────────────────────────────────────┘
```

**Elements:**
- Title: H3 (content title, truncated to 1 line)
- Quality badge: Mini version (40×40px) on right
- Metadata row: CaptionText (date, word count, regenerations)
- Action buttons: CustomTextButton for View/Edit/Delete

**Sorting Options:**
- By date (newest first) - default
- By quality score (highest first)
- By regeneration count (most/least)

---

## 🎯 MANDATORY REQUIREMENTS:

### Custom Widgets (NEVER use standard Flutter widgets):
- ✅ **Text**: H1, H2, H3, DisplayText, BodyText, BodyTextLarge, BodyTextSmall, CaptionText (NEVER Text())
- ✅ **Buttons**: PrimaryButton, SecondaryButton, CustomTextButton (NEVER ElevatedButton/OutlinedButton())
- ✅ **Spacing**: Gap(12), Gap(16), Gap(24) (NEVER SizedBox())
- ✅ **Loading**: AdaptiveLoading, SmallLoader

### Theme Constants (NEVER hardcode):
- ✅ **Colors**: 
  - Success: AppTheme.success or Color(0xFF059669) [Green-600]
  - Info: AppTheme.primary or Color(0xFF2563EB) [Blue-600]
  - Warning: AppTheme.warning or Color(0xFFD97706) [Yellow-600]
  - Error: AppTheme.error or Color(0xFFDC2626) [Red-600]
  - Text: AppTheme.textPrimary, AppTheme.textSecondary
  - Background: AppTheme.bgPrimary, AppTheme.bgSecondary
  - Border: AppTheme.border
  
- ✅ **Spacing**: AppTheme.spacing8/12/16/24/32
- ✅ **Border Radius**: AppTheme.borderRadiusSM/MD/LG/XL
- ✅ **Fonts**: FontSizes.h2/h3/bodyRegular/bodyLarge/bodySmall/captionRegular

### Architecture:
- ✅ **800-line limit per file** - Split large widgets
- ✅ **Folder structure**:
  ```
  features/quality_guarantee/
  ├── models/
  │   └── quality_score.dart (~100 lines) - Data model
  ├── widgets/
  │   ├── quality_score_badge.dart (~120 lines)
  │   ├── quality_details_panel.dart (~200 lines)
  │   ├── quality_metric_row.dart (~100 lines)
  │   ├── auto_regeneration_indicator.dart (~150 lines)
  │   └── quality_history_card.dart (~120 lines)
  └── utils/
      └── quality_helpers.dart (~80 lines) - Helper functions
  ```

### Data Model:
- ✅ Create `QualityScore` model:
  ```dart
  class QualityScore {
    final double overall; // 0.0 - 1.0
    final double readability;
    final double completeness;
    final double seo;
    final double grammar;
    final QualityDetails? details;
    
    QualityScore({
      required this.overall,
      required this.readability,
      required this.completeness,
      required this.seo,
      required this.grammar,
      this.details,
    });
    
    // Computed properties
    String get grade {
      if (overall >= 0.95) return 'A+';
      if (overall >= 0.85) return 'A';
      if (overall >= 0.70) return 'B';
      if (overall >= 0.60) return 'C';
      return 'D';
    }
    
    int get percentage => (overall * 100).toInt();
    
    Color get gradeColor {
      if (overall >= 0.85) return Color(0xFF059669); // Green
      if (overall >= 0.70) return Color(0xFF2563EB); // Blue
      if (overall >= 0.60) return Color(0xFFD97706); // Yellow
      return Color(0xFFDC2626); // Red
    }
    
    String get gradeLabel {
      if (overall >= 0.95) return 'Excellent';
      if (overall >= 0.85) return 'Great';
      if (overall >= 0.70) return 'Good';
      if (overall >= 0.60) return 'Fair';
      return 'Needs Improvement';
    }
    
    factory QualityScore.fromJson(Map<String, dynamic> json) {
      return QualityScore(
        overall: (json['overall'] ?? 0.0).toDouble(),
        readability: (json['readability'] ?? 0.0).toDouble(),
        completeness: (json['completeness'] ?? 0.0).toDouble(),
        seo: (json['seo'] ?? 0.0).toDouble(),
        grammar: (json['grammar'] ?? 0.0).toDouble(),
        details: json['details'] != null
            ? QualityDetails.fromJson(json['details'])
            : null,
      );
    }
  }
  
  class QualityDetails {
    final int wordCount;
    final double? fleschKincaidScore;
    final double? keywordDensity;
    final int? headingCount;
    
    QualityDetails({
      required this.wordCount,
      this.fleschKincaidScore,
      this.keywordDensity,
      this.headingCount,
    });
    
    factory QualityDetails.fromJson(Map<String, dynamic> json) {
      return QualityDetails(
        wordCount: json['word_count'] ?? 0,
        fleschKincaidScore: json['flesch_kincaid_score']?.toDouble(),
        keywordDensity: json['keyword_density']?.toDouble(),
        headingCount: json['heading_count'],
      );
    }
  }
  ```

### API Integration:
- ✅ **Backend Response** (already returns this):
  ```json
  {
    "content": "Generated content...",
    "quality_score": {
      "overall": 0.82,
      "grade": "A",
      "readability": 0.85,
      "completeness": 0.90,
      "seo": 0.78,
      "grammar": 0.95,
      "details": {
        "word_count": 523,
        "flesch_kincaid_score": 72.4,
        "keyword_density": 3.2,
        "heading_count": 5
      }
    },
    "regeneration_count": 1,
    "model_used": "gemini-2.5-flash"
  }
  ```

- ✅ **Parse and display** - Backend does all the work, you just show the data

---

## 🎨 DESIGN SPECIFICATIONS:

### Colors (Grade-based):
- **A+/A (85-100%)**: 
  - Color: Green-600 (#059669)
  - Background: Green-50 (#F0FDF4)
  
- **B (70-84%)**:
  - Color: Blue-600 (#2563EB)
  - Background: Blue-50 (#EFF6FF)
  
- **C (60-69%)**:
  - Color: Yellow-600 (#D97706)
  - Background: Yellow-50 (#FFFBEB)
  
- **D (<60%)**:
  - Color: Red-600 (#DC2626)
  - Background: Red-50 (#FEF2F2)

### Typography:
- Badge grade: 24px, bold
- Badge label: 10px, medium
- Panel title: H2 (20px, semibold)
- Metric labels: BodyTextLarge (16px, medium)
- Metric percentages: BodyTextLarge (16px, bold)
- Helper text: BodyTextSmall (13px, regular)
- Details: CaptionText (12px, regular)

### Spacing:
- Badge: 60×60px, 2px border, 8px inner padding
- Panel: 16px padding all sides
- Gap between metrics: Gap(16)
- Gap before details: Gap(24)
- Progress bar: 8px height, 4px border radius

### Animations:
```dart
// Badge appearance
AnimatedOpacity(
  opacity: _isVisible ? 1.0 : 0.0,
  duration: Duration(milliseconds: 300),
  child: ScaleTransition(...),
)

// Progress bar fill
AnimatedContainer(
  duration: Duration(milliseconds: 500),
  curve: Curves.easeOut,
  width: score * 200, // Animate from 0 to score
)

// Panel expansion
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeInOut,
  height: _isExpanded ? null : 0,
)
```

### Responsive Design:
- **Desktop (>1024px)**: 
  - Badge: 60×60px, top-right of content
  - Panel: Max-width 800px, full details visible
  - Progress bars: 200px width
  
- **Tablet (768px - 1024px)**:
  - Badge: 50×50px, top-right
  - Panel: Full width, scrollable if needed
  - Progress bars: 150px width
  
- **Mobile (<768px)**:
  - Badge: 40×40px, centered above content
  - Panel: Collapsed by default
  - Progress bars: 100% width
  - Metrics stack vertically

---

## 📊 IMPLEMENTATION STEPS:

1. **Read Context Files** (10 min):
   - Read FRONTEND_INSTRUCTIONS.md completely
   - Read app_theme.dart and font_sizes.dart
   - Read QUALITY_GUARANTEE_UX_SPECS.md (section C, D, E)
   - Read 02_QUALITY_GUARANTEE.md (how scoring works)

2. **Create Folder Structure** (2 min):
   - Create features/quality_guarantee/models/, widgets/, utils/ folders

3. **Create Data Model** (15 min):
   - quality_score.dart
   - QualityScore and QualityDetails classes
   - Add fromJson methods
   - Add computed properties (grade, percentage, gradeColor, gradeLabel)

4. **Create Helper Functions** (10 min):
   - quality_helpers.dart
   - Grade calculation logic
   - Color mapping function
   - Helper text generation

5. **Create Widgets** (90 min):
   - **quality_metric_row.dart** (15 min):
     - Label, progress bar, percentage, helper text
     - Color based on score
     - Animated progress bar
     
   - **quality_score_badge.dart** (20 min):
     - Circular badge with grade
     - Border and background colors
     - Fade in + scale animation
     - Clickable with tooltip
     
   - **quality_details_panel.dart** (30 min):
     - ExpansionPanel or custom accordion
     - Summary (collapsed)
     - 4 metric rows (expanded)
     - Details section with bullets
     - Smooth expand/collapse animation
     
   - **auto_regeneration_indicator.dart** (25 min):
     - Modal/Dialog overlay
     - 3 states (generating, regenerating, complete)
     - Progress bar
     - Status messages
     - Warning icon for regeneration
     
   - **quality_history_card.dart** (20 min):
     - List tile with title, badge, metadata
     - Action buttons
     - Truncated text
     - Mini badge (40×40px)

6. **Create Progress File** (5 min):
   - Create QUALITY_GUARANTEE_PROGRESS.md
   - Track completion of each widget
   - Note line counts

7. **Test Widgets in Isolation** (20 min):
   - Create test page with all widgets
   - Test with mock data (A+, A, B, C, D grades)
   - Verify animations work
   - Test responsive layouts
   - Test all states (loading, regenerating, complete)

---

## ✅ SUCCESS CRITERIA:

Quality Guarantee UI is complete when:
- [ ] All 5 widgets implemented
- [ ] All files under 800 lines
- [ ] Only custom widgets used (no Text(), SizedBox())
- [ ] Only AppTheme constants used (no hardcoded colors/spacing)
- [ ] Data model with fromJson and computed properties
- [ ] All 5 grade types work (A+, A, B, C, D)
- [ ] Badge colors match grade (green/blue/yellow/red)
- [ ] Progress bars animate from 0 to score
- [ ] Badge fade in animation works
- [ ] Panel expand/collapse animation smooth
- [ ] Auto-regeneration indicator shows 3 states
- [ ] History card displays mini badge
- [ ] Responsive on all 3 breakpoints
- [ ] Tooltip shows on badge hover
- [ ] Helper text shows appropriate guidance
- [ ] No console errors or warnings
- [ ] QUALITY_GUARANTEE_PROGRESS.md shows 100% completion
- [ ] Code follows FRONTEND_INSTRUCTIONS.md patterns

---

## 🔗 INTEGRATION NOTES:

**These widgets will be used by:**

1. **Content Generation Results Screen** (to be built later):
   - Display `QualityScoreBadge` in top-right corner
   - Display `QualityDetailsPanel` below content
   - Show `AutoRegenerationIndicator` during generation

2. **History/Saved Generations Page** (to be built later):
   - Use `QualityHistoryCard` in list view
   - Enable sorting by quality score

3. **Dashboard** (optional):
   - Show average quality score chart
   - Display recent generations with quality badges

**Example Usage:**
```dart
// In Content Generation Results
QualityScoreBadge(
  qualityScore: generationResult.qualityScore,
  onTap: () => _expandQualityPanel(),
)

QualityDetailsPanel(
  qualityScore: generationResult.qualityScore,
  regenerationCount: generationResult.regenerationCount,
  isExpanded: _isPanelExpanded,
  onToggle: () => setState(() => _isPanelExpanded = !_isPanelExpanded),
)

// During Generation
if (isGenerating)
  AutoRegenerationIndicator(
    currentAttempt: attemptNumber,
    maxAttempts: 2,
    lastScore: previousScore,
    status: generationStatus, // 'generating', 'regenerating', 'complete'
  )

// In History List
ListView.builder(
  itemBuilder: (context, index) {
    final item = historyItems[index];
    return QualityHistoryCard(
      title: item.title,
      qualityScore: item.qualityScore,
      createdAt: item.createdAt,
      wordCount: item.wordCount,
      regenerationCount: item.regenerationCount,
      onView: () => _viewGeneration(item),
      onEdit: () => _editGeneration(item),
      onDelete: () => _deleteGeneration(item),
    );
  },
)
```

---

## 🧪 TESTING CHECKLIST:

- [ ] Test all 5 grades: A+ (95%), A (88%), B (75%), C (65%), D (50%)
- [ ] Test badge colors match grade
- [ ] Test badge animation (fade + scale)
- [ ] Test panel expansion/collapse
- [ ] Test all 4 metric rows display correctly
- [ ] Test progress bars animate from 0 to value
- [ ] Test details section shows all fields
- [ ] Test auto-regeneration indicator 3 states
- [ ] Test history card with mini badge (40×40px)
- [ ] Test responsive layouts (desktop/tablet/mobile)
- [ ] Test with missing data (graceful fallbacks)
- [ ] Test tooltip on badge hover
- [ ] Test helper text changes based on score
- [ ] Test sorting in history (by date, score, regenerations)
- [ ] Test accessibility (screen reader, keyboard navigation)

---

## 📝 NOTES:

- **Backend is 100% complete** - You're building UI display only
- Quality scoring happens **automatically** on every generation
- If score < 60%, backend **auto-regenerates** with premium model
- User sees final result with quality score (no manual intervention needed)
- This is a **MAJOR differentiator** - NO competitor has auto-quality-regeneration
- Transparent quality scores build **trust** with users
- Show regeneration count to demonstrate system is working hard for quality

---

**START NOW:** Read FRONTEND_INSTRUCTIONS.md, QUALITY_GUARANTEE_UX_SPECS.md, app_theme.dart, and font_sizes.dart, then begin implementation with folder structure and data model.
