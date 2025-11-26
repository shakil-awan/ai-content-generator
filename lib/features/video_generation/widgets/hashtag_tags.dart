import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';

/// Hashtag Tags Widget
/// Displays hashtags with expand/collapse functionality
class HashtagTags extends StatelessWidget {
  final List<String> hashtags;
  final bool isExpanded;
  final VoidCallback onToggle;

  const HashtagTags({
    super.key,
    required this.hashtags,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final displayedHashtags = isExpanded ? hashtags : hashtags.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            H3('Hashtags (${hashtags.length})'),
            TextButton.icon(
              onPressed: onToggle,
              icon: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 18,
              ),
              label: BodyTextSmall(isExpanded ? 'Show Less' : 'Show All'),
            ),
          ],
        ),
        const Gap(12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: displayedHashtags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.info.withValues(alpha: 0.1),
                borderRadius: AppTheme.borderRadiusMD,
                border: Border.all(color: AppTheme.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BodyText(
                    tag,
                    color: AppTheme.info,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const Gap(12),
        SecondaryButton(
          text: 'Copy All Hashtags',
          onPressed: () {
            // TODO: Copy to clipboard
          },
          icon: Icons.content_copy,
        ),
      ],
    );
  }
}
