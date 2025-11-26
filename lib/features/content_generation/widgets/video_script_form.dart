import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../video_generation/controllers/video_script_controller.dart';
import '../../video_generation/widgets/script_generation_form.dart';
import '../../video_generation/widgets/script_results_display.dart';

/// Video Script Form Widget
/// Integrates video script generation into content generation page
class VideoScriptForm extends StatelessWidget {
  const VideoScriptForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already done
    if (!Get.isRegistered<VideoScriptController>()) {
      Get.put(VideoScriptController());
    }

    final controller = Get.find<VideoScriptController>();

    return Obx(() {
      // Show results if script exists, otherwise show form
      if (controller.hasScript) {
        return const ScriptResultsDisplay();
      }

      return const ScriptGenerationForm();
    });
  }
}
