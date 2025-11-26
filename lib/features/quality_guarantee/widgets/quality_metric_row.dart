import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../utils/quality_helpers.dart';

/// Quality Metric Row Widget
/// Displays a single quality dimension with progress bar
class QualityMetricRow extends StatefulWidget {
  final String label;
  final double score; // 0.0 - 1.0
  final String? helperText;

  const QualityMetricRow({
    super.key,
    required this.label,
    required this.score,
    this.helperText,
  });

  @override
  State<QualityMetricRow> createState() => _QualityMetricRowState();
}

class _QualityMetricRowState extends State<QualityMetricRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.score,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = QualityHelpers.getMetricColor(widget.score);
    final percentage = (widget.score * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label and percentage row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BodyTextLarge(widget.label),
            BodyText('$percentage%', color: color, fontWeight: FontWeight.w600),
          ],
        ),

        const Gap(8),

        // Animated progress bar
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              child: SizedBox(
                height: 8,
                child: LinearProgressIndicator(
                  value: _animation.value,
                  backgroundColor: AppTheme.neutral200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            );
          },
        ),

        // Helper text
        if (widget.helperText != null) ...[
          const Gap(4),
          BodyTextSmall(widget.helperText!, color: AppTheme.textSecondary),
        ],
      ],
    );
  }
}
