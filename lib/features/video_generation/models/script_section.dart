/// Script Section Model
/// Represents a timestamped section of a video script
class ScriptSection {
  final String timestamp;
  final String content;
  final String visualCue;

  ScriptSection({
    required this.timestamp,
    required this.content,
    required this.visualCue,
  });

  /// Extract heading from content or timestamp
  String get heading {
    // Extract heading from timestamp description (e.g., "0:20-0:45 - Tool 1: ChatGPT")
    if (timestamp.contains(' - ') && timestamp.split(' - ').length > 1) {
      return timestamp.split(' - ').skip(1).join(' - ');
    }
    // Fallback: extract from first line of content
    final firstLine = content.split('\n').first;
    if (firstLine.length > 50) {
      return '${firstLine.substring(0, 47)}...';
    }
    return firstLine.isNotEmpty ? firstLine : 'Section';
  }

  /// Get start time in seconds
  int get startTimeSeconds {
    try {
      final times = timestamp.split('-').first.trim();
      final parts = times.split(':');
      if (parts.length == 2) {
        return int.parse(parts[0]) * 60 + int.parse(parts[1]);
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return 0;
  }

  /// Get end time in seconds
  int get endTimeSeconds {
    try {
      final times = timestamp.split('-').last.split(' ').first.trim();
      final parts = times.split(':');
      if (parts.length == 2) {
        return int.parse(parts[0]) * 60 + int.parse(parts[1]);
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return 0;
  }

  /// Create from JSON
  factory ScriptSection.fromJson(Map<String, dynamic> json) {
    return ScriptSection(
      timestamp: json['timestamp'] ?? '',
      content: json['content'] ?? '',
      visualCue: json['visualCue'] ?? json['visual_cue'] ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'content': content,
      'visual_cue': visualCue,
    };
  }
}
