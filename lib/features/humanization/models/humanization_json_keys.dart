/// JSON keys for humanization API responses
/// Matches backend schema to prevent hardcoded strings
///
/// Backend Response Structure:
/// ```json
/// {
///   "generationId": "gen_123",
///   "originalContent": "...",
///   "humanizedContent": "...",
///   "beforeScore": 85.0,
///   "afterScore": 28.0,
///   "improvement": 57.0,
///   "improvementPercentage": 67.1,
///   "level": "balanced",
///   "detectionApi": "openai-self-detection",
///   "processingTime": 3.45,
///   "tokensUsed": 1250,
///   "beforeAnalysis": {
///     "indicators": [...],
///     "reasoning": "..."
///   },
///   "afterAnalysis": {
///     "indicators": [...],
///     "reasoning": "..."
///   },
///   "appliedAt": "2024-01-15T10:30:00Z"
/// }
/// ```
class HumanizationJsonKeys {
  // ==================== REQUEST KEYS ====================

  /// Humanization level: 'light', 'balanced', 'aggressive'
  static const String level = 'level';

  /// Whether to preserve factual information during humanization
  static const String preserveFacts = 'preserve_facts';

  // ==================== RESPONSE KEYS ====================

  /// Generation ID
  static const String generationId = 'generationId';

  /// Original AI-generated content
  static const String originalContent = 'originalContent';

  /// Humanized version of content
  static const String humanizedContent = 'humanizedContent';

  /// AI detection score before humanization (0-100)
  static const String beforeScore = 'beforeScore';

  /// AI detection score after humanization (0-100)
  static const String afterScore = 'afterScore';

  /// Improvement in points (beforeScore - afterScore)
  static const String improvement = 'improvement';

  /// Improvement percentage
  static const String improvementPercentage = 'improvementPercentage';

  /// Tokens used by humanization process
  static const String tokensUsed = 'tokensUsed';

  /// Detection API used ('openai-self-detection', 'gemini-fallback', etc)
  static const String detectionApi = 'detectionApi';

  /// Processing time in seconds
  static const String processingTime = 'processingTime';

  /// Timestamp when humanization was applied
  static const String appliedAt = 'appliedAt';

  /// Humanization applied flag
  static const String applied = 'applied';

  // ==================== ANALYSIS KEYS ====================

  /// Analysis before humanization
  static const String beforeAnalysis = 'beforeAnalysis';

  /// Analysis after humanization
  static const String afterAnalysis = 'afterAnalysis';

  /// AI detection score (0-100, higher = more AI-like)
  static const String aiScore = 'aiScore';

  /// Confidence level (0-1)
  static const String confidence = 'confidence';

  /// List of AI indicators detected
  static const String indicators = 'indicators';

  /// Reasoning for detection score
  static const String reasoning = 'reasoning';
}
