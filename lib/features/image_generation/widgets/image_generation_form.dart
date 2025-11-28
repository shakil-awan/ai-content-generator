import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/image_generation_controller.dart';
import 'aspect_ratio_selector.dart';
import 'batch_generation_modal.dart';
import 'image_loading_widget.dart';
import 'image_quota_display.dart';
import 'style_selector.dart';

/// Image Generation Form
/// Main form for generating AI images
class ImageGenerationForm extends StatelessWidget {
  const ImageGenerationForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageGenerationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form title
        const H2('Generate AI Image 🎨'),
        const Gap(8),
        const BodyText(
          'Describe what you want to see, and AI will create it for you.',
          color: AppTheme.textSecondary,
        ),
        const Gap(24),

        // Prompt field
        CustomTextField(
          label: 'Describe your image',
          hint:
              'e.g., Modern office workspace with plants and natural lighting',
          maxLines: 3,
          onChanged: (value) => controller.prompt.value = value,
        ),
        const Gap(8),
        Obx(() {
          final length = controller.prompt.value.length;
          final color = length < 10
              ? AppTheme.error
              : length < 50
              ? AppTheme.warning
              : AppTheme.success;
          return BodyTextSmall(
            '$length / 500 characters (minimum 10)',
            color: color,
          );
        }),
        const Gap(24),

        // Style selector
        const StyleSelector(),
        const Gap(24),

        // Aspect ratio selector
        const AspectRatioSelector(),
        const Gap(24),

        // Advanced options
        Obx(() => _buildAdvancedOptions(controller)),
        const Gap(24),

        // Quota display
        const ImageQuotaDisplay(),
        const Gap(24),

        // Generate button
        Obx(
          () => PrimaryButton(
            text: 'Generate Image',
            onPressed: controller.canGenerate
                ? () => controller.generateImage()
                : null,
            isLoading: controller.isGenerating.value,
            icon: Icons.auto_awesome,
            width: double.infinity,
          ),
        ),
        const Gap(8),
        Obx(() {
          if (!controller.hasQuota) {
            return Container(
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
                  Icon(Icons.warning, color: AppTheme.error, size: 20),
                  const Gap(8),
                  Expanded(
                    child: BodyTextSmall(
                      'Image generation quota exceeded. Upgrade to continue.',
                      color: AppTheme.error,
                    ),
                  ),
                ],
              ),
            );
          }
          if (controller.canGenerate) {
            return const BodyTextSmall(
              '💰 Cost: \$0.003 | ⏱️ Time: ~2.5 sec',
              color: AppTheme.textSecondary,
              textAlign: TextAlign.center,
            );
          }
          return const SizedBox.shrink();
        }),
        const Gap(24),

        // Batch generation link
        Center(
          child: TextButton.icon(
            onPressed: () => BatchGenerationModal.show(context),
            icon: const Icon(Icons.photo_library, size: 20),
            label: const BodyText(
              'Need multiple images? Try Batch Generate →',
              color: AppTheme.primary,
            ),
          ),
        ),
        const Gap(24),

        // Loading widget (shown during generation) - stays in constrained width
        const ImageLoadingWidget(),

        // Results break out to full width below
      ],
    );
  }

  Widget _buildAdvancedOptions(ImageGenerationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            // Toggle advanced options visibility (using simple state)
          },
          child: Row(
            children: [
              const BodyText('Advanced Options', fontWeight: FontWeight.w600),
              const Gap(8),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
        const Gap(12),
        // Always show for simplicity
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgSecondary,
            borderRadius: AppTheme.borderRadiusMD,
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                value: controller.enhancePrompt.value,
                onChanged: (value) =>
                    controller.enhancePrompt.value = value ?? true,
                title: const BodyText('Enhance prompt with quality keywords'),
                subtitle: const BodyTextSmall(
                  'Automatically adds professional quality modifiers',
                  color: AppTheme.textSecondary,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const Gap(12),
              const BodyTextSmall(
                'Output: PNG format, High quality',
                color: AppTheme.textSecondary,
              ),
              const Gap(4),
              const BodyTextSmall(
                'Model: Flux Schnell (Fast & Cost-Effective)',
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
