import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// AI Detection Score Display Widget
/// Show before/after AI detection scores with improvement
class AIDetectionScoreDisplay extends StatelessWidget {
  final double beforeScore;
  final double afterScore;
  final double improvement;
  final double improvementPercentage;

  const AIDetectionScoreDisplay({
    super.key,
    required this.beforeScore,
    required this.afterScore,
    required this.improvement,
    required this.improvementPercentage,
  });

  Color _getScoreColor(double score) {
    if (score >= 70) return const Color(0xFFDC2626); // Red
    if (score >= 40) return const Color(0xFFD97706); // Yellow
    return const Color(0xFF059669); // Green
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        border: Border.all(color: AppTheme.border),
        borderRadius: AppTheme.borderRadiusLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const H3('AI Detection Score'),
          const Gap(16),

          if (isDesktop)
            // Desktop: Horizontal layout
            Row(
              children: [
                Expanded(child: _buildScoreBar('Before', beforeScore)),
                const Gap(16),
                Icon(
                  Icons.arrow_forward,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                const Gap(16),
                Expanded(child: _buildScoreBar('After', afterScore)),
              ],
            )
          else
            // Mobile: Vertical layout
            Column(
              children: [
                _buildScoreBar('Before', beforeScore),
                const Gap(12),
                Icon(
                  Icons.arrow_downward,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                const Gap(12),
                _buildScoreBar('After', afterScore),
              ],
            ),

          const Gap(16),

          // Improvement metric
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_down, color: AppTheme.success, size: 20),
              const Gap(8),
              BodyText(
                '${improvement.toInt()} points (${improvementPercentage.toStringAsFixed(1)}% reduction)',
                color: AppTheme.success,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, double score) {
    final scoreColor = _getScoreColor(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BodyText(label),
            BodyText(
              '${score.toInt()}%',
              color: scoreColor,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        const Gap(8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 12,
            backgroundColor: AppTheme.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
          ),
        ),
      ],
    );
  }
}
