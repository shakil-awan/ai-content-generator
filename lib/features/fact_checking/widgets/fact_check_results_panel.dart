import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../models/fact_check_results.dart';
import 'claim_card.dart';
import 'fact_check_loading.dart';

/// Fact-Check Results Panel Widget
/// Displays fact-check results after content generation
class FactCheckResultsPanel extends StatefulWidget {
  final FactCheckResults? results;
  final bool isLoading;
  final String? errorMessage;
  final int currentClaim;
  final int totalClaims;
  final VoidCallback? onRetry;
  final VoidCallback? onSkip;

  const FactCheckResultsPanel({
    super.key,
    this.results,
    this.isLoading = false,
    this.errorMessage,
    this.currentClaim = 0,
    this.totalClaims = 0,
    this.onRetry,
    this.onSkip,
  });

  @override
  State<FactCheckResultsPanel> createState() => _FactCheckResultsPanelState();
}

class _FactCheckResultsPanelState extends State<FactCheckResultsPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (widget.isLoading) {
      return FactCheckLoadingIndicator(
        currentClaim: widget.currentClaim,
        totalClaims: widget.totalClaims,
      );
    }

    // Error state
    if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) {
      return _buildErrorState();
    }

    // No results
    if (widget.results == null) {
      return const SizedBox.shrink();
    }

    // Empty state (no claims found)
    if (widget.results!.claims.isEmpty) {
      return _buildEmptyState();
    }

    // Success state with results
    return _buildSuccessState();
  }

  /// Build error state
  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Red-50
        border: Border.all(color: AppTheme.error),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: AppTheme.error,
                size: 20,
              ),
              const Gap(8),
              H3(
                'Fact-Check Failed',
                color: AppTheme.error,
              ),
            ],
          ),
          const Gap(8),
          BodyText(
            widget.errorMessage ?? 'Unable to verify claims',
            color: AppTheme.textSecondary,
          ),
          const Gap(16),
          Row(
            children: [
              if (widget.onRetry != null)
                Expanded(
                  child: SecondaryButton(
                    text: 'Retry',
                    onPressed: widget.onRetry,
                  ),
                ),
              if (widget.onRetry != null && widget.onSkip != null)
                const Gap(8),
              if (widget.onSkip != null)
                Expanded(
                  child: SecondaryButton(
                    text: 'Skip Fact-Check',
                    onPressed: widget.onSkip,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build empty state (no claims found)
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.success,
                size: 20,
              ),
              const Gap(8),
              H3('Fact-Check Complete'),
            ],
          ),
          const Gap(8),
          BodyText(
            'No verifiable claims detected',
            color: AppTheme.textSecondary,
          ),
          const Gap(4),
          BodyTextSmall(
            '(This content appears opinion-based)',
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  /// Build success state with results
  Widget _buildSuccessState() {
    final results = widget.results!;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.success,
                        size: 20,
                      ),
                      const Gap(8),
                      Expanded(
                        child: H3(
                          'Fact-Check Complete (${results.totalClaims} claim${results.totalClaims != 1 ? 's' : ''} verified)',
                        ),
                      ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),

                  const Gap(8),

                  // Summary stats
                  BodyTextSmall(
                    'Verification time: ${results.formattedVerificationTime}',
                    color: AppTheme.textSecondary,
                  ),

                  const Gap(4),

                  // Breakdown
                  BodyTextSmall(
                    '✓ ${results.verifiedCount} verified  •  ⚠ ${results.partiallyVerifiedCount} partial  •  ✗ ${results.unverifiedCount} unverified',
                    color: AppTheme.textSecondary,
                  ),

                  const Gap(12),

                  // View details button
                  BodyText(
                    _isExpanded ? '▲ Hide Details' : '▼ View Details',
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content (claims list)
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: results.claims.map((claim) {
                  return ClaimCard(
                    claim: claim,
                    onRemove: () {
                      // TODO: Implement remove claim
                      print('Remove claim: ${claim.claim}');
                    },
                    onManualVerify: () {
                      // TODO: Implement manual verification
                      print('Manually verify: ${claim.claim}');
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
