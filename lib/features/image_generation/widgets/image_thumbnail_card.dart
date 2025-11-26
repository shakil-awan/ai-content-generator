import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../models/generated_image.dart';

/// Image Thumbnail Card
/// Display image in gallery with hover actions
class ImageThumbnailCard extends StatefulWidget {
  final GeneratedImage image;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;

  const ImageThumbnailCard({
    super.key,
    required this.image,
    this.onTap,
    this.onDownload,
    this.onDelete,
  });

  @override
  State<ImageThumbnailCard> createState() => _ImageThumbnailCardState();
}

class _ImageThumbnailCardState extends State<ImageThumbnailCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.bgSecondary,
            borderRadius: AppTheme.borderRadiusMD,
            border: Border.all(
              color: isHovered ? AppTheme.primary : AppTheme.border,
              width: isHovered ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with overlay actions
              Stack(
                children: [
                  // Thumbnail image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        widget.image.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.bgPrimary,
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

                  // Hover overlay with actions
                  if (isHovered)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.onDownload != null)
                                IconButton(
                                  onPressed: widget.onDownload,
                                  icon: const Icon(
                                    Icons.download,
                                    color: Colors.white,
                                  ),
                                  tooltip: 'Download',
                                ),
                              if (widget.onDelete != null) ...[
                                const Gap(8),
                                IconButton(
                                  onPressed: widget.onDelete,
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Style badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: BodyTextSmall(
                        widget.image.styleDisplay,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              // Image details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyText(
                      widget.image.truncatedPrompt,
                      fontWeight: FontWeight.w600,
                      maxLines: 2,
                    ),
                    const Gap(8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BodyTextSmall(
                          widget.image.displaySize,
                          color: AppTheme.textSecondary,
                        ),
                        BodyTextSmall(
                          widget.image.formattedDate,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
