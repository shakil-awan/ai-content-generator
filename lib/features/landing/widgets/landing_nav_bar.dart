import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/font_sizes.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';

/// Navigation Bar for Landing Page
class LandingNavBar extends StatelessWidget {
  const LandingNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < FontSizes.mobileBreakpoint;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppTheme.spacing16 : AppTheme.spacing48,
        vertical: AppTheme.spacing16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppTheme.primary, size: 28),
              Gap(AppTheme.spacing8),
              H2('Summarly'),
            ],
          ),

          // Navigation buttons
          Row(
            children: [
              if (!isMobile) ...[
                // Try Demo Button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: TextButton.icon(
                    onPressed: () => context.go(AppRouter.home),
                    icon: const Icon(Icons.dashboard, size: 18),
                    label: const BodyText('Try Demo'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                    ),
                  ),
                ),
                Gap(AppTheme.spacing8),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: TextButton(
                    onPressed: () => context.go(AppRouter.signIn),
                    child: const BodyText('Sign In'),
                  ),
                ),
                Gap(AppTheme.spacing8),
              ],
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: PrimaryButton(
                  text: isMobile ? 'Sign Up' : 'Get Started',
                  onPressed: () => context.go(AppRouter.signUp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
