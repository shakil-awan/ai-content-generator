# FACT-CHECKING UX SPECIFICATIONS

**Feature:** AI-Powered Fact-Checking  
**Status:** NOT IMPLEMENTED  
**Priority:** CRITICAL  
**Last Updated:** November 26, 2025

---

## A. COMPETITIVE RESEARCH

### Writesonic - Fact-Checking Feature
**Implementation Status:** ✅ BASIC IMPLEMENTATION
- **Feature Location:** Content Engine with "Fact-checked" badge
- **Approach:** Auto fact-checking mentioned in marketing ("100+ source-backed articles with auto fact-checking")
- **UI Pattern:** Claims content is fact-checked during generation, no visible verification interface
- **User Control:** Appears to be automatic, no toggle found
- **Verification Display:** Sources mentioned but verification details not exposed to user
- **Limitation:** Basic source verification (checks if sources exist, not accuracy validation)

### Jasper AI
**Implementation Status:** ❌ NO FACT-CHECKING
- No fact-checking feature found
- Focus on SEO/AEO optimization, brand voice, content speed
- User must manually verify all facts

### Copy.ai
**Implementation Status:** ❌ NO FACT-CHECKING  
- No fact-checking capability
- GTM platform focused on workflow automation, not accuracy
- Emphasizes speed over verification

### ContentBot
**Implementation Status:** ❌ NO FACT-CHECKING
- No fact-checking mentioned in features

### Rytr
**Implementation Status:** ❌ NO FACT-CHECKING
- No fact-checking capability

### Key Insights
1. **Market Gap:** Only Writesonic has basic fact-checking; opportunity for differentiation
2. **UX Pattern Missing:** No competitor shows detailed verification UI with confidence scores
3. **Our Advantage:** Multi-source verification with transparent confidence scoring

---

## B. API INTEGRATION MAPPING

### Primary API: Google Fact Check Tools API

**API Endpoint:**
```
GET https://factchecktools.googleapis.com/v1alpha1/claims:search
```

**USER INPUTS (UI Form):**
- ✅ Content text (textarea) → Passed to claim extraction AI
- ✅ Enable fact-checking (toggle) → Controls whether verification runs
- ✅ Confidence threshold (slider, optional) → Filters displayed results

**API REQUEST BODY:**
```json
{
  "query": "Python was created in 1991",
  "key": "API_KEY",
  "languageCode": "en"
}
```

**Key Distinction:**
- **User provides:** Raw content text
- **Backend extracts:** Individual claims using AI
- **API verifies:** Each extracted claim separately

**API RESPONSE:**
```json
{
  "claims": [
    {
      "text": "Python was created in 1991",
      "claimReview": [
        {
          "publisher": {"name": "Wikipedia"},
          "url": "https://...",
          "textualRating": "True",
          "languageCode": "en"
        }
      ]
    }
  ]
}
```

**Rating to Confidence Mapping:**
- "True" → 95%
- "Mostly True" → 85%
- "Half True" → 60%
- "Unverified" → 40%
- "Mostly False" → 30%
- "False" → 5%

### Secondary API: Wikipedia API

**API Endpoint:**
```
GET https://en.wikipedia.org/w/api.php
```

**Request Parameters:**
```
action=query
list=search
srsearch={claim_text}
format=json
```

**Used for:** Secondary verification when Google Fact Check has no results

---

## C. UI COMPONENT SPECIFICATIONS

### 1. Settings Panel - Auto Fact-Check Toggle

**Location:** User Settings → Content Generation Preferences

**Components:**
```
┌─────────────────────────────────────────┐
│ Content Generation Preferences          │
├─────────────────────────────────────────┤
│                                         │
│ ☑ Auto Fact-Check Content              │
│   Automatically verify factual claims   │
│   in generated content                  │
│   [PRO FEATURE]                         │
│                                         │
│ Confidence Threshold: ●────────○ 70%   │
│ (Only show claims with 70%+ confidence) │
│                                         │
│ Quota: 7/10 fact-checks used this month│
│ [Upgrade to Pro for unlimited] →       │
└─────────────────────────────────────────┘
```

**Field Specifications:**
- **Toggle:** Material/Cupertino switch widget
- **Label:** "Auto Fact-Check Content"
- **Helper Text:** "Automatically verify factual claims in generated content"
- **Badge:** "PRO FEATURE" (yellow badge for Hobby/Pro users)
- **Slider:** Range 50-95%, default 70%, step 5%
- **Quota Display:** Only show for Hobby tier users
- **Upgrade Button:** Visible for Free/Hobby users

**Validation:**
- Free tier: Toggle disabled, show "Upgrade to Hobby" tooltip
- Hobby tier: Toggle enabled, show quota limit
- Pro tier: Toggle enabled, no quota limit

### 2. Fact-Check Results Panel

**Location:** Below generated content, expandable section

**Layout:**
```
┌────────────────────────────────────────────────┐
│ ✓ Fact-Check Complete (3 claims verified)     │
│   Verification time: 12.4s                     │
│   ▼ View Details                               │
└────────────────────────────────────────────────┘

[When expanded:]

┌────────────────────────────────────────────────┐
│ Claim 1 of 3                                   │
│ ┌────────────────────────────────────────────┐ │
│ │ "Python was created by Guido van Rossum    │ │
│ │  in 1991"                                  │ │
│ │                                            │ │
│ │ Status: ✓ VERIFIED                         │ │
│ │ Confidence: ████████░░ 85%                 │ │
│ │ Source: Wikipedia - Python (programming)   │ │
│ │ [View Source →]                            │ │
│ └────────────────────────────────────────────┘ │
│                                                │
│ Claim 2 of 3                                   │
│ ┌────────────────────────────────────────────┐ │
│ │ "AI market will reach $500 billion by 2025"│ │
│ │                                            │ │
│ │ Status: ⚠ UNVERIFIED                       │ │
│ │ Confidence: ███░░░░░░░ 35%                 │ │
│ │ Source: No credible source found           │ │
│ │ [Manually Verify] [Remove Claim]           │ │
│ └────────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
```

**Component Details:**

**Claim Card:**
- Border: Green for verified (≥70%), Yellow for medium (50-69%), Red for unverified (<50%)
- Claim Text: Gray 700, 14px font
- Status Icon: ✓ (green), ⚠ (yellow), ✗ (red)
- Confidence Bar: Horizontal progress bar with percentage
- Source Link: Blue underlined, opens in new tab
- Actions: "View Source" button, "Manually Verify" for unverified

**Empty State (No claims found):**
```
┌────────────────────────────────────────┐
│ ✓ Fact-Check Complete                  │
│   No verifiable claims detected        │
│   (This content appears opinion-based) │
└────────────────────────────────────────┘
```

**Error State:**
```
┌────────────────────────────────────────┐
│ ⚠ Fact-Check Failed                    │
│   Unable to verify claims              │
│   [Retry] [Skip Fact-Check]            │
└────────────────────────────────────────┘
```

### 3. In-Content Highlighting (Optional Advanced Feature)

**Pattern:** Highlight verified/unverified claims directly in text

```
Generated content with [verified claim]₉₅% highlighted 
in green and [unverified claim]₃₅% in red.
```

**Implementation:**
- Wrap claims in colored spans
- Tooltip on hover shows confidence + source
- Click opens detailed verification panel

---

## D. USER FLOW DIAGRAMS

### Flow 1: Enable Auto Fact-Check (First Time)

```
User Settings Page
       ↓
Click "Auto Fact-Check" toggle
       ↓
[If Free tier]
   → Show upgrade modal: "Upgrade to Hobby for fact-checking"
   → [Upgrade] → Redirect to pricing page
   → [Cancel] → Toggle stays off
       ↓
[If Hobby/Pro tier]
   → Toggle enabled
   → Show success toast: "Auto fact-checking enabled"
   → Save setting to Firebase
```

### Flow 2: Generate Content with Fact-Check

```
User fills generation form (topic, tone, etc.)
       ↓
Click "Generate" button
       ↓
[Loading state] "Generating content..."
       ↓
Content generation completes (5-8s)
       ↓
[If auto_fact_check = true]
   → [Loading state] "Verifying facts... (3 of 5 claims)"
   → Backend extracts claims
   → Backend calls Google/Wikipedia APIs
   → Process takes 10-15s
       ↓
Display generated content + Fact-Check Results Panel
       ↓
User reviews claims:
   - ✓ Verified claims: Accept
   - ⚠ Unverified: [Edit content] or [Accept anyway]
       ↓
Click "Save" or "Publish"
```

### Flow 3: Quota Exceeded (Hobby Tier)

```
User generates content (10th fact-check this month)
       ↓
Fact-check completes normally
       ↓
Show banner: "Quota limit reached (10/10)"
       ↓
Next generation attempt:
   → Show modal: "You've used all fact-checks this month"
   → Options:
      - [Upgrade to Pro] → Redirect to pricing
      - [Continue without fact-check] → Generate normally
      - [Cancel]
```

---

## E. DESIGN RECOMMENDATIONS

### Color Scheme

**Verification Status Colors:**
- ✅ **Verified (≥70%):** Green-600 (#059669)
- ⚠️ **Medium (50-69%):** Yellow-600 (#D97706)
- ❌ **Unverified (<50%):** Red-600 (#DC2626)

**UI Elements:**
- **Background:** White (#FFFFFF) or Gray-50 (#F9FAFB)
- **Panel Border:** Gray-300 (#D1D5DB)
- **Text:** Gray-900 (#111827) for primary, Gray-600 for secondary
- **Links:** Blue-600 (#2563EB)

### Typography

```
Panel Title: 16px, Semibold, Gray-900
Claim Text: 14px, Regular, Gray-700
Confidence %: 14px, Medium, Status color
Source Link: 13px, Regular, Blue-600
Helper Text: 12px, Regular, Gray-500
```

### Spacing

```
Card Padding: 16px
Claim Spacing: 12px between cards
Panel Margins: 24px top, 16px sides
```

### Accessibility (WCAG AA)

- **Color Contrast:** All text meets 4.5:1 ratio
- **Screen Readers:** 
  - Claim status announced as "Verified with 85% confidence"
  - Progress bars have aria-label="Confidence score: 85%"
- **Keyboard Navigation:** Tab through claims, Enter to expand/collapse
- **Focus Indicators:** 2px blue outline on focused elements

### Mobile Responsive

**Breakpoints:**
- Desktop (>768px): Side-by-side content + fact-check panel
- Tablet (480-768px): Stacked layout, full-width panels
- Mobile (<480px): Collapsed by default, expandable cards

**Mobile Optimizations:**
- Claim text wraps at 2 lines, "Show more" for longer claims
- Confidence bars: 60% width on mobile
- Action buttons stack vertically

---

## F. TECHNICAL IMPLEMENTATION NOTES

### Flutter Widgets

**Settings Toggle:**
```dart
SwitchListTile(
  title: Text('Auto Fact-Check Content'),
  subtitle: Text('Automatically verify factual claims'),
  value: _autoFactCheck,
  onChanged: _isProUser ? _toggleFactCheck : null,
  secondary: Badge(label: Text('PRO')),
)
```

**Fact-Check Results Panel:**
```dart
ExpansionPanel(
  headerBuilder: (context, isExpanded) {
    return ListTile(
      leading: Icon(Icons.check_circle, color: Colors.green),
      title: Text('Fact-Check Complete (3 claims)'),
      subtitle: Text('Verification time: 12.4s'),
    );
  },
  body: ListView.builder(
    itemCount: claims.length,
    itemBuilder: (context, index) => FactClaimCard(claim: claims[index]),
  ),
)
```

**Claim Card Widget:**
```dart
Card(
  color: _getStatusColor(claim.confidence),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(claim.text, style: TextStyle(fontSize: 14)),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(_getStatusIcon(claim.verified)),
            SizedBox(width: 4),
            Text(claim.verified ? 'VERIFIED' : 'UNVERIFIED'),
          ],
        ),
        LinearProgressIndicator(value: claim.confidence / 100),
        Text('${claim.confidence}%'),
        TextButton(
          onPressed: () => _launchURL(claim.source),
          child: Text('View Source →'),
        ),
      ],
    ),
  ),
)
```

### State Management

**Using Provider/Riverpod:**
```dart
class FactCheckProvider extends ChangeNotifier {
  FactCheckResults? _results;
  bool _isLoading = false;
  
  Future<void> verifyContent(String content) async {
    _isLoading = true;
    notifyListeners();
    
    final response = await apiService.post('/verify', {
      'content': content,
      'min_confidence': 0.70,
    });
    
    _results = FactCheckResults.fromJson(response.data);
    _isLoading = false;
    notifyListeners();
  }
}
```

### API Integration

**Backend Endpoint:**
```
POST /api/v1/generate/blog
{
  "topic": "Python programming",
  "tone": "professional",
  "autoFactCheck": true  // From user settings
}

Response:
{
  "content": "...",
  "factCheckResults": {
    "checked": true,
    "claims": [...],
    "verificationTime": 12.4
  }
}
```

### Error Handling

**Strategy:**
1. **API Timeout (>30s):** Show "Fact-check taking longer than expected" with [Cancel] option
2. **API Failure:** Graceful degradation - show content without fact-check, notify user
3. **Quota Exceeded:** Block generation, show upgrade modal
4. **Invalid Response:** Log error, show "Unable to verify" message

**Implementation:**
```dart
try {
  final results = await factCheckService.verify(content);
  setState(() => _factCheckResults = results);
} on TimeoutException {
  _showSnackbar('Fact-check timed out. Content saved without verification.');
} on ApiException catch (e) {
  _showSnackbar('Unable to verify facts. Please check manually.');
  _logError('Fact-check failed', e);
} catch (e) {
  _showSnackbar('An error occurred during fact-checking.');
}
```

### Performance Optimization

**Caching Strategy:**
```dart
// Cache verification results for identical claims
class FactCheckCache {
  final Map<String, FactCheckClaim> _cache = {};
  
  FactCheckClaim? getCached(String claimText) {
    final key = claimText.toLowerCase().trim();
    final cached = _cache[key];
    
    // Cache valid for 7 days
    if (cached != null && cached.timestamp.isAfter(
        DateTime.now().subtract(Duration(days: 7)))) {
      return cached;
    }
    return null;
  }
}
```

### Testing Strategy

**Unit Tests:**
- Test claim extraction from content
- Test confidence score calculation
- Test quota limit enforcement

**Widget Tests:**
- Test toggle enable/disable based on user tier
- Test claim card rendering with different statuses
- Test expansion panel interactions

**Integration Tests:**
- Test full fact-check flow from generation to display
- Test error states (API failure, timeout)
- Test quota exceeded behavior

---

## Summary

This UX specification provides a complete blueprint for implementing AI-powered fact-checking with:
- ✅ Competitive differentiation (only Writesonic has basic version)
- ✅ Clear API integration (Google Fact Check + Wikipedia)
- ✅ Detailed UI components (settings, results panel, claim cards)
- ✅ Complete user flows (enable feature, generate, review claims)
- ✅ Design system (colors, typography, accessibility)
- ✅ Technical implementation (Flutter widgets, state management, error handling)

**Next Steps:** Proceed to Milestone 2 (Quality Guarantee) upon user approval.
