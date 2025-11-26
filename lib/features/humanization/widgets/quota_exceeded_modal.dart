import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';

/// Quota Exceeded Modal Widget
/// Block humanization when limit reached
class QuotaExceededModal extends StatelessWidget {
  final int used;
  final int limit;
  final VoidCallback? onViewPricing;

  const QuotaExceededModal({
    super.key,
    required this.used,
    required this.limit,
    this.onViewPricing,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusLG),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title bar
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.warning,
                  size: 28,
                ),
                const Gap(12),
                const Expanded(
                  child: H2('Monthly Limit Reached'),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const Gap(24),

            // Body text
            BodyText(
              'You\'ve used all $used humanizations this month.',
            ),

            const Gap(24),

            // Benefits list
            const BodyTextLarge('Upgrade to Pro for:'),
            const Gap(12),

            _buildBenefit('Unlimited humanizations'),
            const Gap(8),
            _buildBenefit('Priority support'),
            const Gap(8),
            _buildBenefit('Advanced features'),

            const Gap(24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                ),
                const Gap(12),
                PrimaryButton(
                  text: 'View Pricing',
                  onPressed: () {
                    Navigator.pop(context);
                    onViewPricing?.call();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: AppTheme.success,
          size: 20,
        ),
        const Gap(12),
        BodyText(text),
      ],
    );
  }
}
