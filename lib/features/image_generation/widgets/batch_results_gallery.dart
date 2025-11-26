import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/image_generation_controller.dart';

/// Batch Results Gallery
/// Display all generated images from batch operation
class BatchResultsGallery extends StatelessWidget {
  const BatchResultsGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageGenerationController>();

    return Obx(() {
      final results = controller.batchResults;
      if (results.isEmpty) return const SizedBox.shrink();

      final totalCost = results.fold<double>(0, (sum, r) => sum + r.cost);
      final totalTime = results.fold<double>(
        0,
        (sum, r) => sum + r.generationTime,
      );

      return Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.bgSecondary,
          borderRadius: AppTheme.borderRadiusLG,
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                borderRadius: AppTheme.borderRadiusMD,
                border: Border.all(
                  color: AppTheme.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                  const Gap(8),
                  BodyText(
                    'Successfully generated ${results.length} images! 🎉',
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
            const Gap(24),

            // Summary stats
            Row(
              children: [
                _StatCard(
                  icon: Icons.image,
                  label: 'Images',
                  value: '${results.length}',
                ),
                const Gap(16),
                _StatCard(
                  icon: Icons.attach_money,
                  label: 'Total Cost',
                  value: '\$${totalCost.toStringAsFixed(4)}',
                ),
                const Gap(16),
                _StatCard(
                  icon: Icons.timer,
                  label: 'Total Time',
                  value: '${totalTime.toStringAsFixed(1)}s',
                ),
              ],
            ),
            const Gap(24),

            // Images grid
            const H3('Generated Images'),
            const Gap(16),
            _buildImagesGrid(results),
            const Gap(24),

            // Bulk actions
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                PrimaryButton(
                  text: 'Download All (ZIP)',
                  onPressed: () => _downloadAll(results),
                  icon: Icons.download,
                ),
                SecondaryButton(
                  text: 'Generate More',
                  onPressed: () {
                    controller.batchResults.clear();
                    controller.batchPrompts.clear();
                  },
                  icon: Icons.add,
                ),
                TextButton(
                  onPressed: () => controller.batchResults.clear(),
                  child: const BodyText('Clear', color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildImagesGrid(List results) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return _ImageResultCard(
              imageUrl: result.imageUrl,
              model: result.modelDisplay,
              time: result.formattedTime,
              cost: result.formattedCost,
              onDownload: () => _downloadImage(result.imageUrl),
            );
          },
        );
      },
    );
  }

  void _downloadImage(String url) {
    Get.snackbar(
      'Download Started',
      'Image is being downloaded...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _downloadAll(List results) {
    Get.snackbar(
      'Download Started',
      'Preparing ZIP file with ${results.length} images...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}

/// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgPrimary,
          borderRadius: AppTheme.borderRadiusMD,
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppTheme.primary),
            const Gap(8),
            BodyTextSmall(label, color: AppTheme.textSecondary),
            const Gap(4),
            H3(value),
          ],
        ),
      ),
    );
  }
}

/// Image Result Card
class _ImageResultCard extends StatelessWidget {
  final String imageUrl;
  final String model;
  final String time;
  final String cost;
  final VoidCallback? onDownload;

  const _ImageResultCard({
    required this.imageUrl,
    required this.model,
    required this.time,
    required this.cost,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        borderRadius: AppTheme.borderRadiusMD,
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.bgSecondary,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: BodyTextSmall(
                        model,
                        color: AppTheme.textSecondary,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BodyTextSmall('⏱ $time', color: AppTheme.textSecondary),
                    BodyTextSmall('💰 $cost', color: AppTheme.textSecondary),
                  ],
                ),
                const Gap(12),
                SecondaryButton(
                  text: 'Download',
                  onPressed: onDownload,
                  icon: Icons.download,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
