/// Content Generation Request Model
/// Base request for all content generation types
class ContentGenerationRequest {
  final String contentType;
  final Map<String, dynamic> parameters;
  final bool autoFactCheck;
  final String? brandVoiceId;

  ContentGenerationRequest({
    required this.contentType,
    required this.parameters,
    this.autoFactCheck = false,
    this.brandVoiceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'content_type': contentType,
      'parameters': parameters,
      'auto_fact_check': autoFactCheck,
      if (brandVoiceId != null) 'brand_voice_id': brandVoiceId,
    };
  }
}

/// Blog Post Request - Matches backend BlogGenerationRequest schema (Phase 2)
class BlogPostRequest {
  final String topic;
  final int wordCount; // NEW Phase 2: Direct word count (500-4000)
  final String?
  length; // DEPRECATED: Use wordCount instead (kept for compatibility)
  final String tone; // professional, casual, friendly, formal, humorous, etc.
  final List<String> keywords;
  final bool includeSeo;
  final bool includeImages;
  // Phase 2 new fields
  final String? targetAudience; // NEW: Target audience description
  final String?
  writingStyle; // NEW: narrative, listicle, how-to, case-study, comparison
  final bool includeExamples; // NEW: Include real-world examples
  final bool enableFactCheck; // NEW: Enable fact-checking with Google Search

  BlogPostRequest({
    required this.topic,
    this.wordCount = 1000,
    this.length, // Deprecated
    required this.tone,
    required this.keywords,
    this.includeSeo = true,
    this.includeImages = false,
    this.targetAudience,
    this.writingStyle,
    this.includeExamples = true,
    this.enableFactCheck = true, // Enable by default
  });

  Map<String, dynamic> toJson() {
    final json = {
      'topic': topic,
      'keywords': keywords,
      'tone': tone.toLowerCase(),
      'word_count': wordCount,
      'include_seo': includeSeo,
      'include_images': includeImages,
      'include_examples': includeExamples,
      'enable_fact_check': enableFactCheck,
    };

    // Add optional Phase 2 fields
    if (targetAudience != null && targetAudience!.isNotEmpty) {
      json['target_audience'] = targetAudience!;
    }
    if (writingStyle != null && writingStyle!.isNotEmpty) {
      json['writing_style'] = writingStyle!;
    }

    // Backward compatibility: include length if wordCount not explicitly set
    if (length != null) {
      json['length'] = length!;
    }

    return json;
  }
}

/// Social Media Request
class SocialMediaRequest {
  final String platform;
  final String topic;
  final String tone;
  final bool includeHashtags;
  final bool includeEmoji;
  final bool includeCallToAction;

  SocialMediaRequest({
    required this.platform,
    required this.topic,
    required this.tone,
    this.includeHashtags = true,
    this.includeEmoji = true,
    this.includeCallToAction = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'topic': topic,
      'tone': tone,
      'include_hashtags': includeHashtags,
      'include_emoji': includeEmoji,
      'include_call_to_action': includeCallToAction,
    };
  }
}

/// Email Campaign Request
class EmailCampaignRequest {
  final String emailType;
  final String subject;
  final String? targetAudience;
  final String mainMessage;
  final String? callToAction;
  final String tone;

  EmailCampaignRequest({
    required this.emailType,
    required this.subject,
    this.targetAudience,
    required this.mainMessage,
    this.callToAction,
    required this.tone,
  });

  Map<String, dynamic> toJson() {
    return {
      'email_type': emailType,
      'subject': subject,
      if (targetAudience != null && targetAudience!.isNotEmpty)
        'target_audience': targetAudience,
      'main_message': mainMessage,
      if (callToAction != null && callToAction!.isNotEmpty)
        'call_to_action': callToAction,
      'tone': tone,
    };
  }
}

/// Video Script Request
class VideoScriptRequest {
  final String topic;
  final String platform;
  final String duration;
  final String? targetAudience;
  final String tone;

  VideoScriptRequest({
    required this.topic,
    required this.platform,
    required this.duration,
    this.targetAudience,
    required this.tone,
  });

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'platform': platform,
      'duration': duration,
      if (targetAudience != null && targetAudience!.isNotEmpty)
        'target_audience': targetAudience,
      'tone': tone,
    };
  }
}
