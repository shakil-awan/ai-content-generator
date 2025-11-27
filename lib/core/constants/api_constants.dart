/// API Endpoints Configuration
/// Central location for all API endpoints, headers, and base URL
class ApiEndpoints {
  // ==================== Base Configuration ====================
  /// Base URL for all API requests
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  /// API Version prefix
  static const String apiVersion = '/api/v1';

  // ==================== HTTP Headers ====================
  /// Standard headers for all API requests
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Headers with authorization token
  static Map<String, String> headersWithAuth(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };

  // ==================== Authentication ====================
  static const String authBase = '$apiVersion/auth';
  static const String register = '$authBase/register';
  static const String login = '$authBase/login';
  static const String refreshToken = '$authBase/refresh';
  static const String logout = '$authBase/logout';
  static const String googleAuth = '$authBase/google';

  // ==================== User Profile ====================
  static const String userBase = '$apiVersion/user';
  static const String userProfile = userBase; // GET /api/v1/user
  static const String updateProfile = userBase; // PUT /api/v1/user
  static const String deleteAccount = '$userBase/delete'; // POST
  static const String cancelDeletion = '$userBase/cancel-deletion'; // POST

  // ==================== Content Generation ====================
  static const String generateBase = '$apiVersion/generate';
  static const String generateBlog = '$generateBase/blog';
  static const String generateSocial = '$generateBase/social';
  static const String generateEmail = '$generateBase/email';
  static const String generateProduct = '$generateBase/product';
  static const String generateAd = '$generateBase/ad';
  static const String generateVideo = '$generateBase/video-script';
  static const String generateImage = '$generateBase/image';
  static const String generateImageBatch = '$generateBase/image/batch';

  // Legacy endpoints (for compatibility)
  static const String generationBase = '$apiVersion/generation';
  static const String generateContent = '$generationBase/generate';
  static const String userGenerations = '$generationBase/history';
  static const String generationById = '$generationBase/{id}';
  static const String deleteGeneration = '$generationBase/{id}';

  // ==================== Humanization ====================
  static const String humanizeBase = '$apiVersion/humanize';
  static String humanizeContent(String generationId) =>
      '$humanizeBase/$generationId';
  static String detectAiScore(String generationId) =>
      '$humanizeBase/detect/$generationId';

  // ==================== Fact Checking ====================
  static const String factCheckBase = '$apiVersion/generate';
  static const String factCheck = '$factCheckBase/fact-check';

  // ==================== Quality Scoring ====================
  static const String qualityBase = '$apiVersion/quality';
  static const String qualityScore = '$qualityBase/score';
  static const String qualitySuggestions = '$qualityBase/suggestions';
  static const String qualityThresholds = '$qualityBase/thresholds';

  // ==================== Graphics ====================
  static const String graphicsBase = '$apiVersion/graphics';
  static const String generateGraphic = '$graphicsBase/generate';

  // ==================== Billing & Subscription ====================
  static const String billingBase = '$apiVersion/billing';
  static const String subscription = '$billingBase/subscription';
  static const String updateSubscription = '$billingBase/subscription/update';
  static const String cancelSubscription = '$billingBase/subscription/cancel';
  static const String paymentMethods = '$billingBase/payment-methods';
  static const String invoices = '$billingBase/invoices';
  static const String usage = '$billingBase/usage';

  // ==================== Feedback ====================
  static const String feedbackBase = '$apiVersion/feedback';
  static const String submitFeedback = feedbackBase;

  // ==================== Analytics ====================
  static const String analyticsBase = '$apiVersion/analytics';
  static const String dashboardStats = '$analyticsBase/dashboard';
  static const String usageHistory = '$analyticsBase/usage';
}

/// App-wide Constants
class AppConstants {
  // ==================== Subscription Plans ====================
  static const String planFree = 'free';
  static const String planHobby = 'hobby';
  static const String planPro = 'pro';
  static const String planEnterprise = 'enterprise';

  // ==================== Subscription Status ====================
  static const String statusActive = 'active';
  static const String statusCancelled = 'cancelled';
  static const String statusExpired = 'expired';
  static const String statusPastDue = 'past_due';
  static const String statusTrialing = 'trialing';

  // ==================== Usage Limits ====================
  // Free Plan
  static const int freeGenerations = 5;
  static const int freeHumanizations = 3;
  static const int freeGraphics = 5;

  // Hobby Plan
  static const int hobbyGenerations = 100;
  static const int hobbyHumanizations = 25;
  static const int hobbyGraphics = 50;

  // Pro Plan (Unlimited represented as large number)
  static const int proGenerations = 1000;
  static const int proHumanizations = 999999;
  static const int proGraphics = 999999;

  // Enterprise Plan
  static const int enterpriseGenerations = 10000;
  static const int enterpriseHumanizations = 999999;
  static const int enterpriseGraphics = 999999;

  // ==================== Token Configuration ====================
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const Duration accessTokenExpiry = Duration(hours: 24);
  static const Duration refreshTokenExpiry = Duration(days: 30);

  // ==================== Content Types ====================
  static const List<String> contentTypes = [
    'social_media',
    'blog_post',
    'email',
    'ad_copy',
    'product_description',
    'video_script',
  ];

  // ==================== Tones ====================
  static const List<String> tones = [
    'professional',
    'casual',
    'friendly',
    'formal',
    'humorous',
    'persuasive',
  ];
}

/// Error Messages (matching backend)
class ErrorMessages {
  static const String unauthorized = 'Unauthorized access';
  static const String invalidToken = 'Invalid or expired token';
  static const String emailAlreadyExists = 'Email already exists';
  static const String emailNotFound = 'No account found with this email';
  static const String incorrectPassword = 'Incorrect password';
  static const String invalidCredentials = 'Invalid credentials';
  static const String serverError = 'Server error. Please try again later';
  static const String networkError = 'Network error. Check your connection';
  static const String validationError = 'Validation error';
  static const String notFound = 'Resource not found';
  static const String limitExceeded = 'Usage limit exceeded';
}

/// Success Messages
class SuccessMessages {
  static const String loginSuccess = 'Login successful';
  static const String registerSuccess = 'Account created successfully';
  static const String logoutSuccess = 'Logged out successfully';
  static const String profileUpdated = 'Profile updated successfully';
  static const String passwordReset = 'Password reset link sent';
  static const String feedbackSubmitted = 'Feedback submitted successfully';
}
