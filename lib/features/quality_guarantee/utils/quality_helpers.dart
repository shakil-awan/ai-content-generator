import 'package:flutter/material.dart';

/// Quality Helpers
/// Utility functions for quality scoring UI

class QualityHelpers {
  QualityHelpers._();

  /// Get color for metric score
  static Color getMetricColor(double score) {
    if (score >= 0.85) return const Color(0xFF059669); // Green-600
    if (score >= 0.70) return const Color(0xFF2563EB); // Blue-600
    if (score >= 0.60) return const Color(0xFFD97706); // Yellow-600
    return const Color(0xFFDC2626); // Red-600
  }

  /// Get helper text for readability score
  static String getReadabilityHelperText(double score) {
    if (score >= 0.90) return 'Very easy to read (5th grade level)';
    if (score >= 0.80) return 'Easy to read (7th grade level)';
    if (score >= 0.70) return 'Fairly easy to read (8th grade level)';
    if (score >= 0.60) return 'Standard (9-10th grade level)';
    if (score >= 0.50) return 'Fairly difficult (college level)';
    return 'Difficult to read (graduate level)';
  }

  /// Get helper text for completeness score
  static String getCompletenessHelperText(double score) {
    if (score >= 0.90) return 'Well-structured with proper length';
    if (score >= 0.80) return 'Good structure and length';
    if (score >= 0.70) return 'Adequate structure';
    if (score >= 0.60) return 'Missing some structure elements';
    return 'Incomplete structure or length';
  }

  /// Get helper text for SEO score
  static String getSeoHelperText(double score) {
    if (score >= 0.90) return 'Excellent SEO optimization';
    if (score >= 0.80) return 'Good keyword usage and structure';
    if (score >= 0.70) return 'Decent SEO, could improve headings';
    if (score >= 0.60) return 'Basic SEO, needs more optimization';
    return 'Poor SEO optimization';
  }

  /// Get helper text for grammar score
  static String getGrammarHelperText(double score) {
    if (score >= 0.95) return 'Excellent - no errors detected';
    if (score >= 0.85) return 'Very good - minor issues only';
    if (score >= 0.75) return 'Good - few errors found';
    if (score >= 0.60) return 'Fair - some errors detected';
    return 'Needs improvement - multiple errors';
  }

  /// Get overall helper text
  static String getOverallHelperText(String grade) {
    switch (grade) {
      case 'A+':
        return 'Exceptional quality - ready to publish';
      case 'A':
        return 'High quality - minimal editing needed';
      case 'B':
        return 'Good quality - may need minor improvements';
      case 'C':
        return 'Fair quality - consider regenerating';
      case 'D':
        return 'Low quality - regeneration recommended';
      default:
        return 'No quality score available';
    }
  }
}
