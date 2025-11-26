import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../models/fact_check_claim.dart';
import 'confidence_bar.dart';

/// Claim Card Widget
/// Displays a single fact-checked claim with verification status
class ClaimCard extends StatefulWidget {
  final FactCheckClaim claim;
  final VoidCallback? onRemove;
  final VoidCallback? onManualVerify;

  const ClaimCard({
    super.key,
    required this.claim,
    this.onRemove,
    this.onManualVerify,
  });

  @override
  State<ClaimCard> createState() => _ClaimCardState();
}

class _ClaimCardState extends State<ClaimCard> {
  bool _isExpanded = false;

  /// Open source URL in new tab
  void _openSource() {
    if (widget.claim.source != null && widget.claim.source!.isNotEmpty) {
      // TODO: Implement URL launcher
      print('Opening source: ${widget.claim.source}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.claim.backgroundColor,
        border: Border.all(
          color: widget.claim.statusColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Claim text
            BodyText(
              widget.claim.claim,
              maxLines: _isExpanded ? null : 3,
            ),

            // Show more/less button if claim is long
            if (widget.claim.claim.length > 150) ...[
              const Gap(8),
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: BodyText(
                  _isExpanded ? 'Show less' : 'Show more',
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const Gap(12),

            // Status row
            Row(
              children: [
                Icon(
                  widget.claim.statusIcon,
                  color: widget.claim.statusColor,
                  size: 20,
                ),
                const Gap(8),
                H3(
                  'Status: ${widget.claim.statusLabel}',
                  color: widget.claim.statusColor,
                ),
              ],
            ),

            const Gap(12),

            // Confidence bar
            ConfidenceBar(confidence: widget.claim.confidence),

            const Gap(12),

            // Source
            if (widget.claim.source != null && widget.claim.source!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyTextSmall(
                    'Source: ${widget.claim.source}',
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
                'Source: ${widget.claim.source ?? "No credible source found"}',
                color: AppTheme.textSecondary,
              ),

            // Action buttons for unverified claims
            if (widget.claim.confidence < 0.50) ...[
              const Gap(12),
              Row(
                children: [
                  if (widget.onManualVerify != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onManualVerify,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: widget.claim.statusColor),
                          foregroundColor: widget.claim.statusColor,
                        ),
                        child: const BodyTextSmall('Manually Verify'),
                      ),
                    ),
                  if (widget.onManualVerify != null && widget.onRemove != null)
                    const Gap(8),
                  if (widget.onRemove != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onRemove,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: widget.claim.statusColor),
                          foregroundColor: widget.claim.statusColor,
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
