/// Generated Video Model
/// Represents a video in user's library
class GeneratedVideo {
  final String id;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final String platform;
  final int durationSeconds;
  final String scriptId;
  final DateTime createdAt;
  final String status;
  final Map<String, dynamic> metadata;

  GeneratedVideo({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.platform,
    required this.durationSeconds,
    required this.scriptId,
    required this.createdAt,
    this.status = 'completed',
    this.metadata = const {},
  });

  /// Get platform display name
  String get platformDisplay {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return 'YouTube';
      case 'tiktok':
        return 'TikTok';
      case 'instagram':
        return 'Instagram Reels';
      case 'linkedin':
        return 'LinkedIn';
      default:
        return platform;
    }
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
        return '🎥';
    }
  }

  /// Get duration display
  String get durationDisplay {
    if (durationSeconds < 60) {
      return '${durationSeconds}s';
    } else {
      final minutes = durationSeconds ~/ 60;
      final seconds = durationSeconds % 60;
      if (seconds == 0) {
        return '${minutes}m';
      }
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Get created date display
  String get createdAtDisplay {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
    }
  }

  /// Check if video is ready to view
  bool get isReady => status == 'completed' && videoUrl.isNotEmpty;

  /// Check if video is processing
  bool get isProcessing => status == 'processing' || status == 'queued';

  /// Check if video failed
  bool get isFailed => status == 'failed' || status == 'error';

  /// Create from JSON
  factory GeneratedVideo.fromJson(Map<String, dynamic> json) {
    return GeneratedVideo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      platform: json['platform'] ?? '',
      durationSeconds: json['duration_seconds'] ?? 0,
      scriptId: json['script_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      status: json['status'] ?? 'completed',
      metadata: json['metadata'] ?? {},
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'platform': platform,
      'duration_seconds': durationSeconds,
      'script_id': scriptId,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'metadata': metadata,
    };
  }
}
