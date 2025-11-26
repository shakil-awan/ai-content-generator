import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../fact_checking/models/fact_check_claim.dart' as fc;
import '../../fact_checking/models/fact_check_results.dart' as fc;
import '../../fact_checking/widgets/fact_check_results_panel.dart';
import '../../humanization/controllers/humanization_controller.dart';
import '../../humanization/widgets/humanization_progress_indicator.dart';
import '../../humanization/widgets/humanization_results_panel.dart';
import '../../humanization/widgets/humanization_settings_modal.dart';
import '../../humanization/widgets/humanize_button.dart';
import '../../humanization/widgets/quota_exceeded_modal.dart';
import '../../humanization/widgets/quota_warning_banner.dart';
import '../../quality_guarantee/models/quality_score.dart';
import '../../quality_guarantee/widgets/quality_details_panel.dart';
import '../../quality_guarantee/widgets/quality_score_badge.dart' as qg;
import '../controllers/content_generation_controller.dart';
import '../widgets/action_buttons_row.dart';

/// Content Results Page
/// Displays generated content with quality score, actions, and placeholders for features
class ContentResultsPage extends GetView<ContentGenerationController> {
  const ContentResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      appBar: AppBar(
        title: const H2('Generated Content'),
        actions: [
          // New generation button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SecondaryButton(
              text: 'New Generation',
              onPressed: () => Get.back(),
              icon: Icons.add,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final content = controller.generatedContent.value;

          if (content == null) {
            return const Center(child: BodyText('No content generated yet'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? AppTheme.spacing48 : AppTheme.spacing16,
              vertical: AppTheme.spacing24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 900 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content display card with quality badge
                    _buildContentCard(content, isDesktop),
                    const Gap(24),

                    // Action buttons
                    const ActionButtonsRow(),
                    const Gap(24),

                    // Quality score details (placeholder)
                    _buildQualityDetailsPanel(content),
                    const Gap(16),

                    // Fact-check results (placeholder)
                    _buildFactCheckPanel(content),
                    const Gap(16),

                    // AI Humanization section (placeholder)
                    _buildHumanizationSection(context),

                    const Gap(48),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContentCard(dynamic content, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        border: Border.all(color: AppTheme.border),
        borderRadius: AppTheme.borderRadiusLG,
        boxShadow: AppTheme.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with quality badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    H2(content.contentType.toUpperCase()),
                    const Gap(4),
                    BodyTextSmall(
                      '${content.wordCount} words • ${content.estimatedReadTime}-minute read',
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
              const Gap(16),
              // Quality badge
              qg.QualityScoreBadge(
                qualityScore: _convertToQualityScore(content.qualityMetrics),
              ),
            ],
          ),
          const Gap(24),

          // Generated content
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: AppTheme.borderRadiusMD,
            ),
            child: MarkdownBody(
              data: content.content,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: AppTheme.textPrimary,
                ),
                h1: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                h2: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                h3: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                strong: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                em: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textPrimary,
                ),
                blockquote: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                code: const TextStyle(
                  backgroundColor: AppTheme.bgPrimary,
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const Gap(16),

          // Copy button in bottom right
          Align(
            alignment: Alignment.centerRight,
            child: SecondaryButton(
              text: 'Copy',
              icon: Icons.copy,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: content.content));
                Get.snackbar(
                  'Copied',
                  'Content copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityDetailsPanel(dynamic content) {
    return QualityDetailsPanel(
      qualityScore: _convertToQualityScore(content.qualityMetrics),
    );
  }

  /// Convert backend QualityMetrics to QualityScore model for widgets
  QualityScore _convertToQualityScore(dynamic metrics) {
    if (metrics == null) {
      // Return default low score if no metrics available
      return QualityScore(
        overall: 0.5,
        readability: 0.5,
        completeness: 0.5,
        seo: 0.5,
        grammar: 0.5,
        details: QualityDetails(
          wordCount: 0,
          fleschKincaidScore: 0,
          keywordDensity: 0,
        ),
      );
    }

    // Backend QualityMetrics uses 0-10 scale, convert to 0.0-1.0 for QualityScore
    return QualityScore(
      overall: metrics.overallScore / 10,
      readability: metrics.readabilityScore / 10,
      completeness: metrics.factCheckScore / 10,
      seo: metrics.overallScore / 10,
      grammar: metrics.grammarScore / 10,
      details: QualityDetails(
        wordCount: 0, // TODO: Get from content object
        fleschKincaidScore: metrics.readabilityScore,
        keywordDensity: 0, // TODO: Calculate or get from backend
      ),
    );
  }

  Widget _buildFactCheckPanel(dynamic content) {
    final factCheck = content.factCheckResults;

    // If fact-checking wasn't performed or no results, show placeholder
    if (factCheck == null || !factCheck.checked) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.info.withValues(alpha: 0.05),
          border: Border.all(color: AppTheme.info.withValues(alpha: 0.2)),
          borderRadius: AppTheme.borderRadiusLG,
        ),
        child: Row(
          children: [
            Icon(Icons.fact_check, color: AppTheme.info, size: 20),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const H3('Fact-Check Results'),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const CaptionText(
                          'PRO',
                          color: AppTheme.textOnPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Gap(4),
                  const BodyTextSmall(
                    'Enable auto fact-check in generation form to verify claims',
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Convert backend FactCheckResults to our fact-checking widget models
    final fcResults = fc.FactCheckResults(
      checked: factCheck.checked,
      claims: factCheck.claims
          .map<fc.FactCheckClaim>(
            (claim) => fc.FactCheckClaim(
              claim: claim.claim,
              verified: claim.verified,
              source: claim.source,
              confidence: claim.confidence,
            ),
          )
          .toList(),
      verificationTime: factCheck.verificationTime,
    );

    // Display actual fact-check results using our widget
    return FactCheckResultsPanel(
      results: fcResults,
      isLoading: false,
      onRetry: () {
        Get.snackbar(
          'Retry',
          'Retry functionality will be implemented with backend integration',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      onSkip: () {
        // Do nothing, already generated
      },
    );
  }

  Widget _buildHumanizationSection(BuildContext context) {
    // Initialize controller if not already done
    final humanizationController = Get.put(HumanizationController());

    return Obx(() {
      final content = controller.generatedContent.value;
      if (content == null) return const SizedBox.shrink();

      // Check if content is already humanized
      final isHumanized =
          humanizationController.humanizationResult.value != null;
      final isHumanizing = humanizationController.isHumanizing.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quota warning banner (show when near limit)
          if (humanizationController.isNearLimit && !isHumanized)
            QuotaWarningBanner(
              used: humanizationController.humanizationsUsed.value,
              limit: humanizationController.humanizationsLimit.value,
              onUpgrade: () {
                // TODO: Navigate to pricing page
                Get.snackbar(
                  'Upgrade',
                  'Navigate to pricing page',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),

          if (humanizationController.isNearLimit && !isHumanized) const Gap(12),

          // Show humanize button if not humanized yet
          if (!isHumanized && !isHumanizing)
            HumanizeButton(
              generationId: content.id,
              quotaText: humanizationController.quotaText,
              hasQuota: humanizationController.hasQuota,
              onPressed: () => _showHumanizationModal(context, content.id),
              isEnabled: true,
              disabledTooltip: humanizationController.hasQuota
                  ? null
                  : 'Quota exceeded',
            ),

          // Show progress indicator during humanization
          if (isHumanizing)
            HumanizationProgressIndicator(
              currentStep: humanizationController.currentStep.value,
            ),

          // Show results panel after humanization
          if (isHumanized)
            HumanizationResultsPanel(
              result: humanizationController.humanizationResult.value!,
              onCopy: () {
                Get.snackbar(
                  'Copied',
                  'Humanized content copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              onTryAgain: () => _showHumanizationModal(context, content.id),
              onKeepOriginal: () {
                humanizationController.resetState();
                Get.snackbar(
                  'Restored',
                  'Original content restored',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
        ],
      );
    });
  }

  void _showHumanizationModal(BuildContext context, String generationId) {
    final humanizationController = Get.find<HumanizationController>();

    // Check quota before showing modal
    if (!humanizationController.hasQuota) {
      showDialog(
        context: context,
        builder: (dialogContext) => QuotaExceededModal(
          used: humanizationController.humanizationsUsed.value,
          limit: humanizationController.humanizationsLimit.value,
          onViewPricing: () {
            // TODO: Navigate to pricing page
            Get.snackbar(
              'Pricing',
              'Navigate to pricing page',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      );
      return;
    }

    // Show settings modal
    showDialog(
      context: context,
      builder: (dialogContext) => HumanizationSettingsModal(
        initialLevel: humanizationController.selectedLevel.value,
        initialPreserveFacts: humanizationController.preserveFacts.value,
        onHumanize: (level, preserveFacts) async {
          Navigator.pop(dialogContext);
          humanizationController.updateLevel(level);
          if (preserveFacts != humanizationController.preserveFacts.value) {
            humanizationController.togglePreserveFacts();
          }
          await humanizationController.humanizeContent(generationId);
        },
      ),
    );
  }
}
