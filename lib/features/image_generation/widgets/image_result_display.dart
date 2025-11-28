import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/image_generation_controller.dart';

/// Image Result Display Widget
/// Shows generated image with metadata and actions in a responsive layout
class ImageResultDisplay extends StatelessWidget {
  const ImageResultDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageGenerationController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Obx(() {
      final response = controller.imageResponse.value;
      if (response == null) return const SizedBox.shrink();

      return Container(
        margin: EdgeInsets.only(top: isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success banner - full width
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                borderRadius: AppTheme.borderRadiusMD,
                border: Border.all(
                  color: AppTheme.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.success, size: 24),
                  const Gap(12),
                  const Expanded(
                    child: BodyText(
                      'Image generated successfully! 🎉',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Gap(isMobile ? 16 : 24),

            // Main content - responsive layout
            isMobile
                ? _buildMobileLayout(controller, response)
                : _buildDesktopLayout(controller, response),
          ],
        ),
      );
    });
  }

  /// Desktop layout - side by side image and details
  Widget _buildDesktopLayout(controller, response) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image - 60% width
        Expanded(flex: 6, child: _buildImageCard(response)),
        const Gap(24),
        // Details - 40% width
        Expanded(flex: 4, child: _buildDetailsCard(controller, response)),
      ],
    );
  }

  /// Mobile layout - stacked image and details
  Widget _buildMobileLayout(controller, response) {
    return Column(
      children: [
        _buildImageCard(response),
        const Gap(16),
        _buildDetailsCard(controller, response),
      ],
    );
  }

  /// Image card with large display
  Widget _buildImageCard(response) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: AppTheme.borderRadiusLG,
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppTheme.borderRadiusLG,
        child: Image.network(
          response.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 400,
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
              height: 400,
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
    );
  }

  /// Details card with metadata and actions
  Widget _buildDetailsCard(controller, response) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: AppTheme.borderRadiusLG,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prompt
          const H3('Prompt'),
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.bgPrimary,
              borderRadius: AppTheme.borderRadiusMD,
            ),
            child: BodyTextSmall(controller.prompt.value),
          ),
          const Gap(20),

          // Metadata grid
          const H3('Details'),
          const Gap(12),
          _buildMetadataGrid(controller, response),
          const Gap(20),

          // Actions - full width buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryButton(
                text: 'Download Image',
                onPressed: () => _downloadImage(response.imageUrl),
                icon: Icons.download,
                width: double.infinity,
              ),
              const Gap(8),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'Copy URL',
                      onPressed: () => _copyToClipboard(response.imageUrl),
                      icon: Icons.link,
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: SecondaryButton(
                      text: 'Regenerate',
                      onPressed: () => controller.generateImage(),
                      icon: Icons.refresh,
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Center(
                child: TextButton(
                  onPressed: controller.clearResult,
                  child: const BodyText('Close', color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),

          // Enhanced prompt section
          if (response.enhancedPrompt != null &&
              response.enhancedPrompt != controller.prompt.value) ...[
            const Gap(16),
            ExpansionTile(
              title: const BodyText(
                'View Enhanced Prompt',
                fontWeight: FontWeight.w600,
              ),
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
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
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build metadata grid for compact display
  Widget _buildMetadataGrid(controller, response) {
    return Column(
      children: [
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
        Row(
          children: [
            Expanded(
              child: _MetadataRow(
                icon: Icons.timer,
                label: 'Time',
                value: response.formattedTime,
              ),
            ),
            const Gap(8),
            Expanded(
              child: _MetadataRow(
                icon: Icons.attach_money,
                label: 'Cost',
                value: response.formattedCost,
              ),
            ),
          ],
        ),
        const Gap(8),
        _MetadataRow(
          icon: Icons.model_training,
          label: 'Model',
          value: response.modelDisplay,
        ),
      ],
    );
  }

  void _downloadImage(String url) {
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

/// Metadata Row Widget - Compact display
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
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const Gap(6),
        BodyTextSmall('$label:', color: AppTheme.textSecondary),
        const Gap(6),
        Expanded(child: BodyText(value, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
