import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../models/humanization_result.dart';
import 'ai_detection_score_display.dart';
import 'before_after_comparison.dart';

/// Humanization Results Panel Widget
/// Complete results display combining score, comparison, and actions
class HumanizationResultsPanel extends StatefulWidget {
  final HumanizationResult result;
  final VoidCallback? onCopy;
  final VoidCallback? onTryAgain;
  final VoidCallback? onKeepOriginal;

  const HumanizationResultsPanel({
    super.key,
    required this.result,
    this.onCopy,
    this.onTryAgain,
    this.onKeepOriginal,
  });

  @override
  State<HumanizationResultsPanel> createState() =>
      _HumanizationResultsPanelState();
}

class _HumanizationResultsPanelState extends State<HumanizationResultsPanel> {
  bool _showComparison = false;
  bool _copied = false;

  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: widget.result.humanizedContent));
    setState(() {
      _copied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
    widget.onCopy?.call();
  }

  @override
  Widget build(BuildContext context) {
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
            beforeScore: widget.result.beforeScore,
            afterScore: widget.result.afterScore,
            improvement: widget.result.improvement,
            improvementPercentage: widget.result.improvementPercentage,
          ),

          const Gap(24),

          // Before/After Comparison
          BeforeAfterComparison(
            originalContent: widget.result.originalContent,
            humanizedContent: widget.result.humanizedContent,
            beforeScore: widget.result.beforeScore,
            afterScore: widget.result.afterScore,
            isExpanded: _showComparison,
            onToggle: () {
              setState(() {
                _showComparison = !_showComparison;
              });
            },
            onUseOriginal: widget.onKeepOriginal,
            onUseHumanized: _handleCopy,
          ),

          const Gap(24),

          // Action buttons
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              PrimaryButton(
                text: _copied ? 'Copied!' : 'Copy Humanized',
                onPressed: _copied ? null : _handleCopy,
                icon: _copied ? Icons.check : Icons.copy,
              ),
              if (widget.onTryAgain != null)
                SecondaryButton(
                  text: 'Try Again',
                  onPressed: widget.onTryAgain,
                  icon: Icons.refresh,
                ),
              if (widget.onKeepOriginal != null)
                CustomTextButton(
                  text: 'Keep Original',
                  onPressed: widget.onKeepOriginal,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
