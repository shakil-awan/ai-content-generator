import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/font_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Problem/Solution Section
/// Compares current AI problems with Summarly solutions
class ProblemSolutionSection extends StatelessWidget {
  const ProblemSolutionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < FontSizes.mobileBreakpoint;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppTheme.spacing16 : AppTheme.spacing48,
        vertical: AppTheme.spacing64,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildProblemCard(),
        Gap(AppTheme.spacing24),
        _buildSolutionCard(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildProblemCard()),
        Gap(AppTheme.spacing32),
        Expanded(child: _buildSolutionCard()),
      ],
    );
  }

  Widget _buildProblemCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(AppTheme.spacing32),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.05),
        border: Border.all(
          color: AppTheme.error.withValues(alpha: 0.3),
          width: 2,
        ),
        borderRadius: AppTheme.borderRadiusLG,
        boxShadow: [
          BoxShadow(
            color: AppTheme.error.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          H2('The Problem', color: AppTheme.error),
          Gap(AppTheme.spacing8),
          BodyTextSmall('Current AI Tools', color: AppTheme.textSecondary),
          Gap(AppTheme.spacing24),
          _buildProblemItem('AI content gets flagged as fake or spam'),
          Gap(AppTheme.spacing16),
          _buildProblemItem(
            'Fact-checking requires hours of manual Google searches',
          ),
          Gap(AppTheme.spacing16),
          _buildProblemItem('Quality is inconsistent and often repetitive'),
        ],
      ),
    );
  }

  Widget _buildSolutionCard() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing32),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        border: Border.all(color: AppTheme.primary, width: 2),
        borderRadius: AppTheme.borderRadiusLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          H2('The Solution', color: AppTheme.primary),
          Gap(AppTheme.spacing8),
          BodyTextSmall('Summarly', color: AppTheme.primary),
          Gap(AppTheme.spacing24),
          _buildSolutionItem('Built-in AI Humanizer bypasses detection tools'),
          Gap(AppTheme.spacing16),
          _buildSolutionItem(
            'Automatic real-time fact-checking against trusted sources',
          ),
          Gap(AppTheme.spacing16),
          _buildSolutionItem(
            'Quality guarantee: instant rewrite or your money back',
          ),
        ],
      ),
    );
  }

  Widget _buildProblemItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.close, color: AppTheme.error, size: 24),
        Gap(AppTheme.spacing12),
        Expanded(child: BodyText(text)),
      ],
    );
  }

  Widget _buildSolutionItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: AppTheme.success, size: 24),
        Gap(AppTheme.spacing12),
        Expanded(child: BodyText(text)),
      ],
    );
  }
}
