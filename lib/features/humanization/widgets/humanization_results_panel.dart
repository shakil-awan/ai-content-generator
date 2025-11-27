import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../models/humanization_result.dart';
import 'ai_detection_score_display.dart';
import 'before_after_comparison.dart';

/// Humanization Results Panel Controller
class HumanizationResultsPanelController extends GetxController {
  final showComparison = false.obs;
  final copied = false.obs;

  void toggleComparison() => showComparison.value = !showComparison.value;

  void setCopied(bool value) => copied.value = value;
}

/// Humanization Results Panel Widget
/// Complete results display combining score, comparison, and actions
class HumanizationResultsPanel extends StatelessWidget {
  final HumanizationResult result;
  final VoidCallback? onCopy;
  final VoidCallback? onTryAgain;
  final VoidCallback? onKeepOriginal;
  final VoidCallback? onUseHumanized;

  const HumanizationResultsPanel({
    super.key,
    required this.result,
    this.onCopy,
    this.onTryAgain,
    this.onKeepOriginal,
    this.onUseHumanized,
  });

  void _handleCopy(HumanizationResultsPanelController controller) {
    Clipboard.setData(ClipboardData(text: result.humanizedContent));
    controller.setCopied(true);
    Future.delayed(const Duration(seconds: 2), () {
      controller.setCopied(false);
    });
    onCopy?.call();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HumanizationResultsPanelController());

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        border: Border.all(color: AppTheme.border),
        borderRadius: AppTheme.borderRadiusLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success banner
          Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.success, size: 24),
              const Gap(12),
              H2('Content Humanized Successfully', color: AppTheme.success),
            ],
          ),

          const Gap(24),

          // AI Detection Score Display
          AIDetectionScoreDisplay(
            beforeScore: result.beforeScore,
            afterScore: result.afterScore,
            improvement: result.improvement,
            improvementPercentage: result.improvementPercentage,
          ),

          const Gap(24),

          // Before/After Comparison
          Obx(
            () => BeforeAfterComparison(
              originalContent: result.originalContent,
              humanizedContent: result.humanizedContent,
              beforeScore: result.beforeScore,
              afterScore: result.afterScore,
              isExpanded: controller.showComparison.value,
              onToggle: controller.toggleComparison,
              onUseOriginal: onKeepOriginal,
              onUseHumanized: onUseHumanized,
            ),
          ),

          const Gap(24),

          // Action buttons
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Obx(
                () => PrimaryButton(
                  text: controller.copied.value ? 'Copied!' : 'Copy Humanized',
                  onPressed: controller.copied.value
                      ? null
                      : () => _handleCopy(controller),
                  icon: controller.copied.value ? Icons.check : Icons.copy,
                ),
              ),
              if (onTryAgain != null)
                SecondaryButton(
                  text: 'Try Again',
                  onPressed: onTryAgain,
                  icon: Icons.refresh,
                ),
              if (onKeepOriginal != null)
                CustomTextButton(
                  text: 'Keep Original',
                  onPressed: onKeepOriginal,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
