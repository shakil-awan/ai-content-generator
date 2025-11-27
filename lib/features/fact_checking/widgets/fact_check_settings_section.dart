import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import 'quota_display.dart';

/// Fact-Check Settings Section Widget
/// Display in Settings page to control fact-checking preferences
class FactCheckSettingsSection extends StatelessWidget {
  final bool isEnabled;
  final int confidenceThreshold; // 50-95%
  final int quotaUsed;
  final int quotaLimit;
  final String userTier; // 'free', 'hobby', 'pro'
  final Function(bool) onToggle;
  final Function(double) onThresholdChange;
  final VoidCallback? onUpgrade;

  const FactCheckSettingsSection({
    super.key,
    required this.isEnabled,
    required this.confidenceThreshold,
    required this.quotaUsed,
    required this.quotaLimit,
    required this.userTier,
    required this.onToggle,
    required this.onThresholdChange,
    this.onUpgrade,
  });

  /// Check if feature is available for user's tier
  bool get isFeatureAvailable => userTier != 'free';

  /// Check if user has quota remaining (only for hobby tier)
  bool get hasQuotaRemaining => userTier != 'hobby' || quotaUsed < quotaLimit;

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
          // Toggle with label and badge
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        H3('Auto Fact-Check Content'),
                        const Gap(8),
                        // PRO FEATURE badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusFull,
                            ),
                          ),
                          child: CaptionText(
                            'PRO FEATURE',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    BodyTextSmall(
                      'Automatically verify factual claims in generated content',
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
              const Gap(16),
              // Toggle switch
              Switch(
                value: isEnabled && isFeatureAvailable,
                onChanged: isFeatureAvailable
                    ? (value) {
                        if (value && !hasQuotaRemaining) {
                          // Show quota exceeded message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: BodyText(
                                'Quota limit reached. Upgrade to Pro for unlimited fact-checking.',
                                color: Colors.white,
                              ),
                              backgroundColor: AppTheme.error,
                            ),
                          );
                        } else {
                          onToggle(value);
                        }
                      }
                    : null,
                activeThumbColor: AppTheme.primary,
              ),
            ],
          ),

          // Disabled state message for free tier
          if (!isFeatureAvailable) ...[
            const Gap(12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.1),
                border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, color: AppTheme.warning, size: 18),
                  const Gap(8),
                  Expanded(
                    child: BodyTextSmall(
                      'Upgrade to Hobby tier or higher to enable fact-checking',
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (onUpgrade != null) ...[
                    const Gap(8),
                    TextButton(
                      onPressed: onUpgrade,
                      child: BodyTextSmall('Upgrade', color: AppTheme.primary),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Confidence threshold slider (only visible when toggle is ON)
          if (isEnabled && isFeatureAvailable) ...[
            const Gap(24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    H3('Confidence Threshold'),
                    BodyText(
                      '$confidenceThreshold%',
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                const Gap(4),
                BodyTextSmall(
                  'Only show claims with $confidenceThreshold% or higher confidence',
                  color: AppTheme.textSecondary,
                ),
                const Gap(12),
                // Slider
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppTheme.primary,
                    inactiveTrackColor: AppTheme.neutral200,
                    thumbColor: AppTheme.primary,
                    overlayColor: AppTheme.primary.withValues(alpha: 0.2),
                    valueIndicatorColor: AppTheme.primary,
                  ),
                  child: Slider(
                    value: confidenceThreshold.toDouble(),
                    min: 50,
                    max: 95,
                    divisions: 9, // 5% increments
                    label: '$confidenceThreshold%',
                    onChanged: (value) {
                      onThresholdChange(value);
                    },
                  ),
                ),
                // Min/max labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [CaptionText('50%'), CaptionText('95%')],
                ),
              ],
            ),
          ],

          // Quota display (only for Hobby tier)
          if (isFeatureAvailable && userTier == 'hobby') ...[
            const Gap(24),
            QuotaDisplay(
              used: quotaUsed,
              limit: quotaLimit,
              onUpgrade: onUpgrade,
            ),
          ],
        ],
      ),
    );
  }
}
