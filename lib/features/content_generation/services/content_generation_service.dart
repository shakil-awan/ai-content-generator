import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../models/content_generation_request.dart';
import '../models/content_generation_response.dart';
import '../models/content_type.dart';

/// Content Generation Service
/// Handles API calls to backend for content generation
/// Uses centralized ApiService with authentication
class ContentGenerationService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  ContentGenerationService({
    ApiService? apiService,
    FlutterSecureStorage? storage,
  }) : _apiService = apiService ?? ApiService(),
       _storage = storage ?? const FlutterSecureStorage();

  /// Get auth token from secure storage and set it in ApiService
  Future<void> _ensureAuthenticated() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      _apiService.setAuthToken(token);
    } else {
      throw ContentGenerationException(
        'Not authenticated. Please login first.',
      );
    }
  }

  /// Generate content based on type
  Future<ContentGenerationResponse> generateContent({
    required ContentType contentType,
    required Map<String, dynamic> parameters,
  }) async {
    // Ensure user is authenticated
    await _ensureAuthenticated();

    // Use the correct endpoint from ApiEndpoints based on content type
    final endpoint = _getEndpointForContentType(contentType);

    try {
      final response = await _apiService.post(endpoint, body: parameters);
      return ContentGenerationResponse.fromJson(
        response as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      // Re-throw ApiException with user-friendly message
      throw ContentGenerationException(e.userFriendlyMessage);
    } catch (e) {
      throw ContentGenerationException(
        'Failed to generate content: ${e.toString()}',
      );
    }
  }

  /// Get the correct API endpoint for the content type
  String _getEndpointForContentType(ContentType contentType) {
    switch (contentType) {
      case ContentType.blog:
        return ApiEndpoints.generateBlog;
      case ContentType.social:
        return ApiEndpoints.generateSocial;
      case ContentType.email:
        return ApiEndpoints.generateEmail;
      case ContentType.product:
        return ApiEndpoints.generateProduct;
      case ContentType.ad:
        return ApiEndpoints.generateAd;
      case ContentType.video:
        return ApiEndpoints.generateVideo;
      case ContentType.image:
        // Image generation uses its own service, not this service
        return '/api/v1/generate/image';
    }
  }

  /// Generate blog post
  Future<ContentGenerationResponse> generateBlogPost({
    required BlogPostRequest request,
  }) async {
    return generateContent(
      contentType: ContentType.blog,
      parameters: request.toJson(),
    );
  }

  /// Generate social media post
  Future<ContentGenerationResponse> generateSocialPost({
    required SocialMediaRequest request,
  }) async {
    return generateContent(
      contentType: ContentType.social,
      parameters: request.toJson(),
    );
  }

  /// Generate email campaign
  Future<ContentGenerationResponse> generateEmail({
    required EmailCampaignRequest request,
  }) async {
    return generateContent(
      contentType: ContentType.email,
      parameters: request.toJson(),
    );
  }

  /// Generate video script
  Future<ContentGenerationResponse> generateVideoScript({
    required VideoScriptRequest request,
  }) async {
    return generateContent(
      contentType: ContentType.video,
      parameters: request.toJson(),
    );
  }
}

/// Custom exception for content generation errors
class ContentGenerationException implements Exception {
  final String message;

  ContentGenerationException(this.message);

  @override
  String toString() => message;
}
