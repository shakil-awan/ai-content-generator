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
        width: double.infinity,
        margin: const EdgeInsets.only(top: 32),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 1400 ? 48 : 24,
          vertical: 32,
        ),
        decoration: BoxDecoration(
          color: AppTheme.bgSecondary,
          borderRadius: BorderRadius.zero, // Remove border radius for full width
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

            // Summary stats - responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 768) {
                  // Mobile: Stack vertically
                  return Column(
                    children: [
                      _StatCard(
                        icon: Icons.image,
                        label: 'Images',
                        value: '${results.length}',
                      ),
                      const Gap(12),
                      _StatCard(
                        icon: Icons.attach_money,
                        label: 'Total Cost',
                        value: '\$${totalCost.toStringAsFixed(4)}',
                      ),
                      const Gap(12),
                      _StatCard(
                        icon: Icons.timer,
                        label: 'Total Time',
                        value: '${totalTime.toStringAsFixed(1)}s',
                      ),
                    ],
                  );
                }
                // Desktop: Horizontal row
                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.image,
                        label: 'Images',
                        value: '${results.length}',
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.attach_money,
                        label: 'Total Cost',
                        value: '\$${totalCost.toStringAsFixed(4)}',
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.timer,
                        label: 'Total Time',
                        value: '${totalTime.toStringAsFixed(1)}s',
                      ),
                    ),
                  ],
                );
              },
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
        final width = constraints.maxWidth;
        
        // Responsive grid: Better breakpoints for web and mobile
        int crossAxisCount;
        double spacing;
        
        if (width > 1600) {
          // Ultra-wide: 4 columns
          crossAxisCount = 4;
          spacing = 24;
        } else if (width > 1000) {
          // Desktop: 3 columns
          crossAxisCount = 3;
          spacing = 20;
        } else if (width > 600) {
          // Tablet: 2 columns
          crossAxisCount = 2;
          spacing = 16;
        } else {
          // Mobile: 1 column
          crossAxisCount = 1;
          spacing = 12;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 0.85, // Good balance for image cards
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
              index: index,
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
    return Container(
      width: double.infinity,
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
  final int? index;

  const _ImageResultCard({
    required this.imageUrl,
    required this.model,
    required this.time,
    required this.cost,
    this.onDownload,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.bgPrimary,
          borderRadius: AppTheme.borderRadiusMD,
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with loading indicator
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      color: AppTheme.bgSecondary,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.bgSecondary,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: AppTheme.textSecondary,
                                  ),
                                  const Gap(8),
                                  BodyTextSmall(
                                    'Failed to load',
                                    color: AppTheme.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Image number badge
                    if (index != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#${index! + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppTheme.success,
                      ),
                      const Gap(6),
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
                  SizedBox(
                    width: double.infinity,
                    child: SecondaryButton(
                      text: 'Download',
                      onPressed: onDownload,
                      icon: Icons.download,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
