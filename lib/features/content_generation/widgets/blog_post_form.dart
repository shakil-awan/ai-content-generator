import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/content_generation_controller.dart';

/// Blog Post Form Widget
class BlogPostForm extends GetView<ContentGenerationController> {
  const BlogPostForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title field
        CustomTextField(
          controller: controller.blogTitleController,
          label: 'Blog Title / Topic *',
          hint: 'e.g., 10 AI Tools for Content Creators',
          prefixIcon: Icons.title,
          onChanged: (_) => controller.update(),
        ),
        const Gap(16),

        // Word count dropdown
        H3('Target Word Count'),
        const Gap(8),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: AppTheme.borderRadiusMD,
            ),
            child: DropdownButton<String>(
              value: controller.blogWordCount.value,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: '500', child: Text('500 words')),
                DropdownMenuItem(value: '1000', child: Text('1000 words')),
                DropdownMenuItem(value: '1500', child: Text('1500 words')),
                DropdownMenuItem(value: '2000', child: Text('2000 words')),
                DropdownMenuItem(value: '2500', child: Text('2500 words')),
                DropdownMenuItem(value: '3000', child: Text('3000 words')),
                DropdownMenuItem(value: '3500', child: Text('3500 words')),
                DropdownMenuItem(value: '4000', child: Text('4000 words')),
              ],
              onChanged: (value) {
                if (value != null) controller.blogWordCount.value = value;
              },
            ),
          ),
        ),
        const Gap(16),

        // Tone dropdown
        H3('Tone / Style'),
        const Gap(8),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: AppTheme.borderRadiusMD,
            ),
            child: DropdownButton<String>(
              value: controller.blogTone.value,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: 'Professional',
                  child: Text('Professional'),
                ),
                DropdownMenuItem(value: 'Casual', child: Text('Casual')),
                DropdownMenuItem(value: 'Friendly', child: Text('Friendly')),
                DropdownMenuItem(value: 'Formal', child: Text('Formal')),
                DropdownMenuItem(value: 'Humorous', child: Text('Humorous')),
              ],
              onChanged: (value) {
                if (value != null) controller.blogTone.value = value;
              },
            ),
          ),
        ),
        const Gap(16),

        // Writing Style dropdown
        H3('Writing Style'),
        const Gap(8),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: AppTheme.borderRadiusMD,
            ),
            child: DropdownButton<String>(
              value: controller.blogWritingStyle.value,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'Narrative', child: Text('Narrative')),
                DropdownMenuItem(value: 'Listicle', child: Text('Listicle')),
                DropdownMenuItem(value: 'How-to', child: Text('How-to')),
                DropdownMenuItem(
                  value: 'Case-study',
                  child: Text('Case Study'),
                ),
                DropdownMenuItem(
                  value: 'Comparison',
                  child: Text('Comparison'),
                ),
              ],
              onChanged: (value) {
                if (value != null) controller.blogWritingStyle.value = value;
              },
            ),
          ),
        ),
        const Gap(16),

        // Target audience (optional)
        CustomTextField(
          controller: controller.blogAudienceController,
          label: 'Target Audience (Optional)',
          hint: 'e.g., Beginner content creators',
          prefixIcon: Icons.group,
          maxLines: 2,
        ),
        const Gap(16),

        // Key points (optional)
        CustomTextField(
          controller: controller.blogKeyPointsController,
          label: 'Key Points to Include (Optional)',
          hint: 'e.g., ChatGPT, Midjourney, Jasper AI (comma-separated)',
          prefixIcon: Icons.checklist,
          maxLines: 2,
        ),
        const Gap(16),

        // SEO keywords (optional)
        CustomTextField(
          controller: controller.blogKeywordsController,
          label: 'SEO Keywords (Optional)',
          hint: 'e.g., AI tools, content creation, productivity',
          prefixIcon: Icons.search,
          maxLines: 2,
        ),
        const Gap(24),

        // Advanced options
        _buildAdvancedOptions(),
        const Gap(32),

        // Generate button
        Obx(
          () => PrimaryButton(
            text: 'Generate Blog Post 🚀',
            onPressed: controller.canGenerateBlog
                ? () => controller.generateBlogPost(context)
                : null,
            isLoading: controller.isGenerating.value,
            width: double.infinity,
          ),
        ),
        const Gap(8),
        const CaptionText(
          'Est. 8-12 seconds | 1 credit',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return ExpansionTile(
      title: const H3('Advanced Options'),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Obx(
          () => CheckboxListTile(
            title: const BodyText('Include Real-World Examples'),
            subtitle: const CaptionText(
              'Adds 2-3 relevant examples to your blog',
            ),
            value: controller.blogIncludeExamples.value,
            onChanged: (value) {
              if (value != null) controller.blogIncludeExamples.value = value;
            },
            contentPadding: EdgeInsets.zero,
          ),
        ),
        Obx(
          () => CheckboxListTile(
            title: const BodyText('Auto Fact-Check (adds 10-15s)'),
            subtitle: const CaptionText('PRO feature'),
            value: controller.blogAutoFactCheck.value,
            onChanged: (value) {
              if (value != null) controller.blogAutoFactCheck.value = value;
            },
            contentPadding: EdgeInsets.zero,
          ),
        ),
        Obx(
          () => CheckboxListTile(
            title: const BodyText('Include Visuals (stock images)'),
            value: controller.blogIncludeVisuals.value,
            onChanged: (value) {
              if (value != null) controller.blogIncludeVisuals.value = value;
            },
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const Gap(8),
        const CaptionText(
          'Brand Voice selection coming soon...',
          color: AppTheme.textSecondary,
        ),
      ],
    );
  }
}
