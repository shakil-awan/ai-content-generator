import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';

/// Humanization Settings Modal Widget
/// Select humanization level and options before processing
class HumanizationSettingsModal extends StatefulWidget {
  final Function(String level, bool preserveFacts) onHumanize;
  final String initialLevel;
  final bool initialPreserveFacts;

  const HumanizationSettingsModal({
    super.key,
    required this.onHumanize,
    this.initialLevel = 'balanced',
    this.initialPreserveFacts = true,
  });

  @override
  State<HumanizationSettingsModal> createState() =>
      _HumanizationSettingsModalState();
}

class _HumanizationSettingsModalState extends State<HumanizationSettingsModal> {
  late String _selectedLevel;
  late bool _preserveFacts;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialLevel;
    _preserveFacts = widget.initialPreserveFacts;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusLG),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title bar
            Row(
              children: [
                const Expanded(child: H2('Humanize AI Content')),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const Gap(24),

            // Humanization level section
            const BodyTextLarge('Humanization Level'),
            const Gap(12),

            _buildLevelOption('light', 'Light', 'Minimal changes'),
            const Gap(8),

            _buildLevelOption(
              'balanced',
              'Balanced',
              'Moderate rewrite (Recommended)',
            ),
            const Gap(8),

            _buildLevelOption(
              'aggressive',
              'Aggressive',
              'Maximum humanization',
            ),

            const Gap(24),

            // Options section
            const BodyTextLarge('Options'),
            const Gap(12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _preserveFacts,
                  onChanged: (value) {
                    setState(() {
                      _preserveFacts = value ?? true;
                    });
                  },
                  activeColor: AppTheme.primary,
                ),
                const Gap(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BodyText('Preserve Facts'),
                      const Gap(4),
                      CaptionText(
                        'Maintain factual accuracy while humanizing',
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Gap(24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                ),
                const Gap(12),
                PrimaryButton(
                  text: 'Humanize Now',
                  onPressed: () {
                    widget.onHumanize(_selectedLevel, _preserveFacts);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelOption(String value, String label, String description) {
    final isSelected = _selectedLevel == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLevel = value;
        });
      },
      borderRadius: AppTheme.borderRadiusMD,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: AppTheme.borderRadiusMD,
          color: isSelected ? AppTheme.primary.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedLevel,
              onChanged: (newValue) {
                setState(() {
                  _selectedLevel = newValue ?? 'balanced';
                });
              },
              activeColor: AppTheme.primary,
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyText(
                    label,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  const Gap(2),
                  CaptionText(description, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
