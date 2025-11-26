import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/controllers.dart';
import '../widgets/widgets.dart';

/// Landing Page - Main entry point
/// Assembles all 10 sections with proper spacing
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 400 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 400 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.put(LandingController());

    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
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
      floatingActionButton: AnimatedOpacity(
        opacity: _showScrollToTop ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: _showScrollToTop
            ? FloatingActionButton(
                onPressed: _scrollToTop,
                backgroundColor: AppTheme.primary,
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
