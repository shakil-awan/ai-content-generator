import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/image_generation_controller.dart';

/// Image Quota Display Widget
/// Shows image generation quota status
class ImageQuotaDisplay extends StatelessWidget {
  const ImageQuotaDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageGenerationController>();

    return Obx(() {
      final percentage = controller.quotaPercentage;
      final isNearLimit = controller.isNearLimit;
      final Color barColor = percentage >= 0.95
          ? AppTheme.error
          : percentage >= 0.8
          ? AppTheme.warning
          : AppTheme.primary;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isNearLimit
              ? AppTheme.warning.withValues(alpha: 0.1)
              : AppTheme.bgSecondary,
          borderRadius: AppTheme.borderRadiusMD,
          border: Border.all(
            color: isNearLimit
                ? AppTheme.warning.withValues(alpha: 0.3)
                : AppTheme.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isNearLimit)
                  Icon(Icons.warning, color: AppTheme.warning, size: 20),
                if (isNearLimit) const Gap(8),
                const BodyText(
                  'Image Generation Quota',
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            const Gap(12),
            // Progress bar
            ClipRRect(
              borderRadius: AppTheme.borderRadiusMD,
              child: LinearProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: AppTheme.border,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            const Gap(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BodyText(
                  '${controller.imagesUsed.value} of ${controller.imagesLimit.value} images used',
                ),
                if (isNearLimit)
                  BodyText(
                    'Only ${controller.imagesRemaining} left!',
                    color: AppTheme.warning,
                    fontWeight: FontWeight.w600,
                  ),
              ],
            ),
            const Gap(8),
            const BodyTextSmall(
              'Resets on Dec 1, 2025',
              color: AppTheme.textSecondary,
            ),
            if (isNearLimit) ...[
              const Gap(12),
              TextButton.icon(
                onPressed: () {
                  Get.snackbar(
                    'Upgrade',
                    'Upgrade to Pro for 50 images/month',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const BodyTextSmall(
                  'Upgrade to Pro for more images',
                  color: AppTheme.primary,
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
