import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/image_generation_controller.dart';

/// Style Selector Widget
/// Visual style picker with icons
class StyleSelector extends StatelessWidget {
  const StyleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageGenerationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BodyText('Style', fontWeight: FontWeight.w600),
        const Gap(12),
        Obx(
          () => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: controller.styles.map((style) {
              final isSelected = controller.style.value == style['id'];
              return GestureDetector(
                onTap: () => controller.style.value = style['id']!,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : AppTheme.bgSecondary,
                    borderRadius: AppTheme.borderRadiusMD,
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        style['icon']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const Gap(8),
                      BodyText(
                        style['name']!,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Gap(8),
        const BodyTextSmall(
          '💡 Tip: Try different styles to find the perfect look',
          color: AppTheme.textSecondary,
        ),
      ],
    );
  }
}
