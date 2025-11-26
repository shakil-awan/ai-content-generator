import 'package:get/get.dart';

import '../models/fact_check_claim.dart';
import '../models/fact_check_results.dart';
import '../services/fact_check_service.dart';

/// Fact Check Controller
/// Manages fact-checking state and operations using GetX
class FactCheckController extends GetxController {
  final FactCheckService _factCheckService = FactCheckService();

  // Observable state
  final isFactCheckEnabled = false.obs;
  final confidenceThreshold = 70.obs; // 50-95%
  final factCheckResults = Rxn<FactCheckResults>(); // nullable
  final isLoading = false.obs;
  final currentClaim = 0.obs; // For progress tracking
  final totalClaims = 0.obs;
  final errorMessage = ''.obs;
  final quotaUsed = 0.obs; // For Hobby tier
  final quotaLimit = 10.obs; // Hobby tier limit

  // Computed properties
  bool get hasQuotaRemaining => quotaUsed.value < quotaLimit.value;
  double get quotaPercentage => quotaUsed.value / quotaLimit.value;
  bool get isQuotaExceeded => quotaUsed.value >= quotaLimit.value;
  int get quotaRemaining => quotaLimit.value - quotaUsed.value;

  /// Get progress percentage for loading indicator
  double get verificationProgress {
    if (totalClaims.value == 0) return 0.0;
    return currentClaim.value / totalClaims.value;
  }

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    checkQuota();
  }

  /// Load fact-check settings from storage/API
  Future<void> loadSettings() async {
    try {
      // TODO: Load from Firebase or local storage
      // For now, use default values
      isFactCheckEnabled.value = false;
      confidenceThreshold.value = 70;
    } catch (e) {
      print('Error loading fact-check settings: $e');
    }
  }

  /// Save fact-check settings to storage/API
  Future<void> saveSettings() async {
    try {
      // TODO: Save to Firebase or API
      // Example: await _factCheckService.saveSettings(
      //   autoFactCheck: isFactCheckEnabled.value,
      //   confidenceThreshold: confidenceThreshold.value,
      // );
      print(
        'Saving settings: enabled=${isFactCheckEnabled.value}, threshold=${confidenceThreshold.value}',
      );
    } catch (e) {
      print('Error saving fact-check settings: $e');
      errorMessage.value = 'Failed to save settings';
    }
  }

  /// Check quota usage from API
  Future<void> checkQuota() async {
    try {
      // TODO: Implement API call to get quota
      // final quota = await _factCheckService.getQuota();
      // quotaUsed.value = quota['used'];
      // quotaLimit.value = quota['limit'];

      // Mock data for now
      quotaUsed.value = 7;
      quotaLimit.value = 10;
    } catch (e) {
      print('Error checking quota: $e');
    }
  }

  /// Toggle fact-check enable/disable
  void toggleFactCheck(bool enabled) {
    isFactCheckEnabled.value = enabled;
    saveSettings();
  }

  /// Update confidence threshold
  void updateConfidenceThreshold(double value) {
    confidenceThreshold.value = value.round();
    saveSettings();
  }

  /// Verify content by extracting and checking claims
  Future<FactCheckResults> verifyContent(String content) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentClaim.value = 0;

      // Check quota before proceeding
      if (isQuotaExceeded) {
        throw Exception('Quota limit reached');
      }

      // Call API to verify content
      final results = await _factCheckService.verifyContent(content);

      // Update progress tracking
      totalClaims.value = results.totalClaims;
      currentClaim.value = results.totalClaims;

      // Update quota
      quotaUsed.value++;

      // Store results
      factCheckResults.value = results;

      return results;
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error verifying content: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Simulate progressive verification (for UI demonstration)
  Future<void> verifyContentWithProgress(String content) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Check quota
      if (isQuotaExceeded) {
        throw Exception('Quota limit reached');
      }

      // Simulate extracting claims first
      totalClaims.value = 5; // Mock: assume 5 claims found
      currentClaim.value = 0;

      // Simulate progressive verification
      for (int i = 0; i < totalClaims.value; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        currentClaim.value = i + 1;
      }

      // Get final results
      final results = await _factCheckService.verifyContent(content);
      factCheckResults.value = results;

      // Update quota
      quotaUsed.value++;
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error verifying content: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear fact-check results
  void clearResults() {
    factCheckResults.value = null;
    currentClaim.value = 0;
    totalClaims.value = 0;
    errorMessage.value = '';
  }

  /// Retry verification after error
  Future<void> retry(String content) async {
    await verifyContent(content);
  }

  /// Show quota exceeded modal (to be called by UI)
  void showQuotaExceededModal() {
    // This will be handled by the UI widget
    // Controller just tracks state
  }

  /// Filter claims by confidence threshold
  List<FactCheckClaim> getFilteredClaims() {
    if (factCheckResults.value == null) return [];

    final threshold = confidenceThreshold.value / 100.0;
    return factCheckResults.value!.claims
        .where((claim) => claim.confidence >= threshold)
        .toList();
  }

  /// Get claims count by verification status
  Map<String, int> getClaimsBreakdown() {
    if (factCheckResults.value == null) {
      return {'verified': 0, 'partial': 0, 'unverified': 0};
    }

    final results = factCheckResults.value!;
    return {
      'verified': results.verifiedCount,
      'partial': results.partiallyVerifiedCount,
      'unverified': results.unverifiedCount,
    };
  }
}
