import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/image_generation_controller.dart';
import 'batch_results_gallery.dart';
import 'image_result_display.dart';

/// Full-Width Results Wrapper
/// This widget displays image generation results and breaks out of the constrained container
/// to provide full-width display for batch image galleries
class ImageGenerationResultsWrapper extends StatelessWidget {
  const ImageGenerationResultsWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Single image result display (constrained width for better readability)
        const _SingleImageResultWrapper(),

        // Batch results (full width for grid layout)
        const BatchResultsGallery(),
      ],
    );
  }
}

/// Wrapper for single image results with max width constraint
class _SingleImageResultWrapper extends StatelessWidget {
  const _SingleImageResultWrapper();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageGenerationController>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      final response = controller.imageResponse.value;
      if (response == null) return const SizedBox.shrink();

      // Responsive padding - full width on mobile, comfortable padding on desktop
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth > 1600
              ? 64
              : screenWidth > 1200
              ? 48
              : screenWidth > 768
              ? 32
              : 16,
        ),
        child: const ImageResultDisplay(),
      );
    });
  }
}
