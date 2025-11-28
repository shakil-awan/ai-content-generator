import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/content_generation_controller.dart';

/// Email Campaign Form Widget
class EmailForm extends GetView<ContentGenerationController> {
  const EmailForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email type dropdown
        H3('Email Type *'),
        const Gap(8),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: AppTheme.borderRadiusMD,
            ),
            child: DropdownButton<String>(
              value: controller.emailType.value,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: 'Newsletter',
                  child: Text('Newsletter'),
                ),
                DropdownMenuItem(
                  value: 'Promotional',
                  child: Text('Promotional'),
                ),
                DropdownMenuItem(
                  value: 'Welcome',
                  child: Text('Welcome Email'),
                ),
                DropdownMenuItem(
                  value: 'Announcement',
                  child: Text('Announcement'),
                ),
              ],
              onChanged: (value) {
                if (value != null) controller.emailType.value = value;
              },
            ),
          ),
        ),
        const Gap(16),

        // Subject field
        CustomTextField(
          controller: controller.emailSubjectController,
          label: 'Subject Line / Topic *',
          hint: 'e.g., Weekly AI Updates - November 2025',
          prefixIcon: Icons.email,
          onChanged: (_) => controller.update(),
        ),
        const Gap(16),

        // Target audience
        CustomTextField(
          controller: controller.emailAudienceController,
          label: 'Target Audience',
          hint: 'e.g., Existing subscribers',
          prefixIcon: Icons.group,
        ),
        const Gap(16),

        // Main message
        CustomTextField(
          controller: controller.emailMessageController,
          label: 'Main Message / Offer *',
          hint: 'e.g., Introduce new fact-checking feature',
          prefixIcon: Icons.message,
          maxLines: 4,
          onChanged: (_) => controller.update(),
        ),
        const Gap(16),

        // Call to action
        CustomTextField(
          controller: controller.emailCallToActionController,
          label: 'Call to Action',
          hint: 'e.g., Try it free today',
          prefixIcon: Icons.touch_app,
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
              value: controller.emailTone.value,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: 'Professional',
                  child: Text('Professional'),
                ),
                DropdownMenuItem(value: 'Friendly', child: Text('Friendly')),
                DropdownMenuItem(value: 'Casual', child: Text('Casual')),
                DropdownMenuItem(value: 'Formal', child: Text('Formal')),
              ],
              onChanged: (value) {
                if (value != null) controller.emailTone.value = value;
              },
            ),
          ),
        ),
        const Gap(32),

        // Generate button
        Obx(
          () => PrimaryButton(
            text: 'Generate Email 🚀',
            onPressed: controller.canGenerateEmail
                ? () => controller.generateEmail(context)
                : null,
            isLoading: controller.isGenerating.value,
            width: double.infinity,
          ),
        ),
        const Gap(8),
        const CaptionText(
          'Est. 8-10 seconds | 1 credit',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
