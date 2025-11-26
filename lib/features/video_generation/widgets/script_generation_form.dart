import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/video_script_controller.dart';
import 'duration_selector.dart';
import 'platform_selector.dart';

/// Video Script Generation Form
/// Form for creating video scripts with platform-specific optimization
class ScriptGenerationForm extends StatelessWidget {
  const ScriptGenerationForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoScriptController>();
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form title
        const H3('Video Script Details'),
        const Gap(8),
        const BodyTextSmall(
          'Enter your video topic and preferences. We\'ll generate an optimized script.',
          color: AppTheme.textSecondary,
        ),
        const Gap(24),

        // Topic field
        CustomTextField(
          label: 'Video Topic',
          hint: 'e.g., "How to boost productivity with AI tools"',
          onChanged: (value) => controller.topic.value = value,
          maxLines: 2,
        ),
        const Gap(16),

        // Platform & Duration row (desktop) or column (mobile)
        if (isDesktop)
          Row(
            children: [
              Expanded(child: PlatformSelector()),
              const Gap(16),
              Expanded(child: DurationSelector()),
            ],
          )
        else ...[
          PlatformSelector(),
          const Gap(16),
          DurationSelector(),
        ],
        const Gap(16),

        // Target audience
        CustomTextField(
          label: 'Target Audience (Optional)',
          hint: 'e.g., "Marketing professionals" or "Beginner developers"',
          onChanged: (value) => controller.targetAudience.value = value,
        ),
        const Gap(16),

        // Tone selector
        const BodyText('Tone', fontWeight: FontWeight.w600),
        const Gap(8),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.tones.map((tone) {
              final isSelected = controller.tone.value == tone;
              return GestureDetector(
                onTap: () => controller.tone.value = tone,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : AppTheme.bgSecondary,
                    borderRadius: AppTheme.borderRadiusMD,
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.border,
                    ),
                  ),
                  child: BodyTextSmall(
                    tone.substring(0, 1).toUpperCase() + tone.substring(1),
                    color: isSelected
                        ? AppTheme.textOnPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Gap(16),

        // Key points
        const BodyText(
          'Key Points to Cover (Optional)',
          fontWeight: FontWeight.w600,
        ),
        const Gap(8),
        Obx(
          () => Column(
            children: [
              ...controller.keyPoints.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.bgSecondary,
                            borderRadius: AppTheme.borderRadiusMD,
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: BodyTextSmall(entry.value)),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () =>
                                    controller.removeKeyPoint(entry.key),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (controller.keyPoints.length < 10)
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Add a key point and press Enter',
                    suffixIcon: const Icon(Icons.add),
                    filled: true,
                    fillColor: AppTheme.bgPrimary,
                    border: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadiusMD,
                      borderSide: BorderSide(color: AppTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadiusMD,
                      borderSide: BorderSide(color: AppTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadiusMD,
                      borderSide: BorderSide(color: AppTheme.primary, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing16,
                      vertical: AppTheme.spacing16,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      controller.addKeyPoint(value);
                    }
                  },
                ),
            ],
          ),
        ),
        const Gap(16),

        // Call to action
        CustomTextField(
          label: 'Call to Action (Optional)',
          hint: 'e.g., "Visit our website" or "Subscribe for more tips"',
          onChanged: (value) => controller.cta.value = value,
        ),
        const Gap(24),

        // Options checkboxes
        Obx(
          () => Column(
            children: [
              CheckboxListTile(
                value: controller.includeHooks.value,
                onChanged: (value) =>
                    controller.includeHooks.value = value ?? true,
                title: const BodyText('Include attention-grabbing hooks'),
                subtitle: const BodyTextSmall(
                  'Start with a powerful hook to capture viewers in first 5 seconds',
                  color: AppTheme.textSecondary,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: controller.includeCta.value,
                onChanged: (value) =>
                    controller.includeCta.value = value ?? true,
                title: const BodyText('Include call-to-action'),
                subtitle: const BodyTextSmall(
                  'End with a clear CTA to drive engagement',
                  color: AppTheme.textSecondary,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const Gap(32),

        // Generate button
        Obx(
          () => PrimaryButton(
            text: 'Generate Script',
            onPressed: controller.isFormValid
                ? () => controller.generateScript()
                : null,
            isLoading: controller.isGenerating.value,
            icon: Icons.auto_awesome,
            width: double.infinity,
          ),
        ),
        const Gap(8),
        Obx(() {
          if (controller.isFormValid) {
            return const BodyTextSmall(
              '✨ Estimated time: ~12 seconds | Credits: 1',
              color: AppTheme.textSecondary,
              textAlign: TextAlign.center,
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
