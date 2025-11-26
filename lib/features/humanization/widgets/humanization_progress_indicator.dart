import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Humanization Progress Indicator Widget
/// Show progress during AI detection and humanization
class HumanizationProgressIndicator extends StatelessWidget {
  final int currentStep; // 0-2
  final double progress; // 0-1

  const HumanizationProgressIndicator({
    super.key,
    required this.currentStep,
    this.progress = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusLG),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with spinner
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppTheme.primary,
                    strokeWidth: 2.5,
                  ),
                ),
                const Gap(12),
                const H2('Humanizing Your Content'),
              ],
            ),

            const Gap(24),

            // Step indicators
            _buildStep(
              0,
              'Detecting AI patterns...',
              currentStep >= 0,
              currentStep > 0,
            ),
            const Gap(12),

            _buildStep(
              1,
              'Rewriting content...',
              currentStep >= 1,
              currentStep > 1,
            ),
            const Gap(12),

            _buildStep(
              2,
              'Analyzing humanized version...',
              currentStep >= 2,
              currentStep > 2,
            ),

            const Gap(24),

            // Progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _calculateProgress(),
                      minHeight: 8,
                      backgroundColor: AppTheme.neutral200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                BodyText('${(_calculateProgress() * 100).toInt()}%'),
              ],
            ),

            const Gap(16),

            // Time estimate
            CaptionText(
              'This may take 8-15 seconds',
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int step, String label, bool isActive, bool isComplete) {
    return Row(
      children: [
        if (isComplete)
          Icon(Icons.check_circle, color: AppTheme.success, size: 20)
        else if (isActive)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 2,
            ),
          )
        else
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.neutral200),
            ),
          ),
        const Gap(12),
        Expanded(
          child: BodyText(
            label,
            color: isActive || isComplete
                ? AppTheme.textPrimary
                : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  double _calculateProgress() {
    switch (currentStep) {
      case 0:
        return 0.2;
      case 1:
        return 0.5;
      case 2:
        return 0.8;
      default:
        return 0.0;
    }
  }
}
