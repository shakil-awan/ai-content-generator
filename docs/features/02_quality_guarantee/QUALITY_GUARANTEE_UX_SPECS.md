# QUALITY GUARANTEE UX SPECIFICATIONS

**Feature:** Quality Guarantee with Auto-Regeneration  
**Status:** ✅ FULLY IMPLEMENTED  
**Priority:** ACTIVE (Needs UI Enhancement)  
**Last Updated:** November 26, 2025

---

## A. COMPETITIVE RESEARCH

### Jasper AI
**Implementation Status:** ❌ NO QUALITY SCORING
- No visible quality scores or guarantees
- Manual regeneration only via "Regenerate" button
- No automatic quality-based regeneration
- Grid feature shows "systematic high-quality content" but no scoring system

### Copy.ai
**Implementation Status:** ❌ NO QUALITY SCORING
- No quality metrics displayed
- Focuses on workflow automation, not quality measurement
- Manual regeneration required

### Writesonic
**Implementation Status:** ❌ NO QUALITY SCORING
- Content optimizer exists but no automated scoring
- SEO checker available separately
- No quality guarantee or auto-regeneration

### ContentBot
**Implementation Status:** ❌ NO QUALITY SCORING
- No quality scoring found

### Rytr
**Implementation Status:** ❌ NO QUALITY SCORING
- Basic content generation with manual retry

### Key Insights
1. **Market Gap:** ZERO competitors have automated quality scoring + regeneration
2. **UX Opportunity:** Transparent quality metrics build trust
3. **Our Advantage:** Only platform that auto-regenerates low-quality content
4. **Differentiation:** Letter grade system (A+ to D) is user-friendly

---

## B. API INTEGRATION MAPPING

### Internal Quality Scoring System

**Note:** This is NOT an external API - it's an internal scoring algorithm already implemented in the backend.

**Backend Service:** `quality_scorer.py` (QualityScorer class)

**USER INPUTS (Generation Request):**
- ✅ Content type (blog, email, product, ad) → Determines scoring criteria
- ✅ Target word count → Affects completeness score
- ✅ Keywords → Affects SEO score
- ✅ Tone → Affects readability expectations

**BACKEND SCORING ALGORITHM:**
```python
Quality Score = (
  Readability × 0.30 +
  Completeness × 0.30 +
  SEO × 0.20 +
  Grammar × 0.20
)
```

**Scoring Components:**
1. **Readability (30%):** Flesch-Kincaid score
   - 90-100: Very easy (5th grade) → 1.0
   - 60-70: Standard (8th grade) → 0.7
   - <60: Difficult (college+) → 0.4

2. **Completeness (30%):**
   - Word count vs target (40% weight)
   - Structure - headings/sections (30% weight)
   - Required elements present (30% weight)

3. **SEO (20%):**
   - Keyword density (2-4% optimal)
   - Heading usage (H1, H2, H3)
   - Meta description quality

4. **Grammar (20%):**
   - Capitalization errors
   - Punctuation issues
   - Spacing problems

**RESPONSE STRUCTURE:**
```json
{
  "content": "Generated text...",
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
      "keyword_density": 3.2
    }
  },
  "regeneration_count": 1
}
```

**Auto-Regeneration Trigger:**
- If `overall < 0.60` → Regenerate with premium model (Gemini 2.5 Flash)
- Max attempts: 1 regeneration
- User sees final result regardless of score

---

## C. UI COMPONENT SPECIFICATIONS

### 1. Quality Score Badge (Primary Display)

**Location:** Top-right of generated content card

**Layout:**
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

**Grade Variants:**
- **A+** (95-100%): Green-700, "Excellent"
- **A** (85-94%): Green-600, "Great"
- **B** (70-84%): Blue-600, "Good"
- **C** (60-69%): Yellow-600, "Fair"
- **D** (<60%): Red-600, "Needs Improvement"

**Component Specs:**
```
Size: 60×60px circular badge
Font: 24px bold for grade, 10px for "Quality"
Colors: Background = grade color at 10% opacity
Border: 2px solid grade color
```

### 2. Expandable Quality Details Panel

**Location:** Below content, expandable accordion

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

**Field Specifications:**
- **Progress Bars:** 200px width, 8px height, rounded corners
- **Scores:** Display both bar and percentage
- **Helper Text:** 12px gray-600, explains each metric
- **Details Section:** Collapsed by default, expandable

### 3. Auto-Regeneration Indicator (During Generation)

**Location:** Modal/overlay during content generation

**Layout:**
```
┌────────────────────────────────────┐
│  🔄 Generating Your Content        │
│                                    │
│  ●●●●●●○○○○ 60%                   │
│                                    │
│  ⚠️ Quality below target (Score: D)│
│  Regenerating with premium model...│
│                                    │
│  Attempt 2 of 2                    │
└────────────────────────────────────┘
```

**States:**
- **First Attempt:** "Generating..." with progress bar
- **Low Quality Detected:** Show warning icon + score
- **Regenerating:** "Upgrading to premium model..."
- **Complete:** Transition to content display

### 4. Quality History (Generation History Page)

**Location:** History/Saved Generations list

**List Item:**
```
┌───────────────────────────────────────────────┐
│ Blog Post: "10 Tips for..."          [A] 85% │
│ Nov 26, 2025 • 523 words • 1 regeneration     │
│ [View] [Edit] [Delete]                        │
└───────────────────────────────────────────────┘
```

**Sorting Options:**
- By date (newest first)
- By quality score (highest first)
- By regeneration count

---

## D. USER FLOW DIAGRAMS

### Flow 1: Content Generation with Quality Scoring

```
User submits generation request
       ↓
[Loading] "Generating content..."
       ↓
Backend generates content (Attempt #1)
       ↓
Quality scorer evaluates (1-2 seconds)
       ↓
┌────────────────────────┐
│ Quality Score >= 60%?  │
└───────┬────────────────┘
        │
    YES │                    NO
        ↓                    ↓
Display content      [Warning] "Quality below target"
with score badge     "Regenerating with premium model..."
        │                    │
        │                    ↓
        │            Attempt #2 (Premium Model)
        │                    │
        │                    ↓
        │            Quality scorer evaluates again
        │                    │
        └────────────────────┘
                    ↓
Display final content + score badge + details panel
       ↓
User can:
- View quality breakdown
- Accept content
- Manually regenerate
- Edit content
```

### Flow 2: View Quality Details

```
User sees content with "A" badge
       ↓
Click quality badge OR "View Details"
       ↓
Expand quality details panel
       ↓
Shows breakdown:
- Readability: 85%
- Completeness: 90%
- SEO: 78%
- Grammar: 95%
       ↓
User reviews metrics
       ↓
Options:
- [Accept] → Save content
- [Improve SEO] → Regenerate with focus
- [Simplify] → Regenerate for lower grade level
```

### Flow 3: Low Quality Result (Edge Case)

```
Content generated with D grade (55%)
       ↓
Auto-regeneration attempted but still D (58%)
       ↓
Display content with warning banner:
"⚠️ This content scored below our quality target.
We recommend manual editing or regenerating."
       ↓
User options:
- [Regenerate Again] → Manual retry
- [Edit Manually] → Open editor
- [Accept Anyway] → Proceed with warning
```

---

## E. DESIGN RECOMMENDATIONS

### Color Scheme (Grade-Based)

**Quality Grades:**
- **A+/A:** Green-600 (#059669) - Success
- **B:** Blue-600 (#2563EB) - Good
- **C:** Yellow-600 (#D97706) - Warning
- **D:** Red-600 (#DC2626) - Error

**UI Elements:**
- Background: White (#FFFFFF) or Gray-50 (#F9FAFB)
- Text Primary: Gray-900 (#111827)
- Text Secondary: Gray-600 (#6B7280)
- Borders: Gray-300 (#D1D5DB)

### Typography

```
Quality Badge Grade: 24px, Bold, Grade color
Quality Badge Label: 10px, Medium, Gray-700
Panel Title: 16px, Semibold, Gray-900
Metric Labels: 14px, Medium, Gray-700
Metric Values: 14px, Bold, Grade color
Helper Text: 12px, Regular, Gray-600
Details: 13px, Regular, Gray-600
```

### Spacing & Layout

```
Badge: 60×60px, 2px border, 8px inner padding
Panel: 16px padding, 12px spacing between sections
Progress Bars: 200×8px, 4px border radius
Accordion: 40px height collapsed, auto expanded
```

### Accessibility (WCAG AA)

- **Color Contrast:** All text meets 4.5:1 ratio
- **Screen Readers:**
  - Badge: "Quality score: A, 82 percent"
  - Metrics: "Readability: 85 percent. Easy to read."
- **Keyboard Navigation:** Tab through details, Enter to expand
- **Focus States:** 2px blue outline on interactive elements

### Animations

```
Badge Appearance: Fade in + scale (0.3s ease-out)
Panel Expand: Slide down (0.2s ease-in-out)
Progress Bars: Animate from 0 to value (0.5s ease-out)
Regeneration: Pulse animation (1s infinite)
```

### Mobile Responsive

**Breakpoints:**
- Desktop (>768px): Badge top-right, full panel
- Tablet (480-768px): Badge top-center, scrollable panel
- Mobile (<480px): Badge below content, stacked metrics

**Mobile Optimizations:**
- Progress bars: 100% width
- Metrics stack vertically
- Larger tap targets (48×48px minimum)

---

## F. TECHNICAL IMPLEMENTATION NOTES

### Flutter Widgets

**Quality Score Badge:**
```dart
class QualityScoreBadge extends StatelessWidget {
  final double score;
  final String grade;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getGradeColor(grade).withOpacity(0.1),
        border: Border.all(
          color: _getGradeColor(grade),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            grade,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _getGradeColor(grade),
            ),
          ),
          Text(
            'Quality',
            style: TextStyle(fontSize: 10, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
  
  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green[600]!;
    if (grade == 'B') return Colors.blue[600]!;
    if (grade == 'C') return Colors.yellow[700]!;
    return Colors.red[600]!;
  }
}
```

**Quality Details Panel:**
```dart
class QualityDetailsPanel extends StatelessWidget {
  final QualityScore qualityScore;
  
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('Quality Score: ${qualityScore.grade} (${(qualityScore.overall * 100).toInt()}%)'),
      leading: Icon(Icons.check_circle, color: Colors.green),
      children: [
        _buildMetricRow('Readability', qualityScore.readability),
        _buildMetricRow('Completeness', qualityScore.completeness),
        _buildMetricRow('SEO', qualityScore.seo),
        _buildMetricRow('Grammar', qualityScore.grammar),
        Divider(),
        _buildDetailsSection(qualityScore.details),
      ],
    );
  }
  
  Widget _buildMetricRow(String label, double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 14)),
              Text('${(value * 100).toInt()}%', 
                   style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(_getMetricColor(value)),
          ),
        ],
      ),
    );
  }
}
```

**Auto-Regeneration Indicator:**
```dart
class RegenerationIndicator extends StatelessWidget {
  final String status;
  final int attempt;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating Your Content',
                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              if (attempt > 1) ...[
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(height: 8),
                Text('Quality below target',
                     style: TextStyle(color: Colors.orange[700])),
                Text('Regenerating with premium model...',
                     style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
              SizedBox(height: 8),
              Text('Attempt $attempt of 2',
                   style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
```

### State Management

**Using Provider/Riverpod:**
```dart
class QualityScoreProvider extends ChangeNotifier {
  QualityScore? _currentScore;
  bool _isRegenerating = false;
  
  Future<void> generateContent(GenerationRequest request) async {
    _isRegenerating = false;
    notifyListeners();
    
    final response = await apiService.generate(request);
    _currentScore = QualityScore.fromJson(response['quality_score']);
    
    // Backend already handled regeneration if needed
    notifyListeners();
  }
  
  bool get hasHighQuality => _currentScore?.overall ?? 0 >= 0.70;
  String get grade => _currentScore?.grade ?? 'N/A';
}
```

### API Integration

**Backend Response:**
```json
POST /api/v1/generate/blog
{
  "topic": "AI Content Tools",
  "tone": "professional"
}

Response:
{
  "content": "...",
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

### Performance Optimization

**Scoring Caching:**
- Cache Flesch-Kincaid calculations for identical text
- Reuse SEO analysis for similar keywords
- Minimize recalculations on UI interactions

**Lazy Loading:**
- Quality details panel renders only when expanded
- History list loads scores on demand

### Error Handling

**Strategies:**
1. **Scoring Failure:** If quality scorer crashes, return default 0.50 score with "Unable to calculate" message
2. **Regeneration Timeout:** Max 30s per attempt, fallback to first generation
3. **Display Errors:** Show content even if scoring fails, hide quality badge

**Implementation:**
```dart
try {
  final score = await qualityService.calculateScore(content);
  setState(() => _qualityScore = score);
} on TimeoutException {
  _showSnackbar('Quality scoring timed out. Content saved without score.');
} on ApiException catch (e) {
  _showSnackbar('Unable to calculate quality score.');
  _logError('Quality scoring failed', e);
}
```

### Testing Strategy

**Unit Tests:**
- Test grade calculation (score 0.95 → A+, 0.82 → A, etc.)
- Test metric color mapping
- Test regeneration count tracking

**Widget Tests:**
- Test badge rendering with different grades
- Test panel expansion/collapse
- Test metric progress bars animation

**Integration Tests:**
- Test full generation flow with quality scoring
- Test auto-regeneration trigger (<0.60)
- Test quality history display

---

## Summary

This UX specification provides implementation guidance for the **already-functioning** Quality Guarantee system:
- ✅ Backend scoring algorithm exists and works
- ✅ Auto-regeneration logic implemented
- 🎯 Need to enhance UI to showcase quality scores prominently
- 🎯 Add transparent quality breakdown for user trust
- 🎯 Display regeneration indicator during generation
- 🎯 Show quality history in saved generations

**Key Differentiator:** ONLY platform with automated quality-based regeneration system.

**Next Steps:** Proceed to Milestone 3 (AI Humanization) upon user approval.
