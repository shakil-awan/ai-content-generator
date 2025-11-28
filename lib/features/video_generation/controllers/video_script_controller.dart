import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/video_from_script_request.dart';
import '../models/video_script_request.dart';
import '../models/video_script_response.dart';
import '../services/video_generation_service.dart';
import '../services/video_script_service.dart';
import '../utils/video_script_test_data.dart';

/// Video Script Generation Controller
/// Manages form state and script generation
class VideoScriptController extends GetxController {
  final VideoScriptService _scriptService = VideoScriptService();
  final VideoGenerationService _videoService = VideoGenerationService();
  final VideoScriptTestSeeder? _testSeeder;

  VideoScriptController({VideoScriptTestSeeder? testSeeder})
    : _testSeeder =
          testSeeder ??
          (VideoScriptTestSeeder.isEnabled ? VideoScriptTestSeeder() : null);

  // Form fields
  final topic = ''.obs;
  final platform = 'youtube'.obs;
  final duration = 60.obs; // seconds
  final targetAudience = ''.obs;
  final keyPoints = <String>[].obs;
  final cta = ''.obs;
  final tone = 'professional'.obs;
  final includeHooks = true.obs;
  final includeCta = true.obs;

  // Generation state
  final isGenerating = false.obs;
  final generatedScript = Rx<VideoScriptResponse?>(null);
  final errorMessage = ''.obs;
  final generationId = ''.obs; // Store generation ID from API response

  // Video generation state
  final isGeneratingVideo = false.obs;
  final videoProgress = 0.obs;
  final videoStatus = ''.obs;
  final generatedVideoUrl = ''.obs;
  final videoJobId = ''.obs;
  final videoError = ''.obs;

  // UI state
  final expandedSections = <int>{}.obs;
  final expandedHashtags = false.obs;

  // Available platforms
  final List<Map<String, String>> platforms = [
    {'id': 'youtube', 'name': 'YouTube', 'emoji': '🎬'},
    {'id': 'tiktok', 'name': 'TikTok', 'emoji': '🎵'},
    {'id': 'instagram', 'name': 'Instagram Reels', 'emoji': '📸'},
    {'id': 'linkedin', 'name': 'LinkedIn', 'emoji': '💼'},
  ];

  // Available tones (must match backend Tone enum)
  final List<String> tones = [
    'professional',
    'casual',
    'friendly',
    'formal',
    'humorous',
    'inspirational',
    'informative',
  ];

  // Duration presets (in seconds)
  final List<Map<String, dynamic>> durationPresets = [
    {'label': '30s', 'seconds': 30},
    {'label': '60s', 'seconds': 60},
    {'label': '90s', 'seconds': 90},
    {'label': '3 min', 'seconds': 180},
    {'label': '5 min', 'seconds': 300},
  ];

  /// Get current platform display name
  String get platformDisplay {
    final p = platforms.firstWhere(
      (p) => p['id'] == platform.value,
      orElse: () => platforms.first,
    );
    return p['name']!;
  }

  /// Get current platform emoji
  String get platformEmoji {
    final p = platforms.firstWhere(
      (p) => p['id'] == platform.value,
      orElse: () => platforms.first,
    );
    return p['emoji']!;
  }

  /// Get duration display
  String get durationDisplay {
    if (duration.value < 60) {
      return '${duration.value}s';
    } else {
      final minutes = duration.value ~/ 60;
      final seconds = duration.value % 60;
      if (seconds == 0) {
        return '${minutes}m';
      }
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Check if form is valid
  bool get isFormValid {
    return topic.value.length >= 3 &&
        topic.value.length <= 200 &&
        duration.value >= 15 &&
        duration.value <= 600;
  }

  /// Check if script exists
  bool get hasScript => generatedScript.value != null;

  @override
  void onInit() {
    super.onInit();
    _maybeApplyTestSeed(initial: true);
  }

  /// Add key point
  void addKeyPoint(String point) {
    if (point.isNotEmpty && keyPoints.length < 10) {
      keyPoints.add(point);
    }
  }

  /// Remove key point
  void removeKeyPoint(int index) {
    if (index >= 0 && index < keyPoints.length) {
      keyPoints.removeAt(index);
    }
  }

  /// Toggle section expansion
  void toggleSection(int index) {
    if (expandedSections.contains(index)) {
      expandedSections.remove(index);
    } else {
      expandedSections.add(index);
    }
  }

  /// Expand all sections
  void expandAllSections() {
    if (generatedScript.value != null) {
      expandedSections.clear();
      for (var i = 0; i < generatedScript.value!.script.length; i++) {
        expandedSections.add(i);
      }
    }
  }

  /// Collapse all sections
  void collapseAllSections() {
    expandedSections.clear();
  }

  /// Copy full script
  void copyScript() {
    if (generatedScript.value != null) {
      // In a real app, this would use Clipboard API
      // TODO: Implement clipboard copy functionality
    }
  }

  /// Copy hashtags
  void copyHashtags() {
    if (generatedScript.value != null) {
      // In a real app, this would use Clipboard API
      // TODO: Implement clipboard copy functionality
    }
  }

  /// Generate script
  Future<void> generateScript() async {
    if (!isFormValid) {
      errorMessage.value = 'Please fill in all required fields correctly';
      return;
    }

    try {
      isGenerating.value = true;
      errorMessage.value = '';
      generatedScript.value = null;

      final request = VideoScriptRequest(
        topic: topic.value,
        platform: platform.value,
        duration: duration.value,
        targetAudience: targetAudience.value,
        keyPoints: keyPoints.toList(),
        cta: cta.value,
        tone: tone.value,
        includeHooks: includeHooks.value,
        includeCta: includeCta.value,
      );

      final response = await _scriptService.generateScript(request);
      generatedScript.value = response;

      // Store generation ID for video generation
      if (response.id != null && response.id!.isNotEmpty) {
        generationId.value = response.id!;
      } else {
        // Fallback if backend doesn't return ID yet
        generationId.value = 'gen_${DateTime.now().millisecondsSinceEpoch}';
      }

      // Expand first section by default
      expandedSections.clear();
      expandedSections.add(0);

      // Success! The UI will automatically show the results via Obx reactivity
      // No snackbar needed as the results display provides clear success feedback
    } catch (e) {
      errorMessage.value = 'Failed to generate script: ${e.toString()}';
      // Error message will be displayed in the UI via errorMessage observable
    } finally {
      isGenerating.value = false;
    }
  }

  /// Reset form
  void resetForm() {
    topic.value = '';
    platform.value = 'youtube';
    duration.value = 60;
    targetAudience.value = '';
    keyPoints.clear();
    cta.value = '';
    tone.value = 'professional';
    includeHooks.value = true;
    includeCta.value = true;
    generatedScript.value = null;
    errorMessage.value = '';
    expandedSections.clear();
    expandedHashtags.value = false;
  }

  /// Clear generated script (keep form data)
  void clearScript() {
    generatedScript.value = null;
    errorMessage.value = '';
    expandedSections.clear();
    expandedHashtags.value = false;
    // Clear video state
    isGeneratingVideo.value = false;
    videoProgress.value = 0;
    videoStatus.value = '';
    generatedVideoUrl.value = '';
    videoJobId.value = '';
    videoError.value = '';
  }

  /// Generate video from current script
  Future<void> generateVideoFromScript() async {
    if (generationId.value.isEmpty) {
      videoError.value =
          'Generation ID not found. Please generate a script first.';
      return;
    }

    try {
      isGeneratingVideo.value = true;
      videoError.value = '';
      videoProgress.value = 0;
      videoStatus.value = 'Starting video generation...';
      generatedVideoUrl.value = '';

      // Create request
      final request = VideoFromScriptRequest(
        generationId: generationId.value,
        voiceStyle: tone.value,
        musicMood: generatedScript.value?.recommendedMusic.isNotEmpty == true
            ? generatedScript.value!.recommendedMusic.first
            : 'upbeat',
        videoStyle: 'modern',
        includeSubtitles: true,
        includeCaptions: true,
      );

      // Submit video generation request
      final jobResponse = await _videoService.generateVideoFromScript(request);
      videoJobId.value = jobResponse.id;

      // Poll for completion
      await for (final status in _videoService.pollVideoStatus(
        jobResponse.id,
      )) {
        videoProgress.value = status.progress;
        videoStatus.value = status.status;

        if (status.isCompleted) {
          generatedVideoUrl.value = status.videoUrl ?? '';
          videoStatus.value = 'Video ready!';
          // Success is shown in the UI via video state
          break;
        } else if (status.isFailed) {
          videoError.value = status.error ?? 'Video generation failed';
          // Error is shown in the UI via videoError state
          break;
        }
      }
    } catch (e) {
      videoError.value = 'Failed to generate video: ${e.toString()}';
      // Error is shown in the UI via videoError state
    } finally {
      isGeneratingVideo.value = false;
    }
  }

  /// Check if video is ready
  bool get hasVideo => generatedVideoUrl.value.isNotEmpty;

  /// Download video
  Future<void> downloadVideo() async {
    if (generatedVideoUrl.value.isEmpty) return;

    try {
      final uri = Uri.parse(generatedVideoUrl.value);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        Get.snackbar(
          '✅ Success',
          'Video download started',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        throw Exception('Cannot open video URL');
      }
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Failed to download video: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Share video (copies URL to clipboard)
  Future<void> shareVideo() async {
    if (generatedVideoUrl.value.isEmpty) return;

    try {
      await Clipboard.setData(ClipboardData(text: generatedVideoUrl.value));

      Get.snackbar(
        '✅ Copied!',
        'Video URL copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Failed to copy video URL',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
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

  void _applySeed(VideoScriptTestData seed) {
    topic.value = seed.topic;
    platform.value = seed.platform;
    duration.value = seed.duration;
    targetAudience.value = seed.targetAudience;
    keyPoints.value = seed.keyPoints.toList();
    cta.value = seed.cta;
    tone.value = seed.tone;
    includeHooks.value = seed.includeHooks;
    includeCta.value = seed.includeCta;
  }
}
