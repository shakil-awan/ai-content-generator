/// Image Request Model
/// Request for generating a single AI image
class ImageRequest {
  final String prompt;
  final String style; // realistic, artistic, illustration, 3d
  final String aspectRatio; // 1:1, 16:9, 9:16, 4:3, 3:4
  final bool enhancePrompt;

  ImageRequest({
    required this.prompt,
    required this.style,
    required this.aspectRatio,
    this.enhancePrompt = true,
  });

  /// Convert to API request format
  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'style': style,
      'aspect_ratio': aspectRatio,
      'enhance_prompt': enhancePrompt,
    };
  }

  /// Get dimensions from aspect ratio
  String get dimensions {
    switch (aspectRatio) {
      case '1:1':
        return '1024×1024';
      case '16:9':
        return '1792×1024';
      case '9:16':
        return '1024×1792';
      case '4:3':
        return '1365×1024';
      case '3:4':
        return '1024×1365';
      default:
        return '1024×1024';
    }
  }

  /// Get numeric dimensions for API
  String get apiDimensions {
    switch (aspectRatio) {
      case '1:1':
        return '1024x1024';
      case '16:9':
        return '1792x1024';
      case '9:16':
        return '1024x1792';
      case '4:3':
        return '1365x1024';
      case '3:4':
        return '1024x1365';
      default:
        return '1024x1024';
    }
  }

  /// Validate request
  bool get isValid => prompt.length >= 10 && prompt.length <= 500;

  /// Estimated cost
  double get estimatedCost => 0.003;

  /// Estimated time
  String get estimatedTime => '~2.5 sec';
}
