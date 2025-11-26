import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/constants/font_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/landing_controller.dart';

/// Testimonials Section
/// Carousel with testimonial cards and navigation
class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LandingController>();
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
              H1('What Our Users Say', textAlign: TextAlign.center),
              Gap(AppTheme.spacing16),
              BodyTextLarge(
                'Join thousands of satisfied content creators',
                color: AppTheme.textSecondary,
                textAlign: TextAlign.center,
              ),
              Gap(AppTheme.spacing48),
              Obx(() {
                return Column(
                  children: [
                    _buildTestimonialCard(
                      _testimonials()[controller.currentTestimonialIndex.value],
                    ),
                    Gap(AppTheme.spacing32),
                    _buildNavigation(controller),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(_Testimonial testimonial) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      constraints: const BoxConstraints(maxWidth: 800),
      padding: EdgeInsets.all(AppTheme.spacing32),
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        borderRadius: AppTheme.borderRadiusLG,
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowMD,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
            child: Icon(Icons.person, size: 32, color: AppTheme.primary),
          ),
          Gap(AppTheme.spacing16),
          H3(testimonial.name, textAlign: TextAlign.center),
          CaptionText(testimonial.role, color: AppTheme.textSecondary),
          Gap(AppTheme.spacing12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Icon(Icons.star, size: 20, color: AppTheme.warning),
            ),
          ),
          Gap(AppTheme.spacing16),
          BodyText(
            '"${testimonial.quote}"',
            textAlign: TextAlign.center,
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(LandingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: controller.previousTestimonial,
          icon: Icon(Icons.arrow_back),
          color: AppTheme.primary,
        ),
        Gap(AppTheme.spacing16),
        Row(
          children: List.generate(
            controller.testimonialCount,
            (index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
              child: GestureDetector(
                onTap: () => controller.goToTestimonial(index),
                child: Obx(() {
                  final isActive =
                      controller.currentTestimonialIndex.value == index;
                  return Container(
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primary : AppTheme.neutral200,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        Gap(AppTheme.spacing16),
        IconButton(
          onPressed: controller.nextTestimonial,
          icon: Icon(Icons.arrow_forward),
          color: AppTheme.primary,
        ),
      ],
    );
  }

  List<_Testimonial> _testimonials() {
    return [
      _Testimonial(
        name: 'Sarah Chen',
        role: 'Content Director',
        quote:
            'Finally, an AI writer I don\'t have to babysit. The fact-checking feature saves me hours of research time every week.',
      ),
      _Testimonial(
        name: 'Michael Rodriguez',
        role: 'Marketing Manager',
        quote:
            'Our content passes all AI detection tools now. The quality is consistently high, and our engagement has doubled.',
      ),
      _Testimonial(
        name: 'Emily Watson',
        role: 'Freelance Writer',
        quote:
            'I was skeptical at first, but the quality guarantee convinced me to try it. Now I can\'t work without it.',
      ),
      _Testimonial(
        name: 'David Kim',
        role: 'SEO Specialist',
        quote:
            'The multilingual support is a game-changer. We create content in 15 languages and the quality is the same across all of them.',
      ),
    ];
  }
}

class _Testimonial {
  final String name;
  final String role;
  final String quote;

  _Testimonial({required this.name, required this.role, required this.quote});
}
