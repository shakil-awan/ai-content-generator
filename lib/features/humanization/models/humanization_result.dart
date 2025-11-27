import 'package:flutter/material.dart';

import 'ai_detection_analysis.dart';
import 'humanization_json_keys.dart';

/// Humanization Result Model
/// Represents the complete result of AI humanization process
class HumanizationResult {
  final bool applied;
  final String level; // 'light', 'balanced', 'aggressive'
  final double beforeScore; // 0-100
  final double afterScore; // 0-100
  final double improvement;
  final double improvementPercentage;
  final AIDetectionAnalysis beforeAnalysis;
  final AIDetectionAnalysis afterAnalysis;
  final String humanizedContent;
  final String originalContent;

  HumanizationResult({
    required this.applied,
    required this.level,
    required this.beforeScore,
    required this.afterScore,
    required this.improvement,
    required this.improvementPercentage,
    required this.beforeAnalysis,
    required this.afterAnalysis,
    required this.humanizedContent,
    required this.originalContent,
  });

  /// Get improvement text (e.g., "57 points")
  String get improvementText => '${improvement.toInt()} points';

  /// Get improvement percentage text (e.g., "67.1% reduction")
  String get improvementPercentageText =>
      '${improvementPercentage.toStringAsFixed(1)}% reduction';

  /// Get before score color
  Color get beforeScoreColor => _getScoreColor(beforeScore);

  /// Get after score color
  Color get afterScoreColor => _getScoreColor(afterScore);

  /// Get humanization level label
  String get levelLabel {
    switch (level) {
      case 'light':
        return 'Light Humanization';
      case 'aggressive':
        return 'Aggressive Humanization';
      case 'balanced':
      default:
        return 'Balanced Humanization';
    }
  }

  /// Get score color based on value
  Color _getScoreColor(double score) {
    if (score >= 70) return const Color(0xFFDC2626); // Red
    if (score >= 40) return const Color(0xFFD97706); // Yellow
    return const Color(0xFF059669); // Green
  }

  /// Get score gradient colors
  List<Color> getScoreGradient(double score) {
    if (score >= 70) {
      return [
        const Color(0xFFDC2626), // Red-600
        const Color(0xFFF87171), // Red-400
      ];
    }
    if (score >= 40) {
      return [
        const Color(0xFFD97706), // Yellow-600
        const Color(0xFFFBBF24), // Yellow-400
      ];
    }
    return [
      const Color(0xFF059669), // Green-600
      const Color(0xFF34D399), // Green-400
    ];
  }

  /// Check if improvement is significant (>30 points)
  bool get isSignificantImprovement => improvement >= 30;

  /// Create from JSON
  factory HumanizationResult.fromJson(Map<String, dynamic> json) {
    return HumanizationResult(
      applied: json[HumanizationJsonKeys.applied] ?? false,
      level: json[HumanizationJsonKeys.level] ?? 'balanced',
      beforeScore: (json[HumanizationJsonKeys.beforeScore] ?? 0).toDouble(),
      afterScore: (json[HumanizationJsonKeys.afterScore] ?? 0).toDouble(),
      improvement: (json[HumanizationJsonKeys.improvement] ?? 0).toDouble(),
      improvementPercentage:
          (json[HumanizationJsonKeys.improvementPercentage] ?? 0).toDouble(),
      beforeAnalysis: AIDetectionAnalysis.fromJson(
        json[HumanizationJsonKeys.beforeAnalysis] as Map<String, dynamic>? ??
            {},
      ),
      afterAnalysis: AIDetectionAnalysis.fromJson(
        json[HumanizationJsonKeys.afterAnalysis] as Map<String, dynamic>? ?? {},
      ),
      humanizedContent: json[HumanizationJsonKeys.humanizedContent] ?? '',
      originalContent: json[HumanizationJsonKeys.originalContent] ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      HumanizationJsonKeys.applied: applied,
      HumanizationJsonKeys.level: level,
      HumanizationJsonKeys.beforeScore: beforeScore,
      HumanizationJsonKeys.afterScore: afterScore,
      HumanizationJsonKeys.improvement: improvement,
      HumanizationJsonKeys.improvementPercentage: improvementPercentage,
      HumanizationJsonKeys.beforeAnalysis: beforeAnalysis.toJson(),
      HumanizationJsonKeys.afterAnalysis: afterAnalysis.toJson(),
      HumanizationJsonKeys.humanizedContent: humanizedContent,
      HumanizationJsonKeys.originalContent: originalContent,
    };
  }

  /// Create empty result
  factory HumanizationResult.empty() {
    return HumanizationResult(
      applied: false,
      level: 'balanced',
      beforeScore: 0,
      afterScore: 0,
      improvement: 0,
      improvementPercentage: 0,
      beforeAnalysis: AIDetectionAnalysis.empty(),
      afterAnalysis: AIDetectionAnalysis.empty(),
      humanizedContent: '',
      originalContent: '',
    );
  }
}
