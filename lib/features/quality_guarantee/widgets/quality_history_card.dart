import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../models/quality_score.dart';
import 'quality_score_badge.dart';

/// Quality History Card Widget
/// Display quality scores in generation history list
class QualityHistoryCard extends StatelessWidget {
  final String title;
  final QualityScore qualityScore;
  final DateTime createdAt;
  final int wordCount;
  final int? regenerationCount;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const QualityHistoryCard({
    super.key,
    required this.title,
    required this.qualityScore,
    required this.createdAt,
    required this.wordCount,
    this.regenerationCount,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        border: Border.all(color: AppTheme.border),
        borderRadius: AppTheme.borderRadiusLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and badge row
          Row(
            children: [
              Expanded(child: H3(title, maxLines: 1)),
              const Gap(12),
              // Mini quality badge
              QualityScoreBadge(
                qualityScore: qualityScore,
                size: 40,
                onTap: onView,
              ),
            ],
          ),

          const Gap(8),

          // Metadata row
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              CaptionText(
                _formatDate(createdAt),
                color: AppTheme.textSecondary,
              ),
              const CaptionText('•', color: AppTheme.textSecondary),
              CaptionText('$wordCount words', color: AppTheme.textSecondary),
              if (regenerationCount != null && regenerationCount! > 0) ...[
                const CaptionText('•', color: AppTheme.textSecondary),
                CaptionText(
                  '$regenerationCount ${regenerationCount == 1 ? 'regeneration' : 'regenerations'}',
                  color: AppTheme.textSecondary,
                ),
              ],
            ],
          ),

          const Gap(12),

          // Action buttons
          Row(
            children: [
              if (onView != null)
                TextButton(
                  onPressed: onView,
                  child: const BodyTextSmall('View'),
                ),
              if (onEdit != null) ...[
                const Gap(4),
                TextButton(
                  onPressed: onEdit,
                  child: const BodyTextSmall('Edit'),
                ),
              ],
              if (onDelete != null) ...[
                const Gap(4),
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                  child: const BodyTextSmall('Delete'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
