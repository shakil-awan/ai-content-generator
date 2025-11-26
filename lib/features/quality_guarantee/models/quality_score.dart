import 'package:flutter/material.dart';

/// Quality Score Model
/// Represents quality metrics for generated content
class QualityScore {
  final double overall; // 0.0 - 1.0
  final double readability;
  final double completeness;
  final double seo;
  final double grammar;
  final QualityDetails? details;

  QualityScore({
    required this.overall,
    required this.readability,
    required this.completeness,
    required this.seo,
    required this.grammar,
    this.details,
  });

  /// Get letter grade (A+, A, B, C, D)
  String get grade {
    if (overall >= 0.95) return 'A+';
    if (overall >= 0.85) return 'A';
    if (overall >= 0.70) return 'B';
    if (overall >= 0.60) return 'C';
    return 'D';
  }

  /// Get percentage (0-100)
  int get percentage => (overall * 100).toInt();

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

  /// Create from JSON
  factory QualityScore.fromJson(Map<String, dynamic> json) {
    return QualityScore(
      overall: (json['overall'] ?? 0.0).toDouble(),
      readability: (json['readability'] ?? 0.0).toDouble(),
      completeness: (json['completeness'] ?? 0.0).toDouble(),
      seo: (json['seo'] ?? 0.0).toDouble(),
      grammar: (json['grammar'] ?? 0.0).toDouble(),
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
    );
  }
}

/// Quality Details Model
/// Additional metrics about content quality
class QualityDetails {
  final int wordCount;
  final double? fleschKincaidScore;
  final double? keywordDensity;
  final int? headingCount;

  QualityDetails({
    required this.wordCount,
    this.fleschKincaidScore,
    this.keywordDensity,
    this.headingCount,
  });

  /// Create from JSON
  factory QualityDetails.fromJson(Map<String, dynamic> json) {
    return QualityDetails(
      wordCount: json['word_count'] ?? 0,
      fleschKincaidScore: json['flesch_kincaid_score']?.toDouble(),
      keywordDensity: json['keyword_density']?.toDouble(),
      headingCount: json['heading_count'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'word_count': wordCount,
      if (fleschKincaidScore != null)
        'flesch_kincaid_score': fleschKincaidScore,
      if (keywordDensity != null) 'keyword_density': keywordDensity,
      if (headingCount != null) 'heading_count': headingCount,
    };
  }
}
