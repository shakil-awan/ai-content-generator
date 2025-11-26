import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';

/// Humanize Button Widget
/// Primary action button to trigger AI humanization
class HumanizeButton extends StatelessWidget {
  final String generationId;
  final String quotaText;
  final bool hasQuota;
  final VoidCallback onPressed;
  final bool isEnabled;
  final String? disabledTooltip;

  const HumanizeButton({
    super.key,
    required this.generationId,
    required this.quotaText,
    required this.hasQuota,
    required this.onPressed,
    this.isEnabled = true,
    this.disabledTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final canPress = isEnabled && hasQuota;

    Widget button = SecondaryButton(
      text: '🤖 Humanize Content',
      onPressed: canPress ? onPressed : null,
    );

    // Wrap with tooltip if disabled
    if (!canPress && disabledTooltip != null) {
      button = Tooltip(message: disabledTooltip!, child: button);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        button,
        const Gap(4),
        CaptionText(quotaText, color: AppTheme.textSecondary),
      ],
    );
  }
}
