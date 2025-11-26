import 'package:flutter/material.dart';

/// AI Detection Analysis Model
/// Represents detailed analysis of AI detection scoring
class AIDetectionAnalysis {
  final double aiScore; // 0-100 (higher = more AI-like)
  final double confidence; // 0-1
  final List<String> indicators;
  final String reasoning;

  AIDetectionAnalysis({
    required this.aiScore,
    required this.confidence,
    required this.indicators,
    required this.reasoning,
  });

  /// Get color based on AI score
  Color get scoreColor {
    if (aiScore >= 70) return const Color(0xFFDC2626); // Red (high AI)
    if (aiScore >= 40) return const Color(0xFFD97706); // Yellow (medium AI)
    return const Color(0xFF059669); // Green (low AI)
  }

  /// Get background color for score
  Color get scoreBackgroundColor {
    if (aiScore >= 70) return const Color(0xFFFEF2F2); // Red-50
    if (aiScore >= 40) return const Color(0xFFFFFBEB); // Yellow-50
    return const Color(0xFFF0FDF4); // Green-50
  }

  /// Get score label
  String get scoreLabel {
    if (aiScore >= 70) return 'High AI Detection';
    if (aiScore >= 40) return 'Medium AI Detection';
    return 'Low AI Detection';
  }

  /// Create from JSON
  factory AIDetectionAnalysis.fromJson(Map<String, dynamic> json) {
    return AIDetectionAnalysis(
      aiScore: (json['ai_score'] ?? 0).toDouble(),
      confidence: (json['confidence'] ?? 0).toDouble(),
      indicators: List<String>.from(json['indicators'] ?? []),
      reasoning: json['reasoning'] ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'ai_score': aiScore,
      'confidence': confidence,
      'indicators': indicators,
      'reasoning': reasoning,
    };
  }

  /// Create empty analysis
  factory AIDetectionAnalysis.empty() {
    return AIDetectionAnalysis(
      aiScore: 0,
      confidence: 0,
      indicators: [],
      reasoning: '',
    );
  }
}
