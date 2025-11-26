import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/video_script_controller.dart';

/// Platform Selector Widget
/// Dropdown for selecting video platform (YouTube, TikTok, Instagram, LinkedIn)
class PlatformSelector extends StatelessWidget {
  const PlatformSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoScriptController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BodyText('Platform', fontWeight: FontWeight.w600),
        const Gap(8),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.bgPrimary,
              border: Border.all(color: AppTheme.border),
              borderRadius: AppTheme.borderRadiusMD,
            ),
            child: DropdownButton<String>(
              value: controller.platform.value,
              isExpanded: true,
              underline: const SizedBox(),
              items: controller.platforms.map((platform) {
                return DropdownMenuItem(
                  value: platform['id'],
                  child: Row(
                    children: [
                      Text(
                        platform['emoji']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const Gap(12),
                      BodyText(platform['name']!),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.platform.value = value;
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
