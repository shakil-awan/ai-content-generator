import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../image_generation/widgets/image_generation_form.dart';
import '../../image_generation/widgets/image_generation_results_wrapper.dart';
import '../controllers/content_generation_controller.dart';
import '../models/content_type.dart';
import '../utils/content_generation_test_data.dart';
import '../widgets/blog_post_form.dart';
import '../widgets/content_type_tabs.dart';
import '../widgets/email_form.dart';
import '../widgets/social_media_form.dart';
import '../widgets/video_script_form.dart';

/// Content Generation Form Page
/// Main screen for selecting content type and filling out generation form
class ContentGenerationFormPage extends GetView<ContentGenerationController> {
  const ContentGenerationFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Responsive form section with dynamic width
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: _getHorizontalPadding(context),
                        vertical: AppTheme.spacing24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Page title + dev-only seed controls
                          _PageHeading(controller: controller),
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
                                      color: AppTheme.error.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: AppTheme.borderRadiusMD,
                                      border: Border.all(
                                        color: AppTheme.error.withValues(
                                          alpha: 0.3,
                                        ),
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

                    // Full-width results section (only for image generation)
                    Obx(() {
                      if (controller.selectedContentType.value ==
                          ContentType.image) {
                        return const ImageGenerationResultsWrapper();
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ),
          ],
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

class _PageHeading extends StatelessWidget {
  const _PageHeading({required this.controller});

  final ContentGenerationController controller;

  @override
  Widget build(BuildContext context) {
    if (!ContentGenerationTestSeeder.isEnabled) {
      return const H1('Generate Content');
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // On mobile, stack vertically; on desktop, use row layout
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const H1('Generate Content'),
          const Gap(12),
          _SeedControlGroup(controller: controller),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SeedControlGroup(controller: controller),
        const Gap(16),
        const Expanded(child: H1('Generate Content')),
      ],
    );
  }
}

class _SeedControlGroup extends StatelessWidget {
  const _SeedControlGroup({required this.controller});

  final ContentGenerationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: AppTheme.borderRadiusMD,
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SeedCycleButton(
            icon: Icons.remove,
            tooltip: 'Previous sample data',
            onPressed: controller.loadPreviousSeed,
          ),
          Container(width: 1, height: 24, color: AppTheme.border),
          _SeedCycleButton(
            icon: Icons.add,
            tooltip: 'Next sample data',
            onPressed: controller.loadNextSeed,
          ),
        ],
      ),
    );
  }
}

class _SeedCycleButton extends StatelessWidget {
  const _SeedCycleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 18),
      constraints: const BoxConstraints.tightFor(width: 40, height: 36),
      splashRadius: 20,
    );
  }
}

/// Get responsive horizontal padding based on screen width
/// This ensures proper spacing on all device sizes
double _getHorizontalPadding(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

  if (width > 1600) {
    // Ultra-wide: More padding on sides
    return 64;
  } else if (width > 1200) {
    // Desktop: Moderate padding
    return 48;
  } else if (width > 768) {
    // Tablet: Less padding
    return 32;
  } else {
    // Mobile: Minimal padding
    return 16;
  }
}
