/// Social Media Generation Output Models
/// Matches backend SocialMediaOutput schema from ai_schemas.py
library;

/// Individual social media caption variation
class SocialCaption {
  final int variation;
  final String text;
  final int length;

  SocialCaption({
    required this.variation,
    required this.text,
    required this.length,
  });

  factory SocialCaption.fromJson(Map<String, dynamic> json) {
    return SocialCaption(
      variation: json['variation'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      length: json['length'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'variation': variation, 'text': text, 'length': length};
  }

  /// Get character count (fallback to text length if not provided)
  int get characterCount => length > 0 ? length : text.length;

  /// Check if caption is within platform limits
  bool isWithinLimit(int limit) => characterCount <= limit;

  /// Get preview text (first 100 characters)
  String get preview =>
      text.length > 100 ? '${text.substring(0, 100)}...' : text;
}

/// Social Media Output containing multiple captions and suggestions
class SocialMediaOutput {
  final List<SocialCaption> captions;
  final List<String> hashtags;
  final List<String> emojiSuggestions;
  final String engagementTips;
  final String? formattedContent;

  SocialMediaOutput({
    required this.captions,
    required this.hashtags,
    required this.emojiSuggestions,
    required this.engagementTips,
    this.formattedContent,
  });

  factory SocialMediaOutput.fromJson(Map<String, dynamic> json) {
    return SocialMediaOutput(
      captions:
          (json['captions'] as List<dynamic>?)
              ?.map((e) => SocialCaption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hashtags: (json['hashtags'] as List<dynamic>?)?.cast<String>() ?? [],
      emojiSuggestions:
          (json['emojiSuggestions'] as List<dynamic>?)?.cast<String>() ?? [],
      engagementTips: json['engagementTips'] as String? ?? '',
      formattedContent: json['formatted_content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'captions': captions.map((e) => e.toJson()).toList(),
      'hashtags': hashtags,
      'emojiSuggestions': emojiSuggestions,
      'engagementTips': engagementTips,
      if (formattedContent != null) 'formatted_content': formattedContent,
    };
  }

  /// Get the best caption (first one, usually the best)
  SocialCaption? get bestCaption => captions.isNotEmpty ? captions.first : null;

  /// Get all captions text as a list
  List<String> get allCaptionsText => captions.map((c) => c.text).toList();

  /// Check if has multiple caption variations
  bool get hasMultipleCaptions => captions.length > 1;

  /// Get caption count
  int get captionCount => captions.length;
}
