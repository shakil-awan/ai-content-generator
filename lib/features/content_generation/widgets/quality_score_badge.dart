import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/content_generation_controller.dart';

/// Quality Score Badge Widget
/// Displays circular quality grade badge (placeholder for Prompt 04 integration)
class QualityScoreBadge extends GetView<ContentGenerationController> {
  const QualityScoreBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final content = controller.generatedContent.value;
      final qualityMetrics = content?.qualityMetrics;

      // Calculate grade from overall score
      final overallScore = qualityMetrics?.overallScore ?? 0.0;
      final String grade = _getGradeFromScore(overallScore);
      final int percentage = (overallScore * 10).round();

      // Determine color based on grade
      final Color color = _getColorForGrade(grade);

      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            H2(grade, color: color),
            CaptionText('$percentage%', color: color),
          ],
        ),
      );
    });
  }

  String _getGradeFromScore(double score) {
    if (score >= 9.0) return 'A+';
    if (score >= 8.5) return 'A';
    if (score >= 8.0) return 'A-';
    if (score >= 7.5) return 'B+';
    if (score >= 7.0) return 'B';
    if (score >= 6.5) return 'B-';
    if (score >= 6.0) return 'C+';
    if (score >= 5.5) return 'C';
    if (score >= 5.0) return 'C-';
    if (score >= 4.0) return 'D';
    return 'F';
  }

  Color _getColorForGrade(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':
      case 'A-':
        return AppTheme.success;
      case 'B+':
      case 'B':
      case 'B-':
        return AppTheme.info;
      case 'C+':
      case 'C':
      case 'C-':
        return AppTheme.warning;
      case 'D':
      case 'F':
        return AppTheme.error;
      default:
        return AppTheme.info;
    }
  }
}
