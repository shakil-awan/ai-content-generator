import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../models/video_script_request.dart';
import '../models/video_script_response.dart';

/// Video Script Generation Service
/// Handles API calls to backend for video script generation
class VideoScriptService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  VideoScriptService({ApiService? apiService, FlutterSecureStorage? storage})
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

  /// Generate video script using backend API
  Future<VideoScriptResponse> generateScript(VideoScriptRequest request) async {
    // Ensure user is authenticated
    await _ensureAuthenticated();

    try {
      print('\n═══ VIDEO SCRIPT REQUEST ═══');
      print('Endpoint: ${ApiEndpoints.generateVideo}');
      print('Request data: ${request.toJson()}');

      // Call backend API
      final response = await _apiService.post(
        ApiEndpoints.generateVideo,
        body: request.toJson(),
      );

      print('\n═══ RAW BACKEND RESPONSE ═══');
      print('Response type: ${response.runtimeType}');
      print(
        'Response keys: ${response is Map ? response.keys.toList() : "Not a Map"}',
      );
      print(
        'Has output field: ${response is Map && response.containsKey("output")}',
      );
      print(
        'Has content field: ${response is Map && response.containsKey("content")}',
      );
      print('Full response: $response');

      // Parse response
      print('\n═══ PARSING RESPONSE ═══');
      final parsedResponse = VideoScriptResponse.fromJson(response);
      print('✅ Response parsed successfully');
      print('Script sections count: ${parsedResponse.script.length}');
      return parsedResponse;
    } catch (e, stackTrace) {
      print('\n═══ ERROR IN VIDEO SCRIPT SERVICE ═══');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to generate script: $e');
    }
  }
}
