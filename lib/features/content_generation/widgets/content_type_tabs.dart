import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/content_generation_controller.dart';
import '../models/content_type.dart';

/// Content Type Tabs Widget
/// Shows horizontal tabs on desktop, dropdown on mobile
class ContentTypeTabs extends GetView<ContentGenerationController> {
  const ContentTypeTabs({super.key});

  @override
  Widget build(BuildContext context) {
    // Use tabs on larger screens, dropdown on mobile
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return isDesktop ? _buildTabs(context) : _buildDropdown(context);
  }

  Widget _buildTabs(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ContentType.values.map((type) {
            final isSelected = controller.selectedContentType.value == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => controller.selectContentType(type),
                borderRadius: AppTheme.borderRadiusMD,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.border,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: AppTheme.borderRadiusMD,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        type.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const Gap(8),
                      BodyText(
                        type.displayName,
                        color: isSelected
                            ? AppTheme.textOnPrimary
                            : AppTheme.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border),
          borderRadius: AppTheme.borderRadiusMD,
        ),
        child: DropdownButton<ContentType>(
          value: controller.selectedContentType.value,
          isExpanded: true,
          underline: const SizedBox(),
          items: ContentType.values.map((type) {
            return DropdownMenuItem<ContentType>(
              value: type,
              child: Row(
                children: [
                  Text(
                    type.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const Gap(12),
                  BodyText(type.displayName),
                ],
              ),
            );
          }).toList(),
          onChanged: (type) {
            if (type != null) controller.selectContentType(type);
          },
        ),
      ),
    );
  }
}
