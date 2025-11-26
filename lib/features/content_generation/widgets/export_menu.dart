import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/content_generation_controller.dart';

/// Export Menu Widget
/// Dropdown menu for exporting content in different formats
class ExportMenu extends GetView<ContentGenerationController> {
  const ExportMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (format) => controller.exportContent(format),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'PDF',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, size: 20),
              SizedBox(width: 12),
              BodyText('Export as PDF'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'DOCX',
          child: Row(
            children: [
              Icon(Icons.description, size: 20),
              SizedBox(width: 12),
              BodyText('Export as DOCX'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'HTML',
          child: Row(
            children: [
              Icon(Icons.code, size: 20),
              SizedBox(width: 12),
              BodyText('Export as HTML'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'Markdown',
          child: Row(
            children: [
              Icon(Icons.notes, size: 20),
              SizedBox(width: 12),
              BodyText('Export as Markdown'),
            ],
          ),
        ),
      ],
      child: SecondaryButton(
        text: 'Export',
        icon: Icons.download,
        onPressed: () {}, // Menu handles the action
      ),
    );
  }
}
