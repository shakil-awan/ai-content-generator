/// Image Response Model
/// Response from image generation API
class ImageResponse {
  final String imageUrl;
  final String model; // flux-schnell or dall-e-3
  final double generationTime;
  final double cost;
  final String size;
  final String quality;
  final String? enhancedPrompt;

  ImageResponse({
    required this.imageUrl,
    required this.model,
    required this.generationTime,
    required this.cost,
    required this.size,
    required this.quality,
    this.enhancedPrompt,
  });

  /// Create from JSON
  factory ImageResponse.fromJson(Map<String, dynamic> json) {
    return ImageResponse(
      imageUrl: json['image_url'] ?? '',
      model: json['model'] ?? 'flux-schnell',
      generationTime: (json['generation_time'] ?? 2.5).toDouble(),
      cost: (json['cost'] ?? 0.003).toDouble(),
      size: json['size'] ?? '1024x1024',
      quality: json['quality'] ?? 'high',
      enhancedPrompt: json['enhanced_prompt'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'model': model,
      'generation_time': generationTime,
      'cost': cost,
      'size': size,
      'quality': quality,
      'enhanced_prompt': enhancedPrompt,
    };
  }

  /// Get display-friendly model name
  String get modelDisplay {
    return model == 'flux-schnell'
        ? 'Flux Schnell (Fast & Cost-Effective)'
        : 'DALL-E 3 (Premium Quality)';
  }

  /// Get formatted generation time
  String get formattedTime {
    return '${generationTime.toStringAsFixed(1)} seconds';
  }

  /// Get formatted cost
  String get formattedCost {
    return '\$${cost.toStringAsFixed(3)}';
  }

  /// Get display-friendly size
  String get displaySize {
    return size.replaceAll('x', '×');
  }
}
