import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/video_player/video_player_widgets.dart';
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
                        'Duration: ${controller.durationDisplay}',
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

          // Recommended Music
          if (script.recommendedMusic.isNotEmpty) ...[
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
                  Row(
                    children: [
                      const Text('🎵', style: TextStyle(fontSize: 24)),
                      const Gap(12),
                      const BodyText(
                        'Recommended Music',
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const Gap(12),
                  ...script.recommendedMusic.map(
                    (music) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Gap(8),
                          Expanded(child: BodyTextSmall(music)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(24),
          ],

          // Retention Hooks
          if (script.retentionHooks.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                borderRadius: AppTheme.borderRadiusMD,
                border: Border.all(
                  color: AppTheme.success.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: AppTheme.success,
                        size: 24,
                      ),
                      const Gap(12),
                      const BodyText(
                        'Retention Hooks',
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const Gap(12),
                  ...script.retentionHooks.map(
                    (hook) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Gap(8),
                          Expanded(child: BodyTextSmall(hook)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(32),
          ],

          // Video generation section
          Obx(() {
            // Show error if video generation failed
            if (controller.videoError.value.isNotEmpty &&
                !controller.isGeneratingVideo.value) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: AppTheme.borderRadiusMD,
                      border: Border.all(
                        color: AppTheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppTheme.error,
                          size: 24,
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const BodyText(
                                'Video Generation Failed',
                                fontWeight: FontWeight.w600,
                              ),
                              const Gap(4),
                              BodyTextSmall(
                                controller.videoError.value,
                                color: AppTheme.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),
                ],
              );
            }

            if (controller.isGeneratingVideo.value) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.info.withValues(alpha: 0.1),
                  borderRadius: AppTheme.borderRadiusLG,
                  border: Border.all(
                    color: AppTheme.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircularProgressIndicator(),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const H3('Generating Video 🎬'),
                              const Gap(4),
                              BodyTextSmall(
                                controller.videoStatus.value,
                                color: AppTheme.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                    LinearProgressIndicator(
                      value: controller.videoProgress.value / 100,
                      backgroundColor: AppTheme.border,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.info),
                    ),
                    const Gap(8),
                    BodyTextSmall(
                      '${controller.videoProgress.value}% complete',
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              );
            }

            if (controller.hasVideo) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success banner
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
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.success,
                          size: 24,
                        ),
                        const Gap(12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BodyText(
                                'Video Ready! 🎉',
                                fontWeight: FontWeight.w600,
                              ),
                              Gap(4),
                              BodyTextSmall(
                                'Your video has been generated successfully',
                                color: AppTheme.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),

                  // Video player
                  CustomVideoPlayer(
                    videoUrl: controller.generatedVideoUrl.value,
                    thumbnailUrl: controller
                        .generatedScript
                        .value
                        ?.thumbnailTitles
                        .firstOrNull,
                    title: controller.topic.value,
                    description: controller.generatedScript.value?.description,
                    autoPlay: false,
                    showControls: true,
                    onDownload: () => controller.downloadVideo(),
                    onShare: () => controller.shareVideo(),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          }),

          if (controller.hasVideo) const Gap(24),

          // Action buttons
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    child: SecondaryButton(
                      text: 'Copy Script',
                      onPressed: controller.copyScript,
                      icon: Icons.content_copy,
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: FittedBox(
                    child: SecondaryButton(
                      text: 'Re Generate',
                      onPressed: controller.clearScript,
                      icon: Icons.refresh,
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
                  flex: 2,
                  child: Obx(
                    () => FittedBox(
                      child: PrimaryButton(
                        text: controller.hasVideo
                            ? 'Generate Another Video'
                            : 'Generate Video 🎬',
                        onPressed: controller.isGeneratingVideo.value
                            ? null
                            : controller.generateVideoFromScript,
                        icon: Icons.video_library,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                Obx(
                  () => PrimaryButton(
                    text: controller.hasVideo
                        ? 'Generate Another Video'
                        : 'Generate Video 🎬',
                    onPressed: controller.isGeneratingVideo.value
                        ? null
                        : controller.generateVideoFromScript,
                    icon: Icons.video_library,
                    width: double.infinity,
                  ),
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
