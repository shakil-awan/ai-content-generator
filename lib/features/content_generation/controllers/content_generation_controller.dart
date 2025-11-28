import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../../core/routing/app_router.dart';
import '../../quality_guarantee/models/quality_score.dart' as qm;
import '../../quality_guarantee/services/quality_service.dart';
import '../models/content_generation_request.dart';
import '../models/content_generation_response.dart';
import '../models/content_type.dart';
import '../services/content_generation_service.dart';
import '../utils/content_generation_test_data.dart';
import '../utils/content_pdf_exporter.dart';

/// Content Generation Controller
/// Manages state for content generation feature
class ContentGenerationController extends GetxController {
  final ContentGenerationService _service;
  final ContentPdfExporter _pdfExporter;
  final ContentGenerationTestSeeder? _testSeeder;
  static const List<String> _allowedWordCounts = [
    '500',
    '1000',
    '1500',
    '2000',
    '2500',
    '3000',
    '3500',
    '4000',
  ];

  ContentGenerationController(
    this._service, {
    ContentPdfExporter? pdfExporter,
    ContentGenerationTestSeeder? testSeeder,
  }) : _pdfExporter = pdfExporter ?? ContentPdfExporter(),
       _testSeeder =
           testSeeder ??
           (ContentGenerationTestSeeder.isEnabled
               ? ContentGenerationTestSeeder()
               : null);

  // Observable state
  final selectedContentType = ContentType.blog.obs;
  final isGenerating = false.obs;
  final generatedContent = Rxn<ContentGenerationResponse>();
  final errorMessage = ''.obs;
  final isExportingPdf = false.obs;

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
  void onInit() {
    super.onInit();
    _maybeApplyTestSeed(initial: true);
    _enforceSocialIncludeDefaults();
  }

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
  Future<void> generateSocialPost([BuildContext? context]) async {
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

      // Navigate using GoRouter with BuildContext
      final navContext = context ?? Get.context;
      if (navContext != null && navContext.mounted) {
        navContext.go(AppRouter.generateResults);
      }
    } catch (e) {
      errorMessage.value = 'Failed to generate social post: $e';
    } finally {
      isGenerating.value = false;
    }
  }

  /// Generate Email Campaign
  Future<void> generateEmail([BuildContext? context]) async {
    if (!canGenerateEmail) return;

    print('\n═══ STARTING EMAIL GENERATION ═══');
    print('Email Type: ${emailType.value}');
    print('Subject: ${emailSubjectController.text}');
    print('Message: ${emailMessageController.text}');
    print('Tone: ${emailTone.value}');

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

      print('\n═══ CALLING SERVICE ═══');
      final response = await _service.generateEmail(request: request);

      print('\n═══ EMAIL GENERATED SUCCESSFULLY ═══');
      generatedContent.value = response;

      // Extract quality score from backend response (already included)
      _extractQualityScoreFromResponse(response);

      // Navigate using GoRouter with BuildContext
      final navContext = context ?? Get.context;
      if (navContext != null && navContext.mounted) {
        navContext.go(AppRouter.generateResults);
      }
    } catch (e) {
      print('\n═══ EMAIL GENERATION ERROR ═══');
      print(e);
      errorMessage.value = 'Failed to generate email: $e';

      // Show error snackbar
      Get.snackbar(
        'Generation Failed',
        'Failed to generate email: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      print('\n═══ SETTING isGenerating = false ═══');
      isGenerating.value = false;
    }
  }

  /// Generate Video Script
  Future<void> generateVideoScript([BuildContext? context]) async {
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

      // Navigate using GoRouter with BuildContext
      final navContext = context ?? Get.context;
      if (navContext != null && navContext.mounted) {
        navContext.go(AppRouter.generateResults);
      }
    } catch (e) {
      errorMessage.value = 'Failed to generate video script: $e';

      // Show error snackbar
      Get.snackbar(
        'Generation Failed',
        'Failed to generate video script: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
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
  Future<void> regenerateContent([BuildContext? context]) async {
    regenerationAttempts.value++;

    switch (selectedContentType.value) {
      case ContentType.blog:
        await generateBlogPost(context);
        break;
      case ContentType.social:
        await generateSocialPost(context);
        break;
      case ContentType.email:
        await generateEmail(context);
        break;
      case ContentType.video:
        await generateVideoScript(context);
        break;
      default:
        errorMessage.value = 'Content type not supported yet';
    }
  }

  /// Reset regeneration counter
  void resetRegenerationAttempts() {
    regenerationAttempts.value = 0;
  }

  /// Export content as different formats
  Future<void> exportContent(String format) async {
    if (generatedContent.value == null) return;

    switch (format.toLowerCase()) {
      case 'pdf':
        await exportContentAsPdf();
        break;
      default:
        Get.snackbar(
          'Export unavailable',
          'Exporting as $format is coming soon.',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }

  Future<void> exportContentAsPdf() async {
    final content = generatedContent.value;
    if (content == null || isExportingPdf.value) {
      if (content == null) {
        Get.snackbar(
          'No content',
          'Generate content before exporting.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return;
    }

    try {
      isExportingPdf.value = true;
      final pdf = await _pdfExporter.build(content);
      await Printing.sharePdf(bytes: pdf.bytes, filename: pdf.filename);
      _markContentExported('pdf');
    } catch (error, stackTrace) {
      debugPrint('PDF export failed: $error\n$stackTrace');
      Get.snackbar(
        'Export failed',
        'Unable to export PDF. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isExportingPdf.value = false;
    }
  }

  void _markContentExported(String destination) {
    final content = generatedContent.value;
    if (content == null) return;
    if (content.exportedTo.contains(destination)) return;

    generatedContent.value = content.copyWith(
      exportedTo: [...content.exportedTo, destination],
      updatedAt: DateTime.now(),
    );
  }

  /// Reset form fields
  void resetForm() {
    _clearFormControllers();
    errorMessage.value = '';
    _maybeApplyTestSeed();
  }

  /// Dev-only helper to cycle forward through curated sample inputs.
  void loadNextSeed() {
    final seeder = _testSeeder;
    if (seeder == null) return;
    _applySeed(seeder.nextSeed());
  }

  /// Dev-only helper to cycle backward through curated sample inputs.
  void loadPreviousSeed() {
    final seeder = _testSeeder;
    if (seeder == null) return;
    _applySeed(seeder.previousSeed());
  }

  void _clearFormControllers() {
    blogTitleController.clear();
    blogAudienceController.clear();
    blogKeyPointsController.clear();
    blogKeywordsController.clear();
    socialTopicController.clear();
    _enforceSocialIncludeDefaults();
    emailSubjectController.clear();
    emailAudienceController.clear();
    emailMessageController.clear();
    emailCallToActionController.clear();
    videoTopicController.clear();
    videoAudienceController.clear();
  }

  void _maybeApplyTestSeed({bool initial = false}) {
    final seeder = _testSeeder;
    if (seeder == null) return;
    final seed = initial ? seeder.initialSeed() : seeder.nextSeed();
    _applySeed(seed);
  }

  void _applySeed(ContentGenerationTestData seed) {
    // Blog form fields
    blogTitleController.text = seed.blog.title;
    blogWordCount.value = _normalizeWordCount(seed.blog.wordCountLabel);
    blogTone.value = seed.blog.tone;
    blogWritingStyle.value = seed.blog.writingStyle;
    blogAudienceController.text = seed.blog.targetAudience ?? '';
    blogKeyPointsController.text = seed.blog.keyPoints.join('\n');
    blogKeywordsController.text = seed.blog.seoKeywords.join(', ');
    blogIncludeExamples.value = seed.blog.includeExamples;
    blogAutoFactCheck.value = seed.blog.autoFactCheck;
    blogIncludeVisuals.value = seed.blog.includeVisuals;

    // Social form fields
    socialPlatform.value = seed.social.platform;
    socialTopicController.text = seed.social.topic;
    socialTone.value = seed.social.tone;

    // Email form fields
    emailType.value = seed.email.type;
    emailTone.value = seed.email.tone;
    emailSubjectController.text = seed.email.subject;
    emailAudienceController.text = seed.email.audience ?? '';
    emailMessageController.text = seed.email.message;
    emailCallToActionController.text = seed.email.callToAction ?? '';

    // Video form placeholders (legacy UI)
    videoTopicController.text = seed.video.topic;
    videoPlatform.value = seed.video.platform;
    videoDuration.value = seed.video.duration;
    videoTone.value = seed.video.tone;
    videoAudienceController.text = seed.video.audience ?? '';

    _enforceSocialIncludeDefaults();
  }

  void _enforceSocialIncludeDefaults() {
    socialIncludeHashtags.value = true;
    socialIncludeEmoji.value = true;
    socialIncludeCallToAction.value = true;
  }

  String _normalizeWordCount(String raw) {
    if (_allowedWordCounts.contains(raw)) {
      return raw;
    }
    final numeric = int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), ''));
    if (numeric == null) {
      return _allowedWordCounts.first;
    }
    String closest = _allowedWordCounts.first;
    var smallestDelta = (numeric - int.parse(closest)).abs();
    for (final option in _allowedWordCounts.skip(1)) {
      final optionValue = int.parse(option);
      final delta = (numeric - optionValue).abs();
      if (delta < smallestDelta) {
        smallestDelta = delta;
        closest = option;
      }
    }
    return closest;
  }
}
