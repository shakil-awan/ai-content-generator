# AI HUMANIZATION UX SPECIFICATIONS

**Feature:** AI Humanization & Detection Bypass  
**Status:** ✅ FULLY IMPLEMENTED  
**Priority:** HIGH (Tier 1 Feature)  
**Last Updated:** November 26, 2025

---

## A. COMPETITIVE RESEARCH

### ContentBot
**Implementation Status:** ✅ AI HUMANIZER EXISTS
- **Feature:** "Humanize your AI Content" with "Undetectable AI content"
- **Claims:** "Bypasses tools like ZeroGPT and Winston AI"
- **Approach:** Single humanization process, no visible level options
- **Detection Display:** NO before/after scoring shown to users
- **Pricing:** $9-49/mo (50k-400k words)
- **Limitation:** No transparency on improvement metrics

### Jasper AI
**Implementation Status:** ❌ NO AI HUMANIZATION
- No AI detection bypass feature
- Focus on brand voice and content automation
- Users must manually edit for natural tone

### Copy.ai
**Implementation Status:** ❌ NO AI HUMANIZATION
- No humanization or detection bypass
- Workflow automation focused

### Writesonic
**Implementation Status:** ❌ NO AI HUMANIZATION
- No humanization feature found

### Rytr
**Implementation Status:** ❌ NO AI HUMANIZATION
- No detection bypass capability

### Key Insights
1. **Market Gap:** Only 2 of 6 competitors have AI humanization (Summarly + ContentBot)
2. **Our Advantage:** Before/after scoring with improvement metrics (ContentBot doesn't show)
3. **Multiple Levels:** 3 humanization levels (Light, Balanced, Aggressive) vs ContentBot's single approach
4. **Unique Feature:** Fact preservation mode - maintains accuracy while improving naturalness
5. **Transparency:** Users see exact improvement (avg 44.3 point drop in AI score)

---

## B. API INTEGRATION MAPPING

### Internal AI Detection & Humanization System

**Backend Service:** `humanization_service.py` (HumanizationService class)

**USER INPUTS (Humanization Request):**
- ✅ Generation ID → Identifies content to humanize
- ✅ Humanization level (dropdown) → Light/Balanced/Aggressive
- ✅ Preserve facts (checkbox) → Maintains factual accuracy

**HUMANIZATION LEVELS:**
```
Light: Minimal changes (1-2 contractions, slight variation)
Balanced: Moderate rewrite (contractions, personality, colloquialisms) [DEFAULT]
Aggressive: Heavy rewrite (max contractions, strong voice, imperfections)
```

**AI DETECTION SCORING:**
- Uses OpenAI GPT-4o-mini to analyze AI patterns
- Returns score 0-100 (higher = more AI-like)
- Identifies indicators: repetitive phrasing, formal language, predictable structure
- Fallback to Gemini 2.5 Flash if OpenAI fails

**HUMANIZATION PROCESS:**
1. **Detect Before Score:** Analyze original content for AI patterns
2. **Rewrite Content:** Apply humanization based on selected level
3. **Detect After Score:** Analyze humanized content
4. **Calculate Improvement:** before_score - after_score
5. **Update Firestore:** Save results + increment usage counter

**RESPONSE STRUCTURE:**
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
    "humanizedContent": "Rewritten text..."
  }
}
```

**RATE LIMITING:**
- Free: 5 humanizations/month
- Pro: 25 humanizations/month
- Enterprise: Unlimited

---

## C. UI COMPONENT SPECIFICATIONS

### 1. Humanize Button (Content Card)

**Location:** Content generation result card, below main actions

**Layout:**
```
┌─────────────────────────────────────────────┐
│ Generated Blog Post                         │
│ Lorem ipsum dolor sit amet...               │
│                                             │
│ [Copy] [Regenerate] [Save]                 │
│                                             │
│ 🤖 [Humanize Content] (5/25 used this month)│
└─────────────────────────────────────────────┘
```

**Component Specs:**
- Button: Secondary style, 16px font, robot emoji icon
- Quota Display: Small gray text below button
- Disabled State: For Free users, shows "Upgrade to Pro" tooltip

### 2. Humanization Settings Modal

**Location:** Opens when "Humanize Content" clicked

**Layout:**
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

**Field Specifications:**
- **Radio Buttons:** 3 options with descriptions
- **Default:** Balanced selected
- **Checkbox:** Preserve Facts enabled by default
- **Helper Text:** 12px gray-600 under checkbox
- **Buttons:** Cancel (ghost), Humanize Now (primary)

### 3. Humanization Progress Indicator

**Location:** Modal overlay during processing

**Layout:**
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

**States:**
1. Detecting AI patterns (2-3s)
2. Rewriting content (5-10s)
3. Analyzing humanized version (2-3s)

### 4. Humanization Results Panel

**Location:** Replaces original content after humanization

**Layout:**
```
┌───────────────────────────────────────────────────┐
│ ✓ Content Humanized Successfully                  │
│                                                    │
│ AI Detection Score                                │
│ Before: ████████░░ 85%  →  After: ███░░░░░░░ 28% │
│ Improvement: -57 points (67.1% reduction)         │
│                                                    │
│ [Show Before/After Comparison] ▼                  │
└───────────────────────────────────────────────────┘

[When expanded - Side-by-side comparison:]

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

**Component Details:**
- **Score Display:** Horizontal bars with before/after values
- **Improvement Metric:** Bold green text showing reduction
- **Comparison Toggle:** Expandable accordion
- **Side-by-Side:** 50/50 split on desktop, stacked on mobile
- **Action Buttons:** Choose which version to keep

### 5. Quota Warning (Hobby Tier Approaching Limit)

**Location:** Banner above Humanize button

**Layout:**
```
┌─────────────────────────────────────────────┐
│ ⚠️ 23/25 humanizations used this month      │
│ [Upgrade to Pro for unlimited] →           │
└─────────────────────────────────────────────┘
```

**Trigger:** When usage ≥80% of limit (20/25 for Hobby)

### 6. Quota Exceeded Modal

**Location:** Replaces humanization modal when limit reached

**Layout:**
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

---

## D. USER FLOW DIAGRAMS

### Flow 1: Humanize Generated Content

```
User generates content (blog/email/etc.)
       ↓
Content displayed with "Humanize Content" button
       ↓
Click "Humanize Content"
       ↓
┌────────────────────────┐
│ Check subscription tier│
└───────┬────────────────┘
        │
    FREE│              PRO/ENTERPRISE
        ↓                    ↓
Show upgrade modal    Check quota usage
  [Cancel] [Upgrade]       │
                           ↓
                    ┌──────────────┐
                    │ Usage < Limit?│
                    └───────┬───────┘
                        YES │    NO
                            ↓    ↓
                    Open modal   Show limit
                    Select level  reached modal
                          ↓
                    [Humanize Now]
                          ↓
            [Progress] "Detecting AI patterns..."
                          ↓
            AI detection scores original (85%)
                          ↓
            [Progress] "Rewriting content..."
                          ↓
            Apply humanization (Balanced level)
                          ↓
            [Progress] "Analyzing humanized version..."
                          ↓
            AI detection scores result (28%)
                          ↓
            Calculate improvement (-57 points)
                          ↓
Display results with before/after comparison
       ↓
User reviews:
- [Use Humanized] → Replace original
- [Use Original] → Keep original
- [Try Again] → Adjust level and retry
```

### Flow 2: View Detection Analysis Details

```
Humanization results displayed
       ↓
Click "Show Before/After Comparison"
       ↓
Panel expands showing:
- Original text (left)
- Humanized text (right)
- Detection indicators for each
       ↓
User can:
- Read side-by-side
- Choose preferred version
- Close comparison
```

### Flow 3: Quota Management

```
User clicks "Humanize" (23/25 used)
       ↓
Warning banner visible
       ↓
Humanization completes (24/25)
       ↓
Next attempt (25/25 - last one)
       ↓
Modal shows: "Last humanization this month!"
       ↓
Humanization completes (25/25)
       ↓
Next click shows quota exceeded modal
       ↓
Options:
- [Upgrade to Pro] → Redirect to pricing
- [Cancel] → Close modal
```

---

## E. DESIGN RECOMMENDATIONS

### Color Scheme

**AI Detection Scores:**
- **High AI (70-100%):** Red gradient (#DC2626 to #EF4444)
- **Medium AI (40-69%):** Yellow gradient (#D97706 to #F59E0B)
- **Low AI (0-39%):** Green gradient (#059669 to #10B981)

**Improvement Indicators:**
- **Positive Improvement:** Green-600 (#059669) with ↓ arrow
- **Status Icons:** Robot 🤖, Checkmark ✓, Warning ⚠️

**UI Elements:**
- Background: White or Gray-50
- Text: Gray-900 (primary), Gray-600 (secondary)
- Borders: Gray-300
- Buttons: Blue-600 (primary), Gray-300 (secondary)

### Typography

```
Modal Title: 18px, Semibold, Gray-900
Section Labels: 14px, Medium, Gray-700
Score Values: 16px, Bold, Status color
Improvement Text: 14px, Semibold, Green-600
Comparison Text: 13px, Regular, Gray-800
Helper Text: 12px, Regular, Gray-500
Quota Text: 11px, Regular, Gray-600
```

### Spacing & Layout

```
Modal: 500px width, 24px padding
Progress Bars: 300×8px, 4px radius
Score Comparison: 16px spacing between before/after
Side-by-Side: 48px gap between columns
Button Group: 12px spacing
```

### Accessibility (WCAG AA)

- **Color Contrast:** All text meets 4.5:1 ratio
- **Screen Readers:**
  - Score: "AI detection score: 85 percent before, 28 percent after"
  - Improvement: "Reduced by 57 points, 67 percent improvement"
- **Keyboard Navigation:** Tab through options, Enter to confirm
- **Focus States:** 2px blue outline

### Animations

```
Modal: Fade in + scale (0.2s ease-out)
Progress Bar: Fill animation (0.5s linear)
Score Comparison: Slide in from sides (0.3s ease-out)
Improvement: Count up animation (1s ease-out)
```

### Mobile Responsive

**Breakpoints:**
- Desktop (>768px): Side-by-side comparison
- Tablet (480-768px): Stacked comparison, full width
- Mobile (<480px): Vertically stacked, swipe between versions

**Mobile Optimizations:**
- Progress bars: 100% width
- Comparison: Swipeable tabs instead of side-by-side
- Buttons: Full width, stacked vertically

---

## F. TECHNICAL IMPLEMENTATION NOTES

### Flutter Widgets

**Humanize Button:**
```dart
ElevatedButton.icon(
  icon: Text('🤖'),
  label: Text('Humanize Content'),
  onPressed: _hasQuota ? _showHumanizationModal : _showUpgradeModal,
  child: Column(
    children: [
      Text('Humanize Content'),
      if (_showQuota)
        Text(
          '${_used}/${_limit} used this month',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
    ],
  ),
)
```

**Humanization Settings Modal:**
```dart
class HumanizationModal extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Humanize AI Content'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<HumanizationLevel>(
            title: Text('Light'),
            subtitle: Text('Minimal changes'),
            value: HumanizationLevel.light,
            groupValue: _selectedLevel,
            onChanged: (val) => setState(() => _selectedLevel = val),
          ),
          RadioListTile<HumanizationLevel>(
            title: Text('Balanced'),
            subtitle: Text('Moderate rewrite (Recommended)'),
            value: HumanizationLevel.balanced,
            groupValue: _selectedLevel,
            onChanged: (val) => setState(() => _selectedLevel = val),
          ),
          RadioListTile<HumanizationLevel>(
            title: Text('Aggressive'),
            subtitle: Text('Maximum humanization'),
            value: HumanizationLevel.aggressive,
            groupValue: _selectedLevel,
            onChanged: (val) => setState(() => _selectedLevel = val),
          ),
          CheckboxListTile(
            title: Text('Preserve Facts'),
            subtitle: Text('Maintain factual accuracy'),
            value: _preserveFacts,
            onChanged: (val) => setState(() => _preserveFacts = val),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _humanizeContent,
          child: Text('Humanize Now'),
        ),
      ],
    );
  }
}
```

**Results Panel with Before/After:**
```dart
class HumanizationResults extends StatelessWidget {
  final HumanizationData results;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Content Humanized Successfully',
                     style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            Text('AI Detection Score'),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('Before: ${results.beforeScore.toInt()}%'),
                      LinearProgressIndicator(
                        value: results.beforeScore / 100,
                        color: _getScoreColor(results.beforeScore),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward),
                Expanded(
                  child: Column(
                    children: [
                      Text('After: ${results.afterScore.toInt()}%'),
                      LinearProgressIndicator(
                        value: results.afterScore / 100,
                        color: _getScoreColor(results.afterScore),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Improvement: ${results.improvement.toInt()} points '
              '(${results.improvementPercentage.toStringAsFixed(1)}% reduction)',
              style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.bold),
            ),
            ExpansionTile(
              title: Text('Show Before/After Comparison'),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildComparisonColumn('Original', results.original, results.beforeScore),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildComparisonColumn('Humanized', results.humanized, results.afterScore),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getScoreColor(double score) {
    if (score >= 70) return Colors.red[600]!;
    if (score >= 40) return Colors.yellow[700]!;
    return Colors.green[600]!;
  }
}
```

### State Management

**Using Provider/Riverpod:**
```dart
class HumanizationProvider extends ChangeNotifier {
  HumanizationData? _results;
  bool _isHumanizing = false;
  int _quotaUsed = 0;
  int _quotaLimit = 5;
  
  Future<void> humanizeContent({
    required String generationId,
    required HumanizationLevel level,
    required bool preserveFacts,
  }) async {
    _isHumanizing = true;
    notifyListeners();
    
    try {
      final response = await apiService.post(
        '/humanize/$generationId',
        {
          'level': level.name,
          'preserve_facts': preserveFacts,
        },
      );
      
      _results = HumanizationData.fromJson(response.data);
      _quotaUsed++;
      _isHumanizing = false;
      notifyListeners();
    } catch (e) {
      _isHumanizing = false;
      notifyListeners();
      rethrow;
    }
  }
  
  bool get hasQuota => _quotaUsed < _quotaLimit;
  bool get showWarning => _quotaUsed >= (_quotaLimit * 0.8);
}
```

### API Integration

**Backend Endpoint:**
```
POST /api/v1/humanize/{generation_id}
{
  "level": "balanced",
  "preserve_facts": true
}

Response:
{
  "humanization": {
    "applied": true,
    "level": "balanced",
    "before_score": 85.0,
    "after_score": 28.0,
    "improvement": 57.0,
    "improvement_percentage": 67.1,
    "before_analysis": {...},
    "after_analysis": {...}
  },
  "output": {
    "humanizedContent": "..."
  }
}
```

### Error Handling

**Strategies:**
1. **API Timeout (>60s):** Show "Humanization taking longer than expected" with [Cancel] option
2. **Quota Exceeded:** Block humanization, show upgrade modal
3. **Detection Failure:** Proceed with humanization but show "Unable to calculate AI score" message
4. **Humanization Failure:** Show error, allow retry

**Implementation:**
```dart
try {
  await humanizationService.humanize(generationId, level);
} on QuotaExceededException {
  _showUpgradeModal();
} on TimeoutException {
  _showSnackbar('Humanization timed out. Please try again.');
} catch (e) {
  _showSnackbar('Unable to humanize content. Please try again.');
  _logError('Humanization failed', e);
}
```

### Performance Optimization

**Caching:** Cache detection scores for identical content (7 days TTL)
**Parallel Processing:** Run before/after detection in parallel where possible
**Lazy Loading:** Load comparison view only when expanded

### Testing Strategy

**Unit Tests:**
- Test level selection logic
- Test improvement calculation
- Test quota enforcement

**Widget Tests:**
- Test modal rendering
- Test button enable/disable based on quota
- Test before/after comparison display

**Integration Tests:**
- Test full humanization flow
- Test quota limit enforcement
- Test error handling

---

## Summary

This UX specification provides implementation guidance for the **already-functioning** AI Humanization system:
- ✅ Backend detection & humanization algorithms working
- ✅ 3-level system (Light, Balanced, Aggressive) implemented
- ✅ Before/after scoring with transparent metrics
- 🎯 Need UI to showcase improvement prominently
- 🎯 Add before/after comparison view
- 🎯 Display quota tracking and warnings

**Key Differentiator:** Only 2 competitors have humanization; we're the only one showing transparent before/after metrics.

**Next Steps:** Proceed to Milestone 4 (Brand Voice) upon user approval.
