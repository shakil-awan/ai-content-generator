import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../models/quality_score.dart';

/// Quality Scoring Service
/// Handles all quality-related API calls
///
/// BACKEND STATUS: ✅ COMPLETE & TESTED
/// - POST /api/v1/quality/score - Score content quality
/// - POST /api/v1/quality/suggestions - Get improvement suggestions
/// - GET /api/v1/quality/thresholds - Get quality thresholds
///
/// IMPORTANT: Quality scoring uses LOCAL algorithms only
/// - No Gemini API key needed
/// - No external API dependencies
/// - Fast, instant scoring
class QualityService {
  final ApiService _apiService;

  QualityService(this._apiService);

  /// Score content quality
  ///
  /// Returns detailed quality breakdown with:
  /// - Overall score (0.0-1.0)
  /// - Component scores (readability, completeness, seo, grammar)
  /// - Grade (A+ to D)
  /// - Detailed metrics
  /// - Regeneration flag
  ///
  /// Example:
  /// ```dart
  /// final score = await qualityService.scoreContent(
  ///   content: generatedText,
  ///   contentType: 'blog',
  ///   keywords: ['AI', 'technology'],
  ///   targetLength: 500,
  /// );
  ///
  /// if (score.shouldRegenerate) {
  ///   // Show regeneration prompt
  /// }
  /// ```
  Future<QualityScoreResult> scoreContent({
    required String content,
    required String contentType,
    List<String>? keywords,
    int targetLength = 500,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.qualityScore}',
        body: {
          'content': content,
          'content_type': contentType,
          'keywords': keywords,
          'target_length': targetLength,
        },
      );

      return QualityScoreResult.fromJson(response);
    } catch (e) {
      throw Exception('Failed to score content: $e');
    }
  }

  /// Get improvement suggestions based on quality scores
  ///
  /// Returns:
  /// - List of actionable suggestions
  /// - Priority areas that need improvement
  /// - Strengths to maintain
  ///
  /// Example:
  /// ```dart
  /// final suggestions = await qualityService.getSuggestions(
  ///   overall: qualityScore.overall,
  ///   readability: qualityScore.readability,
  ///   completeness: qualityScore.completeness,
  ///   seo: qualityScore.seo,
  ///   grammar: qualityScore.grammar,
  /// );
  ///
  /// // Display suggestions to user
  /// for (var suggestion in suggestions.suggestions) {
  ///   print(suggestion);
  /// }
  /// ```
  Future<QualityImprovementResult> getSuggestions({
    required double overall,
    required double readability,
    required double completeness,
    required double seo,
    required double grammar,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.qualitySuggestions}',
        body: {
          'overall': overall,
          'readability': readability,
          'completeness': completeness,
          'seo': seo,
          'grammar': grammar,
        },
      );

      return QualityImprovementResult.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get suggestions: $e');
    }
  }

  /// Get quality thresholds and configuration
  ///
  /// Returns:
  /// - Threshold values (excellent, good, regenerate)
  /// - Grade mappings (A+ to D ranges)
  /// - Component weights
  ///
  /// Useful for:
  /// - Displaying threshold markers in UI
  /// - Setting quality goals
  /// - Understanding scoring system
  ///
  /// Example:
  /// ```dart
  /// final thresholds = await qualityService.getThresholds();
  ///
  /// // Show regeneration threshold in UI
  /// final regenThreshold = thresholds.thresholds['regenerate'];
  /// print('Content below $regenThreshold will be regenerated');
  /// ```
  Future<QualityThresholdsResult> getThresholds() async {
    try {
      final response = await _apiService.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.qualityThresholds}',
      );

      return QualityThresholdsResult.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get thresholds: $e');
    }
  }
}

/// Quality Score Result
/// Complete quality breakdown from API
class QualityScoreResult {
  final double overall;
  final double readability;
  final double completeness;
  final double seo;
  final double grammar;
  final String grade;
  final int percentage;
  final QualityDetails details;
  final bool shouldRegenerate;

  QualityScoreResult({
    required this.overall,
    required this.readability,
    required this.completeness,
    required this.seo,
    required this.grammar,
    required this.grade,
    required this.percentage,
    required this.details,
    required this.shouldRegenerate,
  });

  factory QualityScoreResult.fromJson(Map<String, dynamic> json) {
    return QualityScoreResult(
      overall: (json['overall'] as num).toDouble(),
      readability: (json['readability'] as num).toDouble(),
      completeness: (json['completeness'] as num).toDouble(),
      seo: (json['seo'] as num).toDouble(),
      grammar: (json['grammar'] as num).toDouble(),
      grade: json['grade'] as String,
      percentage: json['percentage'] as int,
      details: QualityDetails.fromJson(json['details'] as Map<String, dynamic>),
      shouldRegenerate: json['should_regenerate'] as bool,
    );
  }

  /// Convert to existing QualityScore model (if needed)
  /// Note: Update this based on your actual QualityScore model structure
  QualityScore toQualityScore() {
    return QualityScore(
      overall: overall,
      readability: readability,
      completeness: completeness,
      seo: seo,
      grammar: grammar,
      // Map QualityDetails if your model expects different structure
    );
  }
}

/// Quality Details
/// Detailed metrics from scoring
class QualityDetails {
  final int wordCount;
  final int sentenceCount;
  final double avgSentenceLength;
  final int paragraphCount;
  final double fleschKincaidScore;

  QualityDetails({
    required this.wordCount,
    required this.sentenceCount,
    required this.avgSentenceLength,
    required this.paragraphCount,
    required this.fleschKincaidScore,
  });

  factory QualityDetails.fromJson(Map<String, dynamic> json) {
    return QualityDetails(
      wordCount: json['word_count'] as int,
      sentenceCount: json['sentence_count'] as int,
      avgSentenceLength: (json['avg_sentence_length'] as num).toDouble(),
      paragraphCount: json['paragraph_count'] as int,
      fleschKincaidScore: (json['flesch_kincaid_score'] as num).toDouble(),
    );
  }
}

/// Quality Improvement Result
/// Suggestions from API
class QualityImprovementResult {
  final List<String> suggestions;
  final List<String> priorityAreas;
  final List<String> strengths;

  QualityImprovementResult({
    required this.suggestions,
    required this.priorityAreas,
    required this.strengths,
  });

  factory QualityImprovementResult.fromJson(Map<String, dynamic> json) {
    return QualityImprovementResult(
      suggestions: List<String>.from(json['suggestions'] as List),
      priorityAreas: List<String>.from(json['priority_areas'] as List),
      strengths: List<String>.from(json['strengths'] as List),
    );
  }
}

/// Quality Thresholds Result
/// System thresholds and configuration
class QualityThresholdsResult {
  final Map<String, double> thresholds;
  final Map<String, GradeRange> gradeMapping;
  final Map<String, double> componentWeights;

  QualityThresholdsResult({
    required this.thresholds,
    required this.gradeMapping,
    required this.componentWeights,
  });

  factory QualityThresholdsResult.fromJson(Map<String, dynamic> json) {
    return QualityThresholdsResult(
      thresholds: Map<String, double>.from(
        (json['thresholds'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      ),
      gradeMapping: (json['grade_mapping'] as Map).map(
        (k, v) => MapEntry(
          k.toString(),
          GradeRange.fromJson(v as Map<String, dynamic>),
        ),
      ),
      componentWeights: Map<String, double>.from(
        (json['component_weights'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      ),
    );
  }
}

/// Grade Range
/// Min/max range for a grade
class GradeRange {
  final double min;
  final double max;

  GradeRange({required this.min, required this.max});

  factory GradeRange.fromJson(Map<String, dynamic> json) {
    return GradeRange(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
    );
  }
}
