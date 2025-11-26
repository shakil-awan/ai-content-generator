import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../models/quality_score.dart';
import '../utils/quality_helpers.dart';
import 'quality_metric_row.dart';

/// Quality Details Panel Widget
/// Expandable panel showing quality score breakdown
class QualityDetailsPanel extends StatefulWidget {
  final QualityScore qualityScore;
  final int? regenerationCount;
  final bool initiallyExpanded;

  const QualityDetailsPanel({
    super.key,
    required this.qualityScore,
    this.regenerationCount,
    this.initiallyExpanded = false,
  });

  @override
  State<QualityDetailsPanel> createState() => _QualityDetailsPanelState();
}

class _QualityDetailsPanelState extends State<QualityDetailsPanel> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.qualityScore;
    final grade = score.grade;
    final percentage = score.percentage;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        border: Border.all(color: AppTheme.border),
        borderRadius: AppTheme.borderRadiusLG,
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.verified, color: score.gradeColor, size: 20),
                  const Gap(8),
                  Expanded(child: H3('Quality Score: $grade ($percentage%)')),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const H3('Quality Breakdown'),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: score.gradeBackgroundColor,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMD,
                          ),
                          border: Border.all(color: score.gradeColor),
                        ),
                        child: Row(
                          children: [
                            Text(
                              grade,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: score.gradeColor,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              '($percentage%)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: score.gradeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Gap(24),

                  // Metrics
                  QualityMetricRow(
                    label: 'Readability',
                    score: score.readability,
                    helperText: QualityHelpers.getReadabilityHelperText(
                      score.readability,
                    ),
                  ),

                  const Gap(16),

                  QualityMetricRow(
                    label: 'Completeness',
                    score: score.completeness,
                    helperText: QualityHelpers.getCompletenessHelperText(
                      score.completeness,
                    ),
                  ),

                  const Gap(16),

                  QualityMetricRow(
                    label: 'SEO Optimization',
                    score: score.seo,
                    helperText: QualityHelpers.getSeoHelperText(score.seo),
                  ),

                  const Gap(16),

                  QualityMetricRow(
                    label: 'Grammar & Style',
                    score: score.grammar,
                    helperText: QualityHelpers.getGrammarHelperText(
                      score.grammar,
                    ),
                  ),

                  // Details section
                  if (score.details != null ||
                      widget.regenerationCount != null) ...[
                    const Gap(24),
                    const Divider(),
                    const Gap(16),
                    const BodyText('Details:', fontWeight: FontWeight.w600),
                    const Gap(8),
                    _buildDetailsList(),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsList() {
    final details = widget.qualityScore.details;
    final regenCount = widget.regenerationCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (details != null) ...[
          _buildDetailItem('Word count: ${details.wordCount}'),
          if (details.fleschKincaidScore != null)
            _buildDetailItem(
              'Flesch-Kincaid score: ${details.fleschKincaidScore!.toStringAsFixed(1)}',
            ),
          if (details.keywordDensity != null)
            _buildDetailItem(
              'Keyword density: ${(details.keywordDensity! * 100).toStringAsFixed(1)}%',
            ),
          if (details.headingCount != null)
            _buildDetailItem('Headings: ${details.headingCount}'),
        ],
        if (regenCount != null && regenCount > 0)
          _buildDetailItem(
            'Regenerations: $regenCount (auto-improved quality)',
          ),
      ],
    );
  }

  Widget _buildDetailItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const Gap(8),
          Expanded(child: CaptionText(text, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
