import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../quality_guarantee/models/quality_score.dart' as qm;
import '../../quality_guarantee/services/quality_service.dart';
import '../models/content_generation_request.dart';
import '../models/content_generation_response.dart';
import '../models/content_type.dart';
import '../services/content_generation_service.dart';

/// Content Generation Controller
/// Manages state for content generation feature
class ContentGenerationController extends GetxController {
  final ContentGenerationService _service;

  ContentGenerationController(this._service);

  // Observable state
  final selectedContentType = ContentType.blog.obs;
  final isGenerating = false.obs;
  final generatedContent = Rxn<ContentGenerationResponse>();
  final errorMessage = ''.obs;

  // Quality scoring state
  final currentQualityScore = Rxn<qm.QualityScore>();
  final isScoringQuality = false.obs;
  final qualitySuggestions = <String>[].obs;
  final regenerationAttempts = 0.obs;
  final maxRegenerationAttempts = 3;

  // Blog Post Form Controllers
  final blogTitleController = TextEditingController();
  final blogAudienceController = TextEditingController();
  final blogKeyPointsController = TextEditingController();
  final blogKeywordsController = TextEditingController();
  final blogWordCount = '500'.obs;
  final blogTone = 'Professional'.obs;
  final blogAutoFactCheck = true.obs; // Enable fact-checking by default
  final blogIncludeVisuals = false.obs;
  final blogBrandVoiceId = Rxn<String>();
  // Phase 2 new fields
  final blogWritingStyle =
      'Narrative'.obs; // narrative, listicle, how-to, case-study, comparison
  final blogIncludeExamples = true.obs;

  // Social Media Form Controllers
  final socialTopicController = TextEditingController();
  final socialPlatform = 'Twitter'.obs;
  final socialTone = 'Casual'.obs;
  final socialIncludeHashtags = true.obs;
  final socialIncludeEmoji = true.obs;
  final socialIncludeCallToAction = true.obs;

  // Email Form Controllers
  final emailSubjectController = TextEditingController();
  final emailAudienceController = TextEditingController();
  final emailMessageController = TextEditingController();
  final emailCallToActionController = TextEditingController();
  final emailType = 'Newsletter'.obs;
  final emailTone = 'Friendly'.obs;

  // Video Form Controllers
  final videoTopicController = TextEditingController();
  final videoAudienceController = TextEditingController();
  final videoPlatform = 'YouTube'.obs;
  final videoDuration = '3 minutes'.obs;
  final videoTone = 'Professional'.obs;

  /// Computed properties
  bool get canGenerateBlog =>
      blogTitleController.text.length >= 5 && !isGenerating.value;

  bool get canGenerateSocial =>
      socialTopicController.text.length >= 5 && !isGenerating.value;

  bool get canGenerateEmail =>
      emailSubjectController.text.length >= 5 &&
      emailMessageController.text.length >= 10 &&
      !isGenerating.value;

  bool get canGenerateVideo =>
      videoTopicController.text.length >= 5 && !isGenerating.value;

  @override
  void onClose() {
    // Dispose controllers
    blogTitleController.dispose();
    blogAudienceController.dispose();
    blogKeyPointsController.dispose();
    blogKeywordsController.dispose();
    socialTopicController.dispose();
    emailSubjectController.dispose();
    emailAudienceController.dispose();
    emailMessageController.dispose();
    emailCallToActionController.dispose();
    videoTopicController.dispose();
    videoAudienceController.dispose();
    super.onClose();
  }

  /// Select content type and reset form
  void selectContentType(ContentType type) {
    selectedContentType.value = type;
    errorMessage.value = '';
  }

  /// Generate Blog Post
  Future<void> generateBlogPost([BuildContext? context]) async {
    if (!canGenerateBlog) return;

    isGenerating.value = true;
    errorMessage.value = '';

    try {
      // Phase 2: Use exact word count value from dropdown
      int wordCount = int.tryParse(blogWordCount.value) ?? 1500;

      // Convert keywords string to array
      List<String> keywords = [];
      if (blogKeywordsController.text.trim().isNotEmpty) {
        keywords = blogKeywordsController.text
            .split(',')
            .map((k) => k.trim())
            .where((k) => k.isNotEmpty)
            .toList();
      }
      // If no keywords provided, use title as keyword
      if (keywords.isEmpty) {
        keywords = [blogTitleController.text.trim()];
      }

      // Phase 2: Prepare optional fields
      final targetAudience = blogAudienceController.text.trim().isNotEmpty
          ? blogAudienceController.text.trim()
          : null;

      final writingStyle = blogWritingStyle.value != 'Narrative'
          ? blogWritingStyle.value.toLowerCase()
          : null;

      final request = BlogPostRequest(
        topic: blogTitleController.text.trim(),
        wordCount: wordCount,
        tone: blogTone.value,
        keywords: keywords,
        includeSeo: true,
        includeImages: blogIncludeVisuals.value,
        targetAudience: targetAudience,
        writingStyle: writingStyle,
        includeExamples: blogIncludeExamples.value,
        enableFactCheck: blogAutoFactCheck.value,
      );

      final response = await _service.generateBlogPost(request: request);

      // Use real backend response (backend now implements fact-checking)
      generatedContent.value = response;

      // Extract quality score from backend response (already included)
      _extractQualityScoreFromResponse(response);

      // Navigate to results page using GoRouter
      final navContext = context ?? Get.context;
      if (navContext != null && navContext.mounted) {
        navContext.go(AppRouter.generateResults);
      }
    } catch (e) {
      errorMessage.value = 'Failed to generate blog post: $e';
    } finally {
      isGenerating.value = false;
    }
  }

  /// Generate Social Media Post
  Future<void> generateSocialPost() async {
    if (!canGenerateSocial) return;

    isGenerating.value = true;
    errorMessage.value = '';

    try {
      final request = SocialMediaRequest(
        platform: socialPlatform.value,
        topic: socialTopicController.text.trim(),
        tone: socialTone.value,
        includeHashtags: socialIncludeHashtags.value,
        includeEmoji: socialIncludeEmoji.value,
        includeCallToAction: socialIncludeCallToAction.value,
      );

      final response = await _service.generateSocialPost(request: request);

      generatedContent.value = response;

      // Extract quality score from backend response (already included)
      _extractQualityScoreFromResponse(response);

      // Navigate using GoRouter
      final context = Get.context;
      if (context != null && context.mounted) {
        context.go(AppRouter.generateResults);
      }
    } catch (e) {
      errorMessage.value = 'Failed to generate social post: $e';
    } finally {
      isGenerating.value = false;
    }
  }

  /// Generate Email Campaign
  Future<void> generateEmail() async {
    if (!canGenerateEmail) return;

    isGenerating.value = true;
    errorMessage.value = '';

    try {
      final request = EmailCampaignRequest(
        emailType: emailType.value,
        subject: emailSubjectController.text.trim(),
        targetAudience: emailAudienceController.text.trim().isNotEmpty
            ? emailAudienceController.text.trim()
            : null,
        mainMessage: emailMessageController.text.trim(),
        callToAction: emailCallToActionController.text.trim().isNotEmpty
            ? emailCallToActionController.text.trim()
            : null,
        tone: emailTone.value,
      );

      final response = await _service.generateEmail(request: request);

      generatedContent.value = response;

      // Extract quality score from backend response (already included)
      _extractQualityScoreFromResponse(response);

      // Navigate using GoRouter
      final context = Get.context;
      if (context != null && context.mounted) {
        context.go(AppRouter.generateResults);
      }
    } catch (e) {
      errorMessage.value = 'Failed to generate email: $e';
    } finally {
      isGenerating.value = false;
    }
  }

  /// Generate Video Script
  Future<void> generateVideoScript() async {
    if (!canGenerateVideo) return;

    isGenerating.value = true;
    errorMessage.value = '';

    try {
      final request = VideoScriptRequest(
        topic: videoTopicController.text.trim(),
        platform: videoPlatform.value,
        duration: videoDuration.value,
        targetAudience: videoAudienceController.text.trim().isNotEmpty
            ? videoAudienceController.text.trim()
            : null,
        tone: videoTone.value,
      );

      final response = await _service.generateVideoScript(request: request);

      generatedContent.value = response;

      // Extract quality score from backend response (already included)
      _extractQualityScoreFromResponse(response);

      // Navigate using GoRouter
      final context = Get.context;
      if (context != null && context.mounted) {
        context.go(AppRouter.generateResults);
      }
    } catch (e) {
      errorMessage.value = 'Failed to generate video script: $e';
    } finally {
      isGenerating.value = false;
    }
  }

  /// Copy content to clipboard
  Future<void> copyContent() async {
    if (generatedContent.value == null) return;

    // TODO: Implement clipboard copy
    // Success message will be shown in UI
  }

  /// Extract quality score from backend response
  /// Backend already calculates quality score, no need for separate API call
  void _extractQualityScoreFromResponse(ContentGenerationResponse response) {
    try {
      final metrics = response.qualityMetrics;

      // Convert backend quality metrics (0-10 scale) to QualityScore model (0-1 scale)
      currentQualityScore.value = qm.QualityScore(
        overall: metrics.overallScore / 10,
        readability: metrics.readabilityScore / 10,
        completeness:
            metrics.completenessScore / 10, // NOW USING CORRECT SCORE!
        seo: metrics.seoScore / 10, // NOW USING DEDICATED SEO SCORE!
        grammar: metrics.grammarScore / 10,
        grade: null, // Will be calculated by model
        percentage: null, // Will be calculated by model
        shouldRegenerate: metrics.overallScore < 6.0, // < 60% threshold
      );

      // Note: Backend quality_score comes from quality_scorer during generation
      // No need for improvement suggestions since quality is already good (passed threshold)
      qualitySuggestions.value = [];
    } catch (e) {
      print('Failed to extract quality score: $e');
      // Don't fail silently - set empty score
      currentQualityScore.value = null;
    }
  }

  /// Score content quality using Quality API
  Future<void> scoreContentQuality({
    required String content,
    required String contentType,
    List<String>? keywords,
    int? targetLength,
  }) async {
    if (content.isEmpty) return;

    try {
      isScoringQuality.value = true;
      final qualityService = Get.find<QualityService>();

      // Score the content
      final result = await qualityService.scoreContent(
        content: content,
        contentType: contentType,
        keywords: keywords,
        targetLength: targetLength ?? 500,
      );

      // Convert to QualityScore model
      currentQualityScore.value = qm.QualityScore(
        overall: result.overall,
        readability: result.readability,
        completeness: result.completeness,
        seo: result.seo,
        grammar: result.grammar,
        grade: result.grade,
        percentage: result.percentage,
        shouldRegenerate: result.shouldRegenerate,
        details: qm.QualityDetails(
          wordCount: result.details.wordCount,
          sentenceCount: result.details.sentenceCount,
          avgSentenceLength: result.details.avgSentenceLength,
          paragraphCount: result.details.paragraphCount,
          fleschKincaidScore: result.details.fleschKincaidScore,
        ),
      );

      // If quality is low, get improvement suggestions
      if (result.shouldRegenerate) {
        final suggestions = await qualityService.getSuggestions(
          overall: result.overall,
          readability: result.readability,
          completeness: result.completeness,
          seo: result.seo,
          grammar: result.grammar,
        );
        qualitySuggestions.value = suggestions.suggestions;
      }
    } catch (e) {
      print('Quality scoring error: $e');
      // Don't block content generation if quality scoring fails
    } finally {
      isScoringQuality.value = false;
    }
  }

  /// Regenerate current content
  Future<void> regenerateContent() async {
    regenerationAttempts.value++;

    switch (selectedContentType.value) {
      case ContentType.blog:
        await generateBlogPost();
        break;
      case ContentType.social:
        await generateSocialPost();
        break;
      case ContentType.email:
        await generateEmail();
        break;
      case ContentType.video:
        await generateVideoScript();
        break;
      default:
        errorMessage.value = 'Content type not supported yet';
    }
  }

  /// Reset regeneration counter
  void resetRegenerationAttempts() {
    regenerationAttempts.value = 0;
  }

  /// Save content to history
  Future<void> saveContent() async {
    if (generatedContent.value == null) return;

    // TODO: Implement save to Firebase
    // Success message will be shown in UI
  }

  /// Export content as different formats
  Future<void> exportContent(String format) async {
    if (generatedContent.value == null) return;

    // TODO: Implement export functionality
    // Success message will be shown in UI
  }

  /// Reset form fields
  void resetForm() {
    blogTitleController.clear();
    blogAudienceController.clear();
    blogKeyPointsController.clear();
    blogKeywordsController.clear();
    socialTopicController.clear();
    emailSubjectController.clear();
    emailAudienceController.clear();
    emailMessageController.clear();
    emailCallToActionController.clear();
    videoTopicController.clear();
    videoAudienceController.clear();
    errorMessage.value = '';
  }
}
