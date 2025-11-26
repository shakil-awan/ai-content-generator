import 'package:get/get.dart';

import '../models/humanization_result.dart';
import '../services/humanization_service.dart';

/// Humanization Controller
/// Manages AI humanization state and operations
class HumanizationController extends GetxController {
  final HumanizationService _service = HumanizationService();

  // Observable state
  final selectedLevel = 'balanced'.obs; // 'light', 'balanced', 'aggressive'
  final preserveFacts = true.obs;
  final isHumanizing = false.obs;
  final currentStep = 0.obs; // 0-2 for progress indicator
  final humanizationResult = Rxn<HumanizationResult>();
  final showComparison = false.obs;
  final errorMessage = ''.obs;

  // Quota management
  final humanizationsUsed = 0.obs;
  final humanizationsLimit = 0.obs; // 5 Free, 25 Hobby, -1 Unlimited

  // Computed properties
  bool get hasQuota =>
      humanizationsLimit.value == -1 ||
      humanizationsUsed.value < humanizationsLimit.value;

  bool get isNearLimit =>
      humanizationsLimit.value > 0 &&
      (humanizationsUsed.value / humanizationsLimit.value) >= 0.8;

  String get quotaText {
    if (humanizationsLimit.value == -1) return 'Unlimited';
    return '${humanizationsUsed.value}/${humanizationsLimit.value} used this month';
  }

  int get remainingQuota {
    if (humanizationsLimit.value == -1) return -1;
    return humanizationsLimit.value - humanizationsUsed.value;
  }

  /// Load quota from backend
  Future<void> loadQuota() async {
    try {
      final quota = await _service.getHumanizationQuota();
      humanizationsUsed.value = quota['used'] ?? 0;
      humanizationsLimit.value = quota['limit'] ?? 0;
    } catch (e) {
      print('Error loading quota: $e');
    }
  }

  /// Humanize content
  Future<void> humanizeContent(String generationId) async {
    if (!hasQuota) {
      errorMessage.value = 'Monthly humanization limit reached';
      return;
    }

    try {
      isHumanizing.value = true;
      errorMessage.value = '';
      currentStep.value = 0;

      // Step 1: Detecting AI patterns (simulate delay)
      await Future.delayed(const Duration(milliseconds: 500));
      currentStep.value = 1;

      // Step 2: Rewriting content
      await Future.delayed(const Duration(milliseconds: 500));
      currentStep.value = 2;

      // Call API
      final result = await _service.humanizeContent(
        generationId: generationId,
        level: selectedLevel.value,
        preserveFacts: preserveFacts.value,
      );

      // Step 3: Analyzing humanized version
      await Future.delayed(const Duration(milliseconds: 500));

      humanizationResult.value = result;
      humanizationsUsed.value++;
    } catch (e) {
      errorMessage.value = 'Humanization failed: ${e.toString()}';
      print('Humanization error: $e');
    } finally {
      isHumanizing.value = false;
      currentStep.value = 0;
    }
  }

  /// Update humanization level
  void updateLevel(String level) {
    if (['light', 'balanced', 'aggressive'].contains(level)) {
      selectedLevel.value = level;
    }
  }

  /// Toggle preserve facts
  void togglePreserveFacts() {
    preserveFacts.value = !preserveFacts.value;
  }

  /// Toggle comparison view
  void toggleComparison() {
    showComparison.value = !showComparison.value;
  }

  /// Reset state
  void resetState() {
    selectedLevel.value = 'balanced';
    preserveFacts.value = true;
    isHumanizing.value = false;
    currentStep.value = 0;
    humanizationResult.value = null;
    showComparison.value = false;
    errorMessage.value = '';
  }

  /// Clear error
  void clearError() {
    errorMessage.value = '';
  }

  @override
  void onInit() {
    super.onInit();
    loadQuota();
  }
}
