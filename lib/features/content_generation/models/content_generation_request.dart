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

/// Blog Post Request - Matches backend BlogGenerationRequest schema
class BlogPostRequest {
  final String topic; // Changed from 'title' to match backend
  final String length; // Changed from 'wordCount', values: short, medium, long
  final String
  tone; // lowercase: professional, casual, friendly, formal, humorous
  final List<String> keywords; // Changed from seoKeywords string to array
  final bool includeSeo;
  final bool includeImages; // Changed from includeVisuals

  BlogPostRequest({
    required this.topic,
    required this.length,
    required this.tone,
    required this.keywords,
    this.includeSeo = true,
    this.includeImages = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'keywords': keywords,
      'tone': tone.toLowerCase(),
      'length': length,
      'include_seo': includeSeo,
      'include_images': includeImages,
    };
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
