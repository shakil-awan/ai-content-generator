import 'generation_json_keys.dart';

/// Content Generation Response Model - Matches backend GenerationResponse schema
class ContentGenerationResponse {
  final String id;
  final String userId;
  final String contentType;
  final String content;
  final String? title;
  final QualityMetrics qualityMetrics;
  final FactCheckResults factCheckResults;
  final HumanizationResult humanization;
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
    required this.qualityMetrics,
    required this.factCheckResults,
    required this.humanization,
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
      qualityMetrics: QualityMetrics.fromJson(
        json[GenerationJsonKeys.qualityMetrics] as Map<String, dynamic>,
      ),
      factCheckResults: FactCheckResults.fromJson(
        json[GenerationJsonKeys.factCheckResults] as Map<String, dynamic>,
      ),
      humanization: HumanizationResult.fromJson(
        json[GenerationJsonKeys.humanization] as Map<String, dynamic>,
      ),
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

  /// Calculate word count from content
  int get wordCount {
    return content.trim().split(RegExp(r'\s+')).length;
  }

  /// Calculate estimated read time (assuming 200 words per minute)
  int get estimatedReadTime {
    return (wordCount / 200).ceil();
  }

  /// Alias for qualityMetrics (for backward compatibility with UI)
  QualityMetrics get qualityScore => qualityMetrics;

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
  final double originalityScore;
  final double grammarScore;
  final double factCheckScore;
  final double aiDetectionScore;
  final double overallScore;

  QualityMetrics({
    required this.readabilityScore,
    required this.originalityScore,
    required this.grammarScore,
    required this.factCheckScore,
    required this.aiDetectionScore,
    required this.overallScore,
  });

  factory QualityMetrics.fromJson(Map<String, dynamic> json) {
    return QualityMetrics(
      readabilityScore:
          (json[GenerationJsonKeys.readabilityScore] as num?)?.toDouble() ??
          0.0,
      originalityScore:
          (json[GenerationJsonKeys.originalityScore] as num?)?.toDouble() ??
          0.0,
      grammarScore:
          (json[GenerationJsonKeys.grammarScore] as num?)?.toDouble() ?? 0.0,
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
  double get completeness => factCheckScore * 10;
  double get seo => overallScore * 10;
  double get grammar => grammarScore * 10;

  Map<String, dynamic> toJson() {
    return {
      GenerationJsonKeys.readabilityScore: readabilityScore,
      GenerationJsonKeys.originalityScore: originalityScore,
      GenerationJsonKeys.grammarScore: grammarScore,
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
  final double verificationTime;

  FactCheckResults({
    required this.checked,
    required this.claims,
    required this.verificationTime,
  });

  factory FactCheckResults.fromJson(Map<String, dynamic> json) {
    return FactCheckResults(
      checked: json[GenerationJsonKeys.checked] as bool? ?? false,
      claims:
          (json[GenerationJsonKeys.claims] as List<dynamic>?)
              ?.map((e) => FactCheckClaim.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      verificationTime:
          (json[GenerationJsonKeys.verificationTime] as num?)?.toDouble() ??
          0.0,
    );
  }

  /// Get count of verified claims
  int get verifiedClaims => claims.where((c) => c.verified).length;

  /// Get count of unverified claims
  int get unverifiedClaims => claims.where((c) => !c.verified).length;

  Map<String, dynamic> toJson() {
    return {
      GenerationJsonKeys.checked: checked,
      GenerationJsonKeys.claims: claims.map((e) => e.toJson()).toList(),
      GenerationJsonKeys.verificationTime: verificationTime,
    };
  }
}

/// Individual Fact Check Claim Model - Matches backend FactCheckClaim schema
class FactCheckClaim {
  final String claim;
  final bool verified;
  final String? source;
  final double confidence;

  FactCheckClaim({
    required this.claim,
    required this.verified,
    this.source,
    required this.confidence,
  });

  factory FactCheckClaim.fromJson(Map<String, dynamic> json) {
    return FactCheckClaim(
      claim: json[GenerationJsonKeys.claim] as String,
      verified: json[GenerationJsonKeys.verified] as bool,
      source: json[GenerationJsonKeys.source] as String?,
      confidence:
          (json[GenerationJsonKeys.confidence] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      GenerationJsonKeys.claim: claim,
      GenerationJsonKeys.verified: verified,
      if (source != null) GenerationJsonKeys.source: source,
      GenerationJsonKeys.confidence: confidence,
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

  HumanizationResult({
    required this.applied,
    this.level,
    required this.beforeScore,
    required this.afterScore,
    this.detectionApi,
    required this.processingTime,
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
