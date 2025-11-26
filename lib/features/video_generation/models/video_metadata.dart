/// Video Metadata Model
/// Represents metadata about a video
class VideoMetadata {
  final String platform;
  final int durationSeconds;
  final String tone;

  VideoMetadata({
    required this.platform,
    required this.durationSeconds,
    required this.tone,
  });

  /// Get formatted duration string (e.g., "3:00" or "1m 30s")
  String get durationFormatted {
    if (durationSeconds < 60) {
      return '${durationSeconds}s';
    }
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (seconds == 0) {
      return '${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }

  /// Get short duration format for display (e.g., "3:00")
  String get durationShort {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get platform emoji
  String get platformEmoji {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return '🎬';
      case 'tiktok':
        return '🎵';
      case 'instagram':
        return '📸';
      case 'linkedin':
        return '💼';
      default:
        return '📹';
    }
  }

  /// Get platform display name
  String get platformName {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return 'YouTube';
      case 'tiktok':
        return 'TikTok';
      case 'instagram':
        return 'Instagram';
      case 'linkedin':
        return 'LinkedIn';
      default:
        return platform;
    }
  }

  /// Create from JSON
  factory VideoMetadata.fromJson(Map<String, dynamic> json) {
    return VideoMetadata(
      platform: json['platform'] ?? 'youtube',
      durationSeconds: json['duration_seconds'] ?? json['duration'] ?? 180,
      tone: json['tone'] ?? 'casual',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'duration_seconds': durationSeconds,
      'tone': tone,
    };
  }
}
