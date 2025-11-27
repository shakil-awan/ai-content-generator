import 'package:flutter/material.dart';

/// Quality Helpers
/// Utility functions for quality scoring UI

class QualityHelpers {
  QualityHelpers._();

  /// Get color for metric score (positive and encouraging)
  static Color getMetricColor(double score) {
    if (score >= 0.85) return const Color(0xFF059669); // Green-600 (A+/A)
    if (score >= 0.70)
      return const Color(0xFF10B981); // Green-500 (B - positive!)
    if (score >= 0.60) return const Color(0xFF3B82F6); // Blue-500 (C)
    if (score >= 0.50) return const Color(0xFFF59E0B); // Amber-500 (D)
    return const Color(0xFFDC2626); // Red-600 (F)
  }

  /// Get helper text for readability score (encouraging and positive)
  static String getReadabilityHelperText(double score) {
    if (score >= 0.90) return 'Very Easy to Read ✨ (5th grade)';
    if (score >= 0.80) return 'Easy to Read 📖 (7th grade)';
    if (score >= 0.70) return 'Clear & Accessible 📚 (8th-9th grade)';
    if (score >= 0.60) return 'Standard Level 🎯 (10th grade)';
    if (score >= 0.50) return 'Professional Level 🎓 (college)';
    return 'Advanced Level 🔬 (graduate)';
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

  /// Get overall helper text (encouraging and positive)
  static String getOverallHelperText(String grade) {
    switch (grade) {
      case 'A+':
        return 'Exceptional quality! 🌟 Ready to publish';
      case 'A':
        return 'Excellent work! ✨ Minimal editing needed';
      case 'B':
        return 'Great quality! 👍 Strong content overall';
      case 'C':
        return 'Good start! 💡 Check AI suggestions for improvements';
      case 'D':
        return 'Needs work 🔧 Consider regenerating';
      default:
        return 'No quality score available';
    }
  }
}
