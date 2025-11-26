# BRAND VOICE UX SPECIFICATIONS

**Feature:** Brand Voice Training & Application  
**Status:** 🔨 PLANNED (Schemas exist, API not implemented)  
**Priority:** HIGH (Tier 1 Feature)  
**Last Updated:** November 26, 2025

---

## A. COMPETITIVE RESEARCH

### Jasper AI - Brand Voice
**Implementation Status:** ✅ FULLY IMPLEMENTED (Brand IQ)
- **Feature:** "Brand Voice" - Core part of Brand IQ system
- **Training:** Upload writing samples or define manually
- **Application:** Auto-applied across all content generation
- **Multiple Voices:** Yes (5 voices on Enterprise tier)
- **Voice Tuning:** Fine-tune tone, style, visual guidelines
- **UI Pattern:** Flags off-brand content, provides adjustment recommendations
- **Pricing:** $59-125/mo (mid to enterprise tier)

### Copy.ai - Brand Voice
**Implementation Status:** ✅ FULLY IMPLEMENTED
- **Feature:** "Brand Voice" integrated with Infobase
- **Training:** Analyze existing content or define manually
- **Multiple Voices:** ✅ UNLIMITED - tailor to different ICPs/audiences
- **Application:** Seamlessly infused into all AI-generated content
- **UI Pattern:** Simple brand voice selector, multiple voices per workspace
- **Pricing:** $49-99/mo

### Writesonic
**Implementation Status:** ⚠️ BASIC
- **Feature:** "Brand voice" mentioned in content engine
- **Implementation:** Basic voice settings, not advanced training
- **Limitation:** No multiple voice profiles

### ContentBot
**Implementation Status:** ❌ NO BRAND VOICE
- No voice training feature

### Rytr
**Implementation Status:** ❌ NO BRAND VOICE
- Only tone selection (formal, casual, etc.)

### Key Insights
1. **Market Standard:** Jasper & Copy.ai set the bar with advanced brand voice
2. **Multiple Voices:** Copy.ai wins with unlimited voices vs Jasper's 5
3. **Price Advantage:** Summarly at $29/mo = 51-77% cheaper than competitors
4. **Our Opportunity:** Offer 3+ voices at Pro tier to compete with premium players
5. **UI Pattern:** Simple upload → automatic analysis → apply to all content

---

## B. API INTEGRATION MAPPING

### Internal Brand Voice Training System

**Backend Service:** `voice_analysis_service.py` (to be created)

**USER INPUTS (Training Request):**
- ✅ Writing samples (file upload or paste text) → 3-10 samples, 200-2000 words each
- ✅ Tone description (text field) → "Professional yet friendly", "Casual and humorous"
- ✅ Vocabulary keywords (text field) → "innovative, user-centric, cutting-edge"
- ✅ Brand name (optional) → For naming the voice profile

**TRAINING PROCESS:**
1. **Upload Samples:** User provides 3-10 writing samples
2. **Validate Samples:** Check word count (200-2000 words), quality
3. **Analyze Voice:** Extract patterns using GPT-4o-mini
   - Vocabulary: Common words, unique phrases, technical terms
   - Sentence structure: Avg length, complexity, variation
   - Tone: Formality (0-1), humor (0-1), confidence (0-1)
   - Grammar: Contraction rate, punctuation style
   - Personality: Empathy, assertiveness metrics
4. **Generate Profile:** Create voice JSON with extractable patterns
5. **Save to Firestore:** Store in `users/{userId}/brandVoice`

**VOICE PROFILE STRUCTURE:**
```json
{
  "brandVoice": {
    "isConfigured": true,
    "tone": "Professional yet friendly",
    "vocabulary": "innovative, user-centric, cutting-edge",
    "samples": ["sample1 text...", "sample2 text..."],
    "voice_profile": {
      "vocabulary": {
        "top_words": ["innovative", "customer", "solution", ...],
        "unique_phrases": ["at the end of the day", "let's dive in"],
        "technical_terms": ["API", "machine learning", "SaaS"]
      },
      "sentence_structure": {
        "avg_length": 18.5,
        "complexity": 0.7,
        "variation": "high"
      },
      "tone_analysis": {
        "formality": 0.6,
        "humor": 0.3,
        "confidence": 0.8
      },
      "grammar_patterns": {
        "contraction_rate": 0.4,
        "comma_usage": "high",
        "paragraph_length": "medium"
      },
      "personality": {
        "empathy": 0.7,
        "assertiveness": 0.8
      }
    },
    "injection_prompt": "Write in this style: Professional yet friendly tone...",
    "trainedAt": "2025-11-26T12:00:00Z"
  }
}
```

**APPLICATION TO CONTENT:**
- When generating content, inject voice profile into system prompt
- Example: "Write a blog post about AI. Use this brand voice: [injection_prompt]"
- Model automatically adapts style to match user's unique voice

**API ENDPOINTS (To Be Created):**
```
POST /api/v1/brand-voice/train
Body: { tone, vocabulary, samples: [...] }
Response: { voice_profile, injection_prompt, summary }

GET /api/v1/brand-voice
Response: Current brand voice profile

PUT /api/v1/brand-voice/train
Body: { samples: [...] }  // Refine existing voice

DELETE /api/v1/brand-voice
Response: Voice profile removed
```

---

## C. UI COMPONENT SPECIFICATIONS

### 1. Brand Voice Setup Card (Settings Page)

**Location:** User Settings → Brand Voice section

**Layout (Not Configured):**
```
┌──────────────────────────────────────────────┐
│ 🎨 Brand Voice Training                      │
├──────────────────────────────────────────────┤
│                                              │
│ Train Summarly on your unique writing style │
│ All content will automatically match your    │
│ brand's voice and tone.                      │
│                                              │
│ [Train Your Brand Voice] →                   │
│                                              │
│ ✓ Upload 3-10 writing samples               │
│ ✓ AI analyzes your style in 15 seconds      │
│ ✓ Applied to all future generations         │
└──────────────────────────────────────────────┘
```

**Layout (Configured):**
```
┌──────────────────────────────────────────────┐
│ 🎨 Brand Voice: "Company Blog"          ✓   │
├──────────────────────────────────────────────┤
│                                              │
│ Tone: Professional yet friendly              │
│ Vocabulary: innovative, user-centric         │
│ Trained: Nov 26, 2025                        │
│                                              │
│ [View Details] [Update Voice] [Remove]      │
└──────────────────────────────────────────────┘
```

### 2. Brand Voice Training Modal

**Location:** Opens when "Train Your Brand Voice" clicked

**Layout:**
```
┌────────────────────────────────────────────────┐
│ ✕  Train Your Brand Voice                     │
├────────────────────────────────────────────────┤
│                                                │
│ Step 1: Upload Writing Samples (3-10)         │
│ ┌──────────────────────────────────────────┐  │
│ │ 📄 Sample 1: Blog post excerpt...    ✓  │  │
│ │ 📄 Sample 2: Email newsletter...     ✓  │  │
│ │ 📄 Sample 3: Social media posts...   ✓  │  │
│ │ [+ Add More Samples] (7 more allowed)   │  │
│ └──────────────────────────────────────────┘  │
│                                                │
│ Step 2: Describe Your Brand Tone (Optional)   │
│ ┌──────────────────────────────────────────┐  │
│ │ e.g., "Professional yet friendly"        │  │
│ └──────────────────────────────────────────┘  │
│                                                │
│ Step 3: Key Vocabulary (Optional)              │
│ ┌──────────────────────────────────────────┐  │
│ │ e.g., "innovative, user-centric"         │  │
│ └──────────────────────────────────────────┘  │
│                                                │
│ Voice Profile Name (Optional)                  │
│ ┌──────────────────────────────────────────┐  │
│ │ e.g., "Company Blog Voice"               │  │
│ └──────────────────────────────────────────┘  │
│                                                │
│ [Cancel] [Train Brand Voice]                   │
└────────────────────────────────────────────────┘
```

**Field Specifications:**
- **Sample Upload:** Drag-drop zone or [Upload File] button
- **Text Paste:** Alternative option to paste text directly
- **Minimum:** 3 samples required to enable training
- **Maximum:** 10 samples allowed
- **Word Count:** Display "523 words" for each sample
- **Validation:** Show error if sample <200 or >2000 words

### 3. Training Progress Indicator

**Location:** Modal overlay during analysis

**Layout:**
```
┌────────────────────────────────────┐
│ 🎨 Analyzing Your Writing Style    │
│                                    │
│ ●●●●●●●○○○ 70%                    │
│                                    │
│ Analyzing vocabulary patterns...   │
│                                    │
│ This takes about 15 seconds        │
└────────────────────────────────────┘
```

**Analysis Steps:**
1. Validating samples... (5%)
2. Analyzing vocabulary... (35%)
3. Analyzing tone & style... (65%)
4. Building voice profile... (95%)
5. Complete! (100%)

### 4. Voice Profile Summary

**Location:** Displayed after training completes

**Layout:**
```
┌────────────────────────────────────────────────┐
│ ✓ Brand Voice Trained Successfully!           │
├────────────────────────────────────────────────┤
│                                                │
│ Voice Profile Summary                          │
│                                                │
│ Tone Characteristics:                          │
│ • Formality: ████████░░ Professional (60%)    │
│ • Humor: ███░░░░░░░ Light (30%)               │
│ • Confidence: ████████░░ Strong (80%)         │
│                                                │
│ Writing Style:                                 │
│ • Avg sentence length: 18 words                │
│ • Contractions: Used moderately (40%)          │
│ • Paragraph style: Medium length               │
│                                                │
│ Top Vocabulary:                                │
│ innovative • user-centric • solution           │
│ cutting-edge • seamless • transform            │
│                                                │
│ [Apply to All Content] [Adjust Settings]      │
└────────────────────────────────────────────────┘
```

### 5. Brand Voice Indicator (Generation Page)

**Location:** Generation form, below content type selector

**Layout:**
```
┌──────────────────────────────────────────┐
│ Generate Blog Post                       │
│                                          │
│ Brand Voice: "Company Blog" ✓            │
│ [Change Voice]                           │
└──────────────────────────────────────────┘
```

**States:**
- **Configured:** Shows voice name with checkmark
- **Not Configured:** Shows "No brand voice set" with [Set Up] link
- **Disabled:** For Free tier users

### 6. Multiple Voice Management (Future Enhancement)

**Location:** Settings → Brand Voice section

**Layout:**
```
┌──────────────────────────────────────────┐
│ Your Brand Voices                        │
├──────────────────────────────────────────┤
│ ● Company Blog (Active)                  │
│   Professional yet friendly              │
│   [Edit] [Delete]                        │
│                                          │
│ ○ Email Newsletter                       │
│   Casual and conversational              │
│   [Edit] [Delete] [Set Active]          │
│                                          │
│ ○ Social Media                           │
│   Fun and engaging                       │
│   [Edit] [Delete] [Set Active]          │
│                                          │
│ [+ Add New Voice] (Pro: 3, Enterprise: ∞)│
└──────────────────────────────────────────┘
```

---

## D. USER FLOW DIAGRAMS

### Flow 1: First-Time Brand Voice Training

```
User navigates to Settings → Brand Voice
       ↓
Sees "Brand Voice Training" card
       ↓
Click "Train Your Brand Voice"
       ↓
Training modal opens
       ↓
Step 1: Upload samples
   - [Upload Files] or [Paste Text]
   - Add 3-10 samples
   - Validation: Check word count (200-2000)
       ↓
Step 2: (Optional) Describe tone
   - Enter: "Professional yet friendly"
       ↓
Step 3: (Optional) Key vocabulary
   - Enter: "innovative, user-centric"
       ↓
Click "Train Brand Voice"
       ↓
[Progress] "Analyzing your writing style..."
   - Analysis takes ~15 seconds
   - Progress bar shows % complete
       ↓
Training completes
       ↓
Display Voice Profile Summary
   - Tone: Formality 60%, Humor 30%, Confidence 80%
   - Style: Avg 18 words/sentence, 40% contractions
   - Top vocabulary: innovative, user-centric, solution
       ↓
Click "Apply to All Content"
       ↓
Brand voice saved to Firestore
       ↓
Success message: "Brand voice configured! All future content will match your style."
```

### Flow 2: Generate Content with Brand Voice

```
User opens content generation page
       ↓
Sees "Brand Voice: Company Blog ✓"
       ↓
Fills in generation form (topic, length, etc.)
       ↓
Click "Generate"
       ↓
Backend checks brandVoice.isConfigured = true
       ↓
Inject voice profile into system prompt:
"Write in this style: Professional yet friendly..."
       ↓
AI generates content matching brand voice
       ↓
Content displayed to user
       ↓
User reviews: Sounds exactly like their writing!
```

### Flow 3: Update Existing Brand Voice

```
User in Settings → Brand Voice
       ↓
Click "Update Voice"
       ↓
Modal shows current voice profile
       ↓
Options:
- [Add More Samples] → Upload additional samples for refinement
- [Change Tone] → Modify tone description
- [Update Vocabulary] → Edit keywords
       ↓
Click "Save Changes"
       ↓
Re-analyze with updated samples
       ↓
Voice profile updated in Firestore
       ↓
Success: "Brand voice updated!"
```

---

## E. DESIGN RECOMMENDATIONS

### Color Scheme

**Brand Voice Status:**
- **Configured:** Green-600 (#059669) with ✓ checkmark
- **Not Configured:** Gray-500 (#6B7280)
- **Training:** Blue-600 (#2563EB) with progress animation

**UI Elements:**
- Background: White or Gray-50
- Text: Gray-900 (primary), Gray-600 (secondary)
- Borders: Gray-300
- Progress Bars: Blue-600

### Typography

```
Modal Title: 18px, Semibold, Gray-900
Section Labels: 14px, Medium, Gray-700
Voice Name: 16px, Semibold, Gray-900
Voice Details: 13px, Regular, Gray-600
Metrics: 14px, Regular, Gray-700
Helper Text: 12px, Regular, Gray-500
```

### Spacing & Layout

```
Modal: 600px width, 24px padding
Sample Cards: 12px spacing between
Progress Bar: 300×8px, 4px radius
Voice Summary: 16px padding, 12px spacing
Buttons: 12px spacing horizontal
```

### Accessibility (WCAG AA)

- **Color Contrast:** All text meets 4.5:1 ratio
- **Screen Readers:**
  - Status: "Brand voice configured: Company Blog"
  - Training: "Analyzing writing style, 70 percent complete"
- **Keyboard Navigation:** Tab through samples, Enter to upload
- **Focus States:** 2px blue outline

### Animations

```
Modal: Fade in + scale (0.2s ease-out)
Progress Bar: Fill animation (0.5s linear)
Sample Upload: Slide in (0.3s ease-out)
Checkmark: Pop in (0.2s spring)
```

### Mobile Responsive

**Breakpoints:**
- Desktop (>768px): Multi-column layout
- Tablet (480-768px): Single column, full width
- Mobile (<480px): Stacked samples, simplified metrics

**Mobile Optimizations:**
- Sample cards: 100% width
- Upload button: Full width
- Voice summary: Collapsed by default, expandable

---

## F. TECHNICAL IMPLEMENTATION NOTES

### Flutter Widgets

**Brand Voice Setup Card:**
```dart
class BrandVoiceCard extends StatelessWidget {
  final bool isConfigured;
  final BrandVoice? voice;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: isConfigured
          ? _buildConfiguredState()
          : _buildNotConfiguredState(),
      ),
    );
  }
  
  Widget _buildConfiguredState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('🎨'),
            SizedBox(width: 8),
            Text('Brand Voice: "${voice.name}"',
                 style: TextStyle(fontWeight: FontWeight.bold)),
            Icon(Icons.check_circle, color: Colors.green, size: 20),
          ],
        ),
        SizedBox(height: 8),
        Text('Tone: ${voice.tone}'),
        Text('Vocabulary: ${voice.vocabulary}'),
        Text('Trained: ${_formatDate(voice.trainedAt)}'),
        SizedBox(height: 12),
        Row(
          children: [
            TextButton(
              onPressed: _viewDetails,
              child: Text('View Details'),
            ),
            TextButton(
              onPressed: _updateVoice,
              child: Text('Update Voice'),
            ),
            TextButton(
              onPressed: _removeVoice,
              child: Text('Remove'),
            ),
          ],
        ),
      ],
    );
  }
}
```

**Training Modal:**
```dart
class BrandVoiceTrainingModal extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Train Your Brand Voice'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Step 1: Upload Writing Samples (3-10)'),
            SizedBox(height: 8),
            ..._samples.map((sample) => _buildSampleCard(sample)),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Add More Samples'),
              onPressed: _samples.length < 10 ? _addSample : null,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Brand Tone (Optional)',
                hintText: 'e.g., "Professional yet friendly"',
              ),
              onChanged: (val) => _tone = val,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Key Vocabulary (Optional)',
                hintText: 'e.g., "innovative, user-centric"',
              ),
              onChanged: (val) => _vocabulary = val,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _samples.length >= 3 ? _trainVoice : null,
          child: Text('Train Brand Voice'),
        ),
      ],
    );
  }
}
```

**Voice Indicator:**
```dart
class BrandVoiceIndicator extends StatelessWidget {
  final BrandVoice? voice;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Brand Voice: "${voice?.name ?? 'Not Set'}"'),
          if (voice != null) ...[
            SizedBox(width: 4),
            Icon(Icons.check_circle, color: Colors.green, size: 16),
          ],
          SizedBox(width: 8),
          TextButton(
            onPressed: _changeVoice,
            child: Text('Change Voice'),
          ),
        ],
      ),
    );
  }
}
```

### State Management

**Using Provider/Riverpod:**
```dart
class BrandVoiceProvider extends ChangeNotifier {
  BrandVoice? _voice;
  bool _isTraining = false;
  double _trainingProgress = 0.0;
  
  Future<void> trainVoice({
    required List<String> samples,
    String? tone,
    String? vocabulary,
  }) async {
    _isTraining = true;
    _trainingProgress = 0.0;
    notifyListeners();
    
    try {
      final response = await apiService.post(
        '/brand-voice/train',
        {
          'samples': samples,
          'tone': tone,
          'vocabulary': vocabulary,
        },
      );
      
      _voice = BrandVoice.fromJson(response.data);
      _isTraining = false;
      _trainingProgress = 1.0;
      notifyListeners();
    } catch (e) {
      _isTraining = false;
      notifyListeners();
      rethrow;
    }
  }
  
  bool get hasVoice => _voice != null;
  String? get voiceName => _voice?.name;
}
```

### API Integration

**Backend Endpoint:**
```
POST /api/v1/brand-voice/train
{
  "samples": ["text1", "text2", "text3"],
  "tone": "Professional yet friendly",
  "vocabulary": "innovative, user-centric"
}

Response:
{
  "voice_profile": {...},
  "injection_prompt": "Write in this style...",
  "summary": {
    "tone": {"formality": 0.6, "humor": 0.3},
    "style": {"avg_sentence_length": 18.5},
    "vocabulary": ["innovative", "user-centric"]
  }
}
```

### Error Handling

**Strategies:**
1. **Sample Too Short:** "Sample must be at least 200 words (got 150)"
2. **Too Few Samples:** "Minimum 3 samples required for training"
3. **Training Timeout:** "Training is taking longer than expected. Please try again."
4. **Analysis Failure:** Show partial results, allow retry

**Implementation:**
```dart
try {
  await brandVoiceService.trainVoice(samples, tone, vocabulary);
} on ValidationException catch (e) {
  _showSnackbar(e.message);
} on TimeoutException {
  _showSnackbar('Training timed out. Please try again.');
} catch (e) {
  _showSnackbar('Unable to train brand voice. Please try again.');
  _logError('Brand voice training failed', e);
}
```

### Performance Optimization

**Caching:** Cache voice profile in memory to avoid repeated Firestore reads
**Lazy Loading:** Load voice summary only when settings page opened
**Sample Upload:** Stream upload for large files, show progress

### Testing Strategy

**Unit Tests:**
- Test sample validation (word count, format)
- Test voice profile JSON parsing
- Test injection prompt generation

**Widget Tests:**
- Test modal rendering
- Test sample upload UI
- Test voice indicator display

**Integration Tests:**
- Test full training flow
- Test voice application to content generation
- Test voice update/removal

---

## Summary

This UX specification provides implementation guidance for the **planned** Brand Voice Training system:
- 🔨 Backend schemas exist, API endpoints need to be created
- 🔨 Voice analysis service needs to be built
- 🔨 Content injection mechanism needs implementation
- 🎯 Train on 3-10 samples (200-2000 words each)
- 🎯 Extract vocabulary, tone, style, grammar patterns
- 🎯 Apply voice profile to all generated content
- 🎯 Support multiple voices (Pro: 3, Enterprise: unlimited)

**Key Differentiator:** At $29/mo, offer Jasper-level brand voice for 51-77% less than competitors ($59-125/mo).

**Next Steps:** Proceed to Milestone 5 (Video Scripts/Generation) upon user approval.
