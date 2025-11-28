import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/font_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Trust Bar Section
/// Shows social proof with company logos and ratings
class TrustBar extends StatelessWidget {
  const TrustBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < FontSizes.mobileBreakpoint;

    return Container(
      width: double.infinity,
      color: AppTheme.bgSecondary,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppTheme.spacing16 : AppTheme.spacing48,
        vertical: AppTheme.spacing48,
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
        BodyText(
          'Join 5,000+ content creators',
          color: AppTheme.textSecondary,
          textAlign: TextAlign.center,
        ),
        Gap(AppTheme.spacing24),
        _buildLogos(true),
        Gap(AppTheme.spacing24),
        _buildRating(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: BodyText(
            'Join 5,000+ content creators',
            color: AppTheme.textSecondary,
          ),
        ),
        Flexible(flex: 2, child: _buildLogos(false)),
        Flexible(child: _buildRating()),
      ],
    );
  }

  Widget _buildLogos(bool isMobile) {
    final logos = [
      'Jitter',
      'Krisp',
      'Feedly',
      'Draftbit',
      'Hellosign',
      'Grammarly',
    ];

    return Wrap(
      spacing: isMobile ? AppTheme.spacing16 : AppTheme.spacing32,
      runSpacing: AppTheme.spacing16,
      alignment: WrapAlignment.center,
      children: logos.map((logo) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 120,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.neutral200,
              borderRadius: AppTheme.borderRadiusMD,
            ),
            child: Center(
              child: Text(
                logo,
                style: TextStyle(
                  fontSize: FontSizes.bodySmall,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(
            5,
            (index) => Icon(Icons.star, size: 20, color: AppTheme.warning),
          ),
        ),
        Gap(AppTheme.spacing8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BodyText('4.8/5', fontWeight: FontWeight.w600),
            CaptionText('Based on 500+ reviews', color: AppTheme.textSecondary),
          ],
        ),
      ],
    );
  }
}
