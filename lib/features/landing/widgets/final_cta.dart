import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/font_sizes.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Final CTA Section
/// Full-width call-to-action with gradient background
class FinalCTA extends StatelessWidget {
  const FinalCTA({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < FontSizes.mobileBreakpoint;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primary.withValues(alpha: 0.8),
            Color(0xFF93C5FD),
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppTheme.spacing16 : AppTheme.spacing48,
        vertical: AppTheme.spacing64,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              H1(
                'Ready to create verified content?',
                color: Colors.white,
                textAlign: TextAlign.center,
              ),
              Gap(AppTheme.spacing16),
              BodyTextLarge(
                'Join thousands of content creators using Summarly',
                color: Colors.white.withValues(alpha: 0.95),
                textAlign: TextAlign.center,
              ),
              Gap(AppTheme.spacing32),
              Container(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 300,
                ),
                child: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => context.go(AppRouter.signUp),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      elevation: 8,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing32,
                        vertical: AppTheme.spacing24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.borderRadiusMD,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started Free',
                          style: TextStyle(
                            fontSize: FontSizes.buttonLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Gap(AppTheme.spacing8),
                        Icon(Icons.arrow_forward, size: 24),
                      ],
                    ),
                  ),
                ),
              ),
              Gap(AppTheme.spacing16),
              CaptionText(
                'No credit card required',
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
