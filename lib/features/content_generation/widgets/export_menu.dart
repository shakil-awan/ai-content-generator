import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/custom_buttons.dart';
import '../controllers/content_generation_controller.dart';

/// Export Button Widget
/// Triggers PDF export with a single click
class ExportMenu extends GetView<ContentGenerationController> {
  final double? width;

  const ExportMenu({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PrimaryButton(
        text: 'Export',
        icon: Icons.download,
        width: width,
        isLoading: controller.isExportingPdf.value,
        onPressed: controller.exportContentAsPdf,
      ),
    );
  }
}
