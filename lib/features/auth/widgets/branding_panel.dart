import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Branding panel for authentication pages
///
/// Shows app logo, tagline, and gradient background
class BrandingPanel extends StatelessWidget {
  const BrandingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.secondary],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Icon(Icons.auto_awesome, size: 64, color: Colors.white),
              Gap(AppTheme.spacing24),

              // App name
              H1('AI Content Generator', color: Colors.white),
              Gap(AppTheme.spacing16),

              // Tagline
              BodyText(
                'Create engaging content in seconds with the power of AI',
                color: Colors.white.withValues(alpha: 0.9),
              ),
              Gap(AppTheme.spacing64),

              // Features list
              _buildFeatureItem(
                icon: Icons.bolt,
                text: '10x faster content creation',
              ),
              Gap(AppTheme.spacing16),
              _buildFeatureItem(
                icon: Icons.verified,
                text: 'Professional quality guaranteed',
              ),
              Gap(AppTheme.spacing16),
              _buildFeatureItem(
                icon: Icons.trending_up,
                text: 'Boost your engagement',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.white),
        Gap(AppTheme.spacing8),
        Expanded(
          child: BodyText(text, color: Colors.white.withValues(alpha: 0.9)),
        ),
      ],
    );
  }
}
