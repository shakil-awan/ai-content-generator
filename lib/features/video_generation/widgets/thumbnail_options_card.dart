import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Thumbnail Options Card Widget
/// Displays 3 thumbnail title suggestions
class ThumbnailOptionsCard extends StatelessWidget {
  final List<String> thumbnails;

  const ThumbnailOptionsCard({super.key, required this.thumbnails});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const H3('Thumbnail Title Options'),
        const Gap(12),
        ...thumbnails.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: AppTheme.borderRadiusMD,
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: AppTheme.borderRadiusMD,
                    ),
                    child: Center(
                      child: BodyText(
                        '${entry.key + 1}',
                        color: AppTheme.textOnPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(child: BodyText(entry.value)),
                  IconButton(
                    icon: const Icon(Icons.content_copy, size: 18),
                    onPressed: () {
                      // TODO: Copy to clipboard
                    },
                    tooltip: 'Copy',
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
