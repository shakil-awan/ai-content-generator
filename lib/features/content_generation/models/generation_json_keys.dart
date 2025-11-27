/// JSON keys for content generation API responses
/// Matches backend schema exactly - DO NOT use hardcoded strings
class GenerationJsonKeys {
  // Generation Response Keys
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String contentType = 'content_type';
  static const String content = 'content';
  static const String title = 'title';
  static const String metaDescription = 'meta_description';
  static const String wordCount = 'word_count';
  static const String qualityMetrics = 'quality_metrics';
  static const String factCheckResults = 'fact_check_results';
  static const String humanization = 'humanization';
  static const String aiSuggestions =
      'ai_suggestions'; // Phase 3: AI improvement suggestions
  static const String aiQualityMetrics =
      'ai_quality_metrics'; // Phase 3: Deep AI analysis
  static const String isContentRefresh = 'is_content_refresh';
  static const String originalContentId = 'original_content_id';
  static const String videoScriptSettings = 'video_script_settings';
  static const String generationTime = 'generation_time';
  static const String modelUsed = 'model_used';
  static const String exportedTo = 'exported_to';
  static const String isFavorite = 'is_favorite';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  // Quality Metrics Keys
  static const String readabilityScore = 'readability_score';
  static const String completenessScore = 'completeness_score';
  static const String seoScore = 'seo_score';
  static const String grammarScore = 'grammar_score';
  static const String originalityScore = 'originality_score';
  static const String factCheckScore = 'fact_check_score';
  static const String aiDetectionScore = 'ai_detection_score';
  static const String overallScore = 'overall_score';

  // Fact Check Results Keys
  static const String checked = 'checked';
  static const String claims = 'claims';
  static const String verificationTime = 'verification_time';

  // Fact Check Claim Keys
  static const String claim = 'claim';
  static const String verified = 'verified';
  static const String source = 'source';
  static const String confidence = 'confidence';

  // Humanization Result Keys
  static const String applied = 'applied';
  static const String level = 'level';
  static const String beforeScore = 'before_score';
  static const String afterScore = 'after_score';
  static const String detectionApi = 'detection_api';
  static const String processingTime = 'processing_time';
  static const String humanizedAt = 'humanizedAt';

  // Video Script Settings Keys
  static const String platform = 'platform';
  static const String duration = 'duration';
  static const String includeHooks = 'include_hooks';
  static const String includeCta = 'include_cta';
}
