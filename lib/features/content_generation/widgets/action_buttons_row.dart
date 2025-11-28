import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/custom_buttons.dart';
import '../controllers/content_generation_controller.dart';
import 'export_menu.dart';

/// Action Buttons Row Widget
/// Displays Copy, Regenerate, Save, and Export buttons
class ActionButtonsRow extends GetView<ContentGenerationController> {
  const ActionButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            child: SecondaryButton(
              text: 'Copy',
              icon: Icons.copy,
              onPressed: () => controller.copyContent(),
            ),
          ),
          const Gap(12),
          Expanded(
            child: SecondaryButton(
              text: 'Regenerate',
              icon: Icons.refresh,
              onPressed: () => controller.regenerateContent(context),
            ),
          ),
          const Gap(12),
          Expanded(child: ExportMenu()),
        ],
      );
    }

    // Mobile: Stack buttons vertically
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SecondaryButton(
          text: 'Copy',
          icon: Icons.copy,
          onPressed: () => controller.copyContent(),
          width: double.infinity,
        ),
        const Gap(12),
        SecondaryButton(
          text: 'Regenerate',
          icon: Icons.refresh,
          onPressed: () => controller.regenerateContent(context),
          width: double.infinity,
        ),
        const Gap(12),
        ExportMenu(width: double.infinity),
      ],
    );
  }
}
