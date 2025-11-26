import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Divider with text (e.g., "OR")
///
/// Used to separate form sections
class FormDivider extends StatelessWidget {
  final String text;

  const FormDivider({super.key, this.text = 'OR'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppTheme.border)),
        Gap(AppTheme.spacing8),
        CaptionText(text, color: AppTheme.textSecondary),
        Gap(AppTheme.spacing8),
        Expanded(child: Container(height: 1, color: AppTheme.border)),
      ],
    );
  }
}
