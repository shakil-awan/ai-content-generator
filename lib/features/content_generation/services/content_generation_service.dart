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
      print('\n═══ API REQUEST ═══');
      print('Endpoint: $endpoint');
      print('Parameters: $parameters');

      final response = await _apiService.post(endpoint, body: parameters);

      print('\n═══ API RAW RESPONSE ═══');
      print('Response type: ${response.runtimeType}');
      if (response is Map<String, dynamic>) {
        print('Response keys: ${response.keys.toList()}');

        // Log fact check results specifically
        if (response.containsKey('fact_check_results')) {
          final fcr = response['fact_check_results'];
          print('\n═══ FACT CHECK RESULTS (RAW) ═══');
          print('Type: ${fcr.runtimeType}');
          if (fcr is Map<String, dynamic>) {
            print('Keys: ${fcr.keys.toList()}');
            print('checked: ${fcr['checked']}');
            print('claims_found: ${fcr['claims_found']}');
            print('claims_verified: ${fcr['claims_verified']}');
            print('overall_confidence: ${fcr['overall_confidence']}');
            print('total_searches_used: ${fcr['total_searches_used']}');

            final claims = fcr['claims'];
            print('claims type: ${claims.runtimeType}');
            print('claims length: ${claims is List ? claims.length : "N/A"}');

            if (claims is List && claims.isNotEmpty) {
              print('\nFirst claim keys: ${(claims[0] as Map).keys.toList()}');
              print('First claim verified: ${claims[0]['verified']}');
              final sources = claims[0]['sources'];
              print('First claim sources type: ${sources.runtimeType}');
              print(
                'First claim sources length: ${sources is List ? sources.length : "N/A"}',
              );

              if (sources is List && sources.isNotEmpty) {
                print(
                  'First source keys: ${(sources[0] as Map).keys.toList()}',
                );
                print(
                  'First source authority_level: ${sources[0]['authority_level']}',
                );
              }
            }
          }
        }
      }

      final parsedResponse = ContentGenerationResponse.fromJson(
        response as Map<String, dynamic>,
      );

      print('\n═══ PARSED RESPONSE ═══');
      final fcr = parsedResponse.factCheckResults;
      print('checked: ${fcr.checked}');
      print('claims length: ${fcr.claims.length}');
      print('claims_found: ${fcr.claimsFound}');
      print('claims_verified: ${fcr.claimsVerified}');
      if (fcr.claims.isNotEmpty) {
        print('First claim sources length: ${fcr.claims[0].sources.length}');
        if (fcr.claims[0].sources.isNotEmpty) {
          print(
            'First source authority: ${fcr.claims[0].sources[0].authorityLevel}',
          );
        }
      }

      return parsedResponse;
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
    print('\n═══ GENERATING EMAIL CAMPAIGN ═══');
    print('Email Type: ${request.emailType}');
    print('Subject: ${request.subject}');
    print('Message: ${request.mainMessage}');
    print('Tone: ${request.tone}');

    final requestJson = request.toJson();
    print('\n═══ REQUEST JSON TO BACKEND ═══');
    print(requestJson);

    return generateContent(
      contentType: ContentType.email,
      parameters: requestJson,
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
