import 'fact_check_claim.dart';

/// Fact Check Results Model
/// Contains the results of a fact-checking operation
class FactCheckResults {
  final bool checked;
  final List<FactCheckClaim> claims;
  final double verificationTime; // seconds

  FactCheckResults({
    required this.checked,
    required this.claims,
    required this.verificationTime,
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
      verificationTime: (json['verificationTime'] ?? 0).toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'checked': checked,
      'claims': claims.map((c) => c.toJson()).toList(),
      'verificationTime': verificationTime,
    };
  }

  /// Create a copy with modifications
  FactCheckResults copyWith({
    bool? checked,
    List<FactCheckClaim>? claims,
    double? verificationTime,
  }) {
    return FactCheckResults(
      checked: checked ?? this.checked,
      claims: claims ?? this.claims,
      verificationTime: verificationTime ?? this.verificationTime,
    );
  }

  /// Create empty results
  factory FactCheckResults.empty() {
    return FactCheckResults(checked: false, claims: [], verificationTime: 0.0);
  }
}
