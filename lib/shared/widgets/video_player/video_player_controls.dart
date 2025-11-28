import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_theme.dart';
import '../custom_text.dart';

/// Video Player Progress Bar
/// Shows video playback progress with seeking capability
class VideoProgressBar extends StatelessWidget {
  final int currentTime; // seconds
  final int duration; // seconds
  final ValueChanged<int>? onSeek;

  const VideoProgressBar({
    super.key,
    required this.currentTime,
    required this.duration,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final progress = duration > 0 ? currentTime / duration : 0.0;

    return Column(
      children: [
        Row(
          children: [
            BodyTextSmall(
              _formatTime(currentTime),
              color: AppTheme.textSecondary,
            ),
            const Spacer(),
            BodyTextSmall(_formatTime(duration), color: AppTheme.textSecondary),
          ],
        ),
        const Gap(8),
        GestureDetector(
          onTapDown: (details) => _handleSeek(details, context),
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                // Progress fill
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Progress indicator
                if (progress > 0)
                  Positioned(
                    left: MediaQuery.of(context).size.width * progress - 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(top: -4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleSeek(TapDownDetails details, BuildContext context) {
    if (onSeek == null || duration == 0) return;

    final box = context.findRenderObject() as RenderBox;
    final position = details.localPosition.dx / box.size.width;
    final seekTime = (duration * position).round();
    onSeek!(seekTime);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours:${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

/// Video Playback Speed Selector
class PlaybackSpeedSelector extends StatelessWidget {
  final double currentSpeed;
  final ValueChanged<double> onSpeedChange;

  const PlaybackSpeedSelector({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChange,
  });

  static const List<double> speeds = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        borderRadius: AppTheme.borderRadiusMD,
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: BodyText('Playback Speed', fontWeight: FontWeight.w600),
          ),
          const Divider(height: 1),
          ...speeds.map((speed) {
            final isSelected = (speed - currentSpeed).abs() < 0.01;
            return InkWell(
              onTap: () => onSpeedChange(speed),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BodyText(
                      '${speed}x',
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textPrimary,
                    ),
                    if (isSelected)
                      Icon(Icons.check, size: 16, color: AppTheme.primary),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Video Quality Selector
class VideoQualitySelector extends StatelessWidget {
  final String currentQuality;
  final ValueChanged<String> onQualityChange;

  const VideoQualitySelector({
    super.key,
    required this.currentQuality,
    required this.onQualityChange,
  });

  static const List<Map<String, String>> qualities = [
    {'value': 'auto', 'label': 'Auto'},
    {'value': '2160p', 'label': '2160p (4K)'},
    {'value': '1440p', 'label': '1440p (2K)'},
    {'value': '1080p', 'label': '1080p (Full HD)'},
    {'value': '720p', 'label': '720p (HD)'},
    {'value': '480p', 'label': '480p'},
    {'value': '360p', 'label': '360p'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        borderRadius: AppTheme.borderRadiusMD,
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: BodyText('Video Quality', fontWeight: FontWeight.w600),
          ),
          const Divider(height: 1),
          ...qualities.map((quality) {
            final isSelected = quality['value'] == currentQuality;
            return InkWell(
              onTap: () => onQualityChange(quality['value']!),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BodyText(
                      quality['label']!,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textPrimary,
                    ),
                    if (isSelected)
                      Icon(Icons.check, size: 16, color: AppTheme.primary),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Volume Control Slider
class VolumeControl extends StatelessWidget {
  final double volume; // 0.0 to 1.0
  final bool isMuted;
  final ValueChanged<double> onVolumeChange;
  final VoidCallback onMuteToggle;

  const VolumeControl({
    super.key,
    required this.volume,
    required this.isMuted,
    required this.onVolumeChange,
    required this.onMuteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        borderRadius: AppTheme.borderRadiusMD,
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onMuteToggle,
            icon: Icon(
              isMuted
                  ? Icons.volume_off
                  : volume > 0.5
                  ? Icons.volume_up
                  : Icons.volume_down,
            ),
            style: IconButton.styleFrom(backgroundColor: AppTheme.bgSecondary),
          ),
          const Gap(12),
          SizedBox(
            width: 120,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: AppTheme.primary,
                inactiveTrackColor: AppTheme.border,
                thumbColor: AppTheme.primary,
                overlayColor: AppTheme.primary.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: isMuted ? 0 : volume,
                onChanged: (value) {
                  if (isMuted && value > 0) {
                    onMuteToggle();
                  }
                  onVolumeChange(value);
                },
                min: 0,
                max: 1,
              ),
            ),
          ),
          const Gap(8),
          BodyTextSmall(
            '${(volume * 100).round()}%',
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}
