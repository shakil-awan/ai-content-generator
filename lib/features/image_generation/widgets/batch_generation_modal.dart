import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/image_generation_controller.dart';
import 'aspect_ratio_selector.dart';
import 'style_selector.dart';

/// Batch Generation Modal
/// Modal for generating multiple images at once
class BatchGenerationModal extends StatelessWidget {
  const BatchGenerationModal({super.key});

  static void show() {
    Get.dialog(const BatchGenerationModal(), barrierDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageGenerationController>();

    return Dialog(
      backgroundColor: AppTheme.bgPrimary,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusLG),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          final isGenerating = controller.isBatchGenerating.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const H2('Batch Image Generation 🚀'),
                  if (!isGenerating)
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      color: AppTheme.textSecondary,
                    ),
                ],
              ),
              const Gap(8),
              const BodyTextSmall(
                'Generate up to 10 images in parallel',
                color: AppTheme.textSecondary,
              ),
              const Gap(24),

              // Content
              Expanded(
                child: isGenerating ? _BatchProgressView() : _BatchSetupView(),
              ),

              // Footer actions
              const Gap(24),
              if (!isGenerating)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SecondaryButton(
                      text: 'Cancel',
                      onPressed: () => Get.back(),
                    ),
                    const Gap(12),
                    Obx(() {
                      final canGenerate =
                          controller.batchPrompts.isNotEmpty &&
                          controller.batchPrompts
                              .where((p) => p.length >= 10)
                              .isNotEmpty;
                      return PrimaryButton(
                        text: 'Generate All',
                        onPressed: canGenerate
                            ? () => controller.generateBatch()
                            : null,
                        icon: Icons.auto_awesome,
                      );
                    }),
                  ],
                ),
            ],
          );
        }),
      ),
    );
  }
}

/// Batch Setup View
class _BatchSetupView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageGenerationController>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Style and aspect ratio
          const StyleSelector(),
          const Gap(24),
          const AspectRatioSelector(),
          const Gap(24),

          // Prompts section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const H3('Prompts'),
              Obx(
                () => BodyTextSmall(
                  '${controller.batchPrompts.length}/10 images',
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const Gap(12),

          // Prompt list
          Obx(
            () => Column(
              children: List.generate(
                controller.batchPrompts.length,
                (index) => _PromptInput(index: index),
              ),
            ),
          ),

          // Add prompt button
          const Gap(12),
          Obx(() {
            final canAdd = controller.batchPrompts.length < 10;
            return SecondaryButton(
              text: 'Add Prompt',
              onPressed: canAdd ? () => controller.addBatchPrompt('') : null,
              icon: Icons.add,
            );
          }),

          const Gap(24),

          // Estimated cost and time
          Obx(() {
            if (controller.batchPrompts.isEmpty) {
              return const SizedBox.shrink();
            }
            final validPrompts = controller.batchPrompts
                .where((p) => p.length >= 10)
                .length;
            final estimatedCost = (validPrompts * 0.003).toStringAsFixed(4);
            final estimatedTime = (2.5 + (validPrompts * 0.2)).toStringAsFixed(
              1,
            );

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: AppTheme.borderRadiusMD,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BodyTextSmall('Valid Prompts:'),
                      BodyText(
                        '$validPrompts images',
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const Gap(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BodyTextSmall('Estimated Cost:'),
                      BodyText('\$$estimatedCost', fontWeight: FontWeight.w600),
                    ],
                  ),
                  const Gap(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BodyTextSmall('Estimated Time:'),
                      BodyText(
                        '~${estimatedTime}s',
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Prompt Input Field
class _PromptInput extends StatelessWidget {
  final int index;

  const _PromptInput({required this.index});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageGenerationController>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Obx(() {
              final textController = TextEditingController(
                text: controller.batchPrompts[index],
              );
              return CustomTextField(
                controller: textController,
                label: 'Prompt ${index + 1}',
                onChanged: (value) =>
                    controller.updateBatchPrompt(index, value),
                maxLines: 2,
              );
            }),
          ),
          const Gap(8),
          IconButton(
            onPressed: () => controller.removeBatchPrompt(index),
            icon: const Icon(Icons.delete_outline),
            color: AppTheme.error,
          ),
        ],
      ),
    );
  }
}

/// Batch Progress View
class _BatchProgressView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageGenerationController>();

    return Obx(() {
      final results = controller.batchResults;
      final progress = controller.batchProgress.value;
      final currentIndex = controller.currentBatchIndex.value;
      final total = controller.batchPrompts.where((p) => p.length >= 10).length;

      return Column(
        children: [
          // Overall progress
          const H3('Generating images...'),
          const Gap(16),
          ClipRRect(
            borderRadius: AppTheme.borderRadiusMD,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BodyText('Image ${currentIndex + 1} of $total'),
              BodyText(
                '${(progress * 100).toInt()}%',
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const Gap(24),

          // Per-image status list
          Expanded(
            child: ListView.builder(
              itemCount: total,
              itemBuilder: (context, index) {
                final status = _getImageStatus(index, currentIndex, results);
                return _StatusItem(
                  index: index,
                  status: status,
                  prompt: controller.batchPrompts[index],
                );
              },
            ),
          ),

          // Cancel button
          const Gap(16),
          TextButton(
            onPressed: () {
              controller.isBatchGenerating.value = false;
              Get.back();
            },
            child: const BodyText('Cancel', color: AppTheme.error),
          ),
        ],
      );
    });
  }

  String _getImageStatus(int index, int currentIndex, List results) {
    if (index < results.length) return 'completed';
    if (index == currentIndex) return 'generating';
    if (index < currentIndex) return 'failed';
    return 'queued';
  }
}

/// Status Item for each image in batch
class _StatusItem extends StatelessWidget {
  final int index;
  final String status;
  final String prompt;

  const _StatusItem({
    required this.index,
    required this.status,
    required this.prompt,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _getStatusIcon();
    final color = _getStatusColor();
    final truncated = prompt.length > 50
        ? '${prompt.substring(0, 50)}...'
        : prompt;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: AppTheme.borderRadiusMD,
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyText('Image ${index + 1}', fontWeight: FontWeight.w600),
                const Gap(4),
                BodyTextSmall(truncated, color: AppTheme.textSecondary),
              ],
            ),
          ),
          BodyText(_getStatusText(), color: color, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'generating':
        return Icons.hourglass_empty;
      case 'failed':
        return Icons.error;
      default:
        return Icons.pending;
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case 'completed':
        return AppTheme.success;
      case 'generating':
        return AppTheme.primary;
      case 'failed':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStatusText() {
    switch (status) {
      case 'completed':
        return '✓ Done';
      case 'generating':
        return '⏳ Generating';
      case 'failed':
        return '✗ Failed';
      default:
        return '⏸ Queued';
    }
  }
}
