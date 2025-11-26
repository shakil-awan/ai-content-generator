import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/font_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';

/// Footer Section
/// 4-column layout with links, social icons, and subscribe
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < FontSizes.mobileBreakpoint;

    return Container(
      width: double.infinity,
      color: AppTheme.neutral900,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppTheme.spacing16 : AppTheme.spacing48,
        vertical: AppTheme.spacing64,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            children: [
              isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
              Gap(AppTheme.spacing48),
              Divider(color: Colors.white.withValues(alpha: 0.2)),
              Gap(AppTheme.spacing24),
              _buildBottomBar(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrand(),
        Gap(AppTheme.spacing32),
        _buildProductLinks(),
        Gap(AppTheme.spacing24),
        _buildResourcesLinks(),
        Gap(AppTheme.spacing24),
        _buildLegalLinks(),
        Gap(AppTheme.spacing24),
        _buildSubscribe(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildBrand()),
        Gap(AppTheme.spacing48),
        Expanded(child: _buildProductLinks()),
        Gap(AppTheme.spacing32),
        Expanded(child: _buildResourcesLinks()),
        Gap(AppTheme.spacing32),
        Expanded(child: _buildLegalLinks()),
        Gap(AppTheme.spacing32),
        Expanded(flex: 2, child: _buildSubscribe()),
      ],
    );
  }

  Widget _buildBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.primary, size: 32),
            Gap(AppTheme.spacing8),
            H2('Summarly', color: Colors.white),
          ],
        ),
        Gap(AppTheme.spacing16),
        BodyTextSmall(
          'AI-powered content generation with built-in fact-checking and humanization.',
          color: Colors.white.withValues(alpha: 0.7),
        ),
        Gap(AppTheme.spacing24),
        _buildSocialIcons(),
      ],
    );
  }

  Widget _buildProductLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product',
          style: TextStyle(
            fontSize: FontSizes.bodyRegular,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Gap(AppTheme.spacing16),
        _buildFooterLink('Features'),
        _buildFooterLink('Pricing'),
        _buildFooterLink('Integrations'),
        _buildFooterLink('Changelog'),
      ],
    );
  }

  Widget _buildResourcesLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resources',
          style: TextStyle(
            fontSize: FontSizes.bodyRegular,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Gap(AppTheme.spacing16),
        _buildFooterLink('Blog'),
        _buildFooterLink('Documentation'),
        _buildFooterLink('Community'),
        _buildFooterLink('API Docs'),
      ],
    );
  }

  Widget _buildLegalLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legal',
          style: TextStyle(
            fontSize: FontSizes.bodyRegular,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Gap(AppTheme.spacing16),
        _buildFooterLink('Privacy Policy'),
        _buildFooterLink('Terms of Service'),
        _buildFooterLink('Cookie Policy'),
      ],
    );
  }

  Widget _buildSubscribe() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stay Updated',
          style: TextStyle(
            fontSize: FontSizes.bodyRegular,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Gap(AppTheme.spacing16),
        BodyTextSmall(
          'Get the latest updates and tips delivered to your inbox.',
          color: Colors.white.withValues(alpha: 0.7),
        ),
        Gap(AppTheme.spacing16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            Gap(AppTheme.spacing8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: AppTheme.borderRadiusMD,
              ),
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing8),
      child: InkWell(
        onTap: () {},
        child: BodyTextSmall(text, color: Colors.white.withValues(alpha: 0.7)),
      ),
    );
  }

  Widget _buildSocialIcons() {
    final icons = [
      Icons.facebook,
      Icons.email, // Twitter placeholder
      Icons.camera_alt, // Instagram placeholder
      Icons.business, // LinkedIn placeholder
      Icons.play_circle, // YouTube placeholder
    ];

    return Row(
      children: icons.map((icon) {
        return Padding(
          padding: EdgeInsets.only(right: AppTheme.spacing12),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 18,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar(bool isMobile) {
    return Column(
      children: [
        CaptionText(
          '© 2025 Summarly. All rights reserved.',
          color: Colors.white.withValues(alpha: 0.5),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
      ],
    );
  }
}
