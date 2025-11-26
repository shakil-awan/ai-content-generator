/// Video Script Request Model
/// Request payload for generating video scripts
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

  VideoScriptRequest({
    required this.topic,
    required this.platform,
    required this.duration,
    this.targetAudience,
    this.keyPoints,
    this.cta,
    this.tone = 'casual',
    this.includeHooks = true,
    this.includeCta = true,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'platform': platform,
      'duration': duration,
      if (targetAudience != null && targetAudience!.isNotEmpty)
        'target_audience': targetAudience,
      if (keyPoints != null && keyPoints!.isNotEmpty) 'key_points': keyPoints,
      if (cta != null && cta!.isNotEmpty) 'cta': cta,
      'tone': tone,
      'include_hooks': includeHooks,
      'include_cta': includeCta,
    };
  }

  /// Validate request data
  bool get isValid {
    return topic.length >= 3 &&
        topic.length <= 200 &&
        ['youtube', 'tiktok', 'instagram', 'linkedin'].contains(platform) &&
        duration >= 15 &&
        duration <= 600;
  }

  /// Get estimated credit cost
  int get estimatedCredits => 1; // 1 credit per script

  /// Get estimated generation time
  String get estimatedTime => '~12 seconds';
}
