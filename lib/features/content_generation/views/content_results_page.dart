import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../fact_checking/models/fact_check_claim.dart' as fc;
import '../../fact_checking/models/fact_check_results.dart' as fc;
import '../../fact_checking/models/fact_check_source.dart' as fc;
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
import '../models/content_generation_response.dart';
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
          final ContentGenerationResponse? content =
              controller.generatedContent.value;

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
                    // Quality regeneration prompt (if quality is low)
                    _buildRegenerationPrompt(context),

                    // AI Humanization section - Show ABOVE content when humanized
                    _buildHumanizationSection(context),

                    // Content display card with quality badge and humanization status
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

  Widget _buildContentCard(ContentGenerationResponse content, bool isDesktop) {
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
          // Header with quality badge and humanization status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        H2(content.contentType.toUpperCase()),
                        const Gap(8),
                        // Humanization status badge
                        Obx(() {
                          final humanizationController =
                              Get.find<HumanizationController>();
                          final isHumanized =
                              humanizationController.humanizationResult.value !=
                              null;
                          if (!isHumanized) return const SizedBox.shrink();

                          final result =
                              humanizationController.humanizationResult.value!;
                          final improvement = result.improvementPercentage;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withOpacity(0.1),
                              border: Border.all(color: AppTheme.success),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 14,
                                  color: AppTheme.success,
                                ),
                                const Gap(4),
                                BodyTextSmall(
                                  'Humanized (${improvement.toStringAsFixed(1)}% ↓)',
                                  color: AppTheme.success,
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                    const Gap(4),
                    BodyTextSmall(
                      '${content.actualWordCount} words • ${content.estimatedReadTime}-minute read',
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
              const Gap(16),
              // Quality badge - use real quality score from controller if available
              Obx(() {
                final qualityScore = controller.currentQualityScore.value;
                return qg.QualityScoreBadge(
                  qualityScore:
                      qualityScore ??
                      _convertToQualityScore(content.qualityMetrics),
                );
              }),
            ],
          ),
          const Gap(24),

          // Blog Title & Metadata Section (if available)
          if (content.title != null && content.title!.isNotEmpty) ...[
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary.withOpacity(0.08),
                      AppTheme.accent.withOpacity(0.08),
                    ],
                  ),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                  borderRadius: AppTheme.borderRadiusLG,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title section
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.title_rounded,
                            size: 20,
                            color: AppTheme.primary,
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BodyTextSmall(
                                'Blog Title',
                                color: AppTheme.textSecondary,
                              ),
                              const Gap(4),
                              SelectableText(
                                content.title!,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                  height: 1.3,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Meta Description section (if available in backend)
                    const Gap(20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSecondary.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.border.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              size: 16,
                              color: AppTheme.accent,
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    BodyTextSmall(
                                      'Meta Description',
                                      color: AppTheme.textSecondary,
                                    ),
                                    const Gap(8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.success.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: BodyTextSmall(
                                        'SEO Optimized',
                                        color: AppTheme.success,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(8),
                                SelectableText(
                                  content.metaDescription ??
                                      'No meta description available',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Metadata chips
                    const Gap(16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Blog creation timestamp
                        _buildMetadataChip(
                          icon: Icons.calendar_today,
                          label: 'Blog created',
                          value: _formatDate(content.createdAt),
                          color: AppTheme.primary,
                        ),
                        // Blog generation time
                        if (content.generationTime > 0)
                          _buildMetadataChip(
                            icon: Icons.speed_outlined,
                            label: 'Generated in',
                            value:
                                '${content.generationTime.toStringAsFixed(1)}s',
                            color: AppTheme.info,
                          ),
                        // Humanization timestamp
                        if (content.humanization.applied == true &&
                            content.humanization.humanizedAt != null)
                          _buildMetadataChip(
                            icon: Icons.psychology_outlined,
                            label: 'Humanized',
                            value: _formatDate(
                              content.humanization.humanizedAt!,
                            ),
                            color: AppTheme.success,
                          ),
                        // Humanization processing time
                        if (content.humanization.applied == true &&
                            content.humanization.processingTime > 0)
                          _buildMetadataChip(
                            icon: Icons.timer_outlined,
                            label: 'Humanization took',
                            value:
                                '${content.humanization.processingTime.toStringAsFixed(1)}s',
                            color: AppTheme.success,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Gap(20),
          ],

          // Generated content with animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: AppTheme.borderRadiusLG,
                border: Border.all(color: AppTheme.border.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildQualityDetailsPanel(ContentGenerationResponse content) {
    return Obx(() {
      final qualityScore = controller.currentQualityScore.value;
      final isScoringQuality = controller.isScoringQuality.value;
      final suggestions = controller.qualitySuggestions;

      // Show loading indicator while scoring
      if (isScoringQuality) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.bgSecondary,
            borderRadius: AppTheme.borderRadiusLG,
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              const CircularProgressIndicator(),
              const Gap(16),
              const BodyText('Analyzing content quality...'),
            ],
          ),
        );
      }

      // Show quality score if available
      if (qualityScore != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QualityDetailsPanel(qualityScore: qualityScore),

            // AI-powered improvement suggestions (Phase 3)
            if (content.aiSuggestions.isNotEmpty) ...[
              const Gap(16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: AppTheme.borderRadiusLG,
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF3B82F6,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                        ),
                        const Gap(12),
                        const H3('AI-Powered Suggestions'),
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF3B82F6,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                    const Text(
                      'Gemini AI analyzed your content and found these improvements:',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Gap(16),
                    ...content.aiSuggestions.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF3B82F6,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Show suggestions if quality is low
            if (suggestions.isNotEmpty) ...[
              const Gap(16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: AppTheme.borderRadiusLG,
                  border: Border.all(
                    color: AppTheme.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.warning,
                          size: 24,
                        ),
                        const Gap(12),
                        const H3('Improvement Suggestions'),
                      ],
                    ),
                    const Gap(12),
                    ...suggestions.map(
                      (suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BodyText('• ', color: AppTheme.warning),
                            Expanded(child: BodyText(suggestion)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      }

      // Fallback to backend quality metrics if quality API didn't run
      return QualityDetailsPanel(
        qualityScore: _convertToQualityScore(content.qualityMetrics),
      );
    });
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
      completeness: metrics.completenessScore / 10,
      seo: metrics.seoScore / 10,
      grammar: metrics.grammarScore / 10,
      details: QualityDetails(
        wordCount: 0, // TODO: Get from content object
        fleschKincaidScore: metrics.readabilityScore,
        keywordDensity: 0, // TODO: Calculate or get from backend
      ),
    );
  }

  Widget _buildFactCheckPanel(ContentGenerationResponse content) {
    final factCheck = content.factCheckResults;

    // If fact-checking wasn't performed, show placeholder
    if (!factCheck.checked) {
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

    // Safety check: Skip fact-checking panel if no actual fact-checking was done
    // This handles old content with placeholder/mock data
    if (factCheck.claimsFound == 0) {
      print('\n⚠️ SKIPPING FACT CHECK PANEL: No real fact-checking data');
      print('  - checked: ${factCheck.checked}');
      print('  - claimsFound: ${factCheck.claimsFound}');
      return const SizedBox.shrink(); // Return empty widget
    }

    // Convert backend FactCheckResults to our fact-checking widget models
    print('\n═══ BEFORE WIDGET CONVERSION ═══');
    print('factCheck.checked: ${factCheck.checked}');
    print('factCheck.claims type: ${factCheck.claims.runtimeType}');
    print('factCheck.claims length: ${factCheck.claims.length}');
    print('factCheck.claimsFound: ${factCheck.claimsFound}');
    print('factCheck.claimsVerified: ${factCheck.claimsVerified}');
    print('factCheck.overallConfidence: ${factCheck.overallConfidence}');
    print('factCheck.totalSearchesUsed: ${factCheck.totalSearchesUsed}');

    if (factCheck.claims.isNotEmpty) {
      print('\nFirst claim:');
      print('  - verified: ${factCheck.claims[0].verified}');
      print('  - sources type: ${factCheck.claims[0].sources.runtimeType}');
      print('  - sources length: ${factCheck.claims[0].sources.length}');
      if (factCheck.claims[0].sources.isNotEmpty) {
        print(
          '  - first source authority: ${factCheck.claims[0].sources[0].authorityLevel}',
        );
      }
    }

    final fcResults = fc.FactCheckResults(
      checked: factCheck.checked,
      claims: factCheck.claims.map<fc.FactCheckClaim>((claim) {
        final sourcesList = claim.sources
            .map(
              (s) => fc.FactCheckSource(
                url: s.url,
                title: s.title,
                snippet: s.snippet,
                domain: s.domain,
                authorityLevel: s.authorityLevel,
              ),
            )
            .toList();

        return fc.FactCheckClaim(
          claim: claim.claim,
          verified: claim.verified,
          source: claim.source,
          confidence: claim.confidence,
          sources: sourcesList,
          evidence: claim.evidence,
        );
      }).toList(),
      claimsFound: factCheck.claimsFound,
      claimsVerified: factCheck.claimsVerified,
      overallConfidence: factCheck.overallConfidence,
      verificationTime: factCheck.verificationTime,
      totalSearchesUsed: factCheck.totalSearchesUsed,
    );

    // Display actual fact-check results with credibility badge
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fact-Checked by Google Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E88E5), // Google Blue
                Color(0xFF00ACC1), // Google Cyan
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E88E5).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Google Search Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fact_check_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✓ Fact-Checked by Google Search',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '${factCheck.claims.length} claims verified • ${(factCheck.verificationTime).toStringAsFixed(1)}s verification time',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              // Verified Count Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${factCheck.claims.whereType<FactCheckClaim>().where((c) => c.verified).length}/${factCheck.claims.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(16),
        // Original Fact Check Panel
        FactCheckResultsPanel(
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
        ),
      ],
    );
  }

  // Helper method to build metadata chips
  Widget _buildMetadataChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const Gap(6),
          BodyTextSmall('$label: ', color: AppTheme.textSecondary),
          BodyTextSmall(value, color: color),
        ],
      ),
    );
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    // Ensure we're comparing in the same timezone (UTC)
    final now = DateTime.now().toUtc();
    final dateUtc = date.toUtc();
    final difference = now.difference(dateUtc);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      // Show local time for older dates
      final localDate = date.toLocal();
      return '${localDate.day}/${localDate.month}/${localDate.year}';
    }
  }

  Widget _buildRegenerationPrompt(BuildContext context) {
    return Obx(() {
      final qualityScore = controller.currentQualityScore.value;
      final attempts = controller.regenerationAttempts.value;
      final maxAttempts = controller.maxRegenerationAttempts;

      // Only show if quality is low and we haven't hit max attempts
      if (qualityScore == null ||
          qualityScore.shouldRegenerate != true ||
          attempts >= maxAttempts) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.1),
              borderRadius: AppTheme.borderRadiusLG,
              border: Border.all(
                color: AppTheme.warning.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.auto_fix_high,
                        color: AppTheme.warning,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          H3('Quality Below Threshold'),
                          const Gap(4),
                          BodyTextSmall(
                            'This content scored ${qualityScore.displayPercentage}% (Grade: ${qualityScore.displayGrade}). Would you like to regenerate for better quality?',
                            color: AppTheme.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: 'Keep Current',
                        onPressed: () {
                          controller.resetRegenerationAttempts();
                        },
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        text:
                            'Regenerate Content (${attempts + 1}/$maxAttempts)',
                        icon: Icons.refresh,
                        onPressed: () async {
                          await controller.regenerateContent(context);
                        },
                      ),
                    ),
                  ],
                ),
                if (attempts > 0) ...[
                  const Gap(12),
                  BodyTextSmall(
                    'Attempt ${attempts + 1} of $maxAttempts',
                    color: AppTheme.textSecondary,
                  ),
                ],
              ],
            ),
          ),
          const Gap(24),
        ],
      );
    });
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
          // Show persistent results panel ABOVE content when humanized
          if (isHumanized) ...[
            HumanizationResultsPanel(
              result: humanizationController.humanizationResult.value!,
              onCopy: () {
                Get.snackbar(
                  'Copied',
                  'Humanized content copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
              onTryAgain: () => _showHumanizationModal(context, content.id),
              onKeepOriginal: () {
                // Undo humanization - restore original content
                final originalContent = humanizationController
                    .humanizationResult
                    .value
                    ?.originalContent;
                if (originalContent != null) {
                  controller.generatedContent.value = content.copyWith(
                    content: originalContent,
                  );
                }
                humanizationController.resetState();
                Get.snackbar(
                  'Restored',
                  'Original content restored. You can humanize again if needed.',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 3),
                );
              },
              onUseHumanized: () {
                // Replace displayed content with humanized version
                final humanizedContent = humanizationController
                    .humanizationResult
                    .value
                    ?.humanizedContent;
                if (humanizedContent != null) {
                  // Create updated content object with humanized text
                  controller.generatedContent.value = content.copyWith(
                    content: humanizedContent,
                  );
                  Get.snackbar(
                    'Applied',
                    'Humanized content is now displayed. Your content now has ${humanizationController.humanizationResult.value!.afterScore.toInt()}% AI detection!',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 3),
                  );
                }
              },
            ),
            const Gap(24),
          ],

          // Show progress indicator during humanization
          if (isHumanizing) ...[
            HumanizationProgressIndicator(
              currentStep: humanizationController.currentStep.value,
            ),
            const Gap(24),
          ],

          // Quota warning banner (show when near limit and not humanized)
          if (humanizationController.isNearLimit &&
              !isHumanized &&
              !isHumanizing) ...[
            QuotaWarningBanner(
              used: humanizationController.humanizationsUsed.value,
              limit: humanizationController.humanizationsLimit.value,
              onUpgrade: () {
                // TODO: Navigate to pricing page
                Get.snackbar(
                  'Upgrade',
                  'Upgrade your plan for more humanizations',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            const Gap(12),
          ],

          // Show humanize button BELOW content when not humanized
          if (!isHumanized && !isHumanizing) ...[
            HumanizeButton(
              generationId: content.id,
              quotaText: humanizationController.quotaText,
              hasQuota: humanizationController.hasQuota,
              onPressed: () => _showHumanizationModal(context, content.id),
              isEnabled: true,
              disabledTooltip: humanizationController.hasQuota
                  ? null
                  : 'Quota exceeded. Upgrade to continue humanizing.',
            ),
            const Gap(24),
          ],
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
          final content = controller.generatedContent.value;
          if (content != null) {
            await humanizationController.humanizeContent(
              generationId,
              content.content,
            );
          }
        },
      ),
    );
  }
}
