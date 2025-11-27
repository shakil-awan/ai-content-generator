import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/controllers.dart';
import '../widgets/widgets.dart';

/// Landing Page Scroll Controller
class LandingPageScrollController extends GetxController {
  final showScrollToTop = false.obs;
  late final ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.offset > 400 && !showScrollToTop.value) {
      showScrollToTop.value = true;
    } else if (scrollController.offset <= 400 && showScrollToTop.value) {
      showScrollToTop.value = false;
    }
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }
}

/// Landing Page - Main entry point
/// Assembles all 10 sections with proper spacing
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(LandingController());
    final scrollController = Get.put(LandingPageScrollController());

    return Scaffold(
      body: SingleChildScrollView(
        controller: scrollController.scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Navigation Bar
            const LandingNavBar(),

            // Section 1: Hero
            const HeroSection(),

            // Section 2: Trust Bar
            const TrustBar(),

            // Section 3: Problem/Solution
            const ProblemSolutionSection(),

            Gap(AppTheme.spacing64),

            // Section 4: Features Grid
            const FeaturesGrid(),

            Gap(AppTheme.spacing64),

            // Section 5: Content Types
            const ContentTypesSection(),

            Gap(AppTheme.spacing64),

            // Section 6: Pricing Preview
            const PricingPreview(),

            Gap(AppTheme.spacing64),

            // Section 7: Testimonials
            const TestimonialsSection(),

            Gap(AppTheme.spacing64),

            // Section 8: FAQ
            const FAQSection(),

            Gap(AppTheme.spacing64),

            // Section 9: Final CTA
            const FinalCTA(),

            // Section 10: Footer
            const Footer(),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => AnimatedOpacity(
          opacity: scrollController.showScrollToTop.value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: scrollController.showScrollToTop.value
              ? FloatingActionButton(
                  onPressed: scrollController.scrollToTop,
                  backgroundColor: AppTheme.primary,
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
