/// Batch Request Model
/// Request for generating multiple images in parallel
class BatchRequest {
  final List<String> prompts;
  final String style;
  final String aspectRatio;

  BatchRequest({
    required this.prompts,
    required this.style,
    required this.aspectRatio,
  });

  /// Convert to API request format
  Map<String, dynamic> toJson() {
    return {'prompts': prompts, 'style': style, 'aspect_ratio': aspectRatio};
  }

  /// Get count of non-empty prompts
  int get imageCount => prompts.where((p) => p.trim().isNotEmpty).length;

  /// Get estimated total cost
  double get estimatedCost => imageCount * 0.003;

  /// Get estimated time (parallel processing with overhead)
  double get estimatedTime => 2.5 + (imageCount * 0.2);

  /// Get formatted estimated time
  String get formattedEstimatedTime {
    final seconds = estimatedTime;
    if (seconds < 60) {
      return '${seconds.toStringAsFixed(1)} seconds';
    } else {
      final minutes = (seconds / 60).floor();
      final remainingSeconds = (seconds % 60).round();
      return '$minutes min ${remainingSeconds}s';
    }
  }

  /// Validate request
  bool get isValid => imageCount > 0 && imageCount <= 10;

  /// Get validation error message
  String? get validationError {
    if (imageCount == 0) {
      return 'Add at least one prompt';
    }
    if (imageCount > 10) {
      return 'Maximum 10 images per batch';
    }
    if (prompts.any((p) => p.trim().isNotEmpty && p.trim().length < 10)) {
      return 'Each prompt must be at least 10 characters';
    }
    return null;
  }
}
