import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/batch_request.dart';
import '../models/generated_image.dart';
import '../models/image_request.dart';
import '../models/image_response.dart';
import '../services/image_generation_service.dart';
import '../services/image_storage_service.dart';
import '../utils/image_test_data.dart';

/// Image Generation Controller
/// Manages state for image generation (single and batch)
class ImageGenerationController extends GetxController {
  final ImageGenerationService _generationService = ImageGenerationService();
  final ImageStorageService _storageService = ImageStorageService();
  final ImageGenerationTestSeeder? _testSeeder;

  ImageGenerationController({ImageGenerationTestSeeder? testSeeder})
    : _testSeeder =
          testSeeder ??
          (ImageGenerationTestSeeder.isEnabled
              ? ImageGenerationTestSeeder()
              : null);

  // Single image generation state
  final imageResponse = Rxn<ImageResponse>();
  final isGenerating = false.obs;
  final generationProgress = 0.0.obs;
  final currentStep = ''.obs;
  final errorMessage = ''.obs;

  // Form fields
  final prompt = ''.obs;
  final style = 'realistic'.obs;
  final aspectRatio = '1:1'.obs;
  final enhancePrompt = true.obs;

  // Batch generation state
  final batchPrompts = <String>[].obs;
  final isBatchGenerating = false.obs;
  final batchResults = <ImageResponse>[].obs;
  final batchProgress = 0.0.obs;
  final currentBatchIndex = 0.obs;

  // Quota state
  final imagesUsed = 45.obs; // Mock: loaded from storage stats
  final imagesLimit = 50.obs;

  // Available options
  final List<Map<String, String>> styles = [
    {'id': 'realistic', 'name': 'Realistic', 'icon': '📷'},
    {'id': 'artistic', 'name': 'Artistic', 'icon': '🎨'},
    {'id': 'illustration', 'name': 'Illustration', 'icon': '✏️'},
    {'id': '3d', 'name': '3D Render', 'icon': '🧊'},
  ];

  final List<Map<String, String>> aspectRatios = [
    {'id': '1:1', 'name': 'Square', 'size': '1024×1024', 'use': 'Social posts'},
    {
      'id': '16:9',
      'name': 'Landscape',
      'size': '1792×1024',
      'use': 'YouTube thumbnails',
    },
    {
      'id': '9:16',
      'name': 'Portrait',
      'size': '1024×1792',
      'use': 'Instagram stories',
    },
    {'id': '4:3', 'name': 'Wide', 'size': '1365×1024', 'use': 'Presentations'},
    {'id': '3:4', 'name': 'Tall', 'size': '1024×1365', 'use': 'Pinterest'},
  ];

  // Computed properties
  bool get canGenerate => prompt.value.length >= 10 && hasQuota;
  bool get hasQuota => imagesUsed.value < imagesLimit.value;
  bool get isNearLimit => (imagesUsed.value / imagesLimit.value) >= 0.8;
  int get imagesRemaining => imagesLimit.value - imagesUsed.value;
  double get quotaPercentage => imagesUsed.value / imagesLimit.value;

  @override
  void onInit() {
    super.onInit();
    loadQuota();
    _maybeApplyTestSeed(initial: true);
  }

  /// Load quota from storage stats
  Future<void> loadQuota() async {
    try {
      final stats = await _storageService.getStorageStats();
      imagesUsed.value = stats['images_this_month'] ?? 0;
      imagesLimit.value = stats['monthly_limit'] ?? 50;
    } catch (e) {
      // Use default values
    }
  }

  /// Generate single image
  Future<void> generateImage() async {
    if (!canGenerate) {
      if (!hasQuota) {
        errorMessage.value = 'Image generation quota exceeded';
        Get.snackbar(
          'Quota Exceeded',
          'You have reached your monthly limit. Upgrade to continue.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return;
    }

    try {
      isGenerating.value = true;
      generationProgress.value = 0.0;
      errorMessage.value = '';
      imageResponse.value = null;

      // Step 1: Enhance prompt
      currentStep.value = 'Enhancing prompt...';
      generationProgress.value = 0.2;
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Generate image
      currentStep.value = 'Creating image...';
      generationProgress.value = 0.5;

      final request = ImageRequest(
        prompt: prompt.value,
        style: style.value,
        aspectRatio: aspectRatio.value,
        enhancePrompt: enhancePrompt.value,
      );

      final response = await _generationService.generateImage(request);

      generationProgress.value = 0.9;

      // Step 3: Upload
      currentStep.value = 'Uploading to storage...';
      await Future.delayed(const Duration(milliseconds: 300));

      // Save to gallery
      final generatedImage = GeneratedImage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: response.imageUrl,
        prompt: prompt.value,
        style: style.value,
        size: response.size,
        createdAt: DateTime.now(),
        cost: response.cost,
        model: response.model,
      );
      await _storageService.addImage(generatedImage);

      generationProgress.value = 1.0;
      imageResponse.value = response;
      imagesUsed.value++;

      Get.snackbar(
        'Success! 🎉',
        'Your image is ready',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      errorMessage.value = 'Failed to generate image: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isGenerating.value = false;
      currentStep.value = '';
      generationProgress.value = 0.0;
    }
  }

  /// Generate batch of images
  Future<void> generateBatch() async {
    if (batchPrompts.isEmpty || !hasQuota) return;

    try {
      isBatchGenerating.value = true;
      batchProgress.value = 0.0;
      batchResults.clear();
      errorMessage.value = '';
      currentBatchIndex.value = 0;

      final request = BatchRequest(
        prompts: batchPrompts.toList(),
        style: style.value,
        aspectRatio: aspectRatio.value,
      );

      if (!request.isValid) {
        errorMessage.value = request.validationError ?? 'Invalid batch request';
        isBatchGenerating.value = false;
        return;
      }

      // Generate all images (progress updates handled by service/backend)
      final responses = await _generationService.generateBatch(request);
      batchResults.value = responses;
      batchProgress.value = 1.0;

      // Update quota
      imagesUsed.value += responses.length;

      // Save to gallery
      for (var i = 0; i < responses.length; i++) {
        final response = responses[i];
        final generatedImage = GeneratedImage(
          id: '${DateTime.now().millisecondsSinceEpoch}_$i',
          imageUrl: response.imageUrl,
          prompt: batchPrompts[i],
          style: style.value,
          size: response.size,
          createdAt: DateTime.now(),
          cost: response.cost,
          model: response.model,
        );
        await _storageService.addImage(generatedImage);
      }

      // Wait a moment for user to see completion
      await Future.delayed(const Duration(milliseconds: 1500));

      // Close modal automatically
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Success! 🎉',
        'Successfully generated ${responses.length} images!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );

      // Clear batch prompts after successful generation
      clearBatch();
    } catch (e) {
      errorMessage.value = 'Failed to generate batch: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isBatchGenerating.value = false;
      batchProgress.value = 0.0;
      currentBatchIndex.value = 0;
    }
  }

  /// Clear single image result
  void clearResult() {
    imageResponse.value = null;
    errorMessage.value = '';
  }

  /// Reset form
  void resetForm() {
    prompt.value = '';
    style.value = 'realistic';
    aspectRatio.value = '1:1';
    enhancePrompt.value = true;
    imageResponse.value = null;
    errorMessage.value = '';
  }

  /// Add batch prompt
  void addBatchPrompt(String prompt) {
    if (batchPrompts.length < 10) {
      batchPrompts.add(prompt);
    }
  }

  /// Remove batch prompt
  void removeBatchPrompt(int index) {
    if (index >= 0 && index < batchPrompts.length) {
      batchPrompts.removeAt(index);
    }
  }

  /// Update batch prompt
  void updateBatchPrompt(int index, String prompt) {
    if (index >= 0 && index < batchPrompts.length) {
      batchPrompts[index] = prompt;
    }
  }

  /// Clear batch
  void clearBatch() {
    batchPrompts.clear();
    batchResults.clear();
    batchProgress.value = 0.0;
  }

  /// Dev-only helper to cycle forward through curated sample inputs.
  void loadNextSeed() {
    final seeder = _testSeeder;
    if (seeder == null) return;
    _applySeed(seeder.nextSeed());
  }

  /// Dev-only helper to cycle backward through curated sample inputs.
  void loadPreviousSeed() {
    final seeder = _testSeeder;
    if (seeder == null) return;
    _applySeed(seeder.previousSeed());
  }

  void _maybeApplyTestSeed({bool initial = false}) {
    final seeder = _testSeeder;
    if (seeder == null) return;
    final seed = initial ? seeder.initialSeed() : seeder.nextSeed();
    _applySeed(seed);
  }

  void _applySeed(ImageTestData seed) {
    prompt.value = seed.prompt;
    style.value = seed.style;
    aspectRatio.value = seed.aspectRatio;
    enhancePrompt.value = seed.enhancePrompt;
  }
}
