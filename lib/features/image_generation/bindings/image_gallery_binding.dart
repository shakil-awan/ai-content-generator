import 'package:get/get.dart';

import '../controllers/image_gallery_controller.dart';

/// Image Gallery Binding
/// Sets up dependencies for image gallery feature
class ImageGalleryBinding extends Bindings {
  @override
  void dependencies() {
    // Register ImageGalleryController
    Get.lazyPut<ImageGalleryController>(() => ImageGalleryController());
  }
}
