import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/image_generation_controller.dart';

/// Aspect Ratio Selector Widget
/// Select image dimensions with use case descriptions
class AspectRatioSelector extends StatelessWidget {
  const AspectRatioSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageGenerationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BodyText('Aspect Ratio', fontWeight: FontWeight.w600),
        const Gap(12),
        Obx(
          () => Column(
            children: controller.aspectRatios.map((ratio) {
              final isSelected = controller.aspectRatio.value == ratio['id'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => controller.aspectRatio.value = ratio['id']!,
                  borderRadius: AppTheme.borderRadiusMD,
                  child: Container(
                    padding: const EdgeInsets.all(12),
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
                      children: [
                        // Icon representing aspect ratio
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.border,
                            borderRadius: AppTheme.borderRadiusMD,
                          ),
                          child: Center(
                            child: _getRatioIcon(ratio['id']!, isSelected),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BodyText(
                                '${ratio['id']} ${ratio['name']}',
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.textPrimary,
                              ),
                              const Gap(2),
                              BodyTextSmall(
                                ratio['size']!,
                                color: AppTheme.textSecondary,
                              ),
                              const Gap(2),
                              BodyTextSmall(
                                'Best for: ${ratio['use']}',
                                color: AppTheme.textSecondary,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.primary,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _getRatioIcon(String ratio, bool isSelected) {
    final color = isSelected ? AppTheme.textOnPrimary : AppTheme.textSecondary;

    switch (ratio) {
      case '1:1':
        return Icon(Icons.crop_square, color: color, size: 20);
      case '16:9':
        return Icon(Icons.crop_16_9, color: color, size: 20);
      case '9:16':
        return Icon(Icons.crop_portrait, color: color, size: 20);
      case '4:3':
        return Icon(Icons.crop_landscape, color: color, size: 20);
      case '3:4':
        return Icon(Icons.crop_5_4, color: color, size: 20);
      default:
        return Icon(Icons.crop, color: color, size: 20);
    }
  }
}
