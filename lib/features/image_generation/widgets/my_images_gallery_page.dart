import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/image_gallery_controller.dart';
import '../models/generated_image.dart';
import 'image_thumbnail_card.dart';

/// My Images Gallery Page
/// Full-page gallery view with filters and pagination
class MyImagesGalleryPage extends GetView<ImageGalleryController> {
  const MyImagesGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Load images when page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.isLoading.value && controller.images.isEmpty) {
        controller.loadImages();
      }
    });
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const H1('My Images 🎨'),
                const Gap(8),
                const BodyText(
                  'View and manage your generated images',
                  color: AppTheme.textSecondary,
                ),
                const Gap(32),

                // Filters and search
                _buildFilters(),
                const Gap(24),

                // Gallery grid
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppTheme.error,
                            ),
                            const Gap(16),
                            BodyText(
                              controller.errorMessage.value,
                              color: AppTheme.error,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (controller.images.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildGalleryGrid();
                }),
                const Gap(32),

                // Pagination
                Obx(() {
                  if (controller.images.isEmpty) return const SizedBox.shrink();
                  return _buildPagination();
                }),
                const Gap(32),

                // Storage and quota info
                _buildStorageInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return Column(
            children: [
              _buildSearchField(),
              const Gap(12),
              Row(
                children: [
                  Expanded(child: _buildStyleFilter()),
                  const Gap(12),
                  Expanded(child: _buildSortFilter()),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _buildSearchField()),
            const Gap(16),
            SizedBox(width: 200, child: _buildStyleFilter()),
            const Gap(12),
            SizedBox(width: 200, child: _buildSortFilter()),
          ],
        );
      },
    );
  }

  Widget _buildSearchField() {
    return CustomTextField(
      label: 'Search images',
      hint: 'Search by prompt...',
      prefixIcon: Icons.search,
      onChanged: controller.setSearchQuery,
    );
  }

  Widget _buildStyleFilter() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.bgSecondary,
          borderRadius: AppTheme.borderRadiusMD,
          border: Border.all(color: AppTheme.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.styleFilter.value,
            isExpanded: true,
            items: [
              const DropdownMenuItem(value: 'all', child: Text('All Styles')),
              ...['realistic', 'artistic', 'illustration', '3d'].map(
                (style) => DropdownMenuItem(
                  value: style,
                  child: Text(style.capitalize ?? ''),
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) controller.setStyleFilter(value);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSortFilter() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.bgSecondary,
          borderRadius: AppTheme.borderRadiusMD,
          border: Border.all(color: AppTheme.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.sortOption.value,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'newest', child: Text('Newest First')),
              DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
            ],
            onChanged: (value) {
              if (value != null) controller.setSortOption(value);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
            ? 2
            : 1;

        return Obx(
          () => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: controller.images.length,
            itemBuilder: (context, index) {
              final image = controller.images[index];
              return ImageThumbnailCard(
                image: image,
                onTap: () => _showImageDetails(image),
                onDownload: () => _downloadImage(image),
                onDelete: () => _confirmDelete(image),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.image_not_supported,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const Gap(16),
            const H3('No images found'),
            const Gap(8),
            const BodyText(
              'Start generating images to see them here',
              color: AppTheme.textSecondary,
            ),
            const Gap(24),
            PrimaryButton(
              text: 'Generate Image',
              onPressed: () => Get.offNamed('/content-generation'),
              icon: Icons.add_photo_alternate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SecondaryButton(
            text: 'Previous',
            onPressed: controller.hasPrevPage ? controller.prevPage : null,
            icon: Icons.arrow_back,
          ),
          const Gap(16),
          BodyText(
            'Page ${controller.currentPage.value} of ${controller.totalPages}',
            fontWeight: FontWeight.w600,
          ),
          const Gap(16),
          SecondaryButton(
            text: 'Next',
            onPressed: controller.hasNextPage ? controller.nextPage : null,
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageInfo() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.bgSecondary,
          borderRadius: AppTheme.borderRadiusLG,
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const H3('Storage & Usage'),
            const Gap(16),

            // Storage progress
            Row(
              children: [
                const BodyText('Storage:'),
                const Gap(8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppTheme.borderRadiusMD,
                    child: LinearProgressIndicator(
                      value: controller.storagePercentage,
                      minHeight: 8,
                      backgroundColor: AppTheme.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                BodyText(
                  '${controller.storageUsedMB.value.toStringAsFixed(1)} MB / ${controller.storageLimitMB.value.toStringAsFixed(0)} GB',
                ),
              ],
            ),
            const Gap(16),

            // Images quota
            Row(
              children: [
                const BodyText('Images this month:'),
                const Gap(8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppTheme.borderRadiusMD,
                    child: LinearProgressIndicator(
                      value:
                          controller.imagesThisMonth.value /
                          controller.monthlyLimit.value,
                      minHeight: 8,
                      backgroundColor: AppTheme.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                BodyText(
                  '${controller.imagesThisMonth.value} / ${controller.monthlyLimit.value}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDetails(GeneratedImage image) {
    Get.dialog(
      Dialog(
        backgroundColor: AppTheme.bgPrimary,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const H2('Image Details'),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Gap(24),
                ClipRRect(
                  borderRadius: AppTheme.borderRadiusMD,
                  child: Image.network(image.imageUrl, fit: BoxFit.contain),
                ),
                const Gap(24),
                _DetailRow(label: 'Prompt', value: image.prompt),
                const Gap(12),
                _DetailRow(label: 'Style', value: image.styleDisplay),
                const Gap(12),
                _DetailRow(label: 'Size', value: image.displaySize),
                const Gap(12),
                _DetailRow(label: 'Created', value: image.formattedDate),
                const Gap(24),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: 'Download',
                        onPressed: () {
                          _downloadImage(image);
                          Get.back();
                        },
                        icon: Icons.download,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: SecondaryButton(
                        text: 'Delete',
                        onPressed: () {
                          Get.back();
                          _confirmDelete(image);
                        },
                        icon: Icons.delete,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _downloadImage(GeneratedImage image) {
    Get.snackbar(
      'Download Started',
      'Downloading ${image.truncatedPrompt}...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _confirmDelete(GeneratedImage image) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Image?'),
        content: const Text(
          'This action cannot be undone. The image will be permanently deleted.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.deleteImage(image.id);
              Get.back();
              Get.snackbar(
                'Deleted',
                'Image deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: BodyText('$label:', color: AppTheme.textSecondary),
        ),
        Expanded(child: BodyText(value, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
