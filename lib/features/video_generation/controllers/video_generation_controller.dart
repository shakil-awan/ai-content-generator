import 'dart:async';

import 'package:get/get.dart';

import '../models/generated_video.dart';
import '../models/video_generation_request.dart';
import '../models/video_generation_response.dart';
import '../services/video_generation_service.dart';

/// Video Generation Progress Step
enum VideoGenerationStep {
  preparing,
  generating,
  processing,
  finalizing,
  completed,
}

/// Video Generation Progress Model
class VideoGenerationProgress {
  final VideoGenerationStep step;
  final int percentage;
  final String message;
  final String? estimatedTimeRemaining;

  VideoGenerationProgress({
    required this.step,
    required this.percentage,
    required this.message,
    this.estimatedTimeRemaining,
  });
}

/// Video Generation Controller
/// Manages video generation, progress tracking, and quota
class VideoGenerationController extends GetxController {
  final VideoGenerationService _videoService = VideoGenerationService();

  // Generation state
  final isGenerating = false.obs;
  final currentStep = VideoGenerationStep.preparing.obs;
  final progressPercentage = 0.obs;
  final progressMessage = ''.obs;
  final estimatedTimeRemaining = ''.obs;

  // Results
  final generatedResponse = Rx<VideoGenerationResponse?>(null);
  final errorMessage = ''.obs;

  // Video library
  final videoLibrary = <GeneratedVideo>[].obs;
  final isLoadingLibrary = false.obs;

  // Quota management
  final videosUsed = 0.obs;
  final videosLimit = 10.obs; // Free tier limit

  // Stream subscription
  StreamSubscription<VideoGenerationProgress>? _progressSubscription;

  /// Check if has quota
  bool get hasQuota => videosUsed.value < videosLimit.value;

  /// Check if near quota limit (80%)
  bool get isNearLimit => videosUsed.value >= (videosLimit.value * 0.8);

  /// Get remaining videos
  int get remainingVideos => videosLimit.value - videosUsed.value;

  /// Get quota percentage
  double get quotaPercentage => videosUsed.value / videosLimit.value;

  /// Check if video is ready
  bool get hasGeneratedVideo => generatedResponse.value?.isReady ?? false;

  /// Get step display text
  String getStepDisplay(VideoGenerationStep step) {
    switch (step) {
      case VideoGenerationStep.preparing:
        return 'Preparing...';
      case VideoGenerationStep.generating:
        return 'Generating Video';
      case VideoGenerationStep.processing:
        return 'Processing';
      case VideoGenerationStep.finalizing:
        return 'Finalizing';
      case VideoGenerationStep.completed:
        return 'Completed';
    }
  }

  /// Get step icon
  String getStepIcon(VideoGenerationStep step) {
    switch (step) {
      case VideoGenerationStep.preparing:
        return '⚙️';
      case VideoGenerationStep.generating:
        return '🎬';
      case VideoGenerationStep.processing:
        return '⚡';
      case VideoGenerationStep.finalizing:
        return '✨';
      case VideoGenerationStep.completed:
        return '✅';
    }
  }

  /// Generate video
  Future<void> generateVideo(VideoGenerationRequest request) async {
    if (!hasQuota) {
      errorMessage.value = 'Video generation quota exceeded';
      Get.snackbar(
        'Quota Exceeded',
        'You have reached your video generation limit. Upgrade to continue.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    try {
      isGenerating.value = true;
      errorMessage.value = '';
      generatedResponse.value = null;
      currentStep.value = VideoGenerationStep.preparing;
      progressPercentage.value = 0;
      progressMessage.value = 'Starting video generation...';
      estimatedTimeRemaining.value = '~1.5 minutes';

      // Subscribe to progress stream
      final progressStream = _videoService.generateVideoWithProgress(request);
      _progressSubscription = progressStream.listen(
        (progress) {
          currentStep.value = progress.step;
          progressPercentage.value = progress.percentage;
          progressMessage.value = progress.message;
          estimatedTimeRemaining.value = progress.estimatedTimeRemaining ?? '';
        },
        onError: (error) {
          errorMessage.value = 'Failed to generate video: ${error.toString()}';
          isGenerating.value = false;
          Get.snackbar(
            'Error',
            errorMessage.value,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
        },
      );

      // Generate video
      final response = await _videoService.generateVideo(request);
      generatedResponse.value = response;

      // Update quota
      videosUsed.value++;

      // Add to library
      final video = GeneratedVideo(
        id: response.videoId,
        title: request.topic,
        videoUrl: response.videoUrl,
        thumbnailUrl: response.thumbnailUrl,
        platform: request.platform,
        durationSeconds: response.durationSeconds,
        scriptId: request.scriptId,
        createdAt: DateTime.now(),
        status: response.status,
        metadata: response.metadata,
      );
      videoLibrary.insert(0, video);

      Get.snackbar(
        'Success! 🎉',
        'Your video is ready',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      errorMessage.value = 'Failed to generate video: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isGenerating.value = false;
      _progressSubscription?.cancel();
      _progressSubscription = null;
    }
  }

  /// Cancel video generation
  void cancelGeneration() {
    _progressSubscription?.cancel();
    _progressSubscription = null;
    isGenerating.value = false;
    currentStep.value = VideoGenerationStep.preparing;
    progressPercentage.value = 0;
    errorMessage.value = '';
  }

  /// Load video library
  Future<void> loadLibrary() async {
    try {
      isLoadingLibrary.value = true;
      final videos = await _videoService.getVideoLibrary();
      videoLibrary.value = videos;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load video library: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingLibrary.value = false;
    }
  }

  /// Delete video from library
  Future<void> deleteVideo(String videoId) async {
    try {
      await _videoService.deleteVideo(videoId);
      videoLibrary.removeWhere((v) => v.id == videoId);
      Get.snackbar(
        'Deleted',
        'Video removed from library',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete video: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Clear generated result
  void clearResult() {
    generatedResponse.value = null;
    errorMessage.value = '';
    currentStep.value = VideoGenerationStep.preparing;
    progressPercentage.value = 0;
  }

  @override
  void onInit() {
    super.onInit();
    // Load initial library
    loadLibrary();
  }

  @override
  void onClose() {
    _progressSubscription?.cancel();
    super.onClose();
  }
}
