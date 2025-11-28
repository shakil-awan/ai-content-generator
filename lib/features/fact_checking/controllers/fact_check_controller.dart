import 'dart:developer';

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
      final settings = await _factCheckService.loadSettings();
      isFactCheckEnabled.value = settings['autoFactCheck'] ?? false;
      confidenceThreshold.value = settings['confidenceThreshold'] ?? 70;
    } catch (e) {
      log('Error loading fact-check settings: $e', name: 'FactCheckController');
      // Use defaults on error
      isFactCheckEnabled.value = false;
      confidenceThreshold.value = 70;
    }
  }

  /// Save fact-check settings to storage/API
  Future<void> saveSettings() async {
    try {
      await _factCheckService.saveSettings(
        autoFactCheck: isFactCheckEnabled.value,
        confidenceThreshold: confidenceThreshold.value,
      );
      log(
        'Settings saved: enabled=${isFactCheckEnabled.value}, threshold=${confidenceThreshold.value}',
        name: 'FactCheckController',
      );
    } catch (e) {
      log('Error saving fact-check settings: $e', name: 'FactCheckController');
      errorMessage.value = 'Failed to save settings';
    }
  }

  /// Check quota usage from API
  Future<void> checkQuota() async {
    try {
      final quota = await _factCheckService.getQuota();
      quotaUsed.value = quota['used'];
      quotaLimit.value = quota['limit'];
    } catch (e) {
      log('Error checking quota: $e', name: 'FactCheckController');
      // Set defaults on error
      quotaUsed.value = 0;
      quotaLimit.value = 10;
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
      log('Error verifying content: $e', name: 'FactCheckController');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify content with progress updates
  Future<void> verifyContentWithProgress(String content) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Check quota
      if (isQuotaExceeded) {
        throw Exception('Quota limit reached');
      }

      // Start verification (backend does the actual work)
      currentClaim.value = 0;
      totalClaims.value = 0;

      // Get results from backend
      final results = await _factCheckService.verifyContent(content);

      // Update progress
      totalClaims.value = results.totalClaims;
      currentClaim.value = results.totalClaims;

      factCheckResults.value = results;

      // Update quota
      quotaUsed.value++;
    } catch (e) {
      errorMessage.value = e.toString();
      log('Error verifying content: $e', name: 'FactCheckController');
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
