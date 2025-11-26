import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
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

  // Blog Post Form Controllers
  final blogTitleController = TextEditingController();
  final blogAudienceController = TextEditingController();
  final blogKeyPointsController = TextEditingController();
  final blogKeywordsController = TextEditingController();
  final blogWordCount = '1000-2000'.obs;
  final blogTone = 'Professional'.obs;
  final blogAutoFactCheck = false.obs;
  final blogIncludeVisuals = false.obs;
  final blogBrandVoiceId = Rxn<String>();

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

  /// Add mock fact-check data to response (for testing UI)
  /// TODO: Remove this once backend implements fact-checking
  ContentGenerationResponse _addMockFactCheckData(
    ContentGenerationResponse response,
  ) {
    // Create mock fact-check results
    final mockFactCheck = FactCheckResults(
      checked: true,
      claims: [
        FactCheckClaim(
          claim:
              'Intel Core i5 or AMD Ryzen 5 processor is a good starting point for most students',
          verified: true,
          source: 'Intel Official Specifications & AMD Product Documentation',
          confidence: 0.92,
        ),
        FactCheckClaim(
          claim: 'Aim for at least 8GB of RAM, 16GB is even better',
          verified: true,
          source:
              'Microsoft Windows System Requirements & Apple macOS Guidelines',
          confidence: 0.88,
        ),
        FactCheckClaim(
          claim: 'A Solid State Drive (SSD) is crucial for fast boot times',
          verified: true,
          source: 'Multiple tech benchmark studies',
          confidence: 0.95,
        ),
        FactCheckClaim(
          claim: '256GB is a decent starting point for storage',
          verified: true,
          source: 'Industry storage recommendations',
          confidence: 0.65,
        ),
        FactCheckClaim(
          claim:
              'Laptops can range from a few hundred dollars to well over a thousand',
          verified: false,
          source: 'Vague pricing claim - no specific source',
          confidence: 0.35,
        ),
      ],
      verificationTime: 12.8,
    );

    // Create a new response with mock data
    return ContentGenerationResponse(
      id: response.id,
      userId: response.userId,
      contentType: response.contentType,
      content: response.content,
      title: response.title,
      qualityMetrics: response.qualityMetrics,
      factCheckResults: mockFactCheck,
      humanization: response.humanization,
      isContentRefresh: response.isContentRefresh,
      originalContentId: response.originalContentId,
      videoScriptSettings: response.videoScriptSettings,
      generationTime: response.generationTime,
      modelUsed: response.modelUsed,
      exportedTo: response.exportedTo,
      isFavorite: response.isFavorite,
      createdAt: response.createdAt,
      updatedAt: response.updatedAt,
    );
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
      // Convert word count to length enum (500-1000 -> short, 1000-2000 -> medium, 2000+ -> long)
      String length = 'medium';
      if (blogWordCount.value == '500-1000') {
        length = 'short';
      } else if (blogWordCount.value == '2000-3000' ||
          blogWordCount.value == '3000+') {
        length = 'long';
      }

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

      final request = BlogPostRequest(
        topic: blogTitleController.text.trim(),
        length: length,
        tone: blogTone.value,
        keywords: keywords,
        includeSeo: true,
        includeImages: blogIncludeVisuals.value,
      );

      final response = await _service.generateBlogPost(request: request);

      // Add mock fact-check data if auto fact-check is enabled
      // TODO: Remove this once backend implements fact-checking
      if (blogAutoFactCheck.value) {
        generatedContent.value = _addMockFactCheckData(response);
      } else {
        generatedContent.value = response;
      }

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

  /// Regenerate current content
  Future<void> regenerateContent() async {
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
