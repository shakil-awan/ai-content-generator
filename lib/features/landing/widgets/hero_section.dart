import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/font_sizes.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';

/// Hero Section - Landing Page
/// Responsive gradient background with headline, CTA buttons, and hero image
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < FontSizes.mobileBreakpoint;
    final isTablet =
        screenWidth >= FontSizes.mobileBreakpoint &&
        screenWidth < FontSizes.tabletBreakpoint;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: isMobile ? 600 : MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primary.withValues(alpha: 0.8),
            Color(0xFF93C5FD), // Light blue
          ],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1440),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? AppTheme.spacing16 : AppTheme.spacing48,
            vertical: AppTheme.spacing64,
          ),
          child: isMobile
              ? _buildMobileLayout()
              : _buildDesktopLayout(isTablet),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBadge(),
        Gap(AppTheme.spacing24),
        _buildHeadline(60),
        Gap(AppTheme.spacing16),
        _buildSubheadline(),
        Gap(AppTheme.spacing32),
        _buildCTAButtons(true),
        Gap(AppTheme.spacing48),
        _buildHeroImage(),
      ],
    );
  }

  Widget _buildDesktopLayout(bool isTablet) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(),
              Gap(AppTheme.spacing24),
              _buildHeadline(isTablet ? 48 : 60),
              Gap(AppTheme.spacing16),
              _buildSubheadline(),
              Gap(AppTheme.spacing32),
              _buildCTAButtons(false),
            ],
          ),
        ),
        Gap(AppTheme.spacing64),
        Expanded(flex: 5, child: _buildHeroImage()),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.2),
        border: Border.all(color: AppTheme.accent),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars, size: 16, color: AppTheme.accent),
          Gap(AppTheme.spacing8),
          Text(
            'New: AI Detection Bypass 2.0 is Live',
            style: TextStyle(
              fontSize: FontSizes.bodySmall,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline(double fontSize) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: FontSizes.lineHeightTight,
        ),
        children: [
          const TextSpan(text: 'Generate '),
          TextSpan(
            text: 'Verified Content',
            style: TextStyle(color: AppTheme.accent),
          ),
          const TextSpan(text: '\nin Minutes'),
        ],
      ),
    );
  }

  Widget _buildSubheadline() {
    return BodyTextLarge(
      'Create AI-powered content with built-in fact-checking and humanization. '
      'No more flagged posts or hours of manual verification.',
      color: Colors.white.withValues(alpha: 0.95),
    );
  }

  Widget _buildCTAButtons(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Builder(
              builder: (context) => PrimaryButton(
                text: 'Start For Free',
                onPressed: () => context.go(AppRouter.signUp),
                icon: Icons.arrow_forward,
                width: double.infinity,
              ),
            ),
          ),
          Gap(AppTheme.spacing16),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: SecondaryButton(
              text: 'Watch Demo',
              onPressed: () {
                // Play demo video
              },
              icon: Icons.play_circle_outline,
              width: double.infinity,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Builder(
            builder: (context) => PrimaryButton(
              text: 'Start For Free',
              onPressed: () => context.go(AppRouter.signUp),
              icon: Icons.arrow_forward,
            ),
          ),
        ),
        Gap(AppTheme.spacing16),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: SecondaryButton(
            text: 'Watch Demo',
            onPressed: () {
              // Play demo video
            },
            icon: Icons.play_circle_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: AppTheme.borderRadiusXL,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          ),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: child,
                  ),
                );
              },
              child: Icon(
                Icons.dashboard_rounded,
                size: 120,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
