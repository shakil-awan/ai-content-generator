import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/image_generation_controller.dart';

/// Image Loading Widget
/// Shows progress during image generation
class ImageLoadingWidget extends StatelessWidget {
  const ImageLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageGenerationController>();

    return Obx(() {
      if (!controller.isGenerating.value) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.05),
          borderRadius: AppTheme.borderRadiusLG,
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
                const Gap(12),
                const H3('Creating your image...'),
              ],
            ),
            const Gap(24),

            // Progress bar
            ClipRRect(
              borderRadius: AppTheme.borderRadiusMD,
              child: LinearProgressIndicator(
                value: controller.generationProgress.value,
                minHeight: 8,
                backgroundColor: AppTheme.border,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
            const Gap(12),

            // Percentage and step
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BodyText(
                  controller.currentStep.value,
                  color: AppTheme.textSecondary,
                ),
                BodyText(
                  '${(controller.generationProgress.value * 100).toInt()}%',
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            const Gap(16),

            // Time estimate
            const BodyTextSmall(
              '⏱ Estimated time: 2-3 seconds',
              color: AppTheme.textSecondary,
            ),
            const Gap(16),

            // Cancel button
            TextButton(
              onPressed: () {
                controller.isGenerating.value = false;
                Get.snackbar(
                  'Cancelled',
                  'Image generation cancelled',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: const BodyText('Cancel', color: AppTheme.error),
            ),
          ],
        ),
      );
    });
  }
}
