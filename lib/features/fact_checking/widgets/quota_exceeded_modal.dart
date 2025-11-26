import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';

/// Quota Exceeded Modal Widget
/// Shows when user reaches monthly quota limit
class QuotaExceededModal extends StatelessWidget {
  final VoidCallback onUpgrade;
  final VoidCallback onContinue;

  const QuotaExceededModal({
    super.key,
    required this.onUpgrade,
    required this.onContinue,
  });

  /// Show the modal
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onUpgrade,
    required VoidCallback onContinue,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          QuotaExceededModal(onUpgrade: onUpgrade, onContinue: onContinue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.warning,
                size: 40,
              ),
            ),

            const Gap(16),

            // Title
            H2('Quota Limit Reached', textAlign: TextAlign.center),

            const Gap(16),

            // Description
            BodyText(
              "You've used all 10 fact-checks this month. Upgrade to Pro for unlimited fact-checking.",
              textAlign: TextAlign.center,
              color: AppTheme.textSecondary,
            ),

            const Gap(24),

            // Buttons
            Column(
              children: [
                // Upgrade button
                PrimaryButton(
                  text: 'Upgrade to Pro',
                  onPressed: () {
                    Navigator.of(context).pop();
                    onUpgrade();
                  },
                  width: double.infinity,
                ),

                const Gap(12),

                // Continue button
                SecondaryButton(
                  text: 'Continue Without',
                  onPressed: () {
                    Navigator.of(context).pop();
                    onContinue();
                  },
                  width: double.infinity,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
