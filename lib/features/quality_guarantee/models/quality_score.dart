import 'package:flutter/material.dart';

/// Quality Score Model
/// Represents quality metrics for generated content
class QualityScore {
  final double overall; // 0.0 - 1.0
  final double readability;
  final double completeness;
  final double seo;
  final double grammar;
  final String? grade; // API provides grade directly
  final int? percentage; // API provides percentage directly
  final bool? shouldRegenerate; // API tells us if quality is too low
  final QualityDetails? details;

  QualityScore({
    required this.overall,
    required this.readability,
    required this.completeness,
    required this.seo,
    required this.grammar,
    this.grade,
    this.percentage,
    this.shouldRegenerate,
    this.details,
  });

  /// Get letter grade (computed or from API)
  String get displayGrade {
    if (grade != null) return grade!;
    if (overall >= 0.95) return 'A+';
    if (overall >= 0.85) return 'A';
    if (overall >= 0.70) return 'B';
    if (overall >= 0.60) return 'C';
    return 'D';
  }

  /// Get percentage (computed or from API)
  int get displayPercentage => percentage ?? (overall * 100).toInt();

  /// Get grade color
  Color get gradeColor {
    if (overall >= 0.85) return const Color(0xFF059669); // Green-600
    if (overall >= 0.70) return const Color(0xFF2563EB); // Blue-600
    if (overall >= 0.60) return const Color(0xFFD97706); // Yellow-600
    return const Color(0xFFDC2626); // Red-600
  }

  /// Get background color for grade
  Color get gradeBackgroundColor {
    if (overall >= 0.85) return const Color(0xFFF0FDF4); // Green-50
    if (overall >= 0.70) return const Color(0xFFEFF6FF); // Blue-50
    if (overall >= 0.60) return const Color(0xFFFFFBEB); // Yellow-50
    return const Color(0xFFFEF2F2); // Red-50
  }

  /// Get grade label (Excellent, Great, Good, Fair, Needs Improvement)
  String get gradeLabel {
    if (overall >= 0.95) return 'Excellent';
    if (overall >= 0.85) return 'Great';
    if (overall >= 0.70) return 'Good';
    if (overall >= 0.60) return 'Fair';
    return 'Needs Improvement';
  }

  /// Create from JSON (matches API response)
  factory QualityScore.fromJson(Map<String, dynamic> json) {
    return QualityScore(
      overall: (json['overall'] ?? 0.0).toDouble(),
      readability: (json['readability'] ?? 0.0).toDouble(),
      completeness: (json['completeness'] ?? 0.0).toDouble(),
      seo: (json['seo'] ?? 0.0).toDouble(),
      grammar: (json['grammar'] ?? 0.0).toDouble(),
      grade: json['grade'] as String?,
      percentage: json['percentage'] as int?,
      shouldRegenerate: json['should_regenerate'] as bool?,
      details: json['details'] != null
          ? QualityDetails.fromJson(json['details'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'overall': overall,
      'readability': readability,
      'completeness': completeness,
      'seo': seo,
      'grammar': grammar,
      if (grade != null) 'grade': grade,
      if (percentage != null) 'percentage': percentage,
      if (shouldRegenerate != null) 'should_regenerate': shouldRegenerate,
      if (details != null) 'details': details!.toJson(),
    };
  }

  /// Create empty/default score
  factory QualityScore.empty() {
    return QualityScore(
      overall: 0.0,
      readability: 0.0,
      completeness: 0.0,
      seo: 0.0,
      grammar: 0.0,
      grade: 'N/A',
      percentage: 0,
      shouldRegenerate: false,
    );
  }
}

/// Quality Details Model
/// Additional metrics about content quality (matches API response)
class QualityDetails {
  final int wordCount;
  final int? sentenceCount; // Added from API
  final double? avgSentenceLength; // Added from API
  final int? paragraphCount; // Added from API
  final double? fleschKincaidScore;
  final double? keywordDensity;
  final int? headingCount;

  QualityDetails({
    required this.wordCount,
    this.sentenceCount,
    this.avgSentenceLength,
    this.paragraphCount,
    this.fleschKincaidScore,
    this.keywordDensity,
    this.headingCount,
  });

  /// Create from JSON (matches API response)
  factory QualityDetails.fromJson(Map<String, dynamic> json) {
    return QualityDetails(
      wordCount: json['word_count'] ?? 0,
      sentenceCount: json['sentence_count'] as int?,
      avgSentenceLength: (json['avg_sentence_length'] as num?)?.toDouble(),
      paragraphCount: json['paragraph_count'] as int?,
      fleschKincaidScore: (json['flesch_kincaid_score'] as num?)?.toDouble(),
      keywordDensity: (json['keyword_density'] as num?)?.toDouble(),
      headingCount: json['heading_count'] as int?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'word_count': wordCount,
      if (sentenceCount != null) 'sentence_count': sentenceCount,
      if (avgSentenceLength != null) 'avg_sentence_length': avgSentenceLength,
      if (paragraphCount != null) 'paragraph_count': paragraphCount,
      if (fleschKincaidScore != null)
        'flesch_kincaid_score': fleschKincaidScore,
      if (keywordDensity != null) 'keyword_density': keywordDensity,
      if (headingCount != null) 'heading_count': headingCount,
    };
  }
}
