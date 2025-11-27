import '../models/script_section.dart';
import '../models/video_script_request.dart';
import '../models/video_script_response.dart';

/// Video Script Generation Service
/// Mock service that simulates backend API for script generation
class VideoScriptService {
  /// Generate video script (Mock implementation)
  /// In production, this will call the backend API
  Future<VideoScriptResponse> generateScript(VideoScriptRequest request) async {
    // Simulate API delay (12.4 seconds average based on specs)
    await Future.delayed(const Duration(seconds: 12));

    // Generate mock script based on request
    final scriptSections = _generateMockSections(request);

    return VideoScriptResponse(
      hook: _generateMockHook(request),
      script: scriptSections,
      ctaScript: request.includeCta ? _generateMockCta(request) : '',
      thumbnailTitles: _generateMockThumbnails(request),
      description: _generateMockDescription(request),
      hashtags: _generateMockHashtags(request),
      musicMood: _selectMusicMood(request),
      estimatedRetention: _estimateRetention(request),
    );
  }

  /// Generate mock hook
  String _generateMockHook(VideoScriptRequest request) {
    final hooks = {
      'professional':
          'Did you know that ${request.topic} could transform your approach? Here\'s what you need to know.',
      'casual':
          'Hey! Let me tell you about ${request.topic} - trust me, you\'re going to want to hear this.',
      'energetic':
          '🔥 BOOM! ${request.topic} is about to blow your mind. Let\'s GO!',
      'educational':
          'Today we\'re diving deep into ${request.topic}. By the end of this, you\'ll be an expert.',
      'humorous':
          'So... ${request.topic}. Yeah, that\'s a thing. And it\'s way more interesting than you think!',
      'inspirational':
          'Imagine mastering ${request.topic}. Today, we\'re making that happen together.',
    };
    return hooks[request.tone] ?? hooks['professional']!;
  }

  /// Generate mock script sections
  List<ScriptSection> _generateMockSections(VideoScriptRequest request) {
    final sections = <ScriptSection>[];
    final totalDuration = request.duration;
    final sectionCount = (totalDuration / 15).ceil().clamp(3, 12);
    final sectionDuration = totalDuration ~/ sectionCount;

    for (var i = 0; i < sectionCount; i++) {
      final startTime = i * sectionDuration;
      final endTime = (i + 1) * sectionDuration;

      sections.add(
        ScriptSection(
          timestamp: _formatTimestamp(startTime, endTime),
          content: _generateSectionContent(request, i, sectionCount),
          visualCue: _generateVisualCue(request, i),
        ),
      );
    }

    return sections;
  }

  /// Format timestamp
  String _formatTimestamp(int start, int end) {
    return '${_formatSeconds(start)}-${_formatSeconds(end)}';
  }

  /// Format seconds to MM:SS
  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  /// Generate section content
  String _generateSectionContent(
    VideoScriptRequest request,
    int index,
    int total,
  ) {
    if (index == 0) {
      final audience = request.targetAudience?.isNotEmpty == true
          ? request.targetAudience
          : "everyone";
      return 'Let\'s start with the fundamentals of ${request.topic}. This is crucial for $audience.';
    } else if (index == total - 1) {
      return 'So there you have it - everything you need to know about ${request.topic}. Remember these key points and you\'ll be set for success.';
    } else if (request.keyPoints != null &&
        request.keyPoints!.isNotEmpty &&
        index <= request.keyPoints!.length) {
      return 'Point $index: ${request.keyPoints![index - 1]}. This is essential because it directly impacts your results.';
    } else {
      return 'Another important aspect of ${request.topic} is understanding how all these elements work together. This creates a powerful framework.';
    }
  }

  /// Generate visual cue
  String _generateVisualCue(VideoScriptRequest request, int index) {
    final cues = [
      'Show title card with topic',
      'Display key statistics',
      'Show before/after comparison',
      'Display step-by-step diagram',
      'Show real-world example',
      'Display infographic',
      'Show testimonial overlay',
      'Display call-to-action card',
    ];
    return cues[index % cues.length];
  }

  /// Generate mock CTA
  String _generateMockCta(VideoScriptRequest request) {
    if (request.cta?.isNotEmpty == true) {
      return request.cta!;
    }

    return 'If you found this helpful, make sure to like and subscribe for more content about ${request.topic}. Drop a comment below with your thoughts!';
  }

  /// Generate mock thumbnails
  List<String> _generateMockThumbnails(VideoScriptRequest request) {
    return [
      '${request.topic.toUpperCase()} - The Ultimate Guide',
      'How ${request.topic} Changed Everything 🔥',
      'The Secret to ${request.topic} Nobody Tells You',
    ];
  }

  /// Generate mock description
  String _generateMockDescription(VideoScriptRequest request) {
    final audience = request.targetAudience?.isNotEmpty == true
        ? request.targetAudience
        : "anyone looking to learn";
    final keyPointsText =
        request.keyPoints == null || request.keyPoints!.isEmpty
        ? "- Essential concepts and strategies"
        : request.keyPoints!.map((p) => "- $p").join("\n");

    return 'Discover everything you need to know about ${request.topic} in this comprehensive guide. '
        'Perfect for $audience. '
        '\n\n'
        '🎯 Key Topics Covered:\n'
        '$keyPointsText'
        '\n\n'
        '📱 Follow for more content like this!';
  }

  /// Generate mock hashtags
  List<String> _generateMockHashtags(VideoScriptRequest request) {
    final baseTag = request.topic.toLowerCase().replaceAll(' ', '');
    final platformTags = {
      'youtube': ['#YouTubeEducation', '#LearnOnYouTube', '#Tutorial'],
      'tiktok': ['#TikTokTips', '#LearnOnTikTok', '#Viral'],
      'instagram': ['#InstaLearn', '#ReelsEducation', '#InstaGrowth'],
      'linkedin': [
        '#LinkedInLearning',
        '#ProfessionalDevelopment',
        '#CareerGrowth',
      ],
    };

    final tags = <String>[
      '#$baseTag',
      '#${baseTag}tips',
      '#${baseTag}guide',
      '#Education',
      '#Learning',
      '#Tips',
      '#HowTo',
      '#Tutorial',
      ...platformTags[request.platform] ?? [],
    ];

    return tags.take(18).toList();
  }

  /// Select music mood
  String _selectMusicMood(VideoScriptRequest request) {
    final moods = {
      'professional': 'Corporate & Uplifting',
      'casual': 'Upbeat & Friendly',
      'energetic': 'High Energy & Motivational',
      'educational': 'Calm & Focused',
      'humorous': 'Playful & Fun',
      'inspirational': 'Epic & Emotional',
    };
    return moods[request.tone] ?? 'Upbeat & Friendly';
  }

  /// Estimate retention
  String _estimateRetention(VideoScriptRequest request) {
    // Higher retention for shorter videos and engaging hooks
    int baseRetention = 65;

    if (request.duration < 60) {
      baseRetention += 15;
    } else if (request.duration > 180) {
      baseRetention -= 10;
    }

    if (request.includeHooks) baseRetention += 8;
    if ((request.keyPoints?.length ?? 0) >= 3) baseRetention += 5;

    final retention = baseRetention.clamp(50, 85);
    return '$retention% - Well-structured content with strong hook and clear value proposition';
  }
}
