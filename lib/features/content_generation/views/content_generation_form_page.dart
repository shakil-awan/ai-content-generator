import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/content_generation_controller.dart';
import '../models/content_type.dart';
import '../widgets/blog_post_form.dart';
import '../widgets/content_type_tabs.dart';
import '../widgets/email_form.dart';
import '../widgets/social_media_form.dart';
import '../widgets/video_script_form.dart';
import '../../image_generation/widgets/image_generation_form.dart';

/// Content Generation Form Page
/// Main screen for selecting content type and filling out generation form
class ContentGenerationFormPage extends GetView<ContentGenerationController> {
  const ContentGenerationFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      appBar: AppBar(
        title: const H2('Generate Content'),
        actions: [
          // User avatar placeholder
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.person, color: AppTheme.textOnPrimary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? AppTheme.spacing48 : AppTheme.spacing16,
            vertical: AppTheme.spacing24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 800 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title
                  const H1('Generate Content'),
                  const Gap(8),
                  const BodyText(
                    'Select a content type and fill in the details to generate AI-powered content.',
                    color: AppTheme.textSecondary,
                  ),
                  const Gap(32),

                  // Content type selector
                  const ContentTypeTabs(),
                  const Gap(32),

                  // Dynamic form based on selected type
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.bgPrimary,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: AppTheme.borderRadiusLG,
                    ),
                    child: Obx(() => _buildForm()),
                  ),

                  // Error message
                  Obx(() {
                    if (controller.errorMessage.value.isNotEmpty) {
                      return Column(
                        children: [
                          const Gap(16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withValues(alpha: 0.1),
                              borderRadius: AppTheme.borderRadiusMD,
                              border: Border.all(
                                color: AppTheme.error.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppTheme.error,
                                  size: 20,
                                ),
                                const Gap(8),
                                Expanded(
                                  child: BodyTextSmall(
                                    controller.errorMessage.value,
                                    color: AppTheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  const Gap(48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    switch (controller.selectedContentType.value) {
      case ContentType.blog:
        return const BlogPostForm();
      case ContentType.social:
        return const SocialMediaForm();
      case ContentType.email:
        return const EmailForm();
      case ContentType.video:
        return const VideoScriptForm();
      case ContentType.image:
        return const ImageGenerationForm();
      case ContentType.product:
        return _buildComingSoon('Product Description');
      case ContentType.ad:
        return _buildComingSoon('Ad Copy');
    }
  }

  Widget _buildComingSoon(String contentTypeName) {
    return Column(
      children: [
        Icon(
          Icons.construction,
          size: 64,
          color: AppTheme.textSecondary.withValues(alpha: 0.5),
        ),
        const Gap(16),
        H3('$contentTypeName Generator', textAlign: TextAlign.center),
        const Gap(8),
        const BodyText(
          'Coming Soon!',
          textAlign: TextAlign.center,
          color: AppTheme.textSecondary,
        ),
        const Gap(8),
        const BodyTextSmall(
          'This content type is under development and will be available in the next update.',
          textAlign: TextAlign.center,
          color: AppTheme.textSecondary,
        ),
      ],
    );
  }
}
