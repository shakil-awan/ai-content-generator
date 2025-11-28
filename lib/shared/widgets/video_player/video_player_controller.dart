import 'package:get/get.dart';

/// Custom Video Player Controller
/// Manages video playback state and controls
class CustomVideoPlayerController extends GetxController {
  final String videoUrl;
  final bool autoPlay;

  CustomVideoPlayerController({required this.videoUrl, this.autoPlay = false});

  // Playback state
  final isPlaying = false.obs;
  final isLoading = false.obs;
  final isPaused = false.obs;
  final isMuted = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Video info
  final duration = 0.obs; // in seconds
  final currentTime = 0.obs; // in seconds
  final volume = 1.0.obs; // 0.0 to 1.0
  final playbackSpeed = 1.0.obs;

  // UI state
  final isDescriptionExpanded = false.obs;
  final showControlsOverlay = true.obs;

  // Status message
  final status = 'Ready to play'.obs;

  @override
  void onInit() {
    super.onInit();
    if (autoPlay) {
      play();
    }
    _loadVideoMetadata();
  }

  /// Load video metadata (duration, etc.)
  Future<void> _loadVideoMetadata() async {
    try {
      isLoading.value = true;
      status.value = 'Loading video information...';

      // Simulate loading video metadata
      await Future.delayed(const Duration(milliseconds: 500));

      // In a real implementation, you would:
      // 1. Parse the video URL
      // 2. Fetch video metadata from the hosting service
      // 3. Extract duration, thumbnail, etc.

      // For now, set a default duration
      duration.value = 180; // 3 minutes default
      status.value = 'Ready to play';
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load video information';
      status.value = 'Error';
    } finally {
      isLoading.value = false;
    }
  }

  /// Play video
  void play() {
    if (hasError.value) {
      retry();
      return;
    }

    isPlaying.value = true;
    isPaused.value = false;
    status.value = 'Playing';

    // In a real implementation, this would:
    // 1. Open the video URL in a web view or native player
    // 2. Start tracking playback progress
    // 3. Update currentTime periodically
  }

  /// Pause video
  void pause() {
    isPlaying.value = false;
    isPaused.value = true;
    status.value = 'Paused';
  }

  /// Stop video
  void stop() {
    isPlaying.value = false;
    isPaused.value = false;
    currentTime.value = 0;
    status.value = 'Stopped';
  }

  /// Toggle play/pause
  void togglePlayPause() {
    if (isPlaying.value) {
      pause();
    } else {
      play();
    }
  }

  /// Seek to position (in seconds)
  void seekTo(int seconds) {
    if (seconds < 0) {
      currentTime.value = 0;
    } else if (seconds > duration.value) {
      currentTime.value = duration.value;
    } else {
      currentTime.value = seconds;
    }
  }

  /// Skip forward (default 10 seconds)
  void skipForward([int seconds = 10]) {
    seekTo(currentTime.value + seconds);
  }

  /// Skip backward (default 10 seconds)
  void skipBackward([int seconds = 10]) {
    seekTo(currentTime.value - seconds);
  }

  /// Toggle mute
  void toggleMute() {
    isMuted.value = !isMuted.value;
  }

  /// Set volume (0.0 to 1.0)
  void setVolume(double value) {
    volume.value = value.clamp(0.0, 1.0);
    isMuted.value = value == 0.0;
  }

  /// Set playback speed
  void setPlaybackSpeed(double speed) {
    playbackSpeed.value = speed;
  }

  /// Toggle description expansion
  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

  /// Retry loading video after error
  void retry() {
    hasError.value = false;
    errorMessage.value = '';
    _loadVideoMetadata();
  }

  /// Get progress percentage (0-100)
  double get progressPercentage {
    if (duration.value == 0) return 0;
    return (currentTime.value / duration.value * 100).clamp(0, 100);
  }

  /// Check if video can be played
  bool get canPlay => !isLoading.value && !hasError.value;

  @override
  void onClose() {
    stop();
    super.onClose();
  }
}
