import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../models/auth_models.dart';

/// Authentication Service using ApiService
class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  AuthService({ApiService? apiService, FlutterSecureStorage? storage})
    : _apiService = apiService ?? ApiService(),
      _storage = storage ?? const FlutterSecureStorage();

  /// Register new user (returns UserResponse)
  Future<UserResponse> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.register,
      body: {
        'email': email,
        'password': password,
        if (displayName != null && displayName.isNotEmpty)
          'display_name': displayName,
      },
    );

    return UserResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Login with email and password
  Future<TokenResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
    );

    final tokenResponse = TokenResponse.fromJson(
      response as Map<String, dynamic>,
    );

    // Store tokens
    await _saveTokens(tokenResponse.accessToken, tokenResponse.refreshToken);

    // Set auth token in ApiService
    _apiService.setAuthToken(tokenResponse.accessToken);

    return tokenResponse;
  }

  /// Google OAuth sign in
  Future<TokenResponse> googleSignIn(String firebaseIdToken) async {
    final response = await _apiService.post(
      ApiEndpoints.googleAuth,
      body: {'id_token': firebaseIdToken},
    );

    final tokenResponse = TokenResponse.fromJson(
      response as Map<String, dynamic>,
    );

    // Store tokens
    await _saveTokens(tokenResponse.accessToken, tokenResponse.refreshToken);

    // Set auth token in ApiService
    _apiService.setAuthToken(tokenResponse.accessToken);

    return tokenResponse;
  }

  /// Refresh access token
  Future<String> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await _apiService.post(
      ApiEndpoints.refreshToken,
      body: {'refresh_token': refreshToken},
    );

    final newAccessToken = response['access_token'] as String;

    // Store new access token
    await _storage.write(key: AppConstants.tokenKey, value: newAccessToken);

    // Update ApiService token
    _apiService.setAuthToken(newAccessToken);

    return newAccessToken;
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _apiService.post(ApiEndpoints.logout, body: {});
    } catch (e) {
      // Continue with local logout
    } finally {
      await clearTokens();
      _apiService.clearAuthToken();
    }
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Save tokens to secure storage
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: AppConstants.tokenKey, value: accessToken);
    await _storage.write(
      key: AppConstants.refreshTokenKey,
      value: refreshToken,
    );
  }

  /// Clear all stored tokens
  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }
}
