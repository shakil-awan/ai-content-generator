import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../controllers/video_generation_controller.dart';
import '../models/generated_video.dart';
import '../models/video_from_script_request.dart';
import '../models/video_generation_request.dart';
import '../models/video_generation_response.dart';
import '../models/video_job_response.dart';

/// Video Generation Service
/// Service for generating videos from scripts using backend API
class VideoGenerationService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  VideoGenerationService({
    ApiService? apiService,
    FlutterSecureStorage? storage,
  }) : _apiService = apiService ?? ApiService(),
       _storage = storage ?? const FlutterSecureStorage();

  /// Get auth token from secure storage and set it in ApiService
  Future<void> _ensureAuthenticated() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      _apiService.setAuthToken(token);
    } else {
      throw Exception('Not authenticated. Please login first.');
    }
  }

  /// Generate video from script using backend API
  Future<VideoJobResponse> generateVideoFromScript(
    VideoFromScriptRequest request,
  ) async {
    // Ensure user is authenticated
    await _ensureAuthenticated();

    try {
      final response = await _apiService.post(
        '/api/v1/generate/video-from-script',
        body: request.toJson(),
      );
      return VideoJobResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to generate video: $e');
    }
  }

  /// Check video generation status
  Future<VideoJobResponse> getVideoStatus(String videoJobId) async {
    // Ensure user is authenticated
    await _ensureAuthenticated();

    try {
      final response = await _apiService.get(
        '/api/v1/generate/video-status/$videoJobId',
      );
      return VideoJobResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get video status: $e');
    }
  }

  /// Poll for video completion with progress updates
  Stream<VideoJobResponse> pollVideoStatus(String videoJobId) async* {
    while (true) {
      final status = await getVideoStatus(videoJobId);
      yield status;

      if (status.isCompleted || status.isFailed) {
        break;
      }

      // Poll every 3 seconds
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  /// Generate video with progress stream (Mock implementation)
  /// In production, this will call the backend API and stream progress
  Stream<VideoGenerationProgress> generateVideoWithProgress(
    VideoGenerationRequest request,
  ) async* {
    // Step 1: Preparing (0-20%)
    yield VideoGenerationProgress(
      step: VideoGenerationStep.preparing,
      percentage: 5,
      message: 'Analyzing script...',
      estimatedTimeRemaining: '~1.5 minutes',
    );
    await Future.delayed(const Duration(seconds: 3));

    yield VideoGenerationProgress(
      step: VideoGenerationStep.preparing,
      percentage: 15,
      message: 'Selecting visual assets...',
      estimatedTimeRemaining: '~1.4 minutes',
    );
    await Future.delayed(const Duration(seconds: 5));

    // Step 2: Generating (20-60%)
    yield VideoGenerationProgress(
      step: VideoGenerationStep.generating,
      percentage: 25,
      message: 'Generating voice narration...',
      estimatedTimeRemaining: '~1.2 minutes',
    );
    await Future.delayed(const Duration(seconds: 20));

    yield VideoGenerationProgress(
      step: VideoGenerationStep.generating,
      percentage: 45,
      message: 'Creating video scenes...',
      estimatedTimeRemaining: '~50 seconds',
    );
    await Future.delayed(const Duration(seconds: 20));

    yield VideoGenerationProgress(
      step: VideoGenerationStep.generating,
      percentage: 60,
      message: 'Adding music and sound effects...',
      estimatedTimeRemaining: '~30 seconds',
    );
    await Future.delayed(const Duration(seconds: 15));

    // Step 3: Processing (60-85%)
    yield VideoGenerationProgress(
      step: VideoGenerationStep.processing,
      percentage: 65,
      message: 'Rendering video...',
      estimatedTimeRemaining: '~25 seconds',
    );
    await Future.delayed(const Duration(seconds: 15));

    yield VideoGenerationProgress(
      step: VideoGenerationStep.processing,
      percentage: 80,
      message: 'Adding subtitles and captions...',
      estimatedTimeRemaining: '~10 seconds',
    );
    await Future.delayed(const Duration(seconds: 10));

    // Step 4: Finalizing (85-100%)
    yield VideoGenerationProgress(
      step: VideoGenerationStep.finalizing,
      percentage: 90,
      message: 'Optimizing video quality...',
      estimatedTimeRemaining: '~5 seconds',
    );
    await Future.delayed(const Duration(seconds: 5));

    yield VideoGenerationProgress(
      step: VideoGenerationStep.finalizing,
      percentage: 95,
      message: 'Generating thumbnail...',
      estimatedTimeRemaining: '~2 seconds',
    );
    await Future.delayed(const Duration(seconds: 2));

    // Completed
    yield VideoGenerationProgress(
      step: VideoGenerationStep.completed,
      percentage: 100,
      message: 'Video ready!',
      estimatedTimeRemaining: null,
    );
  }

  /// Generate video (Mock implementation)
  /// Returns the final response after generation completes
  Future<VideoGenerationResponse> generateVideo(
    VideoGenerationRequest request,
  ) async {
    // Simulate total processing time (~97 seconds)
    await Future.delayed(const Duration(seconds: 97));

    // Generate mock response
    final videoId = 'vid_${DateTime.now().millisecondsSinceEpoch}';

    return VideoGenerationResponse(
      videoId: videoId,
      videoUrl: 'https://storage.summarly.ai/videos/$videoId.mp4',
      thumbnailUrl: 'https://storage.summarly.ai/thumbnails/$videoId.jpg',
      durationSeconds: request.duration,
      processingTimeSeconds: 97,
      cost: request.estimatedCost,
      quality: '1080p',
      format: 'mp4',
      fileSizeBytes: _estimateFileSize(request.duration),
      status: 'completed',
      metadata: {
        'platform': request.platform,
        'voice_id': request.voiceId,
        'music_mood': request.musicMood,
        'has_subtitles': request.includeSubtitles,
        'has_captions': request.includeCaptions,
        'script_id': request.scriptId,
      },
    );
  }

  /// Get video library (Mock implementation)
  Future<List<GeneratedVideo>> getVideoLibrary() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock library
    final now = DateTime.now();
    return [
      GeneratedVideo(
        id: 'vid_001',
        title: 'How to Master Content Marketing in 2024',
        videoUrl: 'https://storage.summarly.ai/videos/vid_001.mp4',
        thumbnailUrl: 'https://storage.summarly.ai/thumbnails/vid_001.jpg',
        platform: 'youtube',
        durationSeconds: 180,
        scriptId: 'script_001',
        createdAt: now.subtract(const Duration(hours: 2)),
        status: 'completed',
      ),
      GeneratedVideo(
        id: 'vid_002',
        title: '5 Quick LinkedIn Tips',
        videoUrl: 'https://storage.summarly.ai/videos/vid_002.mp4',
        thumbnailUrl: 'https://storage.summarly.ai/thumbnails/vid_002.jpg',
        platform: 'linkedin',
        durationSeconds: 60,
        scriptId: 'script_002',
        createdAt: now.subtract(const Duration(days: 1)),
        status: 'completed',
      ),
      GeneratedVideo(
        id: 'vid_003',
        title: 'TikTok Growth Strategy',
        videoUrl: 'https://storage.summarly.ai/videos/vid_003.mp4',
        thumbnailUrl: 'https://storage.summarly.ai/thumbnails/vid_003.jpg',
        platform: 'tiktok',
        durationSeconds: 30,
        scriptId: 'script_003',
        createdAt: now.subtract(const Duration(days: 3)),
        status: 'completed',
      ),
    ];
  }

  /// Delete video (Mock implementation)
  Future<void> deleteVideo(String videoId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    // In production, this would call the backend API
  }

  /// Estimate file size based on duration
  /// Rough estimate: ~2MB per minute for 1080p video
  int _estimateFileSize(int durationSeconds) {
    final durationMinutes = durationSeconds / 60;
    final sizeInMB = durationMinutes * 2;
    return (sizeInMB * 1024 * 1024).toInt();
  }
}
