/// Fact Check Source Model
/// Represents a source used to verify a claim with detailed information
class FactCheckSource {
  final String url;
  final String title;
  final String snippet;
  final String domain;
  final String authorityLevel; // 'government', 'academic', 'organization', 'news', 'general'

  FactCheckSource({
    required this.url,
    required this.title,
    required this.snippet,
    required this.domain,
    required this.authorityLevel,
  });

  /// Get authority display name
  String get authorityDisplayName {
    switch (authorityLevel) {
      case 'government':
        return 'Government';
      case 'academic':
        return 'Academic';
      case 'organization':
        return 'International Org';
      case 'news':
        return 'News Outlet';
      default:
        return 'Web Source';
    }
  }

  /// Get authority icon
  String get authorityIcon {
    switch (authorityLevel) {
      case 'government':
        return '🏛️';
      case 'academic':
        return '🎓';
      case 'organization':
        return '🌍';
      case 'news':
        return '📰';
      default:
        return '🌐';
    }
  }

  /// Create from JSON
  factory FactCheckSource.fromJson(Map<String, dynamic> json) {
    return FactCheckSource(
      url: json['url'] ?? '',
      title: json['title'] ?? '',
      snippet: json['snippet'] ?? '',
      domain: json['domain'] ?? '',
      authorityLevel: json['authority_level'] ?? 'general',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'snippet': snippet,
      'domain': domain,
      'authority_level': authorityLevel,
    };
  }

  /// Get truncated URL for display (max 60 chars)
  String get displayUrl {
    return url.length <= 60 ? url : '${url.substring(0, 57)}...';
  }

  /// Get truncated snippet for preview (max 100 chars)
  String get displaySnippet {
    return snippet.length <= 100 ? snippet : '${snippet.substring(0, 97)}...';
  }
}
