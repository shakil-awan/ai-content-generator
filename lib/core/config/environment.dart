/// Environment Configuration for Flutter App
/// Manages different environments (development, staging, production)
///
/// Usage:
///   1. Set environment at compile time:
///      flutter build web --dart-define=ENVIRONMENT=production --dart-define=API_URL=https://your-api.onrender.com
///
///   2. Or use environment-specific build commands (see scripts below)
library;

class Environment {
  /// Current environment name
  static const String current = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  /// Check if running in development
  static bool get isDevelopment => current == 'development';

  /// Check if running in staging
  static bool get isStaging => current == 'staging';

  /// Check if running in production
  static bool get isProduction => current == 'production';

  /// API Base URL based on environment
  static String get apiUrl {
    const envApiUrl = String.fromEnvironment('API_URL');

    // If API_URL is provided via dart-define, use it
    if (envApiUrl.isNotEmpty) {
      return envApiUrl;
    }

    // Otherwise, use environment-specific defaults
    switch (current) {
      case 'production':
        return 'https://api.flutterstudio.dev'; // Custom domain
      case 'staging':
        return 'https://ai-content-generator-api-zwhe.onrender.com'; // Render URL as fallback
      case 'development':
      default:
        return 'http://127.0.0.1:8000'; // Local development
    }
  }

  /// Firebase Hosting URL (frontend)
  static String get appUrl {
    switch (current) {
      case 'production':
        return 'https://ai-content-generator-7ec6a.web.app';
      case 'staging':
        return 'https://ai-content-generator-7ec6a--staging.web.app';
      case 'development':
      default:
        return 'http://localhost:3000';
    }
  }

  /// Enable debug features
  static bool get enableDebugFeatures => !isProduction;

  /// Enable verbose logging
  static bool get enableVerboseLogging => isDevelopment;

  /// API timeout duration
  static Duration get apiTimeout {
    if (isProduction) {
      return const Duration(seconds: 30);
    }
    return const Duration(seconds: 60); // Longer timeout for dev
  }

  /// Print current environment configuration
  static void printConfig() {
    print('🌍 Environment: $current');
    print('🔗 API URL: $apiUrl');
    print('🌐 App URL: $appUrl');
    print('🐛 Debug Features: $enableDebugFeatures');
    print('📝 Verbose Logging: $enableVerboseLogging');
  }
}

/// Environment-specific configuration values
class EnvConfig {
  /// Note: String.fromEnvironment cannot be used dynamically
  /// Each config value must be defined explicitly

  /// Firebase Configuration
  static String get firebaseProjectId => 'ai-content-generator-7ec6a';

  /// Stripe Public Key (environment-specific)
  static String get stripePublicKey {
    if (Environment.isProduction) {
      return const String.fromEnvironment(
        'STRIPE_PUBLIC_KEY',
        defaultValue: 'pk_live_YOUR_LIVE_KEY', // Update with real key
      );
    }
    return const String.fromEnvironment(
      'STRIPE_PUBLIC_KEY',
      defaultValue: 'pk_test_YOUR_TEST_KEY', // Update with test key
    );
  }

  /// Google OAuth Client ID
  static String get googleClientId {
    return const String.fromEnvironment(
      'GOOGLE_CLIENT_ID',
      defaultValue: 'YOUR_GOOGLE_CLIENT_ID',
    );
  }
}
