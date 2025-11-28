import 'dart:convert';

import 'script_section.dart';

/// Video Script Response Model
/// Response from video script generation API
class VideoScriptResponse {
  final String? id; // Generation ID from backend
  final String hook;
  final List<ScriptSection> script;
  final String ctaScript;
  final List<String> thumbnailTitles;
  final String description;
  final List<String> hashtags;
  final List<String> recommendedMusic;
  final List<String> retentionHooks;

  VideoScriptResponse({
    this.id,
    required this.hook,
    required this.script,
    required this.ctaScript,
    required this.thumbnailTitles,
    required this.description,
    required this.hashtags,
    required this.recommendedMusic,
    required this.retentionHooks,
  });

  /// Get total script text (for copying)
  String get fullScriptText {
    final buffer = StringBuffer();

    // Hook
    buffer.writeln(
      '🎯 HOOK (${script.isNotEmpty ? script.first.timestamp : '0:00-0:05'})',
    );
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

  /// Get recommended music as comma-separated string
  String get musicText => recommendedMusic.join(', ');

  /// Get retention hooks as comma-separated string
  String get retentionHooksText => retentionHooks.join(', ');

  /// Check if we have all recommendation data
  bool get hasRecommendations =>
      hashtags.isNotEmpty ||
      recommendedMusic.isNotEmpty ||
      retentionHooks.isNotEmpty;

  /// Create from JSON
  factory VideoScriptResponse.fromJson(Map<String, dynamic> json) {
    print('\n═══ VideoScriptResponse.fromJson ═══');
    print('JSON keys: ${json.keys.toList()}');
    print('Has output: ${json.containsKey("output")}');
    print('Has content: ${json.containsKey("content")}');

    // Handle nested output structure from backend
    Map<String, dynamic>? output;

    if (json.containsKey('output')) {
      print('Found output field');
      output = json['output'] is String
          ? jsonDecode(json['output']) as Map<String, dynamic>
          : json['output'] as Map<String, dynamic>?;
    } else if (json.containsKey('content')) {
      print('Found content field instead of output - trying to parse');
      // Backend returns content field, not output field
      // Try to parse content as JSON if it's a string
      final content = json['content'];
      if (content is String) {
        try {
          output = jsonDecode(content) as Map<String, dynamic>;
          print('Successfully parsed content as JSON');
        } catch (e) {
          print('Content is not JSON, treating as plain text: $e');
          // Content is plain text, not structured JSON
          output = null;
        }
      }
    }

    if (output == null) {
      print('❌ ERROR: No valid output or content field found');
      print('Available fields: ${json.keys.join(", ")}');
      throw Exception(
        'Invalid response: missing output field. Available fields: ${json.keys.join(", ")}',
      );
    }

    print('Output structure: ${output.keys.toList()}');

    // Extract sections array (backend uses 'sections', not 'script')
    final sections = output['sections'] as List? ?? [];
    print('Parsing ${sections.length} sections from backend');

    // Extract hook - could be in 'hook' field or first section with type 'hook'
    String hookText = output['hook'] ?? '';
    if (hookText.isEmpty && sections.isNotEmpty) {
      final hookSection =
          sections.firstWhere(
                (s) => s['sectionType'] == 'hook',
                orElse: () => {},
              )
              as Map<String, dynamic>?;
      if (hookSection != null && hookSection.isNotEmpty) {
        hookText = hookSection['script'] ?? '';
      }
    }

    // Extract CTA - could be in 'callToAction' or section with type 'call_to_action'
    String ctaText =
        output['callToAction'] ??
        output['call_to_action'] ??
        output['ctaScript'] ??
        output['cta_script'] ??
        '';
    if (ctaText.isEmpty && sections.isNotEmpty) {
      final ctaSection =
          sections.firstWhere(
                (s) =>
                    s['sectionType'] == 'call_to_action' ||
                    s['sectionType'] == 'cta',
                orElse: () => {},
              )
              as Map<String, dynamic>?;
      if (ctaSection != null && ctaSection.isNotEmpty) {
        ctaText = ctaSection['script'] ?? '';
      }
    }

    // Convert backend sections to frontend ScriptSection objects
    final scriptSections = sections.map((s) {
      final section = s as Map<String, dynamic>;
      return ScriptSection(
        timestamp: section['timestamp'] ?? '0:00-0:00',
        content: section['script'] ?? '', // Backend uses 'script' field
        visualCue:
            section['visualNotes'] ??
            section['visualDescription'] ??
            '', // Backend uses 'visualNotes' or 'visualDescription'
      );
    }).toList();

    print('✅ Parsed ${scriptSections.length} script sections');

    return VideoScriptResponse(
      id: json['id'] as String?, // Extract generation ID from response
      hook: hookText,
      script: scriptSections,
      ctaScript: ctaText,
      thumbnailTitles: List<String>.from(
        output['thumbnailTitles'] ?? output['thumbnail_titles'] ?? [],
      ),
      description: output['description'] ?? '',
      hashtags: List<String>.from(output['hashtags'] ?? []),
      recommendedMusic: List<String>.from(
        output['recommendedMusic'] ?? output['recommended_music'] ?? [],
      ),
      retentionHooks: List<String>.from(
        output['retentionHooks'] ?? output['retention_hooks'] ?? [],
      ),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'hook': hook,
      'script': script.map((s) => s.toJson()).toList(),
      'cta_script': ctaScript,
      'thumbnail_titles': thumbnailTitles,
      'description': description,
      'hashtags': hashtags,
      'recommended_music': recommendedMusic,
      'retention_hooks': retentionHooks,
    };
  }
}
