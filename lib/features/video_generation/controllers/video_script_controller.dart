import 'package:get/get.dart';

import '../models/video_script_request.dart';
import '../models/video_script_response.dart';
import '../services/video_script_service.dart';

/// Video Script Generation Controller
/// Manages form state and script generation
class VideoScriptController extends GetxController {
  final VideoScriptService _scriptService = VideoScriptService();

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

  // Available tones
  final List<String> tones = [
    'professional',
    'casual',
    'energetic',
    'educational',
    'humorous',
    'inspirational',
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
      // For now, we'll just show a success message
      Get.snackbar(
        'Copied!',
        'Script copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Copy hashtags
  void copyHashtags() {
    if (generatedScript.value != null) {
      // In a real app, this would use Clipboard API
      Get.snackbar(
        'Copied!',
        'Hashtags copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
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

      // Expand first section by default
      expandedSections.clear();
      expandedSections.add(0);
    } catch (e) {
      errorMessage.value = 'Failed to generate script: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
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
  }
}
