import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Quota Display Widget
/// Shows fact-check usage for Hobby tier users
class QuotaDisplay extends StatelessWidget {
  final int used;
  final int limit;
  final VoidCallback? onUpgrade;

  const QuotaDisplay({
    super.key,
    required this.used,
    required this.limit,
    this.onUpgrade,
  });

  /// Get quota percentage (0.0 - 1.0)
  double get percentage => limit > 0 ? used / limit : 0.0;

  /// Get quota color based on usage
  Color get quotaColor {
    if (percentage <= 0.50) return const Color(0xFF059669); // Green-600
    if (percentage <= 0.80) return const Color(0xFFD97706); // Yellow-600
    return const Color(0xFFDC2626); // Red-600
  }

  /// Get background color based on usage
  Color get backgroundColor {
    if (percentage <= 0.50) return const Color(0xFFD1FAE5); // Green-200
    if (percentage <= 0.80) return const Color(0xFFFEF3C7); // Yellow-200
    return const Color(0xFFFECACA); // Red-200
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          H3('Fact-Check Quota'),

          const Gap(12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(quotaColor),
              minHeight: 8,
            ),
          ),

          const Gap(8),

          // Usage text
          BodyText(
            '$used/$limit used this month',
            color: AppTheme.textSecondary,
          ),

          // Upgrade link
          if (onUpgrade != null) ...[
            const Gap(12),
            InkWell(
              onTap: onUpgrade,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BodyText(
                    'Upgrade to Pro for unlimited',
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  const Gap(4),
                  Icon(Icons.arrow_forward, size: 16, color: AppTheme.primary),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
