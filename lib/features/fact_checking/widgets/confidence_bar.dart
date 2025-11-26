import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Confidence Bar Widget
/// Displays a progress bar showing confidence percentage with color coding
class ConfidenceBar extends StatelessWidget {
  final double confidence; // 0.0 - 1.0

  const ConfidenceBar({super.key, required this.confidence});

  /// Get color based on confidence level
  Color _getConfidenceColor() {
    if (confidence >= 0.70) return const Color(0xFF059669); // Green-600
    if (confidence >= 0.50) return const Color(0xFFD97706); // Yellow-600
    return const Color(0xFFDC2626); // Red-600
  }

  /// Get background color for progress bar
  Color _getBackgroundColor() {
    if (confidence >= 0.70) return const Color(0xFFD1FAE5); // Green-200
    if (confidence >= 0.50) return const Color(0xFFFEF3C7); // Yellow-200
    return const Color(0xFFFECACA); // Red-200
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).toInt();

    return Row(
      children: [
        // Label
        BodyText('Confidence:', color: AppTheme.textSecondary),
        const Gap(8),

        // Progress bar
        Expanded(
          child: SizedBox(
            height: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              child: LinearProgressIndicator(
                value: confidence,
                backgroundColor: _getBackgroundColor(),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getConfidenceColor(),
                ),
              ),
            ),
          ),
        ),

        const Gap(8),

        // Percentage label
        BodyText(
          '$percentage%',
          fontWeight: FontWeight.w600,
          color: _getConfidenceColor(),
        ),
      ],
    );
  }
}
