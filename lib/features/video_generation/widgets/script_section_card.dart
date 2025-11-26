import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../models/script_section.dart';

/// Script Section Card Widget
/// Expandable card showing individual script section with timestamp and visual cue
class ScriptSectionCard extends StatelessWidget {
  final ScriptSection section;
  final int index;
  final bool isExpanded;
  final VoidCallback onToggle;

  const ScriptSectionCard({
    super.key,
    required this.section,
    required this.index,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        border: Border.all(color: AppTheme.border),
        borderRadius: AppTheme.borderRadiusLG,
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: AppTheme.borderRadiusLG,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Section number
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: AppTheme.borderRadiusMD,
                    ),
                    child: Center(
                      child: BodyText(
                        '${index + 1}',
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Gap(12),
                  // Timestamp and heading
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyText(
                          section.timestamp,
                          fontWeight: FontWeight.w600,
                        ),
                        if (section.heading.isNotEmpty) ...[
                          const Gap(4),
                          BodyTextSmall(
                            section.heading,
                            color: AppTheme.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Expand icon
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content
                  BodyText(section.content),

                  // Visual cue (if exists)
                  if (section.visualCue.isNotEmpty) ...[
                    const Gap(16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.info.withValues(alpha: 0.1),
                        borderRadius: AppTheme.borderRadiusMD,
                        border: Border.all(
                          color: AppTheme.info.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: AppTheme.info,
                          ),
                          const Gap(8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const BodyText(
                                  'Visual Suggestion',
                                  fontWeight: FontWeight.w600,
                                ),
                                const Gap(4),
                                BodyTextSmall(
                                  section.visualCue,
                                  color: AppTheme.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
