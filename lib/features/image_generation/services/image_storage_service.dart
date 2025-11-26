import '../models/generated_image.dart';

/// Image Storage Service
/// Mock service for managing image library
class ImageStorageService {
  // Mock image gallery
  final List<GeneratedImage> _mockImages = [
    GeneratedImage(
      id: '1',
      imageUrl:
          'https://via.placeholder.com/1024x1024/2563EB/FFFFFF?text=Modern+Office',
      prompt: 'Modern office workspace with plants and natural lighting',
      style: 'realistic',
      size: '1024x1024',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      cost: 0.003,
    ),
    GeneratedImage(
      id: '2',
      imageUrl:
          'https://via.placeholder.com/1792x1024/8B5CF6/FFFFFF?text=Tech+Startup',
      prompt: 'Tech startup team meeting in modern conference room',
      style: 'realistic',
      size: '1792x1024',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      cost: 0.003,
    ),
    GeneratedImage(
      id: '3',
      imageUrl:
          'https://via.placeholder.com/1024x1792/EC4899/FFFFFF?text=Creative+Studio',
      prompt: 'Creative studio interior with artistic decor',
      style: 'artistic',
      size: '1024x1792',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      cost: 0.003,
    ),
    GeneratedImage(
      id: '4',
      imageUrl:
          'https://via.placeholder.com/1024x1024/10B981/FFFFFF?text=Product+Shot',
      prompt: 'Professional product photography of smartphone',
      style: 'realistic',
      size: '1024x1024',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      cost: 0.003,
    ),
    GeneratedImage(
      id: '5',
      imageUrl:
          'https://via.placeholder.com/1024x1024/F59E0B/FFFFFF?text=Social+Media',
      prompt: 'Eye-catching social media post design',
      style: 'illustration',
      size: '1024x1024',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      cost: 0.003,
    ),
    GeneratedImage(
      id: '6',
      imageUrl:
          'https://via.placeholder.com/1792x1024/EF4444/FFFFFF?text=Blog+Header',
      prompt: 'Blog header image with technology theme',
      style: 'realistic',
      size: '1792x1024',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      cost: 0.003,
    ),
  ];

  /// Get all images with filters and pagination
  Future<List<GeneratedImage>> getMyImages({
    String? styleFilter,
    String? sort,
    String? searchQuery,
    int page = 1,
    int pageSize = 12,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    var images = List<GeneratedImage>.from(_mockImages);

    // Apply style filter
    if (styleFilter != null && styleFilter != 'all') {
      images = images.where((img) => img.style == styleFilter).toList();
    }

    // Apply search
    if (searchQuery != null && searchQuery.isNotEmpty) {
      images = images
          .where(
            (img) =>
                img.prompt.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply sorting
    if (sort == 'oldest') {
      images.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      // Default: newest first
      images.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    // Pagination
    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, images.length);

    if (start >= images.length) return [];

    return images.sublist(start, end);
  }

  /// Get total count of images
  Future<int> getTotalCount({String? styleFilter, String? searchQuery}) async {
    await Future.delayed(const Duration(milliseconds: 100));

    var images = List<GeneratedImage>.from(_mockImages);

    if (styleFilter != null && styleFilter != 'all') {
      images = images.where((img) => img.style == styleFilter).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      images = images
          .where(
            (img) =>
                img.prompt.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    return images.length;
  }

  /// Add new image to gallery
  Future<void> addImage(GeneratedImage image) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockImages.insert(0, image);
  }

  /// Delete image from gallery
  Future<void> deleteImage(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockImages.removeWhere((img) => img.id == id);
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Mock storage data
    return {
      'total_images': _mockImages.length,
      'storage_used_mb': _mockImages.length * 2.5, // ~2.5MB per image
      'storage_limit_mb': 5120, // 5GB for Pro tier
      'images_this_month': 45,
      'monthly_limit': 50,
    };
  }
}
