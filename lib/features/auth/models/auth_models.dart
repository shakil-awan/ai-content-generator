// ==================== JSON KEYS ====================

/// JSON keys for parsing API responses - matches backend schema
class AuthJsonKeys {
  // Token Response Keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenType = 'token_type';
  static const String user = 'user';

  // User Keys
  static const String uid = 'uid';
  static const String email = 'email';
  static const String displayName = 'displayName';
  static const String profileImage = 'profileImage';
  static const String createdAt = 'createdAt';
  static const String subscription = 'subscription';
  static const String usageThisMonth = 'usageThisMonth';
  static const String brandVoice = 'brandVoice';
  static const String settings = 'settings';
  static const String team = 'team';
  static const String onboarding = 'onboarding';
  static const String allTimeStats = 'allTimeStats';

  // Subscription Keys
  static const String plan = 'plan';
  static const String status = 'status';
  static const String currentPeriodStart = 'currentPeriodStart';
  static const String currentPeriodEnd = 'currentPeriodEnd';
  static const String stripeSubscriptionId = 'stripeSubscriptionId';
  static const String stripeCustomerId = 'stripeCustomerId';
  static const String cancelledAt = 'cancelledAt';

  // Usage Keys
  static const String generations = 'generations';
  static const String limit = 'limit';
  static const String humanizations = 'humanizations';
  static const String humanizationsLimit = 'humanizationsLimit';
  static const String socialGraphics = 'socialGraphics';
  static const String socialGraphicsLimit = 'socialGraphicsLimit';
  static const String resetDate = 'resetDate';
  static const String percentageUsed = 'percentageUsed';
  static const String percentageUsedAlt =
      'percentage_used'; // snake_case alternative

  // Brand Voice Keys
  static const String isConfigured = 'isConfigured';
  static const String tone = 'tone';
  static const String vocabulary = 'vocabulary';
  static const String samples = 'samples';
  static const String customParameters = 'customParameters';
  static const String trainedAt = 'trainedAt';

  // Settings Keys
  static const String defaultContentType = 'defaultContentType';
  static const String defaultTone = 'defaultTone';
  static const String defaultLanguage = 'defaultLanguage';
  static const String primaryUseCase = 'primaryUseCase';
  static const String autoFactCheck = 'autoFactCheck';
  static const String emailNotifications = 'emailNotifications';
  static const String theme = 'theme';

  // Team Keys
  static const String role = 'role';
  static const String invitedMembers = 'invitedMembers';

  // Onboarding Keys
  static const String completed = 'completed';
  static const String currentStep = 'currentStep';
  static const String completedAt = 'completedAt';

  // Stats Keys
  static const String totalGenerations = 'totalGenerations';
  static const String totalHumanizations = 'totalHumanizations';
  static const String totalGraphics = 'totalGraphics';
  static const String averageQualityScore = 'averageQualityScore';
  static const String favoriteCount = 'favoriteCount';
}

// ==================== NESTED MODELS ====================

/// Subscription information from backend
class SubscriptionInfo {
  final String plan;
  final String status;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final String? stripeSubscriptionId;
  final String? stripeCustomerId;
  final DateTime? cancelledAt;

  SubscriptionInfo({
    required this.plan,
    required this.status,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.stripeSubscriptionId,
    this.stripeCustomerId,
    this.cancelledAt,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      plan: json[AuthJsonKeys.plan] as String? ?? 'free',
      status: json[AuthJsonKeys.status] as String? ?? 'active',
      currentPeriodStart: json[AuthJsonKeys.currentPeriodStart] != null
          ? DateTime.parse(json[AuthJsonKeys.currentPeriodStart] as String)
          : null,
      currentPeriodEnd: json[AuthJsonKeys.currentPeriodEnd] != null
          ? DateTime.parse(json[AuthJsonKeys.currentPeriodEnd] as String)
          : null,
      stripeSubscriptionId: json[AuthJsonKeys.stripeSubscriptionId] as String?,
      stripeCustomerId: json[AuthJsonKeys.stripeCustomerId] as String?,
      cancelledAt: json[AuthJsonKeys.cancelledAt] != null
          ? DateTime.parse(json[AuthJsonKeys.cancelledAt] as String)
          : null,
    );
  }
}

/// Usage information for current month
class UsageInfo {
  final int generations;
  final int limit;
  final int humanizations;
  final int humanizationsLimit;
  final int socialGraphics;
  final int socialGraphicsLimit;
  final DateTime resetDate;
  final double percentageUsed;

  UsageInfo({
    required this.generations,
    required this.limit,
    required this.humanizations,
    required this.humanizationsLimit,
    required this.socialGraphics,
    required this.socialGraphicsLimit,
    required this.resetDate,
    required this.percentageUsed,
  });

  factory UsageInfo.fromJson(Map<String, dynamic> json) {
    return UsageInfo(
      generations: json[AuthJsonKeys.generations] as int? ?? 0,
      limit: json[AuthJsonKeys.limit] as int? ?? 5,
      humanizations: json[AuthJsonKeys.humanizations] as int? ?? 0,
      humanizationsLimit: json[AuthJsonKeys.humanizationsLimit] as int? ?? 3,
      socialGraphics: json[AuthJsonKeys.socialGraphics] as int? ?? 0,
      socialGraphicsLimit: json[AuthJsonKeys.socialGraphicsLimit] as int? ?? 5,
      resetDate: DateTime.parse(
        json[AuthJsonKeys.resetDate] as String? ??
            DateTime.now().toIso8601String(),
      ),
      percentageUsed:
          (json[AuthJsonKeys.percentageUsed] ??
                  json[AuthJsonKeys.percentageUsedAlt] ??
                  0)
              .toDouble(),
    );
  }
}

/// Brand voice configuration
class BrandVoice {
  final bool isConfigured;
  final String? tone;
  final String? vocabulary;
  final List<String> samples;
  final Map<String, dynamic> customParameters;
  final DateTime? trainedAt;

  BrandVoice({
    required this.isConfigured,
    this.tone,
    this.vocabulary,
    required this.samples,
    required this.customParameters,
    this.trainedAt,
  });

  factory BrandVoice.fromJson(Map<String, dynamic> json) {
    return BrandVoice(
      isConfigured: json[AuthJsonKeys.isConfigured] as bool? ?? false,
      tone: json[AuthJsonKeys.tone] as String?,
      vocabulary: json[AuthJsonKeys.vocabulary] as String?,
      samples: (json[AuthJsonKeys.samples] as List?)?.cast<String>() ?? [],
      customParameters:
          json[AuthJsonKeys.customParameters] as Map<String, dynamic>? ?? {},
      trainedAt: json[AuthJsonKeys.trainedAt] != null
          ? DateTime.parse(json[AuthJsonKeys.trainedAt] as String)
          : null,
    );
  }
}

/// User settings
class UserSettings {
  final String? defaultContentType;
  final String? defaultTone;
  final String defaultLanguage;
  final String? primaryUseCase;
  final bool autoFactCheck;
  final bool emailNotifications;
  final String theme;

  UserSettings({
    this.defaultContentType,
    this.defaultTone,
    required this.defaultLanguage,
    this.primaryUseCase,
    required this.autoFactCheck,
    required this.emailNotifications,
    required this.theme,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      defaultContentType: json[AuthJsonKeys.defaultContentType] as String?,
      defaultTone: json[AuthJsonKeys.defaultTone] as String?,
      defaultLanguage:
          json[AuthJsonKeys.defaultLanguage] as String? ?? 'english',
      primaryUseCase: json[AuthJsonKeys.primaryUseCase] as String?,
      autoFactCheck: json[AuthJsonKeys.autoFactCheck] as bool? ?? false,
      emailNotifications:
          json[AuthJsonKeys.emailNotifications] as bool? ?? true,
      theme: json[AuthJsonKeys.theme] as String? ?? 'light',
    );
  }
}

/// Team information
class TeamInfo {
  final String role;
  final List<dynamic> invitedMembers;

  TeamInfo({required this.role, required this.invitedMembers});

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      role: json[AuthJsonKeys.role] as String? ?? 'owner',
      invitedMembers: json[AuthJsonKeys.invitedMembers] as List? ?? [],
    );
  }
}

/// Onboarding status
class OnboardingStatus {
  final bool completed;
  final int currentStep;
  final DateTime? completedAt;

  OnboardingStatus({
    required this.completed,
    required this.currentStep,
    this.completedAt,
  });

  factory OnboardingStatus.fromJson(Map<String, dynamic> json) {
    return OnboardingStatus(
      completed: json[AuthJsonKeys.completed] as bool? ?? false,
      currentStep: json[AuthJsonKeys.currentStep] as int? ?? 0,
      completedAt: json[AuthJsonKeys.completedAt] != null
          ? DateTime.parse(json[AuthJsonKeys.completedAt] as String)
          : null,
    );
  }
}

/// All-time statistics
class AllTimeStats {
  final int totalGenerations;
  final int totalHumanizations;
  final int totalGraphics;
  final double averageQualityScore;
  final int favoriteCount;

  AllTimeStats({
    required this.totalGenerations,
    required this.totalHumanizations,
    required this.totalGraphics,
    required this.averageQualityScore,
    required this.favoriteCount,
  });

  factory AllTimeStats.fromJson(Map<String, dynamic> json) {
    return AllTimeStats(
      totalGenerations: json[AuthJsonKeys.totalGenerations] as int? ?? 0,
      totalHumanizations: json[AuthJsonKeys.totalHumanizations] as int? ?? 0,
      totalGraphics: json[AuthJsonKeys.totalGraphics] as int? ?? 0,
      averageQualityScore: (json[AuthJsonKeys.averageQualityScore] ?? 0)
          .toDouble(),
      favoriteCount: json[AuthJsonKeys.favoriteCount] as int? ?? 0,
    );
  }
}

// ==================== MAIN RESPONSE MODELS ====================

/// Token Response from backend (login, google auth)
class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final UserResponse user;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.user,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json[AuthJsonKeys.accessToken] as String,
      refreshToken: json[AuthJsonKeys.refreshToken] as String,
      tokenType: json[AuthJsonKeys.tokenType] as String,
      user: UserResponse.fromJson(
        json[AuthJsonKeys.user] as Map<String, dynamic>,
      ),
    );
  }
}

/// User Response from backend - Matches backend UserResponse schema EXACTLY
class UserResponse {
  final String uid;
  final String email;
  final String displayName;
  final String profileImage;
  final DateTime createdAt;
  final SubscriptionInfo subscription;
  final UsageInfo usageThisMonth;
  final BrandVoice brandVoice;
  final UserSettings settings;
  final TeamInfo team;
  final OnboardingStatus onboarding;
  final AllTimeStats allTimeStats;

  UserResponse({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.profileImage,
    required this.createdAt,
    required this.subscription,
    required this.usageThisMonth,
    required this.brandVoice,
    required this.settings,
    required this.team,
    required this.onboarding,
    required this.allTimeStats,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      uid: json[AuthJsonKeys.uid] as String,
      email: json[AuthJsonKeys.email] as String,
      displayName: json[AuthJsonKeys.displayName] as String? ?? '',
      profileImage: json[AuthJsonKeys.profileImage] as String? ?? '',
      createdAt: DateTime.parse(json[AuthJsonKeys.createdAt] as String),
      subscription: SubscriptionInfo.fromJson(
        json[AuthJsonKeys.subscription] as Map<String, dynamic>,
      ),
      usageThisMonth: UsageInfo.fromJson(
        json[AuthJsonKeys.usageThisMonth] as Map<String, dynamic>,
      ),
      brandVoice: BrandVoice.fromJson(
        json[AuthJsonKeys.brandVoice] as Map<String, dynamic>,
      ),
      settings: UserSettings.fromJson(
        json[AuthJsonKeys.settings] as Map<String, dynamic>,
      ),
      team: TeamInfo.fromJson(json[AuthJsonKeys.team] as Map<String, dynamic>),
      onboarding: OnboardingStatus.fromJson(
        json[AuthJsonKeys.onboarding] as Map<String, dynamic>,
      ),
      allTimeStats: AllTimeStats.fromJson(
        json[AuthJsonKeys.allTimeStats] as Map<String, dynamic>,
      ),
    );
  }
}
