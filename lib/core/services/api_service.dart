import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

/// API Service using HTTP package
/// Centralized API calls with error handling and authentication
/// Uses ApiEndpoints for base URL and headers
class ApiService {
  final http.Client _client = http.Client();
  String? _authToken;

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Get headers using centralized ApiEndpoints
  Map<String, String> _getHeaders({Map<String, String>? additionalHeaders}) {
    // Use centralized headers from ApiEndpoints
    final headers = _authToken != null
        ? ApiEndpoints.headersWithAuth(_authToken!)
        : Map<String, String>.from(ApiEndpoints.headers);

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      // Parse error response
      try {
        final errorData = json.decode(response.body);

        // Backend returns structured errors like:
        // { "error": "email_already_exists", "message": "...", "field": "email" }
        // or simple errors like:
        // { "detail": "..." }
        // or validation errors:
        // { "detail": [{"msg": "...", "type": "...", "loc": [...]}] }

        String errorMessage;
        String? errorCode;
        String? errorField;

        // Check if detail is a dict with error/message/field structure
        if (errorData['detail'] is Map) {
          final detail = errorData['detail'] as Map<String, dynamic>;
          errorCode = detail['error'] as String?;
          errorMessage = detail['message'] as String? ?? 'An error occurred';
          errorField = detail['field'] as String?;
        }
        // Check if detail is a list (validation errors from FastAPI)
        else if (errorData['detail'] is List) {
          final details = errorData['detail'] as List;
          if (details.isNotEmpty) {
            final firstError = details[0] as Map<String, dynamic>;
            errorMessage = firstError['msg'] as String? ?? 'Validation error';
            final loc = firstError['loc'] as List?;
            if (loc != null && loc.length > 1) {
              errorField = loc[1].toString();
            }
          } else {
            errorMessage = 'Validation error';
          }
        }
        // Check if detail is a string
        else if (errorData['detail'] is String) {
          errorMessage = errorData['detail'] as String;
        }
        // Fallback to message field
        else {
          errorMessage = errorData['message'] as String? ?? 'An error occurred';
        }

        throw ApiException(
          errorMessage,
          statusCode: response.statusCode,
          errorCode: errorCode,
          errorField: errorField,
        );
      } catch (e) {
        if (e is ApiException) rethrow;

        // Failed to parse error, return generic message
        if (response.statusCode == 401) {
          throw ApiException(
            'Unauthorized. Please login again.',
            statusCode: 401,
          );
        } else if (response.statusCode == 404) {
          throw ApiException('Resource not found', statusCode: 404);
        } else if (response.statusCode >= 500) {
          throw ApiException(
            'Server error. Please try again later.',
            statusCode: response.statusCode,
          );
        } else {
          throw ApiException(
            'Something went wrong',
            statusCode: response.statusCode,
          );
        }
      }
    }
  }

  /// GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await _client.get(uri, headers: _getHeaders());
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      if (kDebugMode) print('API Error: $e');
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// POST request
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
      final response = await _client.post(
        uri,
        headers: _getHeaders(),
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      if (kDebugMode) print('API Error: $e');
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// PUT request
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
      final response = await _client.put(
        uri,
        headers: _getHeaders(),
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      if (kDebugMode) print('API Error: $e');
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
      final response = await _client.delete(uri, headers: _getHeaders());
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      if (kDebugMode) print('API Error: $e');
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Dispose client
  void dispose() {
    _client.close();
  }
}

/// Custom API Exception with enhanced error details
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode; // Backend error code like "email_already_exists"
  final String? errorField; // Field that caused the error like "email"

  ApiException(
    this.message, {
    this.statusCode,
    this.errorCode,
    this.errorField,
  });

  @override
  String toString() => message;

  /// Check if error is a specific type
  bool isErrorCode(String code) => errorCode == code;

  /// Get user-friendly message for common auth errors
  String get userFriendlyMessage {
    switch (errorCode) {
      case 'email_already_exists':
        return 'This email is already registered. Please use a different email or try logging in.';
      case 'email_not_found':
        return 'No account found with this email. Please check your email or sign up.';
      case 'incorrect_password':
        return 'Incorrect password. Please try again or use "Forgot Password".';
      case 'invalid_token':
        return 'Your session has expired. Please login again.';
      case 'expired_token':
        return 'Your session has expired. Please login again.';
      default:
        return message;
    }
  }
}
