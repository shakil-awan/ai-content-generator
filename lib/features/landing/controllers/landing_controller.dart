import 'dart:async';

import 'package:get/get.dart';

/// Landing Page Controller
/// Manages state for carousel, accordion, and smooth scrolling
class LandingController extends GetxController {
  // Testimonial carousel state
  final currentTestimonialIndex = 0.obs;
  final testimonialCount = 4;
  Timer? _carouselTimer;

  // FAQ accordion state
  final expandedFaqIndices = <int>{0}.obs; // First item expanded by default

  @override
  void onInit() {
    super.onInit();
    _startCarouselAutoPlay();
  }

  @override
  void onClose() {
    _carouselTimer?.cancel();
    super.onClose();
  }

  // Testimonial Carousel Methods
  void _startCarouselAutoPlay() {
    _carouselTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => nextTestimonial(),
    );
  }

  void nextTestimonial() {
    currentTestimonialIndex.value =
        (currentTestimonialIndex.value + 1) % testimonialCount;
  }

  void previousTestimonial() {
    currentTestimonialIndex.value =
        (currentTestimonialIndex.value - 1 + testimonialCount) %
        testimonialCount;
  }

  void goToTestimonial(int index) {
    currentTestimonialIndex.value = index;
    // Reset timer when manually navigating
    _carouselTimer?.cancel();
    _startCarouselAutoPlay();
  }

  // FAQ Accordion Methods
  void toggleFaq(int index) {
    if (expandedFaqIndices.contains(index)) {
      expandedFaqIndices.remove(index);
    } else {
      expandedFaqIndices.add(index);
    }
  }

  bool isFaqExpanded(int index) {
    return expandedFaqIndices.contains(index);
  }
}
