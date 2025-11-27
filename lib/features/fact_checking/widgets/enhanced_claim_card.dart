import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/fact_check_claim.dart';
import '../models/fact_check_source.dart';
import 'source_authority_badge.dart';

/// Enhanced Claim Card Widget
/// Displays a fact-check claim with rich source information including:
/// - Source titles, snippets, and URLs
/// - Authority badges
/// - Clickable source links
/// - Evidence details
class EnhancedClaimCard extends StatelessWidget {
  final FactCheckClaim claim;
  final int claimNumber;

  const EnhancedClaimCard({
    super.key,
    required this.claim,
    required this.claimNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Gap(16),
          _buildClaimText(),
          const Gap(20),
          _buildVerificationStatus(),
          if (claim.sources.isNotEmpty) ...[
            const Gap(16),
            _buildSourcesList(),
          ] else if (claim.source != null && claim.source!.isNotEmpty) ...[
            // Fallback: Show legacy source for old content
            const Gap(16),
            _buildLegacySource(),
          ],
          if (claim.evidence.isNotEmpty) ...[const Gap(12), _buildEvidence()],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '📌 CLAIM #$claimNumber',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B82F6),
            ),
          ),
        ),
        const Spacer(),
        _buildConfidenceBadge(),
      ],
    );
  }

  Widget _buildConfidenceBadge() {
    final percentage = (claim.confidence * 100).round();
    final color = _getConfidenceColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14, color: color),
          const Gap(4),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimText() {
    return Text(
      '"${claim.claim}"',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
        height: 1.5,
      ),
    );
  }

  Widget _buildVerificationStatus() {
    final icon = claim.verified ? Icons.check_circle : Icons.warning;
    final color = _getConfidenceColor();

    // Handle legacy content (no sources list)
    final hasDetailedSources = claim.sources.isNotEmpty;
    final status = claim.verified
        ? (hasDetailedSources
              ? 'VERIFIED BY ${claim.sources.length} AUTHORITATIVE SOURCES:'
              : 'VERIFIED:')
        : 'PARTIALLY VERIFIED:';

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const Gap(8),
        Expanded(
          child: Text(
            status,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSourcesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: claim.sources.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSourceCard(entry.key + 1, entry.value),
        );
      }).toList(),
    );
  }

  Widget _buildSourceCard(int index, FactCheckSource source) {
    return InkWell(
      onTap: () => _openUrl(source.url),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getSourceDisplayName(source),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        source.domain,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                SourceAuthorityBadge(source: source, compact: true),
                const Gap(8),
                const Icon(Icons.open_in_new, size: 16, color: Colors.blue),
              ],
            ),
            if (source.snippet.isNotEmpty) ...[
              const Gap(10),
              Text(
                source.snippet,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Gap(8),
            Text(
              source.displayUrl,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegacySource() {
    // Display legacy source format for old content
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.link, size: 16, color: Colors.grey),
          const Gap(8),
          Expanded(
            child: Text(
              claim.source!,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidence() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
          const Gap(8),
          Expanded(
            child: Text(
              claim.evidence,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSourceDisplayName(FactCheckSource source) {
    // Map known domains to friendly names
    final domainMap = {
      'climate.gov': '🌐 NOAA Climate.gov',
      'ipcc.ch': '🏛️ IPCC',
      'nasa.gov': '🚀 NASA',
      'epa.gov': '🌿 EPA',
      'noaa.gov': '🌊 NOAA',
      'who.int': '🏥 WHO',
      'nature.com': '📚 Nature',
      'science.org': '🔬 Science',
      'cdc.gov': '🏥 CDC',
      'nih.gov': '🏥 NIH',
      'un.org': '🌍 United Nations',
      'worldbank.org': '🏛️ World Bank',
    };

    // Check if domain contains any known keywords
    for (var entry in domainMap.entries) {
      if (source.domain.contains(entry.key)) {
        return entry.value;
      }
    }

    // Fallback to title
    return source.title;
  }

  Color _getBorderColor() {
    if (claim.confidence >= 0.70) return Colors.green;
    if (claim.confidence >= 0.50) return Colors.orange;
    return Colors.red;
  }

  Color _getConfidenceColor() {
    if (claim.confidence >= 0.70) return Colors.green;
    if (claim.confidence >= 0.50) return Colors.orange;
    return Colors.red;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
