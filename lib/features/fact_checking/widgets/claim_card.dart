import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../models/fact_check_claim.dart';
import 'confidence_bar.dart';

/// Claim Card Controller
class ClaimCardController extends GetxController {
  final isExpanded = false.obs;

  void toggleExpanded() => isExpanded.value = !isExpanded.value;
}

/// Claim Card Widget
/// Displays a single fact-checked claim with verification status
class ClaimCard extends StatelessWidget {
  final FactCheckClaim claim;
  final VoidCallback? onRemove;
  final VoidCallback? onManualVerify;

  const ClaimCard({
    super.key,
    required this.claim,
    this.onRemove,
    this.onManualVerify,
  });

  /// Open source URL in new tab
  void _openSource() {
    if (claim.source != null && claim.source!.isNotEmpty) {
      // TODO: Implement URL launcher
      log('Opening source: ${claim.source}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClaimCardController(), tag: claim.claim);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: claim.backgroundColor,
        border: Border.all(color: claim.statusColor, width: 2),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Claim text
            Obx(
              () => BodyText(
                claim.claim,
                maxLines: controller.isExpanded.value ? null : 3,
              ),
            ),

            // Show more/less button if claim is long
            if (claim.claim.length > 150) ...[
              const Gap(8),
              InkWell(
                onTap: controller.toggleExpanded,
                child: Obx(
                  () => BodyText(
                    controller.isExpanded.value ? 'Show less' : 'Show more',
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            const Gap(12),

            // Status row
            Row(
              children: [
                Icon(claim.statusIcon, color: claim.statusColor, size: 20),
                const Gap(8),
                H3('Status: ${claim.statusLabel}', color: claim.statusColor),
              ],
            ),

            const Gap(12),

            // Confidence bar
            ConfidenceBar(confidence: claim.confidence),

            const Gap(12),

            // Source
            if (claim.source != null && claim.source!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyTextSmall(
                    'Source: ${claim.source}',
                    color: AppTheme.textSecondary,
                  ),
                  const Gap(8),
                  InkWell(
                    onTap: _openSource,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BodyText(
                          'View Source',
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        const Gap(4),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: AppTheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              BodyTextSmall(
                'Source: ${claim.source ?? "No credible source found"}',
                color: AppTheme.textSecondary,
              ),

            // Action buttons for unverified claims
            if (claim.confidence < 0.50) ...[
              const Gap(12),
              Row(
                children: [
                  if (onManualVerify != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onManualVerify,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: claim.statusColor),
                          foregroundColor: claim.statusColor,
                        ),
                        child: const BodyTextSmall('Manually Verify'),
                      ),
                    ),
                  if (onManualVerify != null && onRemove != null) const Gap(8),
                  if (onRemove != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onRemove,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: claim.statusColor),
                          foregroundColor: claim.statusColor,
                        ),
                        child: const BodyTextSmall('Remove Claim'),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
