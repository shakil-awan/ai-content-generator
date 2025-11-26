/// Generated Image Model
/// Represents a generated image in user's library
class GeneratedImage {
  final String id;
  final String imageUrl;
  final String prompt;
  final String style;
  final String size;
  final DateTime createdAt;
  final double cost;
  final String model;

  GeneratedImage({
    required this.id,
    required this.imageUrl,
    required this.prompt,
    required this.style,
    required this.size,
    required this.createdAt,
    required this.cost,
    this.model = 'flux-schnell',
  });

  /// Create from JSON
  factory GeneratedImage.fromJson(Map<String, dynamic> json) {
    return GeneratedImage(
      id: json['id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      prompt: json['prompt'] ?? '',
      style: json['style'] ?? 'realistic',
      size: json['size'] ?? '1024x1024',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      cost: (json['cost'] ?? 0.003).toDouble(),
      model: json['model'] ?? 'flux-schnell',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'prompt': prompt,
      'style': style,
      'size': size,
      'created_at': createdAt.toIso8601String(),
      'cost': cost,
      'model': model,
    };
  }

  /// Get display-friendly date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
    }
  }

  /// Get truncated prompt for display
  String get truncatedPrompt {
    if (prompt.length <= 30) return prompt;
    return '${prompt.substring(0, 30)}...';
  }

  /// Get display-friendly size
  String get displaySize {
    return size.replaceAll('x', '×');
  }

  /// Get style display name
  String get styleDisplay {
    switch (style.toLowerCase()) {
      case 'realistic':
        return 'Realistic';
      case 'artistic':
        return 'Artistic';
      case 'illustration':
        return 'Illustration';
      case '3d':
        return '3D Render';
      default:
        return style;
    }
  }

  /// Get aspect ratio from size
  String get aspectRatio {
    final parts = size.split('x');
    if (parts.length != 2) return 'Unknown';

    final width = int.tryParse(parts[0]) ?? 0;
    final height = int.tryParse(parts[1]) ?? 0;

    if (width == height) return '1:1';
    if (width > height) {
      if ((width / height) > 1.7) return '16:9';
      return '4:3';
    } else {
      if ((height / width) > 1.7) return '9:16';
      return '3:4';
    }
  }
}
