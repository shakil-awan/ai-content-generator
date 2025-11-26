/// Video Generation Response Model
/// Response from automated video generation API
class VideoGenerationResponse {
  final String videoId;
  final String videoUrl;
  final String thumbnailUrl;
  final int durationSeconds;
  final int processingTimeSeconds;
  final double cost;
  final String quality;
  final String format;
  final int fileSizeBytes;
  final String status;
  final Map<String, dynamic> metadata;

  VideoGenerationResponse({
    required this.videoId,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.processingTimeSeconds,
    required this.cost,
    this.quality = '1080p',
    this.format = 'mp4',
    required this.fileSizeBytes,
    this.status = 'completed',
    this.metadata = const {},
  });

  /// Get human-readable file size
  String get fileSizeDisplay {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Get human-readable processing time
  String get processingTimeDisplay {
    if (processingTimeSeconds < 60) {
      return '$processingTimeSeconds seconds';
    } else {
      final minutes = processingTimeSeconds ~/ 60;
      final seconds = processingTimeSeconds % 60;
      return '$minutes min ${seconds}s';
    }
  }

  /// Get human-readable duration
  String get durationDisplay {
    if (durationSeconds < 60) {
      return '$durationSeconds seconds';
    } else {
      final minutes = durationSeconds ~/ 60;
      final seconds = durationSeconds % 60;
      if (seconds == 0) {
        return '$minutes min';
      }
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Get cost display
  String get costDisplay => '\$${cost.toStringAsFixed(2)}';

  /// Check if video is ready
  bool get isReady => status == 'completed' && videoUrl.isNotEmpty;

  /// Check if processing failed
  bool get isFailed => status == 'failed' || status == 'error';

  /// Check if still processing
  bool get isProcessing => status == 'processing' || status == 'queued';

  /// Create from JSON
  factory VideoGenerationResponse.fromJson(Map<String, dynamic> json) {
    return VideoGenerationResponse(
      videoId: json['video_id'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      durationSeconds: json['duration_seconds'] ?? 0,
      processingTimeSeconds: json['processing_time_seconds'] ?? 0,
      cost: (json['cost'] ?? 0).toDouble(),
      quality: json['quality'] ?? '1080p',
      format: json['format'] ?? 'mp4',
      fileSizeBytes: json['file_size_bytes'] ?? 0,
      status: json['status'] ?? 'completed',
      metadata: json['metadata'] ?? {},
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'duration_seconds': durationSeconds,
      'processing_time_seconds': processingTimeSeconds,
      'cost': cost,
      'quality': quality,
      'format': format,
      'file_size_bytes': fileSizeBytes,
      'status': status,
      'metadata': metadata,
    };
  }
}
