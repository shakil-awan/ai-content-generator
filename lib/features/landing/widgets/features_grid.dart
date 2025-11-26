import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/font_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Features Grid Section
/// Displays 4 feature cards in a responsive grid
class FeaturesGrid extends StatelessWidget {
  const FeaturesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < FontSizes.mobileBreakpoint;
    final isTablet =
        screenWidth >= FontSizes.mobileBreakpoint &&
        screenWidth < FontSizes.tabletBreakpoint;

    return Container(
      width: double.infinity,
      color: AppTheme.bgSecondary,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppTheme.spacing16 : AppTheme.spacing48,
        vertical: AppTheme.spacing64,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            children: [
              H1('Powerful Features', textAlign: TextAlign.center),
              Gap(AppTheme.spacing16),
              BodyTextLarge(
                'Everything you need to create verified, human-like content',
                color: AppTheme.textSecondary,
                textAlign: TextAlign.center,
              ),
              Gap(AppTheme.spacing48),
              _buildFeaturesGrid(isMobile, isTablet, screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid(bool isMobile, bool isTablet, double screenWidth) {
    final features = [
      _FeatureData(
        icon: Icons.shield,
        iconColor: AppTheme.primary,
        title: 'Fact-Checking Layer',
        description:
            'Automatic verification against trusted sources. Every claim is cross-referenced in real-time.',
      ),
      _FeatureData(
        icon: Icons.bolt,
        iconColor: AppTheme.error,
        title: 'AI Detection Bypass',
        description:
            'Advanced humanization that passes all major AI detection tools. Your content reads naturally.',
      ),
      _FeatureData(
        icon: Icons.check_circle,
        iconColor: AppTheme.success,
        title: 'Quality Guarantee',
        description:
            'Not satisfied? Get an instant rewrite or your money back. We stand behind our content.',
      ),
      _FeatureData(
        icon: Icons.language,
        iconColor: AppTheme.accent,
        title: 'Multilingual Support',
        description:
            'Create content in 50+ languages with the same quality standards and fact-checking.',
      ),
    ];

    if (isMobile) {
      return Column(
        children: features
            .map(
              (feature) => Padding(
                padding: EdgeInsets.only(bottom: AppTheme.spacing24),
                child: _buildFeatureCard(feature),
              ),
            )
            .toList(),
      );
    }

    if (isTablet) {
      return Wrap(
        spacing: AppTheme.spacing24,
        runSpacing: AppTheme.spacing24,
        children: features
            .map(
              (feature) => SizedBox(
                width:
                    (screenWidth -
                        AppTheme.spacing48 * 2 -
                        AppTheme.spacing24) /
                    2,
                child: _buildFeatureCard(feature),
              ),
            )
            .toList(),
      );
    }

    return Wrap(
      spacing: AppTheme.spacing24,
      runSpacing: AppTheme.spacing24,
      children: features.map((feature) => _buildFeatureCard(feature)).toList(),
    );
  }

  Widget _buildFeatureCard(_FeatureData feature) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 300,
        padding: EdgeInsets.all(AppTheme.spacing32),
        decoration: BoxDecoration(
          color: AppTheme.bgPrimary,
          borderRadius: AppTheme.borderRadiusLG,
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.shadowMD,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: feature.iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(feature.icon, color: feature.iconColor, size: 28),
            ),
            Gap(AppTheme.spacing24),
            H3(feature.title),
            Gap(AppTheme.spacing12),
            BodyText(feature.description, color: AppTheme.textSecondary),
            Gap(AppTheme.spacing16),
            Row(
              children: [
                Text(
                  'Learn More',
                  style: TextStyle(
                    fontSize: FontSizes.bodyRegular,
                    color: feature.iconColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap(AppTheme.spacing4),
                Icon(Icons.arrow_forward, color: feature.iconColor, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  _FeatureData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}
