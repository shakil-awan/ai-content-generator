import 'fact_check_claim.dart';

/// Fact Check Results Model
/// Contains the results of a fact-checking operation
class FactCheckResults {
  final bool checked;
  final List<FactCheckClaim> claims;
  final int claimsFound;
  final int claimsVerified;
  final double overallConfidence;
  final double verificationTime; // seconds
  final int totalSearchesUsed; // Transparency: shows API usage

  FactCheckResults({
    required this.checked,
    required this.claims,
    this.claimsFound = 0,
    this.claimsVerified = 0,
    this.overallConfidence = 0.0,
    required this.verificationTime,
    this.totalSearchesUsed = 0,
  });

  /// Get total number of claims
  int get totalClaims => claims.length;

  /// Get number of verified claims (confidence >= 70%)
  int get verifiedCount => claims.where((c) => c.confidence >= 0.70).length;

  /// Get number of partially verified claims (50-69%)
  int get partiallyVerifiedCount =>
      claims.where((c) => c.confidence >= 0.50 && c.confidence < 0.70).length;

  /// Get number of unverified claims (<50%)
  int get unverifiedCount => claims.where((c) => c.confidence < 0.50).length;

  /// Check if all claims are verified
  bool get allVerified => verifiedCount == totalClaims;

  /// Check if any claims failed verification
  bool get hasUnverifiedClaims => unverifiedCount > 0;

  /// Get verification time in formatted string
  String get formattedVerificationTime =>
      '${verificationTime.toStringAsFixed(1)}s';

  /// Create from JSON
  factory FactCheckResults.fromJson(Map<String, dynamic> json) {
    return FactCheckResults(
      checked: json['checked'] ?? false,
      claims:
          (json['claims'] as List?)
              ?.map((c) => FactCheckClaim.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      claimsFound: json['claims_found'] ?? json['claimsFound'] ?? 0,
      claimsVerified: json['claims_verified'] ?? json['claimsVerified'] ?? 0,
      overallConfidence:
          (json['overall_confidence'] ?? json['overallConfidence'] ?? 0.0)
              .toDouble(),
      verificationTime:
          (json['verification_time'] ?? json['verificationTime'] ?? 0.0)
              .toDouble(),
      totalSearchesUsed:
          json['total_searches_used'] ?? json['totalSearchesUsed'] ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'checked': checked,
      'claims': claims.map((c) => c.toJson()).toList(),
      'claims_found': claimsFound,
      'claims_verified': claimsVerified,
      'overall_confidence': overallConfidence,
      'verificationTime': verificationTime,
      'total_searches_used': totalSearchesUsed,
    };
  }

  /// Create a copy with modifications
  FactCheckResults copyWith({
    bool? checked,
    List<FactCheckClaim>? claims,
    int? claimsFound,
    int? claimsVerified,
    double? overallConfidence,
    double? verificationTime,
    int? totalSearchesUsed,
  }) {
    return FactCheckResults(
      checked: checked ?? this.checked,
      claims: claims ?? this.claims,
      claimsFound: claimsFound ?? this.claimsFound,
      claimsVerified: claimsVerified ?? this.claimsVerified,
      overallConfidence: overallConfidence ?? this.overallConfidence,
      verificationTime: verificationTime ?? this.verificationTime,
      totalSearchesUsed: totalSearchesUsed ?? this.totalSearchesUsed,
    );
  }

  /// Create empty results
  factory FactCheckResults.empty() {
    return FactCheckResults(
      checked: false,
      claims: [],
      claimsFound: 0,
      claimsVerified: 0,
      overallConfidence: 0.0,
      verificationTime: 0.0,
      totalSearchesUsed: 0,
    );
  }
}
