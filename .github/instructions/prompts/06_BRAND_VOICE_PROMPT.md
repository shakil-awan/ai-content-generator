# 🎨 BRAND VOICE FEATURE - DEVELOPMENT PROMPT

**Copy this entire prompt into a new chat session with GitHub Copilot**

---

## 🚨 PREREQUISITES: BUILD CONTENT GENERATION PAGE FIRST!

**⚠️ CRITICAL: You MUST build the Content Generation Page BEFORE this feature!**

**Required:**
1. ✅ Complete Prompt `00_CONTENT_GENERATION_PAGE_PROMPT.md` first
2. ✅ Ensure `ContentGenerationFormPage` exists at `lib/features/content_generation/views/content_generation_form_page.dart`
3. ✅ Ensure Settings Page exists (from Auth setup)

**Why?** Brand Voice selector appears in the Content Generation Form (advanced options) and in Settings. You need those pages built first.

---

## TASK: Build Brand Voice Training System

I'm building the **Brand Voice Training Feature** for Summarly AI Content Generator (Flutter web app). This allows users to upload writing samples, train an AI on their unique style, and automatically apply it to all generated content.

### 📚 CONTEXT FILES TO READ FIRST:

**CRITICAL - Read these files before starting:**
1. `.github/instructions/FRONTEND_INSTRUCTIONS.md` - Complete development guide with custom widgets, theme, architecture patterns
2. `lib/core/theme/app_theme.dart` (281 lines) - All colors, spacing, border radius constants
3. `lib/core/constants/font_sizes.dart` (211 lines) - Typography system
4. `docs/features/04_brand_voice/BRAND_VOICE_UX_SPECS.md` (760 lines) - Complete UX specifications
5. `docs/features/04_brand_voice/04_BRAND_VOICE.md` (1723 lines) - Feature overview and implementation plan
6. `.github/instructions/prompts/00_CONTENT_GENERATION_PAGE_PROMPT.md` - Content Generation Page specs (MUST be built first)

---

## 🎯 IMPORTANT: Backend is NOT IMPLEMENTED

**Brand Voice is PLANNED but NOT BUILT:**
- ✅ Schemas exist: `BrandVoice`, `BrandVoiceTraining` in `backend/app/schemas/user.py`
- ✅ Firestore structure defined
- ❌ API endpoints NOT created (`POST /api/v1/brand-voice/train`)
- ❌ Voice analysis service NOT implemented
- ❌ Content injection NOT implemented

**You are building FULL FEATURE** - Frontend UI + prepare for backend integration (mock data for now).

---

## 🚨 RECOMMENDATION: SKIP THIS FEATURE FOR NOW

**Reason:** This is a **4-6 week backend implementation** that requires:
- Voice analysis service (400+ lines)
- Sample validation and processing
- Pattern extraction algorithms
- Voice profile generation
- Content injection into generation prompts
- API endpoints (300+ lines)

**Alternative Approach:**
1. **Build UI components** with mock data
2. **Disable the feature** for users (show "Coming Soon" badge)
3. **Wait for backend** to be implemented
4. **Integrate later** when backend is ready

**OR - If you want to proceed:**
Build the UI now, but mark feature as "Coming Soon" in production.

---

## 📋 COMPONENTS TO BUILD (9 Total)

### Component 1: Brand Voice Setup Card Widget
**Purpose:** Show brand voice status in Settings page

**Location in UI:** Settings Page → Brand Voice section

**Visual (Not Configured):**
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

**Visual (Configured):**
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

**Elements:**
- Title with emoji: "🎨 Brand Voice Training" (H2)
- Description: BodyText, gray-600
- Checkmarks: Green color
- Train button: PrimaryButton
- Status badge: Green checkmark for configured
- Action buttons: CustomTextButton for View/Update/Remove

---

### Component 2: Brand Voice Training Modal Widget
**Purpose:** Multi-step form to train brand voice

**Location in UI:** Modal dialog overlay

**Visual:**
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

**Elements:**
1. **Step 1 - Sample Upload**:
   - File upload zone or paste text area
   - List of uploaded samples with checkmarks
   - Word count display per sample (e.g., "523 words")
   - Validation: 3 minimum, 10 maximum, 200-2000 words each
   - Remove button per sample

2. **Step 2 - Tone Description** (Optional):
   - CustomTextField
   - Placeholder: "e.g., Professional yet friendly"
   - Helper text: "Describe how you want to sound"

3. **Step 3 - Vocabulary** (Optional):
   - CustomTextField
   - Placeholder: "e.g., innovative, user-centric"
   - Helper text: "Key words you frequently use"

4. **Voice Name** (Optional):
   - CustomTextField
   - Placeholder: "e.g., Company Blog Voice"
   - Default: "My Brand Voice"

5. **Action Buttons**:
   - Cancel: SecondaryButton
   - Train Brand Voice: PrimaryButton (disabled until 3+ samples)

**Validation:**
- Show error if sample < 200 words: "Sample too short (min 200 words)"
- Show error if sample > 2000 words: "Sample too long (max 2000 words)"
- Enable Train button only when 3+ valid samples

---

### Component 3: Sample Upload Card Widget
**Purpose:** Display uploaded sample with metadata

**Visual:**
```
┌──────────────────────────────────────────┐
│ 📄 Sample 1: Blog post excerpt...    ✓  │
│    523 words • Uploaded Nov 26, 2025     │
│    [View] [Remove]                       │
└──────────────────────────────────────────┘
```

**Elements:**
- Icon: Document emoji (📄)
- Title: First 50 characters of sample + "..." (BodyText)
- Status: Green checkmark if valid
- Metadata: Word count + upload date (CaptionText, gray-600)
- Actions: View (opens preview), Remove (deletes sample)

**States:**
- Valid: Green checkmark, green border
- Too short: Red warning, "Too short (min 200 words)"
- Too long: Yellow warning, "Too long (max 2000 words)"

---

### Component 4: Training Progress Indicator Widget
**Purpose:** Show voice analysis progress

**Location in UI:** Modal overlay replacing training modal

**Visual:**
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

**Steps:**
1. Validating samples... (5%)
2. Analyzing vocabulary... (35%)
3. Analyzing tone & style... (65%)
4. Building voice profile... (95%)
5. Complete! (100%)

**Elements:**
- Title: "Analyzing Your Writing Style" (H2) with emoji
- Progress bar: LinearProgressIndicator
- Percentage: BodyTextLarge next to bar
- Current step: BodyText
- Time estimate: "About 15 seconds" (CaptionText, gray-600)

---

### Component 5: Voice Profile Summary Widget
**Purpose:** Display analysis results after training

**Location in UI:** Modal after training completes

**Visual:**
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

**Elements:**
1. **Success Banner**:
   - Green checkmark icon
   - "Brand Voice Trained Successfully!" (H2, green-600)

2. **Tone Characteristics** (3 metrics):
   - Formality: Progress bar 0-100%
   - Humor: Progress bar 0-100%
   - Confidence: Progress bar 0-100%
   - Each with label + percentage

3. **Writing Style** (bullet points):
   - Avg sentence length
   - Contraction usage
   - Paragraph style

4. **Top Vocabulary** (tags):
   - Display top 6-8 words
   - Pill-shaped tags with gray background

5. **Action Buttons**:
   - Apply to All Content: PrimaryButton
   - Adjust Settings: SecondaryButton

---

### Component 6: Brand Voice Indicator Widget
**Purpose:** Show active voice in generation form

**Location in UI:** Content generation page, below content type

**Visual (Configured):**
```
┌──────────────────────────────────────────┐
│ Generate Blog Post                       │
│                                          │
│ Brand Voice: "Company Blog" ✓            │
│ [Change Voice]                           │
└──────────────────────────────────────────┘
```

**Visual (Not Configured):**
```
┌──────────────────────────────────────────┐
│ Generate Blog Post                       │
│                                          │
│ Brand Voice: Not configured              │
│ [Set Up Brand Voice] →                   │
└──────────────────────────────────────────┘
```

**Elements:**
- Label: "Brand Voice:" (BodyText)
- Voice name: BodyTextLarge with green checkmark (if configured)
- Change/Set Up button: CustomTextButton

---

### Component 7: Voice Metric Bar Widget
**Purpose:** Reusable progress bar for tone metrics

**Visual:**
```
Formality: ████████░░ Professional (60%)
```

**Props:**
- `label`: String (e.g., "Formality")
- `value`: double (0-1)
- `descriptor`: String (e.g., "Professional")

**Colors:**
- Progress bar: Blue-600
- Label: BodyText
- Descriptor: BodyTextSmall, gray-600
- Percentage: BodyTextSmall, bold

---

### Component 8: Vocabulary Tag Widget
**Purpose:** Display vocabulary words as tags

**Visual:**
```
[innovative] [user-centric] [solution]
```

**Specs:**
- Pill-shaped with gray-100 background
- Gray-700 text
- 8px padding vertical, 12px horizontal
- 16px border radius
- Gap(8) between tags

---

### Component 9: Multiple Voice Management Widget (Future)
**Purpose:** Manage multiple brand voices (Pro/Enterprise only)

**Visual:**
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

**Elements:**
- Voice list with radio buttons
- Active voice highlighted
- Action buttons per voice
- Add New Voice button with tier limits

---

## 🎯 MANDATORY REQUIREMENTS:

### Custom Widgets (NEVER use standard Flutter widgets):
- ✅ **Text**: H1, H2, H3, DisplayText, BodyText, BodyTextLarge, BodyTextSmall, CaptionText (NEVER Text())
- ✅ **Buttons**: PrimaryButton, SecondaryButton, CustomTextButton (NEVER ElevatedButton/OutlinedButton())
- ✅ **Input**: CustomTextField, CustomTextFormField (NEVER TextField())
- ✅ **Spacing**: Gap(8), Gap(12), Gap(16), Gap(24) (NEVER SizedBox())
- ✅ **Loading**: AdaptiveLoading, SmallLoader

### Theme Constants (NEVER hardcode):
- ✅ **Colors**: 
  - Success: AppTheme.success or Color(0xFF059669) [Green-600]
  - Primary: AppTheme.primary [Blue-600]
  - Warning: AppTheme.warning [Yellow-600]
  - Text: AppTheme.textPrimary, AppTheme.textSecondary
  - Background: AppTheme.bgPrimary, AppTheme.bgSecondary
  - Border: AppTheme.border
  
- ✅ **Spacing**: AppTheme.spacing8/12/16/24/32
- ✅ **Border Radius**: AppTheme.borderRadiusSM/MD/LG
- ✅ **Fonts**: FontSizes.h2/h3/bodyRegular/bodyLarge/bodySmall/captionRegular

### Architecture:
- ✅ **800-line limit per file**
- ✅ **Folder structure**:
  ```
  features/brand_voice/
  ├── models/
  │   ├── brand_voice.dart (~100 lines)
  │   ├── voice_sample.dart (~80 lines)
  │   └── voice_profile.dart (~150 lines)
  ├── controllers/
  │   └── brand_voice_controller.dart (~300 lines)
  ├── widgets/
  │   ├── brand_voice_setup_card.dart (~200 lines)
  │   ├── brand_voice_training_modal.dart (~350 lines)
  │   ├── sample_upload_card.dart (~120 lines)
  │   ├── training_progress_indicator.dart (~120 lines)
  │   ├── voice_profile_summary.dart (~250 lines)
  │   ├── brand_voice_indicator.dart (~100 lines)
  │   ├── voice_metric_bar.dart (~80 lines)
  │   ├── vocabulary_tag.dart (~50 lines)
  │   └── voice_management_list.dart (~200 lines)
  └── services/
      └── brand_voice_service.dart (~200 lines) - Mock for now
  ```

### Data Models:
```dart
class BrandVoice {
  final bool isConfigured;
  final String? name;
  final String? tone;
  final String? vocabulary;
  final List<String> samples;
  final VoiceProfile? profile;
  final DateTime? trainedAt;
  
  factory BrandVoice.fromJson(Map<String, dynamic> json) { ... }
}

class VoiceSample {
  final String id;
  final String text;
  final int wordCount;
  final DateTime uploadedAt;
  final bool isValid;
  
  bool get isTooShort => wordCount < 200;
  bool get isTooLong => wordCount > 2000;
  String get validationMessage {
    if (isTooShort) return 'Too short (min 200 words)';
    if (isTooLong) return 'Too long (max 2000 words)';
    return 'Valid';
  }
}

class VoiceProfile {
  final ToneCharacteristics tone;
  final WritingStyle style;
  final List<String> topVocabulary;
  
  factory VoiceProfile.fromJson(Map<String, dynamic> json) { ... }
}

class ToneCharacteristics {
  final double formality; // 0-1
  final double humor; // 0-1
  final double confidence; // 0-1
  
  String get formalityLabel {
    if (formality >= 0.7) return 'Very Professional';
    if (formality >= 0.5) return 'Professional';
    if (formality >= 0.3) return 'Casual';
    return 'Very Casual';
  }
}
```

### State Management with GetX:
```dart
class BrandVoiceController extends GetxController {
  final brandVoice = Rxn<BrandVoice>();
  final samples = <VoiceSample>[].obs;
  final isTraining = false.obs;
  final trainingProgress = 0.0.obs;
  final trainingStep = ''.obs;
  final errorMessage = ''.obs;
  
  // Form fields
  final toneDescription = ''.obs;
  final vocabularyKeywords = ''.obs;
  final voiceName = 'My Brand Voice'.obs;
  
  // Computed
  bool get canTrain => samples.length >= 3 && 
                       samples.every((s) => s.isValid);
  bool get isConfigured => brandVoice.value?.isConfigured ?? false;
  
  // Methods
  void addSample(String text) { ... }
  void removeSample(String id) { ... }
  Future<void> trainVoice() async { ... }
  Future<void> loadBrandVoice() async { ... }
  Future<void> deleteBrandVoice() async { ... }
}
```

### API Integration (Mock for Now):
```dart
// brand_voice_service.dart
class BrandVoiceService {
  // TODO: Replace with real API when backend is ready
  Future<VoiceProfile> trainVoice({
    required List<String> samples,
    String? tone,
    String? vocabulary,
  }) async {
    // Simulate API delay
    await Future.delayed(Duration(seconds: 15));
    
    // Return mock profile
    return VoiceProfile(
      tone: ToneCharacteristics(
        formality: 0.6,
        humor: 0.3,
        confidence: 0.8,
      ),
      style: WritingStyle(
        avgSentenceLength: 18,
        contractionRate: 0.4,
        paragraphStyle: 'medium',
      ),
      topVocabulary: [
        'innovative', 'user-centric', 'solution',
        'cutting-edge', 'seamless', 'transform'
      ],
    );
  }
}
```

---

## 📊 IMPLEMENTATION STEPS:

1. **Read Context Files** (10 min)
2. **Create Folder Structure** (2 min)
3. **Create Data Models** (30 min) - BrandVoice, VoiceSample, VoiceProfile, ToneCharacteristics
4. **Create Controller** (35 min) - BrandVoiceController with mock data
5. **Create Service** (20 min) - Mock service returning fake data
6. **Create Widgets** (150 min):
   - brand_voice_setup_card.dart (25 min)
   - brand_voice_training_modal.dart (40 min)
   - sample_upload_card.dart (15 min)
   - training_progress_indicator.dart (15 min)
   - voice_profile_summary.dart (30 min)
   - brand_voice_indicator.dart (12 min)
   - voice_metric_bar.dart (8 min)
   - vocabulary_tag.dart (5 min)
   - voice_management_list.dart (20 min)
7. **Create Progress File** (5 min)
8. **Test with Mock Data** (25 min)

---

## ✅ SUCCESS CRITERIA:

Brand Voice UI is complete when:
- [ ] All 9 widgets implemented
- [ ] All files under 800 lines
- [ ] Only custom widgets used
- [ ] Only AppTheme constants used
- [ ] Data models complete with validation
- [ ] Controller with mock data works
- [ ] Service returns mock profiles
- [ ] Sample upload shows validation
- [ ] Training progress animates
- [ ] Profile summary displays metrics
- [ ] Voice indicator shows status
- [ ] Multiple voices UI ready (even if disabled)
- [ ] Responsive on all breakpoints
- [ ] Feature marked as "Coming Soon" in production
- [ ] Code follows FRONTEND_INSTRUCTIONS.md

---

## 🔗 INTEGRATION NOTES (Future):

**When backend is ready:**
1. Replace mock service with real API calls
2. Enable feature in production
3. Add to Settings page
4. Add to content generation forms
5. Update pricing page to highlight feature

---

## 📝 NOTES:

- **Backend NOT implemented** - This is UI-only with mock data
- **4-6 week backend effort** required for full feature
- Mark as **"Coming Soon"** badge in production
- Jasper charges $59-125/mo for this ($29/mo = 51-77% cheaper)
- Copy.ai offers unlimited voices ($49-99/mo)
- **Major competitive advantage** when implemented
- Free tier: No brand voice
- Hobby tier: 1 voice
- Pro tier: 3 voices
- Enterprise: Unlimited

---

**START NOW:** Read docs, create folder structure, build UI with mock data, mark as "Coming Soon" in production.
