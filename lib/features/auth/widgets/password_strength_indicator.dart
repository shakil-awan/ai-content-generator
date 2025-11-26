import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Password strength indicator widget
///
/// Shows visual bar and text based on password strength (0.0 to 1.0)
class PasswordStrengthIndicator extends StatelessWidget {
  final double strength;

  const PasswordStrengthIndicator({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    final strengthText = _getStrengthText(strength);
    final strengthColor = _getStrengthColor(strength);

    if (strength == 0.0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bar
        Row(
          children: [
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: strength,
                  child: Container(
                    decoration: BoxDecoration(
                      color: strengthColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Gap(AppTheme.spacing8),

        // Strength text
        CaptionText('Password strength: $strengthText', color: strengthColor),
      ],
    );
  }

  String _getStrengthText(double strength) {
    if (strength <= 0.25) return 'Weak';
    if (strength <= 0.5) return 'Fair';
    if (strength <= 0.75) return 'Good';
    return 'Strong';
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.25) return AppTheme.error;
    if (strength <= 0.5) return Colors.orange;
    if (strength <= 0.75) return Colors.yellow.shade700;
    return AppTheme.success;
  }
}
