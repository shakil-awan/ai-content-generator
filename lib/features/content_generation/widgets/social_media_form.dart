import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/content_generation_controller.dart';

/// Social Media Form Widget
class SocialMediaForm extends GetView<ContentGenerationController> {
  const SocialMediaForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Platform dropdown
        H3('Platform *'),
        const Gap(8),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: AppTheme.borderRadiusMD,
            ),
            child: DropdownButton<String>(
              value: controller.socialPlatform.value,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'Twitter', child: Text('Twitter / X')),
                DropdownMenuItem(value: 'LinkedIn', child: Text('LinkedIn')),
                DropdownMenuItem(value: 'Instagram', child: Text('Instagram')),
                DropdownMenuItem(value: 'Facebook', child: Text('Facebook')),
              ],
              onChanged: (value) {
                if (value != null) controller.socialPlatform.value = value;
              },
            ),
          ),
        ),
        const Gap(16),

        // Topic field
        CustomTextField(
          controller: controller.socialTopicController,
          label: 'Topic / Message *',
          hint: 'e.g., Announcing our new AI feature',
          prefixIcon: Icons.message,
          maxLines: 3,
          onChanged: (_) => controller.update(),
        ),
        const Gap(16),

        // Tone dropdown
        H3('Tone'),
        const Gap(8),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: AppTheme.borderRadiusMD,
            ),
            child: DropdownButton<String>(
              value: controller.socialTone.value,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: 'Professional',
                  child: Text('Professional'),
                ),
                DropdownMenuItem(value: 'Casual', child: Text('Casual')),
                DropdownMenuItem(value: 'Friendly', child: Text('Friendly')),
                DropdownMenuItem(value: 'Exciting', child: Text('Exciting')),
                DropdownMenuItem(value: 'Humorous', child: Text('Humorous')),
              ],
              onChanged: (value) {
                if (value != null) controller.socialTone.value = value;
              },
            ),
          ),
        ),
        const Gap(24),

        // Include options
        const H3('Include (check all that apply)'),
        const Gap(8),
        Obx(
          () => CheckboxListTile(
            title: const BodyText('Hashtags (5-10)'),
            value: controller.socialIncludeHashtags.value,
            onChanged: (value) {
              if (value != null) controller.socialIncludeHashtags.value = value;
            },
            contentPadding: EdgeInsets.zero,
          ),
        ),
        Obx(
          () => CheckboxListTile(
            title: const BodyText('Emoji'),
            value: controller.socialIncludeEmoji.value,
            onChanged: (value) {
              if (value != null) controller.socialIncludeEmoji.value = value;
            },
            contentPadding: EdgeInsets.zero,
          ),
        ),
        Obx(
          () => CheckboxListTile(
            title: const BodyText('Call to Action'),
            value: controller.socialIncludeCallToAction.value,
            onChanged: (value) {
              if (value != null) {
                controller.socialIncludeCallToAction.value = value;
              }
            },
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const Gap(32),

        // Generate button
        Obx(
          () => PrimaryButton(
            text: 'Generate Post 🚀',
            onPressed: controller.canGenerateSocial
                ? () => controller.generateSocialPost()
                : null,
            isLoading: controller.isGenerating.value,
            width: double.infinity,
          ),
        ),
        const Gap(8),
        const CaptionText(
          'Est. 5-8 seconds | 1 credit',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
