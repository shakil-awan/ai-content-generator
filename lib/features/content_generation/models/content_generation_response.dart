import 'generation_json_keys.dart';

/// Content Generation Response Model - Matches backend GenerationResponse schema
class ContentGenerationResponse {
  final String id;
  final String userId;
  final String contentType;
  final String content;
  final String? title;
  final String? metaDescription;
  final int? wordCount;
  final QualityMetrics qualityMetrics;
  final FactCheckResults factCheckResults;
  final HumanizationResult humanization;
  final ValidationResult? validation; // Phase 2: Post-generation validation
  final List<String>
  aiSuggestions; // Phase 3: AI-powered improvement suggestions
  final Map<String, dynamic>?
  aiQualityMetrics; // Phase 3: Deep AI quality analysis
  final bool isContentRefresh;
  final String? originalContentId;
  final VideoScriptSettings? videoScriptSettings;
  final double generationTime;
  final String modelUsed;
  final List<String> exportedTo;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContentGenerationResponse({
    required this.id,
    required this.userId,
    required this.contentType,
    required this.content,
    this.title,
    this.metaDescription,
    this.wordCount,
    required this.qualityMetrics,
    required this.factCheckResults,
    required this.humanization,
    this.validation, // Phase 2: Optional validation
    this.aiSuggestions = const [], // Phase 3: AI suggestions
    this.aiQualityMetrics, // Phase 3: AI quality metrics
    required this.isContentRefresh,
    this.originalContentId,
    this.videoScriptSettings,
    required this.generationTime,
    required this.modelUsed,
    required this.exportedTo,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContentGenerationResponse.fromJson(Map<String, dynamic> json) {
    return ContentGenerationResponse(
      id: json[GenerationJsonKeys.id] as String,
      userId: json[GenerationJsonKeys.userId] as String,
      contentType: json[GenerationJsonKeys.contentType] as String,
      content: json[GenerationJsonKeys.content] as String,
      title: json[GenerationJsonKeys.title] as String?,
      metaDescription: json[GenerationJsonKeys.metaDescription] as String?,
      wordCount: json[GenerationJsonKeys.wordCount] as int?,
      qualityMetrics: QualityMetrics.fromJson(
        json[GenerationJsonKeys.qualityMetrics] as Map<String, dynamic>,
      ),
      factCheckResults: FactCheckResults.fromJson(
        json[GenerationJsonKeys.factCheckResults] as Map<String, dynamic>,
      ),
      humanization: HumanizationResult.fromJson(
        json[GenerationJsonKeys.humanization] as Map<String, dynamic>,
      ),
      validation: json['validation'] != null
          ? ValidationResult.fromJson(
              json['validation'] as Map<String, dynamic>,
            )
          : null,
      aiSuggestions:
          (json[GenerationJsonKeys.aiSuggestions] as List?)?.cast<String>() ??
          [],
      aiQualityMetrics: json[GenerationJsonKeys.aiQualityMetrics] != null
          ? Map<String, dynamic>.from(json[GenerationJsonKeys.aiQualityMetrics])
          : null,
      isContentRefresh:
          json[GenerationJsonKeys.isContentRefresh] as bool? ?? false,
      originalContentId: json[GenerationJsonKeys.originalContentId] as String?,
      videoScriptSettings: json[GenerationJsonKeys.videoScriptSettings] != null
          ? VideoScriptSettings.fromJson(
              json[GenerationJsonKeys.videoScriptSettings]
                  as Map<String, dynamic>,
            )
          : null,
      generationTime: (json[GenerationJsonKeys.generationTime] as num)
          .toDouble(),
      modelUsed: json[GenerationJsonKeys.modelUsed] as String,
      exportedTo:
          (json[GenerationJsonKeys.exportedTo] as List?)?.cast<String>() ?? [],
      isFavorite: json[GenerationJsonKeys.isFavorite] as bool? ?? false,
      createdAt: DateTime.parse(json[GenerationJsonKeys.createdAt] as String),
      updatedAt: DateTime.parse(json[GenerationJsonKeys.updatedAt] as String),
    );
  }

  /// Get word count (from backend or calculate as fallback)
  int get actualWordCount {
    return wordCount ?? content.trim().split(RegExp(r'\s+')).length;
  }

  /// Calculate estimated read time (assuming 200 words per minute)
  int get estimatedReadTime {
    return (actualWordCount / 200).ceil();
  }

  /// Alias for qualityMetrics (for backward compatibility with UI)
  QualityMetrics get qualityScore => qualityMetrics;

  /// Create a copy with modified fields
  ContentGenerationResponse copyWith({
    String? id,
    String? userId,
    String? contentType,
    String? content,
    String? title,
    QualityMetrics? qualityMetrics,
    FactCheckResults? factCheckResults,
    HumanizationResult? humanization,
    ValidationResult? validation,
    bool? isContentRefresh,
    String? originalContentId,
    VideoScriptSettings? videoScriptSettings,
    double? generationTime,
    String? modelUsed,
    List<String>? exportedTo,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContentGenerationResponse(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contentType: contentType ?? this.contentType,
      content: content ?? this.content,
      title: title ?? this.title,
      qualityMetrics: qualityMetrics ?? this.qualityMetrics,
      factCheckResults: factCheckResults ?? this.factCheckResults,
      humanization: humanization ?? this.humanization,
      validation: validation ?? this.validation,
      isContentRefresh: isContentRefresh ?? this.isContentRefresh,
      originalContentId: originalContentId ?? this.originalContentId,
      videoScriptSettings: videoScriptSettings ?? this.videoScriptSettings,
      generationTime: generationTime ?? this.generationTime,
      modelUsed: modelUsed ?? this.modelUsed,
      exportedTo: exportedTo ?? this.exportedTo,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      GenerationJsonKeys.id: id,
      GenerationJsonKeys.userId: userId,
      GenerationJsonKeys.contentType: contentType,
      GenerationJsonKeys.content: content,
      if (title != null) GenerationJsonKeys.title: title,
      GenerationJsonKeys.qualityMetrics: qualityMetrics.toJson(),
      GenerationJsonKeys.factCheckResults: factCheckResults.toJson(),
      GenerationJsonKeys.humanization: humanization.toJson(),
      if (validation != null) 'validation': validation!.toJson(),
      GenerationJsonKeys.aiSuggestions: aiSuggestions,
      if (aiQualityMetrics != null)
        GenerationJsonKeys.aiQualityMetrics: aiQualityMetrics,
      GenerationJsonKeys.isContentRefresh: isContentRefresh,
      if (originalContentId != null)
        GenerationJsonKeys.originalContentId: originalContentId,
      if (videoScriptSettings != null)
        GenerationJsonKeys.videoScriptSettings: videoScriptSettings!.toJson(),
      GenerationJsonKeys.generationTime: generationTime,
      GenerationJsonKeys.modelUsed: modelUsed,
      GenerationJsonKeys.exportedTo: exportedTo,
      GenerationJsonKeys.isFavorite: isFavorite,
      GenerationJsonKeys.createdAt: createdAt.toIso8601String(),
      GenerationJsonKeys.updatedAt: updatedAt.toIso8601String(),
    };
  }
}

/// Quality Metrics Model - Matches backend QualityMetrics schema
class QualityMetrics {
  final double readabilityScore;
  final double completenessScore;
  final double seoScore;
  final double grammarScore;
  final double originalityScore;
  final double factCheckScore;
  final double aiDetectionScore;
  final double overallScore;

  QualityMetrics({
    required this.readabilityScore,
    required this.completenessScore,
    required this.seoScore,
    required this.grammarScore,
    required this.originalityScore,
    required this.factCheckScore,
    required this.aiDetectionScore,
    required this.overallScore,
  });

  factory QualityMetrics.fromJson(Map<String, dynamic> json) {
    return QualityMetrics(
      readabilityScore:
          (json[GenerationJsonKeys.readabilityScore] as num?)?.toDouble() ??
          0.0,
      completenessScore:
          (json[GenerationJsonKeys.completenessScore] as num?)?.toDouble() ??
          0.0,
      seoScore: (json[GenerationJsonKeys.seoScore] as num?)?.toDouble() ?? 0.0,
      grammarScore:
          (json[GenerationJsonKeys.grammarScore] as num?)?.toDouble() ?? 0.0,
      originalityScore:
          (json[GenerationJsonKeys.originalityScore] as num?)?.toDouble() ??
          0.0,
      factCheckScore:
          (json[GenerationJsonKeys.factCheckScore] as num?)?.toDouble() ?? 0.0,
      aiDetectionScore:
          (json[GenerationJsonKeys.aiDetectionScore] as num?)?.toDouble() ??
          0.0,
      overallScore:
          (json[GenerationJsonKeys.overallScore] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Aliases for UI compatibility (converts 0-10 scores to 0-100 percentages)
  double get readability => readabilityScore * 10;
  double get completeness => completenessScore * 10;
  double get seo => seoScore * 10;
  double get grammar => grammarScore * 10;

  Map<String, dynamic> toJson() {
    return {
      GenerationJsonKeys.readabilityScore: readabilityScore,
      GenerationJsonKeys.completenessScore: completenessScore,
      GenerationJsonKeys.seoScore: seoScore,
      GenerationJsonKeys.grammarScore: grammarScore,
      GenerationJsonKeys.originalityScore: originalityScore,
      GenerationJsonKeys.factCheckScore: factCheckScore,
      GenerationJsonKeys.aiDetectionScore: aiDetectionScore,
      GenerationJsonKeys.overallScore: overallScore,
    };
  }
}

/// Fact Check Results Model - Matches backend FactCheckResults schema
class FactCheckResults {
  final bool checked;
  final List<FactCheckClaim> claims;
  final int claimsFound;
  final int claimsVerified;
  final double overallConfidence;
  final double verificationTime;
  final int totalSearchesUsed;

  FactCheckResults({
    required this.checked,
    required this.claims,
    this.claimsFound = 0,
    this.claimsVerified = 0,
    this.overallConfidence = 0.0,
    required this.verificationTime,
    this.totalSearchesUsed = 0,
  });

  factory FactCheckResults.fromJson(Map<String, dynamic> json) {
    // Ensure proper type casting for claims list
    final claimsList = <FactCheckClaim>[];
    final claimsData = json[GenerationJsonKeys.claims] as List<dynamic>? ?? [];
    for (var claim in claimsData) {
      claimsList.add(FactCheckClaim.fromJson(claim as Map<String, dynamic>));
    }

    return FactCheckResults(
      checked: json[GenerationJsonKeys.checked] as bool? ?? false,
      claims: claimsList,
      claimsFound: json['claims_found'] as int? ?? 0,
      claimsVerified: json['claims_verified'] as int? ?? 0,
      overallConfidence:
          (json['overall_confidence'] as num?)?.toDouble() ?? 0.0,
      verificationTime:
          (json[GenerationJsonKeys.verificationTime] as num?)?.toDouble() ??
          0.0,
      totalSearchesUsed: json['total_searches_used'] as int? ?? 0,
    );
  }

  /// Get count of verified claims
  int get verifiedClaims =>
      claims.whereType<FactCheckClaim>().where((c) => c.verified).length;

  /// Get count of unverified claims
  int get unverifiedClaims =>
      claims.whereType<FactCheckClaim>().where((c) => !c.verified).length;

  Map<String, dynamic> toJson() {
    return {
      GenerationJsonKeys.checked: checked,
      GenerationJsonKeys.claims: claims.map((e) => e.toJson()).toList(),
      'claims_found': claimsFound,
      'claims_verified': claimsVerified,
      'overall_confidence': overallConfidence,
      GenerationJsonKeys.verificationTime: verificationTime,
      'total_searches_used': totalSearchesUsed,
    };
  }
}

/// Individual Fact Check Claim Model - Matches backend FactCheckClaim schema
class FactCheckClaim {
  final String claim;
  final bool verified;
  final String? source; // Legacy field
  final double confidence;
  final List<FactCheckSource> sources; // Enhanced with detailed source info
  final String evidence;

  FactCheckClaim({
    required this.claim,
    required this.verified,
    this.source,
    required this.confidence,
    this.sources = const [],
    this.evidence = '',
  });

  factory FactCheckClaim.fromJson(Map<String, dynamic> json) {
    return FactCheckClaim(
      claim: json[GenerationJsonKeys.claim] as String,
      verified: json[GenerationJsonKeys.verified] as bool,
      source: json[GenerationJsonKeys.source] as String?,
      confidence:
          (json[GenerationJsonKeys.confidence] as num?)?.toDouble() ?? 0.0,
      sources:
          (json['sources'] as List<dynamic>?)
              ?.map((e) => FactCheckSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      evidence: json['evidence'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      GenerationJsonKeys.claim: claim,
      GenerationJsonKeys.verified: verified,
      if (source != null) GenerationJsonKeys.source: source,
      GenerationJsonKeys.confidence: confidence,
      'sources': sources.map((e) => e.toJson()).toList(),
      'evidence': evidence,
    };
  }
}

/// Fact Check Source Model - Detailed source information
class FactCheckSource {
  final String url;
  final String title;
  final String snippet;
  final String domain;
  final String authorityLevel;

  FactCheckSource({
    required this.url,
    required this.title,
    required this.snippet,
    required this.domain,
    required this.authorityLevel,
  });

  factory FactCheckSource.fromJson(Map<String, dynamic> json) {
    return FactCheckSource(
      url: json['url'] as String,
      title: json['title'] as String,
      snippet: json['snippet'] as String,
      domain: json['domain'] as String,
      authorityLevel: json['authority_level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'snippet': snippet,
      'domain': domain,
      'authority_level': authorityLevel,
    };
  }
}

/// Humanization Result Model - Matches backend HumanizationResult schema
class HumanizationResult {
  final bool applied;
  final String? level;
  final double beforeScore;
  final double afterScore;
  final String? detectionApi;
  final double processingTime;
  final DateTime? humanizedAt;

  HumanizationResult({
    required this.applied,
    this.level,
    required this.beforeScore,
    required this.afterScore,
    this.detectionApi,
    required this.processingTime,
    this.humanizedAt,
  });

  factory HumanizationResult.fromJson(Map<String, dynamic> json) {
    return HumanizationResult(
      applied: json[GenerationJsonKeys.applied] as bool? ?? false,
      level: json[GenerationJsonKeys.level] as String?,
      beforeScore:
          (json[GenerationJsonKeys.beforeScore] as num?)?.toDouble() ?? 0.0,
      afterScore:
          (json[GenerationJsonKeys.afterScore] as num?)?.toDouble() ?? 0.0,
      detectionApi: json[GenerationJsonKeys.detectionApi] as String?,
      processingTime:
          (json[GenerationJsonKeys.processingTime] as num?)?.toDouble() ?? 0.0,
      humanizedAt: json[GenerationJsonKeys.humanizedAt] != null
          ? DateTime.parse(json[GenerationJsonKeys.humanizedAt] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      GenerationJsonKeys.applied: applied,
      if (level != null) GenerationJsonKeys.level: level,
      GenerationJsonKeys.beforeScore: beforeScore,
      GenerationJsonKeys.afterScore: afterScore,
      if (detectionApi != null) GenerationJsonKeys.detectionApi: detectionApi,
      GenerationJsonKeys.processingTime: processingTime,
      if (humanizedAt != null)
        GenerationJsonKeys.humanizedAt: humanizedAt!.toIso8601String(),
    };
  }
}

/// Validation Issue Model - Individual validation issue (Phase 2)
class ValidationIssue {
  final String field;
  final String expected;
  final dynamic actual;
  final String severity;

  ValidationIssue({
    required this.field,
    required this.expected,
    required this.actual,
    required this.severity,
  });

  factory ValidationIssue.fromJson(Map<String, dynamic> json) {
    return ValidationIssue(
      field: json['field'] as String,
      expected: json['expected'] as String,
      actual: json['actual'],
      severity: json['severity'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'expected': expected,
      'actual': actual,
      'severity': severity,
    };
  }
}

/// Validation Result Model - Post-generation validation (Phase 2)
class ValidationResult {
  final bool valid;
  final List<ValidationIssue> issues;
  final double qualityScore;
  final double wordCountAccuracy;

  ValidationResult({
    required this.valid,
    required this.issues,
    required this.qualityScore,
    required this.wordCountAccuracy,
  });

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    return ValidationResult(
      valid: json['valid'] as bool? ?? true,
      issues:
          (json['issues'] as List<dynamic>?)
              ?.map((e) => ValidationIssue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      qualityScore: (json['quality_score'] as num?)?.toDouble() ?? 100.0,
      wordCountAccuracy:
          (json['word_count_accuracy'] as num?)?.toDouble() ?? 100.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valid': valid,
      'issues': issues.map((e) => e.toJson()).toList(),
      'quality_score': qualityScore,
      'word_count_accuracy': wordCountAccuracy,
    };
  }
}

/// Video Script Settings Model - Matches backend VideoScriptSettings schema
class VideoScriptSettings {
  final String platform;
  final int duration;
  final bool includeHooks;
  final bool includeCta;

  VideoScriptSettings({
    required this.platform,
    required this.duration,
    required this.includeHooks,
    required this.includeCta,
  });

  factory VideoScriptSettings.fromJson(Map<String, dynamic> json) {
    return VideoScriptSettings(
      platform: json[GenerationJsonKeys.platform] as String,
      duration: json[GenerationJsonKeys.duration] as int,
      includeHooks: json[GenerationJsonKeys.includeHooks] as bool? ?? true,
      includeCta: json[GenerationJsonKeys.includeCta] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      GenerationJsonKeys.platform: platform,
      GenerationJsonKeys.duration: duration,
      GenerationJsonKeys.includeHooks: includeHooks,
      GenerationJsonKeys.includeCta: includeCta,
    };
  }
}
