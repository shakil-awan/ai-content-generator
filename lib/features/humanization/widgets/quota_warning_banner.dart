import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Quota Warning Banner Widget
/// Warn when approaching monthly limit
class QuotaWarningBanner extends StatelessWidget {
  final int used;
  final int limit;
  final VoidCallback? onUpgrade;

  const QuotaWarningBanner({
    super.key,
    required this.used,
    required this.limit,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Yellow-50
        border: Border.all(color: const Color(0xFFD97706)), // Yellow-600
        borderRadius: AppTheme.borderRadiusMD,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFD97706), // Yellow-600
            size: 20,
          ),
          const Gap(12),
          Expanded(
            child: BodyTextSmall(
              '$used/$limit humanizations used this month',
              color: const Color(0xFF92400E), // Yellow-900
            ),
          ),
          if (onUpgrade != null) ...[
            const Gap(12),
            InkWell(
              onTap: onUpgrade,
              child: Row(
                children: [
                  BodyTextSmall(
                    'Upgrade to Pro for unlimited',
                    color: AppTheme.primary,
                  ),
                  const Gap(4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
