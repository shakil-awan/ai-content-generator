import 'package:flutter/material.dart';

import '../models/fact_check_source.dart';

/// Authority Configuration
/// Defines the visual properties for each authority level
class AuthorityConfig {
  final String icon;
  final String label;
  final Color color;
  final String description;

  AuthorityConfig({
    required this.icon,
    required this.label,
    required this.color,
    required this.description,
  });
}

/// Source Authority Badge Widget
/// Displays an authority level badge for fact-check sources
/// with appropriate icon, label, and color coding
class SourceAuthorityBadge extends StatelessWidget {
  final FactCheckSource source;
  final bool compact;

  const SourceAuthorityBadge({
    super.key,
    required this.source,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getAuthorityConfig(source.authorityLevel);

    if (compact) {
      return _buildCompactBadge(config);
    }

    return _buildFullBadge(config);
  }

  Widget _buildFullBadge(AuthorityConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        border: Border.all(color: config.color, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            config.icon,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: config.color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBadge(AuthorityConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            config.icon,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  AuthorityConfig _getAuthorityConfig(String level) {
    switch (level.toLowerCase()) {
      case 'government':
        return AuthorityConfig(
          icon: '🏛️',
          label: 'Government',
          color: const Color(0xFF1565C0), // Blue 800
          description: 'Government agency or official source',
        );
      case 'academic':
        return AuthorityConfig(
          icon: '🎓',
          label: 'Academic',
          color: const Color(0xFF6A1B9A), // Purple 800
          description: 'Academic institution or educational source',
        );
      case 'organization':
        return AuthorityConfig(
          icon: '🌍',
          label: 'International Org',
          color: const Color(0xFF00695C), // Teal 800
          description: 'International organization or NGO',
        );
      case 'news':
        return AuthorityConfig(
          icon: '📰',
          label: 'News Outlet',
          color: const Color(0xFFE65100), // Orange 900
          description: 'News publication or media outlet',
        );
      default:
        return AuthorityConfig(
          icon: '🌐',
          label: 'Web Source',
          color: const Color(0xFF757575), // Grey 600
          description: 'General web source',
        );
    }
  }
}

/// Authority Level Info Card
/// Shows detailed information about an authority level
/// Useful for tooltips or info panels
class AuthorityLevelInfo extends StatelessWidget {
  final String authorityLevel;

  const AuthorityLevelInfo({
    super.key,
    required this.authorityLevel,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getAuthorityConfig(authorityLevel);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.05),
        border: Border.all(color: config.color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                config.icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                config.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: config.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            config.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  AuthorityConfig _getAuthorityConfig(String level) {
    switch (level.toLowerCase()) {
      case 'government':
        return AuthorityConfig(
          icon: '🏛️',
          label: 'Government',
          color: const Color(0xFF1565C0),
          description: 'Government agency or official source',
        );
      case 'academic':
        return AuthorityConfig(
          icon: '🎓',
          label: 'Academic',
          color: const Color(0xFF6A1B9A),
          description: 'Academic institution or educational source',
        );
      case 'organization':
        return AuthorityConfig(
          icon: '🌍',
          label: 'International Org',
          color: const Color(0xFF00695C),
          description: 'International organization or NGO',
        );
      case 'news':
        return AuthorityConfig(
          icon: '📰',
          label: 'News Outlet',
          color: const Color(0xFFE65100),
          description: 'News publication or media outlet',
        );
      default:
        return AuthorityConfig(
          icon: '🌐',
          label: 'Web Source',
          color: const Color(0xFF757575),
          description: 'General web source',
        );
    }
  }
}
