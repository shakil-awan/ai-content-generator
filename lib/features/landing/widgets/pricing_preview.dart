import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/constants/font_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';

/// Pricing Preview Section
/// Displays 3 pricing cards with features
class PricingPreview extends StatelessWidget {
  const PricingPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < FontSizes.mobileBreakpoint;

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
              H1('Simple, Transparent Pricing', textAlign: TextAlign.center),
              Gap(AppTheme.spacing16),
              BodyTextLarge(
                'Start free, upgrade when you need more',
                color: AppTheme.textSecondary,
                textAlign: TextAlign.center,
              ),
              Gap(AppTheme.spacing48),
              isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
              Gap(AppTheme.spacing32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Full Comparison Table',
                    style: TextStyle(
                      fontSize: FontSizes.bodyRegular,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap(AppTheme.spacing4),
                  Icon(Icons.arrow_forward, color: AppTheme.primary, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildPricingCard(_freePlan(), false),
        Gap(AppTheme.spacing24),
        _buildPricingCard(_hobbyPlan(), false),
        Gap(AppTheme.spacing24),
        _buildPricingCard(_proPlan(), true),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildPricingCard(_freePlan(), false)),
        Gap(AppTheme.spacing24),
        Expanded(child: _buildPricingCard(_hobbyPlan(), false)),
        Gap(AppTheme.spacing24),
        Expanded(child: _buildPricingCard(_proPlan(), true)),
      ],
    );
  }

  Widget _buildPricingCard(_PricingPlan plan, bool isPopular) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(AppTheme.spacing32),
        decoration: BoxDecoration(
          color: AppTheme.bgPrimary,
          borderRadius: AppTheme.borderRadiusLG,
          border: Border.all(
            color: isPopular ? AppTheme.primary : AppTheme.border,
            width: isPopular ? 2 : 1,
          ),
          boxShadow: isPopular ? AppTheme.shadowLG : AppTheme.shadowMD,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing12,
                  vertical: AppTheme.spacing4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    fontSize: FontSizes.captionRegular,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (isPopular) Gap(AppTheme.spacing16),
            H2(plan.name),
            Gap(AppTheme.spacing8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${plan.price}',
                  style: TextStyle(
                    fontSize: FontSizes.displayMedium,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Gap(AppTheme.spacing4),
                Padding(
                  padding: EdgeInsets.only(top: AppTheme.spacing8),
                  child: BodyTextSmall('/month', color: AppTheme.textSecondary),
                ),
              ],
            ),
            Gap(AppTheme.spacing24),
            ...plan.features.map((feature) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppTheme.spacing12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                    Gap(AppTheme.spacing8),
                    Expanded(child: BodyTextSmall(feature)),
                  ],
                ),
              );
            }),
            Gap(AppTheme.spacing24),
            plan.isPrimary
                ? PrimaryButton(
                    text: 'Get Started',
                    onPressed: () {},
                    width: double.infinity,
                  )
                : SecondaryButton(
                    text: 'Get Started',
                    onPressed: () {},
                    width: double.infinity,
                  ),
          ],
        ),
      ),
    );
  }

  _PricingPlan _freePlan() {
    return _PricingPlan(
      name: 'Free',
      price: 0,
      features: [
        '2,000 Words/mo',
        'Basic Fact Checking',
        '1 Project Folder',
        'Email Support',
      ],
      isPrimary: false,
    );
  }

  _PricingPlan _hobbyPlan() {
    return _PricingPlan(
      name: 'Hobby',
      price: 9,
      features: [
        '20,000 Words/mo',
        'Advanced Fact Checking',
        'AI Humanizer',
        'Priority Support',
      ],
      isPrimary: true,
    );
  }

  _PricingPlan _proPlan() {
    return _PricingPlan(
      name: 'Pro',
      price: 29,
      features: [
        'Unlimited Words',
        'Deep Research Mode',
        'API Access',
        'Dedicated Account Manager',
      ],
      isPrimary: true,
    );
  }
}

class _PricingPlan {
  final String name;
  final int price;
  final List<String> features;
  final bool isPrimary;

  _PricingPlan({
    required this.name,
    required this.price,
    required this.features,
    required this.isPrimary,
  });
}
