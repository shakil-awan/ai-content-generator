/// Video From Script Request Model
/// Request model for generating video from existing script
class VideoFromScriptRequest {
  final String generationId;
  final String? voiceStyle;
  final String? musicMood;
  final String? videoStyle;
  final bool includeSubtitles;
  final bool includeCaptions;

  VideoFromScriptRequest({
    required this.generationId,
    this.voiceStyle,
    this.musicMood,
    this.videoStyle,
    this.includeSubtitles = true,
    this.includeCaptions = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'generation_id': generationId,
      if (voiceStyle != null) 'voice_style': voiceStyle,
      if (musicMood != null) 'music_mood': musicMood,
      if (videoStyle != null) 'video_style': videoStyle,
      'include_subtitles': includeSubtitles,
      'include_captions': includeCaptions,
    };
  }
}
