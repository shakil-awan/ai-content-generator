import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/video_script_controller.dart';
import 'hashtag_tags.dart';
import 'script_section_card.dart';
import 'thumbnail_options_card.dart';

/// Script Results Display Widget
/// Shows generated video script with sections, thumbnails, and hashtags
class ScriptResultsDisplay extends StatelessWidget {
  const ScriptResultsDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoScriptController>();
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Obx(() {
      final script = controller.generatedScript.value;
      if (script == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success header
          Container(
            padding: const EdgeInsets.all(16),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const H3('Script Generated Successfully! 🎉'),
                      const Gap(4),
                      BodyTextSmall(
                        'Platform: ${controller.platformEmoji} ${controller.platformDisplay} | '
                        'Duration: ${controller.durationDisplay} | '
                        'Retention: ${script.retentionPercentage}%',
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(24),

          // Hook section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.1),
              borderRadius: AppTheme.borderRadiusLG,
              border: Border.all(
                color: AppTheme.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 24)),
                    const Gap(12),
                    const H3('Opening Hook (First 5 seconds)'),
                  ],
                ),
                const Gap(12),
                BodyText(script.hook),
                const Gap(8),
                const BodyTextSmall(
                  'This hook is designed to capture attention immediately',
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
          const Gap(24),

          // Script sections
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              H3('Script Sections (${script.script.length})'),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: controller.expandAllSections,
                    icon: const Icon(Icons.unfold_more, size: 18),
                    label: const BodyTextSmall('Expand All'),
                  ),
                  const Gap(8),
                  TextButton.icon(
                    onPressed: controller.collapseAllSections,
                    icon: const Icon(Icons.unfold_less, size: 18),
                    label: const BodyTextSmall('Collapse All'),
                  ),
                ],
              ),
            ],
          ),
          const Gap(12),
          ...script.script.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ScriptSectionCard(
                section: entry.value,
                index: entry.key,
                isExpanded: controller.expandedSections.contains(entry.key),
                onToggle: () => controller.toggleSection(entry.key),
              ),
            );
          }),
          const Gap(24),

          // CTA section (if exists)
          if (script.ctaScript.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.info.withValues(alpha: 0.1),
                borderRadius: AppTheme.borderRadiusLG,
                border: Border.all(color: AppTheme.info.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📢', style: TextStyle(fontSize: 24)),
                      const Gap(12),
                      const H3('Call to Action'),
                    ],
                  ),
                  const Gap(12),
                  BodyText(script.ctaScript),
                ],
              ),
            ),
            const Gap(24),
          ],

          // Thumbnail options
          ThumbnailOptionsCard(thumbnails: script.thumbnailTitles),
          const Gap(24),

          // Description
          const H3('Video Description'),
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: AppTheme.borderRadiusMD,
              border: Border.all(color: AppTheme.border),
            ),
            child: BodyTextSmall(script.description),
          ),
          const Gap(24),

          // Hashtags
          HashtagTags(
            hashtags: script.hashtags,
            isExpanded: controller.expandedHashtags.value,
            onToggle: () => controller.expandedHashtags.value =
                !controller.expandedHashtags.value,
          ),
          const Gap(24),

          // Music mood
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: AppTheme.borderRadiusMD,
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Text('🎵', style: TextStyle(fontSize: 24)),
                const Gap(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BodyText(
                      'Recommended Music Mood',
                      fontWeight: FontWeight.w600,
                    ),
                    const Gap(4),
                    BodyTextSmall(
                      script.musicMood,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(24),

          // Retention estimate
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: AppTheme.borderRadiusMD,
              border: Border.all(
                color: AppTheme.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: AppTheme.success, size: 24),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const BodyText(
                            'Estimated Retention: ',
                            fontWeight: FontWeight.w600,
                          ),
                          BodyText(
                            '${script.retentionPercentage}%',
                            fontWeight: FontWeight.bold,
                            color: AppTheme.success,
                          ),
                        ],
                      ),
                      const Gap(4),
                      BodyTextSmall(
                        script.retentionReasoning,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(32),

          // Action buttons
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Copy Script',
                    onPressed: controller.copyScript,
                    icon: Icons.content_copy,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: SecondaryButton(
                    text: 'Generate New',
                    onPressed: controller.clearScript,
                    icon: Icons.refresh,
                  ),
                ),
                const Gap(16),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    text: 'Create Automated Video',
                    onPressed: () {
                      // TODO: Navigate to video generation
                      Get.snackbar(
                        'Coming Soon',
                        'Automated video generation will be available soon!',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: Icons.video_library,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                PrimaryButton(
                  text: 'Create Automated Video',
                  onPressed: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Automated video generation will be available soon!',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: Icons.video_library,
                  width: double.infinity,
                ),
                const Gap(12),
                SecondaryButton(
                  text: 'Copy Script',
                  onPressed: controller.copyScript,
                  icon: Icons.content_copy,
                  width: double.infinity,
                ),
                const Gap(12),
                SecondaryButton(
                  text: 'Generate New',
                  onPressed: controller.clearScript,
                  icon: Icons.refresh,
                  width: double.infinity,
                ),
              ],
            ),
        ],
      );
    });
  }
}
