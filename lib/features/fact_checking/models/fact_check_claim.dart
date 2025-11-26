import 'package:flutter/material.dart';

/// Fact Check Claim Model
/// Represents a single claim that has been fact-checked
class FactCheckClaim {
  final String claim;
  final bool verified;
  final String? source;
  final double confidence; // 0.0 - 1.0

  FactCheckClaim({
    required this.claim,
    required this.verified,
    this.source,
    required this.confidence,
  });

  /// Get confidence as percentage string (e.g., "85%")
  String get confidencePercentage => '${(confidence * 100).toInt()}%';

  /// Get status color based on confidence level
  Color get statusColor {
    if (confidence >= 0.70) return const Color(0xFF059669); // Green-600
    if (confidence >= 0.50) return const Color(0xFFD97706); // Yellow-600
    return const Color(0xFFDC2626); // Red-600
  }

  /// Get background color based on confidence level
  Color get backgroundColor {
    if (confidence >= 0.70) return const Color(0xFFF0FDF4); // Green-50
    if (confidence >= 0.50) return const Color(0xFFFFFBEB); // Yellow-50
    return const Color(0xFFFEF2F2); // Red-50
  }

  /// Get status label text
  String get statusLabel {
    if (confidence >= 0.70) return 'VERIFIED';
    if (confidence >= 0.50) return 'PARTIALLY VERIFIED';
    return 'UNVERIFIED';
  }

  /// Get status icon
  IconData get statusIcon {
    if (confidence >= 0.70) return Icons.check_circle;
    if (confidence >= 0.50) return Icons.warning;
    return Icons.cancel;
  }

  /// Create from JSON
  factory FactCheckClaim.fromJson(Map<String, dynamic> json) {
    return FactCheckClaim(
      claim: json['claim'] ?? '',
      verified: json['verified'] ?? false,
      source: json['source'],
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'claim': claim,
      'verified': verified,
      'source': source,
      'confidence': confidence,
    };
  }

  /// Create a copy with modifications
  FactCheckClaim copyWith({
    String? claim,
    bool? verified,
    String? source,
    double? confidence,
  }) {
    return FactCheckClaim(
      claim: claim ?? this.claim,
      verified: verified ?? this.verified,
      source: source ?? this.source,
      confidence: confidence ?? this.confidence,
    );
  }
}
