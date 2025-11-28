import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../custom_text.dart';
import 'video_player_controller.dart';

/// Custom Video Player Widget
/// YouTube-inspired video player with advanced controls
/// Supports both web URLs and local files
class CustomVideoPlayer extends StatelessWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final String? title;
  final String? description;
  final bool autoPlay;
  final bool showControls;
  final double aspectRatio;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;

  const CustomVideoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.title,
    this.description,
    this.autoPlay = false,
    this.showControls = true,
    this.aspectRatio = 16 / 9,
    this.onDownload,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    // Create unique tag for this video player instance
    final tag = 'video_player_${videoUrl.hashCode}';

    // Initialize controller
    Get.put(
      CustomVideoPlayerController(videoUrl: videoUrl, autoPlay: autoPlay),
      tag: tag,
    );

    final controller = Get.find<CustomVideoPlayerController>(tag: tag);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        borderRadius: AppTheme.borderRadiusLG,
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video player area
          AspectRatio(
            aspectRatio: aspectRatio,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: _buildVideoArea(controller, tag),
            ),
          ),

          // Video controls and info
          if (showControls) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and actions row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null) ...[
                              BodyText(
                                title!,
                                fontWeight: FontWeight.w600,
                                maxLines: 2,
                              ),
                              const Gap(4),
                            ],
                            Obx(() {
                              final status = controller.status.value;
                              final duration = controller.duration.value;
                              return BodyTextSmall(
                                status == 'ready' && duration > 0
                                    ? _formatDuration(duration)
                                    : status,
                                color: AppTheme.textSecondary,
                              );
                            }),
                          ],
                        ),
                      ),
                      const Gap(16),
                      _buildActionButtons(context, controller),
                    ],
                  ),

                  // Description
                  if (description != null && description!.isNotEmpty) ...[
                    const Gap(12),
                    Obx(() {
                      final isExpanded = controller.isDescriptionExpanded.value;
                      return GestureDetector(
                        onTap: controller.toggleDescription,
                        child: BodyTextSmall(
                          description!,
                          color: AppTheme.textSecondary,
                          maxLines: isExpanded ? null : 2,
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoArea(CustomVideoPlayerController controller, String tag) {
    return Obx(() {
      final isPlaying = controller.isPlaying.value;
      final isLoading = controller.isLoading.value;
      final hasError = controller.hasError.value;
      final errorMessage = controller.errorMessage.value;

      return Stack(
        fit: StackFit.expand,
        children: [
          // Background (thumbnail or black)
          if (thumbnailUrl != null && !isPlaying)
            Image.network(
              thumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.white54),
                ),
              ),
            )
          else
            Container(color: Colors.black),

          // Gradient overlay
          if (!isPlaying && !hasError)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

          // Error state
          if (hasError)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const Gap(16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Gap(16),
                    TextButton.icon(
                      onPressed: () => controller.retry(),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Loading state
          if (isLoading && !hasError)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    Gap(16),
                    Text(
                      'Loading video...',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          // Play button overlay (when not playing)
          if (!isPlaying && !isLoading && !hasError)
            Center(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => controller.play(),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),

          // Video iframe (when playing)
          if (isPlaying && !hasError)
            GestureDetector(
              onTap: () => _openInBrowser(videoUrl),
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.open_in_new,
                        color: Colors.white,
                        size: 48,
                      ),
                      const Gap(16),
                      const Text(
                        'Video is playing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Click to open video in browser',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Gap(24),
                      ElevatedButton.icon(
                        onPressed: () => controller.pause(),
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildActionButtons(
    BuildContext context,
    CustomVideoPlayerController controller,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Download button
        if (onDownload != null)
          IconButton(
            onPressed: onDownload,
            icon: const Icon(Icons.download),
            tooltip: 'Download video',
            style: IconButton.styleFrom(backgroundColor: AppTheme.bgSecondary),
          ),

        const Gap(8),

        // Share button
        if (onShare != null)
          IconButton(
            onPressed: onShare,
            icon: const Icon(Icons.share),
            tooltip: 'Share video',
            style: IconButton.styleFrom(backgroundColor: AppTheme.bgSecondary),
          ),

        const Gap(8),

        // Open in browser button
        IconButton(
          onPressed: () => _openInBrowser(videoUrl),
          icon: const Icon(Icons.open_in_new),
          tooltip: 'Open in browser',
          style: IconButton.styleFrom(backgroundColor: AppTheme.bgSecondary),
        ),

        const Gap(8),

        // Fullscreen button
        IconButton(
          onPressed: () => _openFullscreen(context, controller),
          icon: const Icon(Icons.fullscreen),
          tooltip: 'Fullscreen',
          style: IconButton.styleFrom(backgroundColor: AppTheme.bgSecondary),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours:${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _openInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openFullscreen(
    BuildContext context,
    CustomVideoPlayerController controller,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: _buildVideoArea(
                  controller,
                  'video_player_${videoUrl.hashCode}',
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
