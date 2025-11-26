import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/image_generation_controller.dart';

/// Image Result Display Widget
/// Shows generated image with metadata and actions
class ImageResultDisplay extends StatelessWidget {
  const ImageResultDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageGenerationController>();

    return Obx(() {
      final response = controller.imageResponse.value;
      if (response == null) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.bgSecondary,
          borderRadius: AppTheme.borderRadiusLG,
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                borderRadius: AppTheme.borderRadiusMD,
                border: Border.all(
                  color: AppTheme.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                  const Gap(8),
                  const BodyText(
                    'Image generated successfully! 🎉',
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
            const Gap(24),

            // Image preview
            Center(
              child: ClipRRect(
                borderRadius: AppTheme.borderRadiusMD,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.border),
                    borderRadius: AppTheme.borderRadiusMD,
                  ),
                  child: Image.network(
                    response.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: AppTheme.bgPrimary,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 48,
                                color: AppTheme.textSecondary,
                              ),
                              const Gap(8),
                              const BodyText(
                                'Image failed to load',
                                color: AppTheme.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 300,
                        color: AppTheme.bgPrimary,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const Gap(24),

            // Prompt display
            const H3('Prompt'),
            const Gap(8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgPrimary,
                borderRadius: AppTheme.borderRadiusMD,
              ),
              child: BodyText(controller.prompt.value),
            ),
            const Gap(24),

            // Metadata
            const H3('Details'),
            const Gap(12),
            _MetadataRow(
              icon: Icons.model_training,
              label: 'Model',
              value: response.modelDisplay,
            ),
            const Gap(8),
            _MetadataRow(
              icon: Icons.palette,
              label: 'Style',
              value: controller.style.value.capitalize ?? '',
            ),
            const Gap(8),
            _MetadataRow(
              icon: Icons.aspect_ratio,
              label: 'Size',
              value: response.displaySize,
            ),
            const Gap(8),
            _MetadataRow(
              icon: Icons.timer,
              label: 'Time',
              value: response.formattedTime,
            ),
            const Gap(8),
            _MetadataRow(
              icon: Icons.attach_money,
              label: 'Cost',
              value: response.formattedCost,
            ),
            const Gap(24),

            // Actions
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                PrimaryButton(
                  text: 'Download Image',
                  onPressed: () => _downloadImage(response.imageUrl),
                  icon: Icons.download,
                ),
                SecondaryButton(
                  text: 'Copy URL',
                  onPressed: () => _copyToClipboard(response.imageUrl),
                  icon: Icons.link,
                ),
                SecondaryButton(
                  text: 'Regenerate',
                  onPressed: () => controller.generateImage(),
                  icon: Icons.refresh,
                ),
                TextButton(
                  onPressed: controller.clearResult,
                  child: const BodyText('Close', color: AppTheme.textSecondary),
                ),
              ],
            ),

            // Enhanced prompt section
            if (response.enhancedPrompt != null &&
                response.enhancedPrompt != controller.prompt.value) ...[
              const Gap(24),
              ExpansionTile(
                title: const BodyText(
                  'View Enhanced Prompt',
                  fontWeight: FontWeight.w600,
                ),
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 12),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.bgPrimary,
                      borderRadius: AppTheme.borderRadiusMD,
                    ),
                    child: BodyTextSmall(
                      response.enhancedPrompt!,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Gap(8),
                  const BodyTextSmall(
                    '💡 AI automatically added style-specific keywords',
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  void _downloadImage(String url) {
    // Mock download - in real app would use download package
    Get.snackbar(
      'Download Started',
      'Image is being downloaded...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _copyToClipboard(String url) {
    Clipboard.setData(ClipboardData(text: url));
    Get.snackbar(
      'Copied!',
      'Image URL copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}

/// Metadata Row Widget
class _MetadataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const Gap(8),
        BodyText('$label:', color: AppTheme.textSecondary),
        const Gap(8),
        BodyText(value, fontWeight: FontWeight.w600),
      ],
    );
  }
}
