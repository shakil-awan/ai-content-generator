import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/video_script_controller.dart';

/// Duration Selector Widget
/// Allows users to select video duration with presets or custom value
class DurationSelector extends StatelessWidget {
  const DurationSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoScriptController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BodyText('Duration', fontWeight: FontWeight.w600),
        const Gap(8),
        Obx(
          () => Column(
            children: [
              // Duration presets
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.durationPresets.map((preset) {
                  final isSelected =
                      controller.duration.value == preset['seconds'];
                  return GestureDetector(
                    onTap: () =>
                        controller.duration.value = preset['seconds'] as int,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.bgSecondary,
                        borderRadius: AppTheme.borderRadiusMD,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.border,
                        ),
                      ),
                      child: BodyTextSmall(
                        preset['label'] as String,
                        color: isSelected
                            ? AppTheme.textOnPrimary
                            : AppTheme.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Gap(8),
              // Current duration display
              BodyTextSmall(
                'Selected: ${controller.durationDisplay}',
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
