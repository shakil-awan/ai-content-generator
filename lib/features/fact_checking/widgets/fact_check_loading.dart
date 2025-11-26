import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Fact-Check Loading Indicator Widget
/// Shows progress during fact-checking process
class FactCheckLoadingIndicator extends StatelessWidget {
  final int currentClaim;
  final int totalClaims;
  final double? progress; // 0.0 - 1.0, if not provided calculates from claims

  const FactCheckLoadingIndicator({
    super.key,
    required this.currentClaim,
    required this.totalClaims,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final calculatedProgress =
        progress ?? (totalClaims > 0 ? currentClaim / totalClaims : 0.0);

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
          // Title with icon
          Row(
            children: [
              Icon(Icons.hourglass_empty, color: AppTheme.primary, size: 20),
              const Gap(8),
              H3('Verifying facts...'),
            ],
          ),

          const Gap(12),

          // Progress text
          if (totalClaims > 0)
            BodyTextSmall(
              'Checking claim $currentClaim of $totalClaims',
              color: AppTheme.textSecondary,
            )
          else
            BodyTextSmall(
              'Extracting claims from content...',
              color: AppTheme.textSecondary,
            ),

          const Gap(12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            child: LinearProgressIndicator(
              value: calculatedProgress,
              backgroundColor: AppTheme.neutral200,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              minHeight: 8,
            ),
          ),

          const Gap(8),

          // Percentage
          BodyTextSmall(
            '${(calculatedProgress * 100).toInt()}%',
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}
