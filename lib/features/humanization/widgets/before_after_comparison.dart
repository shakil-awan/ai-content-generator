import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';

/// Before/After Comparison Widget
/// Side-by-side view of original vs humanized content
class BeforeAfterComparison extends StatelessWidget {
  final String originalContent;
  final String humanizedContent;
  final double beforeScore;
  final double afterScore;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback? onUseOriginal;
  final VoidCallback? onUseHumanized;

  const BeforeAfterComparison({
    super.key,
    required this.originalContent,
    required this.humanizedContent,
    required this.beforeScore,
    required this.afterScore,
    required this.isExpanded,
    required this.onToggle,
    this.onUseOriginal,
    this.onUseHumanized,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: AppTheme.borderRadiusLG,
      ),
      child: Column(
        children: [
          // Toggle button
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BodyTextLarge('Show Before/After Comparison'),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildContentColumn(
              'Original',
              originalContent,
              beforeScore,
              const Color(0xFFDC2626), // Red
              onUseOriginal,
            ),
          ),
          Container(width: 1, color: AppTheme.border),
          Expanded(
            child: _buildContentColumn(
              'Humanized',
              humanizedContent,
              afterScore,
              const Color(0xFF059669), // Green
              onUseHumanized,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildContentColumn(
          'Original',
          originalContent,
          beforeScore,
          const Color(0xFFDC2626), // Red
          onUseOriginal,
        ),
        Container(height: 1, color: AppTheme.border),
        _buildContentColumn(
          'Humanized',
          humanizedContent,
          afterScore,
          const Color(0xFF059669), // Green
          onUseHumanized,
        ),
      ],
    );
  }

  Widget _buildContentColumn(
    String title,
    String content,
    double score,
    Color scoreColor,
    VoidCallback? onUse,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              H3(title),
              Row(
                children: [
                  BodyText('AI: ', color: AppTheme.textSecondary),
                  BodyText(
                    '${score.toInt()}%',
                    color: scoreColor,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ],
          ),
          const Gap(12),

          // Content with better formatting
          Container(
            constraints: const BoxConstraints(maxHeight: 300, minHeight: 150),
            decoration: BoxDecoration(
              color: AppTheme.bgPrimary,
              borderRadius: AppTheme.borderRadiusMD,
              border: Border.all(color: AppTheme.border.withOpacity(0.5)),
            ),
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: MarkdownBody(
                data: content,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppTheme.textPrimary,
                  ),
                  h1: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  h2: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  h3: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  listBullet: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppTheme.textPrimary,
                  ),
                  blockquote: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textSecondary,
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const Gap(12),

          // Action button
          if (onUse != null)
            SecondaryButton(text: 'Use $title', onPressed: onUse),
        ],
      ),
    );
  }
}
