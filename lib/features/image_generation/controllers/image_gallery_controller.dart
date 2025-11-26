import 'package:get/get.dart';

import '../models/generated_image.dart';
import '../services/image_storage_service.dart';

/// Image Gallery Controller
/// Manages state for image library/gallery page
class ImageGalleryController extends GetxController {
  final ImageStorageService _storageService = ImageStorageService();

  // Gallery state
  final images = <GeneratedImage>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Filters and sorting
  final styleFilter = 'all'.obs;
  final sortOption = 'newest'.obs;
  final searchQuery = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final pageSize = 12;
  final totalCount = 0.obs;

  // Storage stats
  final storageUsedMB = 0.0.obs;
  final storageLimitMB = 5120.0.obs; // 5GB
  final imagesThisMonth = 0.obs;
  final monthlyLimit = 50.obs;

  // Computed properties
  int get totalPages => (totalCount.value / pageSize).ceil();
  bool get hasNextPage => currentPage.value < totalPages;
  bool get hasPrevPage => currentPage.value > 1;
  double get storagePercentage => storageUsedMB.value / storageLimitMB.value;
  bool get isStorageNearLimit => storagePercentage >= 0.8;

  @override
  void onInit() {
    super.onInit();
    loadImages();
    loadStorageStats();
  }

  /// Load images with current filters
  Future<void> loadImages() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final loadedImages = await _storageService.getMyImages(
        styleFilter: styleFilter.value == 'all' ? null : styleFilter.value,
        sort: sortOption.value,
        searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
        page: currentPage.value,
        pageSize: pageSize,
      );

      images.value = loadedImages;

      // Get total count
      final count = await _storageService.getTotalCount(
        styleFilter: styleFilter.value == 'all' ? null : styleFilter.value,
        searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      totalCount.value = count;
    } catch (e) {
      errorMessage.value = 'Failed to load images: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load storage statistics
  Future<void> loadStorageStats() async {
    try {
      final stats = await _storageService.getStorageStats();
      storageUsedMB.value = stats['storage_used_mb'] ?? 0.0;
      storageLimitMB.value = stats['storage_limit_mb'] ?? 5120.0;
      imagesThisMonth.value = stats['images_this_month'] ?? 0;
      monthlyLimit.value = stats['monthly_limit'] ?? 50;
    } catch (e) {
      // Use default values
    }
  }

  /// Change style filter
  void setStyleFilter(String filter) {
    styleFilter.value = filter;
    currentPage.value = 1;
    loadImages();
  }

  /// Change sort option
  void setSortOption(String sort) {
    sortOption.value = sort;
    currentPage.value = 1;
    loadImages();
  }

  /// Update search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    loadImages();
  }

  /// Go to next page
  void nextPage() {
    if (hasNextPage) {
      currentPage.value++;
      loadImages();
    }
  }

  /// Go to previous page
  void prevPage() {
    if (hasPrevPage) {
      currentPage.value--;
      loadImages();
    }
  }

  /// Go to specific page
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
      loadImages();
    }
  }

  /// Delete image
  Future<void> deleteImage(String id) async {
    try {
      await _storageService.deleteImage(id);
      images.removeWhere((img) => img.id == id);
      totalCount.value--;

      Get.snackbar(
        'Deleted',
        'Image removed from library',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Reload if current page is empty
      if (images.isEmpty && currentPage.value > 1) {
        currentPage.value--;
        loadImages();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Refresh images
  @override
  Future<void> refresh() async {
    await loadImages();
    await loadStorageStats();
  }
}
