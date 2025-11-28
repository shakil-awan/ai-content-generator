/// Video Generation Job Response Model
/// Response model for video generation job from backend
class VideoJobResponse {
  final String id;
  final String status;
  final int progress;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int? duration;
  final double? processingTime;
  final double? cost;
  final Map<String, dynamic>? metadata;
  final String? error;
  final DateTime createdAt;
  final DateTime? completedAt;

  VideoJobResponse({
    required this.id,
    required this.status,
    required this.progress,
    this.videoUrl,
    this.thumbnailUrl,
    this.duration,
    this.processingTime,
    this.cost,
    this.metadata,
    this.error,
    required this.createdAt,
    this.completedAt,
  });

  factory VideoJobResponse.fromJson(Map<String, dynamic> json) {
    return VideoJobResponse(
      id: json['id'] as String,
      status: json['status'] as String,
      progress: json['progress'] as int,
      videoUrl: json['video_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      duration: json['duration'] as int?,
      processingTime: (json['processing_time'] as num?)?.toDouble(),
      cost: (json['cost'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      error:
          json['error_message']
              as String?, // Backend sends 'error_message', not 'error'
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(), // Fallback to current time if missing
      completedAt: json['completed_at'] != null || json['updated_at'] != null
          ? DateTime.parse(
              (json['completed_at'] ?? json['updated_at']) as String,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'progress': progress,
      if (videoUrl != null) 'video_url': videoUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (duration != null) 'duration': duration,
      if (processingTime != null) 'processing_time': processingTime,
      if (cost != null) 'cost': cost,
      if (metadata != null) 'metadata': metadata,
      if (error != null) 'error': error,
      'created_at': createdAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    };
  }

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed' || status == 'error';
  bool get isProcessing => status == 'processing' || status == 'pending';
}
