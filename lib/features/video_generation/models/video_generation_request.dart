/// Video Generation Request Model
/// Request for automated video generation from script
class VideoGenerationRequest {
  final String scriptId;
  final String topic;
  final String platform;
  final int duration;
  final String hook;
  final List<Map<String, String>> scriptSections;
  final String ctaScript;
  final String voiceId;
  final String musicMood;
  final bool includeSubtitles;
  final bool includeCaptions;

  VideoGenerationRequest({
    required this.scriptId,
    required this.topic,
    required this.platform,
    required this.duration,
    required this.hook,
    required this.scriptSections,
    required this.ctaScript,
    required this.voiceId,
    required this.musicMood,
    this.includeSubtitles = true,
    this.includeCaptions = true,
  });

  /// Available voice options
  static const List<Map<String, String>> voiceOptions = [
    {
      'id': 'emma',
      'name': 'Emma - Professional Female',
      'emoji': '👩',
      'description': 'Clear, engaging, professional',
    },
    {
      'id': 'ryan',
      'name': 'Ryan - Professional Male',
      'emoji': '👨',
      'description': 'Deep, authoritative, trustworthy',
    },
    {
      'id': 'sophia',
      'name': 'Sophia - Friendly Female',
      'emoji': '👧',
      'description': 'Warm, conversational, approachable',
    },
    {
      'id': 'marcus',
      'name': 'Marcus - Energetic Male',
      'emoji': '🧑',
      'description': 'Dynamic, motivational, powerful',
    },
  ];

  /// Get voice display name
  String get voiceDisplayName {
    final voice = voiceOptions.firstWhere(
      (v) => v['id'] == voiceId,
      orElse: () => voiceOptions.first,
    );
    return voice['name']!;
  }

  /// Get voice emoji
  String get voiceEmoji {
    final voice = voiceOptions.firstWhere(
      (v) => v['id'] == voiceId,
      orElse: () => voiceOptions.first,
    );
    return voice['emoji']!;
  }

  /// Validate request
  bool get isValid {
    return scriptId.isNotEmpty &&
        topic.isNotEmpty &&
        duration >= 15 &&
        duration <= 600 &&
        hook.isNotEmpty &&
        scriptSections.isNotEmpty &&
        voiceId.isNotEmpty &&
        musicMood.isNotEmpty;
  }

  /// Get estimated cost
  double get estimatedCost => 0.43; // $0.43 per video (93% cheaper than competitors)

  /// Get estimated time (90 seconds average)
  String get estimatedTime => '~1.5 minutes';

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'script_id': scriptId,
      'topic': topic,
      'platform': platform,
      'duration': duration,
      'hook': hook,
      'script_sections': scriptSections,
      'cta_script': ctaScript,
      'voice_id': voiceId,
      'music_mood': musicMood,
      'include_subtitles': includeSubtitles,
      'include_captions': includeCaptions,
    };
  }

  /// Create from JSON
  factory VideoGenerationRequest.fromJson(Map<String, dynamic> json) {
    return VideoGenerationRequest(
      scriptId: json['script_id'] ?? '',
      topic: json['topic'] ?? '',
      platform: json['platform'] ?? '',
      duration: json['duration'] ?? 0,
      hook: json['hook'] ?? '',
      scriptSections: List<Map<String, String>>.from(
        (json['script_sections'] as List?)?.map((s) => Map<String, String>.from(s)) ?? [],
      ),
      ctaScript: json['cta_script'] ?? '',
      voiceId: json['voice_id'] ?? 'emma',
      musicMood: json['music_mood'] ?? '',
      includeSubtitles: json['include_subtitles'] ?? true,
      includeCaptions: json['include_captions'] ?? true,
    );
  }
}
