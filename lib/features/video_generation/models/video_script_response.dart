import 'dart:convert';

import 'script_section.dart';

/// Video Script Response Model
/// Response from video script generation API
class VideoScriptResponse {
  final String hook;
  final List<ScriptSection> script;
  final String ctaScript;
  final List<String> thumbnailTitles;
  final String description;
  final List<String> hashtags;
  final String musicMood;
  final String estimatedRetention;

  VideoScriptResponse({
    required this.hook,
    required this.script,
    required this.ctaScript,
    required this.thumbnailTitles,
    required this.description,
    required this.hashtags,
    required this.musicMood,
    required this.estimatedRetention,
  });

  /// Get total script text (for copying)
  String get fullScriptText {
    final buffer = StringBuffer();

    // Hook
    buffer.writeln('🎯 HOOK (${script.isNotEmpty ? script.first.timestamp : '0:00-0:05'})');
    buffer.writeln(hook);
    buffer.writeln();

    // Script sections
    for (final section in script) {
      buffer.writeln('📝 ${section.timestamp}');
      buffer.writeln(section.content);
      if (section.visualCue.isNotEmpty) {
        buffer.writeln('Visual: ${section.visualCue}');
      }
      buffer.writeln();
    }

    // CTA
    if (ctaScript.isNotEmpty) {
      buffer.writeln('📢 CALL TO ACTION');
      buffer.writeln(ctaScript);
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Get hashtags as space-separated string
  String get hashtagsText => hashtags.join(' ');

  /// Get retention percentage (parse from estimatedRetention)
  int get retentionPercentage {
    try {
      final match = RegExp(r'(\d+)%').firstMatch(estimatedRetention);
      if (match != null) {
        return int.parse(match.group(1)!);
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return 0;
  }

  /// Get retention reasoning (text after percentage)
  String get retentionReasoning {
    try {
      final parts = estimatedRetention.split('-');
      if (parts.length > 1) {
        return parts.skip(1).join('-').trim();
      }
      // Remove percentage part
      return estimatedRetention.replaceFirst(RegExp(r'\d+%\s*-?\s*'), '').trim();
    } catch (e) {
      return estimatedRetention;
    }
  }

  /// Create from JSON
  factory VideoScriptResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested output structure from backend
    final output = json['output'] is String
        ? jsonDecode(json['output']) as Map<String, dynamic>
        : json['output'] as Map<String, dynamic>?;

    if (output == null) {
      throw Exception('Invalid response: missing output field');
    }

    return VideoScriptResponse(
      hook: output['hook'] ?? '',
      script: (output['script'] as List?)
              ?.map((s) => ScriptSection.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      ctaScript: output['ctaScript'] ?? output['cta_script'] ?? '',
      thumbnailTitles: List<String>.from(
          output['thumbnailTitles'] ?? output['thumbnail_titles'] ?? []),
      description: output['description'] ?? '',
      hashtags: List<String>.from(output['hashtags'] ?? []),
      musicMood: output['musicMood'] ?? output['music_mood'] ?? '',
      estimatedRetention:
          output['estimatedRetention'] ?? output['estimated_retention'] ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'hook': hook,
      'script': script.map((s) => s.toJson()).toList(),
      'cta_script': ctaScript,
      'thumbnail_titles': thumbnailTitles,
      'description': description,
      'hashtags': hashtags,
      'music_mood': musicMood,
      'estimated_retention': estimatedRetention,
    };
  }
}
