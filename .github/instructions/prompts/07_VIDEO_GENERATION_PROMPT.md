# 🎬 VIDEO GENERATION FEATURE - DEVELOPMENT PROMPT

**Copy this entire prompt into a new chat session with GitHub Copilot**

---

## 🚨 PREREQUISITES: BUILD CONTENT GENERATION PAGE FIRST!

**⚠️ CRITICAL: You MUST build the Content Generation Page BEFORE this feature!**

**Required:**
1. ✅ Complete Prompt `00_CONTENT_GENERATION_PAGE_PROMPT.md` first
2. ✅ Ensure Content Type tabs/selector exists in Content Generation Form
3. ✅ Ensure `ContentResultsPage` exists for displaying video scripts

**Why?** Video Script is a CONTENT TYPE (like Blog, Social, Email). It integrates INTO the Content Generation Page as a tab/option, NOT a separate page.

---

## TASK: Build Video Script + Automated Video Generation

I'm building the **Video Generation Feature** for Summarly AI Content Generator (Flutter web app). This feature has **TWO PARTS**:

1. **Video Script Generation** (✅ BACKEND COMPLETE) - Just needs UI
2. **Automated Video Creation** (❌ BACKEND NOT IMPLEMENTED) - Full pipeline needs building

### 📚 CONTEXT FILES TO READ FIRST:

**CRITICAL - Read these files before starting:**
1. `.github/instructions/FRONTEND_INSTRUCTIONS.md` - Complete development guide with custom widgets, theme, architecture patterns
2. `lib/core/theme/app_theme.dart` (281 lines) - All colors, spacing, border radius constants
3. `lib/core/constants/font_sizes.dart` (211 lines) - Typography system
4. `docs/features/06_video_generation/VIDEO_GENERATION_UX_SPECS.md` (954 lines) - Complete UX specifications
5. `docs/features/06_video_generation/05_VIDEO_SCRIPTS.md` (3213 lines) - Feature overview and backend API specs
6. `docs/features/06_video_generation/VIDEO_GENERATION_EXECUTIVE_SUMMARY.md` (245 lines) - Business case and ROI
7. `.github/instructions/prompts/00_CONTENT_GENERATION_PAGE_PROMPT.md` - Content Generation Page specs (MUST be built first)

---

## 🎯 IMPORTANT: Implementation Status

### Part 1: Video Script Generation (✅ FULLY IMPLEMENTED)

**Backend Status:**
- ✅ Endpoint: `POST /api/v1/generate/video-script`
- ✅ 4 platforms: YouTube, TikTok, Instagram, LinkedIn
- ✅ Duration: 15-600 seconds (15s to 10 minutes)
- ✅ Retention-optimized hooks (first 5 seconds)
- ✅ Timestamped sections with visual cues
- ✅ CTA integration, thumbnail suggestions (3 options)
- ✅ Hashtag recommendations (15-20 tags)
- ✅ Music mood suggestions
- ✅ Performance: 12.4s avg time, 96.3% success rate, 8.8/10 quality

**You are building:** Complete pixel-perfect UI with mock data. API integration will be added later.

---

### Part 2: Automated Video Generation (🔜 COMING SOON)

**Backend Status:**
- 🔜 API endpoints will be created later (`POST /api/v1/generate/video-automated`)
- 🔜 Pictory.ai integration planned
- 🔜 ElevenLabs voiceover planned
- 🔜 Video composition planned
- 🔜 Estimated 4-6 weeks for backend implementation

**You are building:** Complete pixel-perfect UI with mock data. Backend integration later.

---

## 🎨 APPROACH: BUILD PERFECT UI WITH MOCK DATA

**Strategy:**
1. **Build complete UI** for both video scripts AND automated videos
2. **Use mock data** for all functionality (no API calls yet)
3. **Perfect pixel-perfect design** following design system
4. **API integration comes later** when backend is ready

**Why this approach:**
- ✅ Frontend team can work independently
- ✅ UI/UX can be perfected without backend delays
- ✅ Easy to integrate real API later (just swap mock service)
- ✅ Faster development and iteration
- ✅ Design review can happen immediately

**Mock Data Strategy:**
- Create realistic mock responses matching backend schema
- Simulate loading states (2-3 seconds delay)
- Simulate success/error states
- Store mock data in controller or service file

---

## 📍 WHERE DOES THIS APPEAR IN THE APP?

**CRITICAL ARCHITECTURE DECISION:**

Video Generation is **NOT a separate screen**. It's integrated into the **unified Content Generation Page**.

### Location Hierarchy:
```
App Navigation:
├── Landing Page
├── Auth Pages (Sign In / Sign Up)
├── Dashboard
├── Content Generation Page  ← VIDEO IS HERE
│   └── Content Type Selector:
│       ├── Blog Post
│       ├── Social Media
│       ├── Email Campaign
│       ├── Product Description
│       ├── Ad Copy
│       └── Video Script  ← THIS TAB/SECTION
│           ├── Platform: [YouTube ▼]
│           ├── Duration: [3 min ▼]
│           ├── Target Audience: [...]
│           ├── Output Type:
│           │   ⚪ Script Only (12 sec) ← DEFAULT, WORKING
│           │   ⚪ Script + Video (1.5 min, $0.43) ← FUTURE
│           └── [Generate Script/Video]
├── My Videos (Future)  ← NEW page for video library
├── Settings
└── Billing
```

**Implementation Strategy:**

1. **Content Generation Page** already exists (or will be built for blog/social/email)
2. Add **"Video Script" tab/section** to content type selector
3. Show video-specific form fields (platform, duration, etc.)
4. Add **"Output Type" radio buttons** (Script Only vs Script + Video)
5. When "Script Only" selected → Call existing backend endpoint
6. When "Script + Video" selected → Show "Coming Soon" or call future endpoint

---

## 📋 COMPONENTS TO BUILD

### ALL COMPONENTS TO BUILD (13 Total - Build Everything with Mock Data)

#### Component 1: Video Script Generation Form
**Purpose:** Form for generating video scripts (part of Content Generation page)

**Location in UI:** Content Generation Page → Video Script tab

**Visual:**
```
┌──────────────────────────────────────────────┐
│ Generate Video Script                     🎬 │
├──────────────────────────────────────────────┤
│ Topic                                        │
│ ┌──────────────────────────────────────────┐│
│ │ 5 AI Tools for Content Creators          ││
│ └──────────────────────────────────────────┘│
│                                              │
│ Platform                  Duration           │
│ [YouTube      ▼]         [3 minutes    ▼]   │
│                                              │
│ Target Audience (Optional)                   │
│ ┌──────────────────────────────────────────┐│
│ │ Content creators aged 25-35              ││
│ └──────────────────────────────────────────┘│
│                                              │
│ Key Points (Optional)                        │
│ ┌──────────────────────────────────────────┐│
│ │ ChatGPT, Midjourney, Descript            ││
│ └──────────────────────────────────────────┘│
│                                              │
│ Call to Action (Optional)                    │
│ ┌──────────────────────────────────────────┐│
│ │ Try our AI platform today                ││
│ └──────────────────────────────────────────┘│
│                                              │
│ Tone                                         │
│ [Casual        ▼]                            │
│                                              │
│ ☑ Include retention hooks                   │
│ ☑ Include call-to-action                    │
│                                              │
│ [Generate Script] 🎬                         │
│ ~12 seconds | 1 credit                       │
└──────────────────────────────────────────────┘
```

**Elements:**
- **Topic:** CustomTextField (required, 3-200 chars)
- **Platform:** Dropdown (YouTube, TikTok, Instagram, LinkedIn)
- **Duration:** Dropdown (15s, 30s, 60s, 90s, 2min, 3min, 5min, 10min)
- **Target Audience:** CustomTextField (optional, 5-200 chars)
- **Key Points:** CustomTextField (optional, comma-separated)
- **CTA:** CustomTextField (optional, max 200 chars)
- **Tone:** Dropdown (Professional, Casual, Friendly, Formal)
- **Include Hooks:** Checkbox (default: true)
- **Include CTA:** Checkbox (default: true)
- **Generate Button:** PrimaryButton

**Duration Mapping:**
- 15 seconds → 15
- 30 seconds → 30
- 1 minute → 60
- 1.5 minutes → 90
- 2 minutes → 120
- 3 minutes → 180
- 5 minutes → 300
- 10 minutes → 600

**Validation:**
- Topic required (min 3 chars)
- Platform required
- Duration required

---

#### Component 2: Video Script Results Display Widget
**Purpose:** Display generated video script with all metadata

**Location in UI:** Content Generation Results page (after generation)

**Visual:**
```
┌────────────────────────────────────────────────┐
│ ✅ Video Script Generated Successfully!        │
├────────────────────────────────────────────────┤
│                                                │
│ 📹 5 AI Tools for Content Creators            │
│ YouTube • 3:00 min • Casual                    │
│                                                │
│ 🎯 Hook (0:00-0:05)                            │
│ ┌──────────────────────────────────────────┐  │
│ │ "Did you know AI can 10x your content    │  │
│ │ creation speed? Here are 5 game-changing │  │
│ │ tools you need to try today!"            │  │
│ │                                          │  │
│ │ Visual Cue: Fast-paced montage of AI     │  │
│ │ tools in action                          │  │
│ └──────────────────────────────────────────┘  │
│                                                │
│ 📝 Script Sections (9 timestamps)              │
│ ┌──────────────────────────────────────────┐  │
│ │ 0:05-0:20 - Introduction                 │  │
│ │ Welcome to the AI revolution...          │  │
│ │ Visual: Presenter speaking to camera     │  │
│ │                                          │  │
│ │ 0:20-0:45 - Tool 1: ChatGPT              │  │
│ │ First up is ChatGPT...                   │  │
│ │ Visual: ChatGPT interface demo           │  │
│ │                                          │  │
│ │ [Show All 9 Sections] ▼                  │  │
│ └──────────────────────────────────────────┘  │
│                                                │
│ 📢 Call to Action                              │
│ ┌──────────────────────────────────────────┐  │
│ │ "Ready to transform your workflow?        │  │
│ │ Try our AI platform today!"              │  │
│ └──────────────────────────────────────────┘  │
│                                                │
│ 🎨 Thumbnail Options (3)                       │
│ ○ "5 AI Tools That Will Change Your Life"     │
│ ○ "Stop Wasting Time: Use These AI Tools Now" │
│ ○ "The Ultimate AI Content Creator Toolkit"   │
│                                                │
│ #️⃣ Hashtags (18)                               │
│ #AI #ContentCreation #Productivity             │
│ #ChatGPT #Midjourney #AITools #YouTube         │
│ [Show All 18] ▼                                │
│                                                │
│ 🎵 Music Mood: Upbeat Energetic                │
│                                                │
│ 📊 Estimated Retention: 68%                    │
│ Strong hook, clear value proposition           │
│                                                │
│ [Copy Script] [Download .txt] [Generate Video]│
└────────────────────────────────────────────────┘
```

**Elements:**
1. **Title Section:**
   - Video title (H2)
   - Metadata: Platform, Duration, Tone (CaptionText, gray-600)

2. **Hook Section:**
   - "🎯 Hook (0:00-0:05)" label (BodyTextLarge)
   - Hook text in bordered box (gray-200 border, 12px padding)
   - Visual cue in italic (gray-600)

3. **Script Sections:**
   - Expandable list (show first 2, collapse rest)
   - Each section: timestamp, heading, content, visual cue
   - "Show All X Sections" button to expand

4. **CTA Section:**
   - "📢 Call to Action" label
   - CTA text in bordered box

5. **Thumbnail Options:**
   - Radio buttons with 3 title options
   - BodyText for each option

6. **Hashtags:**
   - Pill-shaped tags (gray-100 background)
   - Show first 8, collapse rest
   - "Show All X" to expand

7. **Music Mood:**
   - Label + value (e.g., "Upbeat Energetic")

8. **Estimated Retention:**
   - Percentage + reasoning (e.g., "68% - Strong hook, clear value")

9. **Action Buttons:**
   - Copy Script: SecondaryButton
   - Download .txt: SecondaryButton
   - Generate Video: PrimaryButton (disabled with "Coming Soon" tooltip)

---

#### Component 3: Script Section Card Widget
**Purpose:** Display individual script section with timestamp

**Visual:**
```
┌──────────────────────────────────────────┐
│ 0:20-0:45 - Tool 1: ChatGPT              │
│                                          │
│ First up is ChatGPT, the revolutionary  │
│ AI writing assistant that can help you  │
│ draft content in seconds...             │
│                                          │
│ Visual: ChatGPT interface demo with      │
│ typing animation                         │
└──────────────────────────────────────────┘
```

**Elements:**
- Timestamp + heading (BodyTextLarge, bold)
- Content text (BodyText)
- Visual cue (BodyTextSmall, italic, gray-600)
- Border: gray-200, 12px padding, 8px radius

---

#### Component 4: Platform Selector Dropdown Widget
**Purpose:** Select video platform (YouTube, TikTok, etc.)

**Visual:**
```
Platform
[YouTube                          ▼]

Dropdown options:
• YouTube (3-10 min recommended)
• TikTok (15-60 sec recommended)
• Instagram Reels (15-90 sec recommended)
• LinkedIn (1-3 min recommended)
```

**Elements:**
- Label: "Platform" (BodyText)
- Dropdown: CustomDropdown (or DropdownButtonFormField)
- Helper text shows recommended durations
- Icons: 🎬 YouTube, 🎵 TikTok, 📸 Instagram, 💼 LinkedIn

---

#### Component 5: Duration Selector Dropdown Widget
**Purpose:** Select video duration

**Visual:**
```
Duration
[3 minutes                        ▼]

Dropdown options:
• 15 seconds (TikTok, Reels)
• 30 seconds (Short-form)
• 1 minute
• 1.5 minutes
• 2 minutes
• 3 minutes (Most popular)
• 5 minutes
• 10 minutes (Long-form)
```

**Elements:**
- Label: "Duration" (BodyText)
- Dropdown with 8 duration options
- Smart defaults based on selected platform:
  - YouTube → 3 minutes
  - TikTok → 30 seconds
  - Instagram → 60 seconds
  - LinkedIn → 2 minutes

---

#### Component 6: Thumbnail Options Widget
**Purpose:** Display 3 AI-generated thumbnail title options

**Visual:**
```
🎨 Thumbnail Options (3)
○ "5 AI Tools That Will Change Your Life"
○ "Stop Wasting Time: Use These AI Tools Now"
○ "The Ultimate AI Content Creator Toolkit"

[Copy Selected]
```

**Elements:**
- Radio buttons (allow single selection)
- 3 title options from backend
- Copy button to copy selected title
- BodyText for each option

---

#### Component 7: Hashtag Tags Widget
**Purpose:** Display hashtags as pill-shaped tags

**Visual:**
```
#️⃣ Hashtags (18)

[#AI] [#ContentCreation] [#Productivity] [#ChatGPT]
[#Midjourney] [#AITools] [#YouTube] [#VideoMarketing]

[Show All 18 Hashtags] ▼
```

**Elements:**
- Pill-shaped tags (gray-100 background, gray-700 text)
- Show first 8 tags, collapse rest
- "Show All X" button to expand
- Click to copy individual hashtag
- 8px padding, 16px border radius, Gap(8) between tags

---

#### Component 8: Video Output Type Selector Widget
**Purpose:** Toggle between Script Only vs Script + Video

**Visual:**
```
Output Type:
⚪ Script Only (12 seconds, free)
⚫ Script + Video (1.5 minutes, $0.43)

Voiceover: [Professional Male (Josh)    ▼]
Music Mood: [Upbeat Energetic          ▼]

[Generate Video] 🎬
Cost: $0.43 | Time: ~1.5 min | 10 left/mo
```

**Elements:**
- Radio buttons (Script Only vs Script + Video)
- Conditional fields (show only when Script + Video selected):
  - Voiceover dropdown (4 options)
  - Music Mood dropdown (4 options)
- Cost/time/quota display
- Generate button changes text based on selection

---

#### Component 9: Video Progress Modal Widget
**Purpose:** Show video generation progress

**Visual:**
```
┌────────────────────────────────────────────┐
│ 🎬 Creating Your Video                     │
│ Estimated time: 1 minute 37 seconds        │
├────────────────────────────────────────────┤
│                                            │
│ Progress: 65%                              │
│ ████████████████████░░░░░░░░░░░░░░░░░░    │
│                                            │
│ Current Step: Composing video              │
│                                            │
│ ✓ Generated script (12 seconds)            │
│ ✓ Created voiceover (15 seconds)           │
│ ⏳ Composing video with stock footage...   │
│ ⏸ Uploading to storage                     │
│                                            │
│ [Cancel Generation]                        │
│ You can leave this page - we'll email you  │
│ when it's ready                            │
└────────────────────────────────────────────┘
```

**Elements:**
- Title: "🎬 Creating Your Video" (H2)
- Estimated time (CaptionText)
- Progress percentage (BodyTextLarge, bold)
- LinearProgressIndicator (blue-600)
- Current step label (BodyText)
- 4 step checkmarks:
  1. ✓ Generated script
  2. ✓ Created voiceover
  3. ⏳ Composing video (current)
  4. ⏸ Uploading to storage
- Cancel button (SecondaryButton)
- Info text (CaptionText, gray-600)

---

#### Component 10: Video Player Widget
**Purpose:** Play generated video inline

**Visual:**
```
┌────────────────────────────────────────┐
│                                        │
│          [VIDEO PLAYER]                │
│        ▶  0:00 / 3:00                 │
│                                        │
└────────────────────────────────────────┘

Title: 5 AI Tools for Content Creators
Duration: 3:00 | Size: 45MB | Quality: 1080p

[⬇ Download MP4] [📋 Copy Link] [🔗 Share]
```

**Elements:**
- Video player (16:9 aspect ratio)
- Playback controls
- Video metadata (title, duration, size, quality)
- Action buttons (Download, Copy Link, Share)

---

#### Component 11: Voice Preview Selector Widget
**Purpose:** Select voiceover voice with preview

**Visual:**
```
Voiceover
┌────────────────────────────────────────┐
│ ⚫ Professional Male (Josh)            │
│    ▶ Play Sample                      │
│                                        │
│ ⚪ Professional Female (Rachel)        │
│    ▶ Play Sample                      │
│                                        │
│ ⚪ British Male (Antoni)               │
│    ▶ Play Sample                      │
│                                        │
│ ⚪ American Female (Bella)             │
│    ▶ Play Sample                      │
└────────────────────────────────────────┘
```

**Elements:**
- Radio list with 4 voice options
- Play Sample button per voice
- Audio preview on click

---

#### Component 12: My Videos Library Page
**Purpose:** Video library with thumbnails and management

**Visual:**
```
┌────────────────────────────────────────────┐
│ 📹 My Videos                  [+ New Video]│
├────────────────────────────────────────────┤
│                                            │
│ Filter: [All ▼]  Sort: [Newest ▼]         │
│                                            │
│ ┌──────────────────────────────────────┐  │
│ │ [Thumbnail] 5 AI Tools for Content...│  │
│ │ 3:00 min | YouTube | Nov 26, 2025   │  │
│ │ [▶ Play] [⬇ Download] [🗑 Delete]   │  │
│ └──────────────────────────────────────┘  │
│                                            │
│ ┌──────────────────────────────────────┐  │
│ │ [Thumbnail] Productivity Tips for... │  │
│ │ 1:30 min | TikTok | Nov 25, 2025    │  │
│ │ [▶ Play] [⬇ Download] [🗑 Delete]   │  │
│ └──────────────────────────────────────┘  │
│                                            │
│ Storage Used: 145MB / 1GB (Free tier)      │
│ Videos Remaining: 8 / 10 this month        │
│                                            │
│ [Upgrade to Pro for Unlimited Videos]     │
└────────────────────────────────────────────┘
```

**Elements:**
- Page title with "+ New Video" button
- Filter and sort dropdowns
- Video card grid (2 columns on desktop, 1 on mobile)
- Each card: thumbnail, title, metadata, action buttons
- Storage quota display
- Upgrade prompt

---

#### Component 13: Video Quota Display Widget
**Purpose:** Show video generation quota

**Visual:**
```
Video Generation Quota
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
2 of 10 videos used this month

Resets on Dec 1, 2025
```

**Elements:**
- Label: "Video Generation Quota" (BodyText)
- Progress bar (blue-600)
- Usage text: "X of Y videos used" (BodyTextSmall)
- Reset date (CaptionText, gray-600)

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
  features/video_generation/
  ├── models/
  │   ├── video_script_request.dart (~100 lines)
  │   ├── video_script_response.dart (~200 lines)
  │   ├── script_section.dart (~80 lines)
  │   ├── video_metadata.dart (~60 lines)
  │   ├── video_generation_request.dart (~120 lines)
  │   ├── video_generation_response.dart (~150 lines)
  │   └── generated_video.dart (~100 lines)
  ├── controllers/
  │   ├── video_script_controller.dart (~350 lines)
  │   └── video_generation_controller.dart (~400 lines)
  ├── widgets/
  │   ├── video_script_generation_form.dart (~350 lines)
  │   ├── video_script_results_display.dart (~400 lines)
  │   ├── script_section_card.dart (~120 lines)
  │   ├── platform_selector_dropdown.dart (~150 lines)
  │   ├── duration_selector_dropdown.dart (~120 lines)
  │   ├── thumbnail_options_widget.dart (~100 lines)
  │   ├── hashtag_tags_widget.dart (~120 lines)
  │   ├── video_output_type_selector.dart (~200 lines)
  │   ├── video_progress_modal.dart (~250 lines)
  │   ├── video_player_widget.dart (~300 lines)
  │   ├── voice_preview_selector.dart (~200 lines)
  │   ├── video_quota_display.dart (~100 lines)
  │   └── my_videos_library_page.dart (~500 lines)
  └── services/
      ├── video_script_service.dart (~150 lines) - Mock data
      └── video_generation_service.dart (~200 lines) - Mock data
  ```

### Data Models:

```dart
class VideoScriptRequest {
  final String topic;
  final String platform; // youtube, tiktok, instagram, linkedin
  final int duration; // seconds (15-600)
  final String? targetAudience;
  final List<String>? keyPoints;
  final String? cta;
  final String tone; // professional, casual, friendly, formal
  final bool includeHooks;
  final bool includeCta;
  
  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'platform': platform,
      'duration': duration,
      'target_audience': targetAudience,
      'key_points': keyPoints,
      'cta': cta,
      'tone': tone,
      'include_hooks': includeHooks,
      'include_cta': includeCta,
    };
  }
}

class VideoScriptResponse {
  final String hook;
  final List<ScriptSection> script;
  final String ctaScript;
  final List<String> thumbnailTitles;
  final String description;
  final List<String> hashtags;
  final String musicMood;
  final String estimatedRetention;
  
  factory VideoScriptResponse.fromJson(Map<String, dynamic> json) {
    // Parse nested JSON from backend
    final output = json['output'] is String 
        ? jsonDecode(json['output']) 
        : json['output'];
    
    return VideoScriptResponse(
      hook: output['hook'] ?? '',
      script: (output['script'] as List?)
          ?.map((s) => ScriptSection.fromJson(s))
          .toList() ?? [],
      ctaScript: output['ctaScript'] ?? output['cta_script'] ?? '',
      thumbnailTitles: List<String>.from(output['thumbnailTitles'] ?? 
                                         output['thumbnail_titles'] ?? []),
      description: output['description'] ?? '',
      hashtags: List<String>.from(output['hashtags'] ?? []),
      musicMood: output['musicMood'] ?? output['music_mood'] ?? '',
      estimatedRetention: output['estimatedRetention'] ?? 
                         output['estimated_retention'] ?? '',
    );
  }
}

class ScriptSection {
  final String timestamp;
  final String content;
  final String visualCue;
  
  factory ScriptSection.fromJson(Map<String, dynamic> json) {
    return ScriptSection(
      timestamp: json['timestamp'] ?? '',
      content: json['content'] ?? '',
      visualCue: json['visualCue'] ?? json['visual_cue'] ?? '',
    );
  }
  
  String get heading {
    // Extract heading from content (first line or timestamp description)
    return timestamp.split(' - ').length > 1 
        ? timestamp.split(' - ')[1] 
        : 'Section';
  }
}

class VideoMetadata {
  final String platform;
  final int durationSeconds;
  final String tone;
  
  String get durationFormatted {
    if (durationSeconds < 60) return '${durationSeconds}s';
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
  }
  
  String get platformEmoji {
    switch (platform.toLowerCase()) {
      case 'youtube': return '🎬';
      case 'tiktok': return '🎵';
      case 'instagram': return '📸';
      case 'linkedin': return '💼';
      default: return '📹';
    }
  }
}
```

### State Management with GetX:

```dart
class VideoScriptController extends GetxController {
  final videoScriptResponse = Rxn<VideoScriptResponse>();
  final isGenerating = false.obs;
  final errorMessage = ''.obs;
  final expandedSections = false.obs;
  final expandedHashtags = false.obs;
  final selectedThumbnailIndex = 0.obs;
  
  // Form fields
  final topic = ''.obs;
  final platform = 'youtube'.obs;
  final duration = 180.obs; // 3 minutes default
  final targetAudience = ''.obs;
  final keyPoints = ''.obs;
  final cta = ''.obs;
  final tone = 'casual'.obs;
  final includeHooks = true.obs;
  final includeCta = true.obs;
  
  // Computed
  bool get canGenerate => topic.value.length >= 3;
  String get selectedThumbnail => 
      videoScriptResponse.value?.thumbnailTitles[selectedThumbnailIndex.value] ?? '';
  
  // Duration helpers
  String get durationLabel {
    final sec = duration.value;
    if (sec < 60) return '${sec} seconds';
    final min = sec ~/ 60;
    return '$min minute${min > 1 ? 's' : ''}';
  }
  
  List<int> get recommendedDurations {
    switch (platform.value) {
      case 'tiktok': return [15, 30, 60];
      case 'instagram': return [15, 30, 60, 90];
      case 'linkedin': return [60, 120, 180];
      case 'youtube': return [180, 300, 600];
      default: return [180];
    }
  }
  
  // Methods
  Future<void> generateScript() async {
    if (!canGenerate) return;
    
    isGenerating.value = true;
    errorMessage.value = '';
    
    try {
      final request = VideoScriptRequest(
        topic: topic.value,
        platform: platform.value,
        duration: duration.value,
        targetAudience: targetAudience.value.isEmpty ? null : targetAudience.value,
        keyPoints: keyPoints.value.isEmpty ? null : keyPoints.value.split(',').map((e) => e.trim()).toList(),
        cta: cta.value.isEmpty ? null : cta.value,
        tone: tone.value,
        includeHooks: includeHooks.value,
        includeCta: includeCta.value,
      );
      
      final response = await VideoScriptService().generateScript(request);
      videoScriptResponse.value = response;
      
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isGenerating.value = false;
    }
  }
  
  void copyScript() {
    // Copy full script to clipboard
    final script = videoScriptResponse.value;
    if (script == null) return;
    
    final text = '''
${script.hook}

${script.script.map((s) => '${s.timestamp}\n${s.content}\n${s.visualCue}').join('\n\n')}

${script.ctaScript}
    ''';
    
    // Use Clipboard.setData(ClipboardData(text: text))
  }
  
  void copyHashtags() {
    final hashtags = videoScriptResponse.value?.hashtags ?? [];
    final text = hashtags.join(' ');
    // Use Clipboard.setData(ClipboardData(text: text))
  }
  
  void toggleSections() {
    expandedSections.value = !expandedSections.value;
  }
  
  void toggleHashtags() {
    expandedHashtags.value = !expandedHashtags.value;
  }
}
```

### Mock Service Implementation:

```dart
// video_script_service.dart
class VideoScriptService {
  // TODO: Replace with real API when backend is ready
  // final ApiService _api = Get.find<ApiService>();
  
  Future<VideoScriptResponse> generateScript(VideoScriptRequest request) async {
    // Simulate API delay
    await Future.delayed(Duration(seconds: 2));
    
    // Return mock data
    return VideoScriptResponse.fromJson({
      'output': {
        'hook': 'Did you know ${request.topic} can transform your workflow? Here\'s everything you need to know!',
        'script': [
          {
            'timestamp': '0:00-0:05',
            'content': 'Hook: Attention-grabbing opening about ${request.topic}',
            'visualCue': 'Fast-paced montage, energetic music'
          },
          {
            'timestamp': '0:05-0:20',
            'content': 'Introduction: Welcome viewers and establish credibility',
            'visualCue': 'Presenter speaking to camera, professional background'
          },
          {
            'timestamp': '0:20-0:45',
            'content': 'Point 1: First key insight about ${request.topic}',
            'visualCue': 'Screen recording, demo footage'
          },
          {
            'timestamp': '0:45-1:10',
            'content': 'Point 2: Second major benefit and explanation',
            'visualCue': 'B-roll footage, infographics'
          },
          {
            'timestamp': '1:10-1:35',
            'content': 'Point 3: Third valuable tip or strategy',
            'visualCue': 'Case study examples, testimonials'
          },
          {
            'timestamp': '1:35-2:00',
            'content': 'Point 4: Fourth important consideration',
            'visualCue': 'Comparison charts, data visualization'
          },
          {
            'timestamp': '2:00-2:25',
            'content': 'Point 5: Final key takeaway',
            'visualCue': 'Presenter with props, demonstration'
          },
          {
            'timestamp': '2:25-2:50',
            'content': 'Summary: Recap of main points',
            'visualCue': 'Quick cuts of previous footage'
          },
          {
            'timestamp': '2:50-3:00',
            'content': 'CTA: ${request.cta ?? "Subscribe for more content like this!"}',
            'visualCue': 'Subscribe button animation, end screen'
          }
        ],
        'ctaScript': request.cta ?? 'Try our AI platform today and transform your ${request.topic}!',
        'thumbnailTitles': [
          '${request.topic}: Everything You Need to Know!',
          'The Ultimate ${request.topic} Guide (2025)',
          'Why ${request.topic} Will Change Your Life'
        ],
        'description': 'Learn everything about ${request.topic} in this comprehensive guide. Perfect for ${request.targetAudience ?? "anyone interested"}.',
        'hashtags': [
          '#${request.topic.replaceAll(' ', '')}',
          '#${request.platform}',
          '#Tutorial',
          '#HowTo',
          '#Guide2025',
          '#Productivity',
          '#TechTips',
          '#ContentCreation',
          '#DigitalMarketing',
          '#SocialMedia',
          '#VideoMarketing',
          '#ContentStrategy',
          '#Marketing101',
          '#BusinessTips',
          '#Entrepreneurship',
          '#SmallBusiness',
          '#OnlineMarketing',
          '#GrowthHacking'
        ],
        'musicMood': 'Upbeat Energetic',
        'estimatedRetention': '68% (strong hook, clear value proposition, engaging pacing)'
      }
    });
  }
}

// video_generation_service.dart
class VideoGenerationService {
  // TODO: Replace with real API when backend is ready
  
  Future<VideoGenerationResponse> generateVideo(VideoGenerationRequest request) async {
    // Simulate multi-step process
    await Future.delayed(Duration(seconds: 1)); // Script generation
    await Future.delayed(Duration(seconds: 1)); // Voiceover creation
    await Future.delayed(Duration(seconds: 3)); // Video composition
    await Future.delayed(Duration(seconds: 1)); // Upload
    
    // Return mock video
    return VideoGenerationResponse(
      videoUrl: 'https://example.com/mock-video.mp4',
      thumbnailUrl: 'https://via.placeholder.com/1280x720/2563EB/FFFFFF?text=${Uri.encodeComponent(request.topic)}',
      title: request.topic,
      duration: request.duration,
      size: '45 MB',
      quality: '1080p',
      script: VideoScriptResponse(/* mock script data */),
      voiceUsed: request.voice,
      musicMood: request.musicMood,
      processingTime: 97, // seconds
      cost: 0.43,
    );
  }
  
  Stream<VideoGenerationProgress> generateVideoWithProgress(VideoGenerationRequest request) async* {
    // Step 1: Generating script
    yield VideoGenerationProgress(
      percentage: 15,
      currentStep: 'Generating script...',
      completedSteps: [],
    );
    await Future.delayed(Duration(seconds: 2));
    
    // Step 2: Creating voiceover
    yield VideoGenerationProgress(
      percentage: 30,
      currentStep: 'Creating voiceover...',
      completedSteps: ['✓ Generated script (12 seconds)'],
    );
    await Future.delayed(Duration(seconds: 2));
    
    // Step 3: Composing video
    for (int i = 30; i <= 90; i += 15) {
      yield VideoGenerationProgress(
        percentage: i,
        currentStep: 'Composing video with stock footage...',
        completedSteps: [
          '✓ Generated script (12 seconds)',
          '✓ Created voiceover (15 seconds)',
        ],
      );
      await Future.delayed(Duration(seconds: 1));
    }
    
    // Step 4: Uploading
    yield VideoGenerationProgress(
      percentage: 95,
      currentStep: 'Uploading to storage...',
      completedSteps: [
        '✓ Generated script (12 seconds)',
        '✓ Created voiceover (15 seconds)',
        '✓ Composed video (60 seconds)',
      ],
    );
    await Future.delayed(Duration(seconds: 1));
    
    // Complete
    yield VideoGenerationProgress(
      percentage: 100,
      currentStep: 'Completed!',
      completedSteps: [
        '✓ Generated script (12 seconds)',
        '✓ Created voiceover (15 seconds)',
        '✓ Composed video (60 seconds)',
        '✓ Uploaded to storage (10 seconds)',
      ],
    );
  }
}
```

---

## 📊 IMPLEMENTATION STEPS:

### BUILD COMPLETE UI WITH MOCK DATA (All Components)

1. **Read Context Files** (10 min)
2. **Create Folder Structure** (3 min)
3. **Create Data Models** (60 min):
   - VideoScriptRequest, VideoScriptResponse, ScriptSection, VideoMetadata
   - VideoGenerationRequest, VideoGenerationResponse, GeneratedVideo
   - VideoGenerationProgress

4. **Create Controllers** (70 min):
   - VideoScriptController (35 min) - Form state, script generation
   - VideoGenerationController (35 min) - Video generation, progress tracking

5. **Create Mock Services** (40 min):
   - video_script_service.dart (20 min) - Mock script generation
   - video_generation_service.dart (20 min) - Mock video generation with progress stream

6. **Create Script Widgets** (120 min):
   - video_script_generation_form.dart (40 min)
   - video_script_results_display.dart (45 min)
   - script_section_card.dart (12 min)
   - platform_selector_dropdown.dart (15 min)
   - duration_selector_dropdown.dart (12 min)
   - thumbnail_options_widget.dart (10 min)
   - hashtag_tags_widget.dart (12 min)

7. **Create Video Generation Widgets** (120 min):
   - video_output_type_selector.dart (20 min)
   - video_progress_modal.dart (25 min)
   - video_player_widget.dart (30 min)
   - voice_preview_selector.dart (20 min)
   - video_quota_display.dart (10 min)
   - my_videos_library_page.dart (45 min)

8. **Integrate into Content Generation Page** (20 min)
9. **Test All UI Flows** (30 min) - Script generation, video generation, video library
10. **Polish & Responsive Design** (30 min)

**Total Time: ~8.5 hours**

---

## 🔄 WHEN BACKEND IS READY (Future):

**Simple API Integration Steps:**
1. Replace mock services with real API calls
2. Update VideoScriptService to use `ApiService`
3. Update VideoGenerationService to use `ApiService`
4. Test with real endpoints
5. Handle real error cases

**Estimated Integration Time: ~2 hours**

---

## ✅ SUCCESS CRITERIA:

Complete Video Generation UI is ready when:

**Script Generation:**
- [ ] All 7 script widgets implemented
- [ ] Form generates mock scripts successfully
- [ ] Results display all script sections beautifully
- [ ] Thumbnail options selectable
- [ ] Hashtags expandable/collapsible
- [ ] Copy to clipboard works
- [ ] Download .txt works

**Video Generation:**
- [ ] All 6 video widgets implemented
- [ ] Output type selector toggles script/video modes
- [ ] Video generation shows progress modal
- [ ] Progress modal animates through 4 steps
- [ ] Video player displays mock video
- [ ] Voice selector shows 4 options with descriptions
- [ ] Video library page displays mock videos
- [ ] Quota display shows usage correctly

**Code Quality:**
- [ ] All files under 800 lines
- [ ] Only custom widgets used (no Text(), TextField(), etc.)
- [ ] Only AppTheme constants used (no hardcoded colors/spacing)
- [ ] Data models with proper structure
- [ ] Controllers with clean state management
- [ ] Mock services with realistic delays
- [ ] Responsive on all breakpoints
- [ ] Loading states for all async operations
- [ ] Error states handled gracefully
- [ ] Empty states with helpful messages

**Integration:**
- [ ] Integrated into Content Generation page
- [ ] Video library accessible from sidebar
- [ ] Navigation flows smoothly
- [ ] Code follows FRONTEND_INSTRUCTIONS.md 100%

**Polish:**
- [ ] Animations smooth (progress bar, modals)
- [ ] Hover states on interactive elements
- [ ] Focus states for accessibility
- [ ] Tooltips where helpful
- [ ] Icons used appropriately (🎬🎵📸💼🎯📝📢🎨#️⃣🎵📹)
- [ ] Consistent spacing throughout
- [ ] Professional appearance matching design system

---

## 🔗 INTEGRATION WITH CONTENT GENERATION PAGE:

**Assumption:** Content Generation page has a tab/section selector for content types.

**Add Video Script as new tab:**
```dart
// In content_generation_page.dart or similar

enum ContentType {
  blog,
  social,
  email,
  product,
  adCopy,
  videoScript, // NEW
}

// Render appropriate form based on selected type
Widget _buildForm() {
  switch (selectedContentType) {
    case ContentType.blog:
      return BlogGenerationForm();
    case ContentType.social:
      return SocialMediaGenerationForm();
    case ContentType.videoScript:
      return VideoScriptGenerationForm(); // NEW
    // ... other types
  }
}
```

**If Content Generation page doesn't exist yet:**
- Build it as a new page with tab selector
- Video Script is one of 6 tabs
- Each tab shows different form

---

## 📝 NOTES:

- **Build complete UI NOW** - All 13 components with mock data
- **API integration LATER** - Easy swap when backend is ready
- **Mock data is realistic** - Matches expected backend response structure
- **Progress animations** - Make UI feel alive and responsive
- **Competitive advantage:** Only platform with video scripts + automation at $29/mo
- **Expected performance:** 12.4s avg generation time, 96.3% success rate, 8.8/10 quality
- **Quota tiers:** Free 5/mo, Hobby 25/mo, Pro 100/mo
- **Future backend:** $0.43 per video, 1.5 min generation time
- **Easy integration:** Just replace mock services with real API calls (2 hours work)

---

## 🎨 MOCK DATA EXAMPLES:

```dart
// Mock video script response
final mockScriptResponse = VideoScriptResponse.fromJson({
  'output': {
    'hook': 'Did you know 5 AI Tools can transform your workflow?',
    'script': [
      {'timestamp': '0:00-0:05', 'content': 'Hook content...', 'visualCue': 'Montage'},
      {'timestamp': '0:05-0:20', 'content': 'Intro content...', 'visualCue': 'Presenter'},
      // ... more sections
    ],
    'ctaScript': 'Try our AI platform today!',
    'thumbnailTitles': ['Title 1', 'Title 2', 'Title 3'],
    'hashtags': ['#AI', '#Productivity', '#ContentCreation', ...],
    'musicMood': 'Upbeat Energetic',
    'estimatedRetention': '68% (strong hook, clear value)'
  }
});

// Mock video library
final mockVideos = [
  GeneratedVideo(
    id: '1',
    title: '5 AI Tools for Content Creators',
    thumbnailUrl: 'https://via.placeholder.com/1280x720',
    duration: 180,
    platform: 'youtube',
    createdAt: DateTime.now().subtract(Duration(days: 1)),
    videoUrl: 'https://example.com/video1.mp4',
    size: '45 MB',
  ),
  GeneratedVideo(
    id: '2',
    title: 'Productivity Tips for 2025',
    thumbnailUrl: 'https://via.placeholder.com/1280x720',
    duration: 90,
    platform: 'tiktok',
    createdAt: DateTime.now().subtract(Duration(days: 2)),
    videoUrl: 'https://example.com/video2.mp4',
    size: '22 MB',
  ),
];
```

---

**START NOW:** Build all 13 components with perfect pixel-perfect UI and mock data. API integration comes later (easy 2-hour task).
