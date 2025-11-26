import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';

/// Auto-Regeneration Indicator Widget
/// Shows progress during content generation with quality check
class AutoRegenerationIndicator extends StatelessWidget {
  final String status; // 'generating', 'regenerating', 'complete'
  final int currentAttempt;
  final int maxAttempts;
  final String? lastScore;
  final double? progress; // 0.0 - 1.0
  final VoidCallback? onViewContent;

  const AutoRegenerationIndicator({
    super.key,
    required this.status,
    this.currentAttempt = 1,
    this.maxAttempts = 2,
    this.lastScore,
    this.progress,
    this.onViewContent,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (status) {
      case 'regenerating':
        return _buildRegeneratingState();
      case 'complete':
        return _buildCompleteState();
      case 'generating':
      default:
        return _buildGeneratingState();
    }
  }

  /// Initial generation state
  Widget _buildGeneratingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.auto_fix_high, color: AppTheme.primary, size: 32),
        ),

        const Gap(16),

        const H2('Generating Your Content', textAlign: TextAlign.center),

        const Gap(16),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppTheme.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),

        const Gap(8),

        BodyTextSmall(
          progress != null ? '${(progress! * 100).toInt()}%' : 'Processing...',
          color: AppTheme.textSecondary,
        ),

        const Gap(16),

        const BodyText(
          'Analyzing quality...',
          textAlign: TextAlign.center,
          color: AppTheme.textSecondary,
        ),
      ],
    );
  }

  /// Regenerating state (low quality detected)
  Widget _buildRegeneratingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Warning icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warning.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.warning,
            size: 32,
          ),
        ),

        const Gap(16),

        const H2('Generating Your Content', textAlign: TextAlign.center),

        const Gap(16),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppTheme.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.warning),
          ),
        ),

        const Gap(8),

        BodyTextSmall(
          progress != null ? '${(progress! * 100).toInt()}%' : 'Processing...',
          color: AppTheme.textSecondary,
        ),

        const Gap(16),

        // Warning message
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.info, size: 16, color: AppTheme.warning),
                  const Gap(8),
                  Expanded(
                    child: BodyText(
                      lastScore != null
                          ? 'Quality below target (Score: $lastScore)'
                          : 'Quality below target',
                      color: AppTheme.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Gap(4),
              const BodyTextSmall(
                'Regenerating with premium model...',
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),

        const Gap(16),

        CaptionText(
          'Attempt $currentAttempt of $maxAttempts',
          color: AppTheme.textSecondary,
        ),
      ],
    );
  }

  /// Complete state
  Widget _buildCompleteState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle, color: AppTheme.success, size: 32),
        ),

        const Gap(16),

        const H2('Content Generated', textAlign: TextAlign.center),

        const Gap(12),

        if (lastScore != null)
          BodyText(
            'Quality Score: $lastScore',
            textAlign: TextAlign.center,
            color: AppTheme.success,
            fontWeight: FontWeight.w600,
          ),

        const Gap(24),

        if (onViewContent != null)
          PrimaryButton(
            text: 'View Content',
            onPressed: onViewContent,
            width: double.infinity,
          ),
      ],
    );
  }
}
