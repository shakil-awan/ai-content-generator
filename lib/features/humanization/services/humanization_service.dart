import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../models/humanization_json_keys.dart';
import '../models/humanization_result.dart';

/// Humanization Service
/// Handles API calls for AI humanization operations
class HumanizationService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  /// Constructor with dependency injection
  HumanizationService({ApiService? apiService, FlutterSecureStorage? storage})
    : _apiService = apiService ?? ApiService(),
      _storage = storage ?? const FlutterSecureStorage();

  /// Get auth token from secure storage and set it in ApiService
  Future<void> _ensureAuthenticated() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      _apiService.setAuthToken(token);
    } else {
      throw Exception('Not authenticated. Please login first.');
    }
  }

  /// Humanize content and return results
  /// Calls backend API to detect AI patterns and rewrite content
  ///
  /// Throws:
  /// - Exception with 'quota_exceeded' if user has reached monthly limit
  /// - Exception with 'not_found' if generation doesn't exist
  /// - Exception with 'unauthorized' if user doesn't own generation
  /// - Exception with 'already_humanized' if content was previously humanized
  Future<HumanizationResult> humanizeContent({
    required String generationId,
    required String level,
    required bool preserveFacts,
    required String originalContent,
  }) async {
    // Ensure user is authenticated
    await _ensureAuthenticated();

    try {
      log(
        'Humanizing content: generationId=$generationId, level=$level, preserveFacts=$preserveFacts',
      );

      // Call backend API using ApiService
      // Endpoint: POST /api/v1/humanize/{generationId}
      final endpoint = ApiEndpoints.humanizeContent(generationId);

      final response = await _apiService.post(
        endpoint,
        body: {
          HumanizationJsonKeys.level: level,
          HumanizationJsonKeys.preserveFacts: preserveFacts,
        },
      );

      log(
        'Humanization response received: ${response.toString().substring(0, 100)}...',
      );

      // Parse response as HumanizationResult
      return HumanizationResult.fromJson(response as Map<String, dynamic>);
    } on ApiException catch (e) {
      // Handle specific API errors
      log('API error during humanization: ${e.message}', level: 900);

      if (e.statusCode == 402) {
        throw Exception('quota_exceeded: ${e.message}');
      } else if (e.statusCode == 404) {
        throw Exception('not_found: ${e.message}');
      } else if (e.statusCode == 403) {
        throw Exception('unauthorized: ${e.message}');
      } else if (e.statusCode == 400 && e.errorCode == 'already_humanized') {
        throw Exception('already_humanized: ${e.message}');
      }

      throw Exception('Failed to humanize content: ${e.message}');
    } catch (e) {
      log('Unexpected error during humanization: $e', level: 1000);
      throw Exception('Failed to humanize content: ${e.toString()}');
    }
  }

  /// Get humanization quota for current user
  /// Fetches from user profile in Firebase (usageThisMonth.humanizations)
  Future<Map<String, int>> getHumanizationQuota() async {
    // Ensure user is authenticated
    await _ensureAuthenticated();

    try {
      log('Fetching humanization quota');

      // Get user profile which contains quota info
      final response = await _apiService.get(ApiEndpoints.userProfile);

      final usageThisMonth =
          response['usageThisMonth'] as Map<String, dynamic>?;
      final used = usageThisMonth?['humanizations'] as int? ?? 0;
      final limit = usageThisMonth?['humanizationsLimit'] as int? ?? 5;

      log('Quota: $used/$limit');
      return {'used': used, 'limit': limit};
    } catch (e) {
      log('Error getting quota: $e', level: 900);
      // Return safe defaults on error
      return {'used': 0, 'limit': 5};
    }
  }
}
