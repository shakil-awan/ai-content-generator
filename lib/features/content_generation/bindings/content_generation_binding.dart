import 'package:get/get.dart';

import '../../../core/services/api_service.dart';
import '../../image_generation/controllers/image_generation_controller.dart';
import '../../quality_guarantee/services/quality_service.dart';
import '../controllers/content_generation_controller.dart';
import '../services/content_generation_service.dart';

/// Content Generation Binding
/// Sets up dependencies for content generation feature
class ContentGenerationBinding extends Bindings {
  @override
  void dependencies() {
    // Register ApiService singleton if not already registered
    if (!Get.isRegistered<ApiService>()) {
      Get.put<ApiService>(ApiService(), permanent: true);
    }

    // Register QualityService
    if (!Get.isRegistered<QualityService>()) {
      Get.lazyPut<QualityService>(() => QualityService(Get.find<ApiService>()));
    }

    // Register ContentGenerationService
    Get.lazyPut<ContentGenerationService>(
      () => ContentGenerationService(apiService: Get.find<ApiService>()),
    );

    // Register ContentGenerationController
    Get.lazyPut<ContentGenerationController>(
      () => ContentGenerationController(Get.find()),
    );

    // Register ImageGenerationController for AI Image generation
    Get.lazyPut<ImageGenerationController>(() => ImageGenerationController());
  }
}
