import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';
import '../models/fact_check_results.dart';

/// Fact Check Service
/// Handles API calls for fact-checking operations
class FactCheckService {
  final AuthService _authService = AuthService();

  /// Verify content and return fact-check results
  /// Calls backend API which extracts claims and verifies them using Google Search
  Future<FactCheckResults> verifyContent(String content) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.factCheck}'),
        headers: ApiEndpoints.headersWithAuth(token),
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FactCheckResults.fromJson(data);
      } else {
        throw Exception('Failed to verify content: ${response.statusCode}');
      }
    } catch (e) {
      developer.log(
        'Error in fact-check service: $e',
        name: 'FactCheckService',
      );
      rethrow;
    }
  }

  /// Save user's fact-check settings
  Future<void> saveSettings({
    required bool autoFactCheck,
    required int confidenceThreshold,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.put(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.userProfile}'),
        headers: ApiEndpoints.headersWithAuth(token),
        body: jsonEncode({
          'factCheckSettings': {
            'autoFactCheck': autoFactCheck,
            'confidenceThreshold': confidenceThreshold,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save settings: ${response.statusCode}');
      }

      developer.log(
        'Settings saved - autoFactCheck: $autoFactCheck, threshold: $confidenceThreshold',
        name: 'FactCheckService',
      );
    } catch (e) {
      developer.log('Error saving settings: $e', name: 'FactCheckService');
      rethrow;
    }
  }

  /// Load user's fact-check settings
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.userProfile}'),
        headers: ApiEndpoints.headersWithAuth(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['factCheckSettings'] ??
            {'autoFactCheck': false, 'confidenceThreshold': 70};
      }

      return {'autoFactCheck': false, 'confidenceThreshold': 70};
    } catch (e) {
      developer.log('Error loading settings: $e', name: 'FactCheckService');
      return {'autoFactCheck': false, 'confidenceThreshold': 70};
    }
  }

  /// Get user's fact-check quota
  Future<Map<String, dynamic>> getQuota() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.usage}'),
        headers: ApiEndpoints.headersWithAuth(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'used': data['factChecksUsed'] ?? 0,
          'limit': data['factChecksLimit'] ?? 10,
          'tier': data['plan'] ?? 'free',
        };
      }

      return {'used': 0, 'limit': 10, 'tier': 'free'};
    } catch (e) {
      developer.log('Error getting quota: $e', name: 'FactCheckService');
      return {'used': 0, 'limit': 10, 'tier': 'free'};
    }
  }

  /// Check if fact-checking is included in content generation response
  /// This is used when content is generated with autoFactCheck enabled
  FactCheckResults? extractFactCheckResults(Map<String, dynamic> response) {
    try {
      if (response.containsKey('factCheckResults')) {
        return FactCheckResults.fromJson(
          response['factCheckResults'] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      developer.log(
        'Error extracting fact-check results: $e',
        name: 'FactCheckService',
      );
      return null;
    }
  }
}
