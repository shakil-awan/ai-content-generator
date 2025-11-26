import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/font_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Content Types Section
/// Displays 6 content type cards in a responsive grid
class ContentTypesSection extends StatelessWidget {
  const ContentTypesSection({super.key});

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
          child: Column(
            children: [
              H1('Create Any Type of Content', textAlign: TextAlign.center),
              Gap(AppTheme.spacing16),
              BodyTextLarge(
                'From blog posts to video scripts, we\'ve got you covered',
                color: AppTheme.textSecondary,
                textAlign: TextAlign.center,
              ),
              Gap(AppTheme.spacing48),
              isMobile ? _buildMobileScroll() : _buildDesktopGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileScroll() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _contentTypes()
            .map(
              (type) => Padding(
                padding: EdgeInsets.only(right: AppTheme.spacing16),
                child: _buildContentCard(type),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDesktopGrid() {
    return Wrap(
      spacing: AppTheme.spacing24,
      runSpacing: AppTheme.spacing24,
      alignment: WrapAlignment.center,
      children: _contentTypes().map((type) => _buildContentCard(type)).toList(),
    );
  }

  List<_ContentType> _contentTypes() {
    return [
      _ContentType(
        icon: Icons.article,
        title: 'Blog Posts',
        example: 'SEO-optimized articles with fact-checked claims',
      ),
      _ContentType(
        icon: Icons.tag,
        title: 'Social Media Captions',
        example: 'Engaging posts that pass AI detection',
      ),
      _ContentType(
        icon: Icons.email,
        title: 'Email Campaigns',
        example: 'Persuasive copy that converts',
      ),
      _ContentType(
        icon: Icons.shopping_bag,
        title: 'Product Descriptions',
        example: 'Compelling descriptions that sell',
      ),
      _ContentType(
        icon: Icons.campaign,
        title: 'Ad Copy',
        example: 'High-converting ad content',
      ),
      _ContentType(
        icon: Icons.videocam,
        title: 'Video Scripts',
        example: 'Engaging scripts for your videos',
      ),
    ];
  }

  Widget _buildContentCard(_ContentType type) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 280,
        padding: EdgeInsets.all(AppTheme.spacing24),
        decoration: BoxDecoration(
          color: AppTheme.bgPrimary,
          borderRadius: AppTheme.borderRadiusLG,
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.shadowSM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: Icon(type.icon, size: 48, color: AppTheme.primary),
            ),
            Gap(AppTheme.spacing16),
            H3(type.title),
            Gap(AppTheme.spacing8),
            BodyTextSmall(type.example, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ContentType {
  final IconData icon;
  final String title;
  final String example;

  _ContentType({
    required this.icon,
    required this.title,
    required this.example,
  });
}
