import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:markdown/markdown.dart' as md;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/content_generation_response.dart';

/// Result payload returned after building the PDF document.
class ContentPdfExportResult {
  final Uint8List bytes;
  final String filename;

  const ContentPdfExportResult({required this.bytes, required this.filename});
}

/// Builds branded PDF exports for generated content so multiple screens can reuse the layout.
class ContentPdfExporter {
  ContentPdfExporter({
    this.brandName = 'Summarly',
    this.reportTagline = 'Intelligence Brief',
  });

  final String brandName;
  final String reportTagline;

  static _PdfFonts? _cachedFonts;

  Future<ContentPdfExportResult> build(
    ContentGenerationResponse content,
  ) async {
    final fonts = await _loadFonts();
    final exportedAt = DateTime.now();
    final document = pw.Document(
      theme: pw.ThemeData.withFont(
        base: fonts.regular,
        bold: fonts.bold,
        italic: fonts.italic,
        fontFallback: [fonts.regular],
      ),
    );

    final headerTitle = content.title?.isNotEmpty == true
        ? content.title!
        : 'Generated ${content.contentType}';

    document.addPage(
      pw.MultiPage(
        pageTheme: _buildPageTheme(),
        header: (context) =>
            _buildHeader(headerTitle, content.createdAt, exportedAt),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildSummarySection(content),
          _buildQualitySection(content.qualityMetrics),
          if (content.factCheckResults.checked &&
              content.factCheckResults.claims.isNotEmpty)
            _buildFactCheckSection(content.factCheckResults),
          if (content.humanization.applied)
            _buildHumanizationSection(content.humanization),
          _buildContentSection(content.content),
        ],
      ),
    );

    final filename = _buildFileName(content, exportedAt);
    final bytes = await document.save();

    return ContentPdfExportResult(bytes: bytes, filename: filename);
  }

  pw.PageTheme _buildPageTheme() {
    return pw.PageTheme(
      margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 50),
      buildBackground: (_) => _buildStamp(),
    );
  }

  pw.Widget _buildStamp() {
    return pw.Positioned.fill(
      child: pw.Center(
        child: pw.Transform.rotate(
          angle: -math.pi / 8,
          child: pw.Opacity(
            opacity: 0.08,
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 36,
                vertical: 12,
              ),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blueGrey200, width: 1),
                borderRadius: pw.BorderRadius.circular(16),
              ),
              child: pw.Text(
                brandName,
                style: _fontStyle(
                  fontSize: 48,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey300,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  pw.Widget _buildHeader(
    String title,
    DateTime generatedAt,
    DateTime exportedAt,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                brandName,
                style: _fontStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                reportTagline,
                style: _fontStyle(fontSize: 10, color: PdfColors.blueGrey700),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                title,
                style: _fontStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Generated: ${_formatReadableTimestamp(generatedAt)}',
                style: _pdfLabelStyle,
              ),
              pw.Text(
                'Exported: ${_formatReadableTimestamp(exportedAt)}',
                style: _fontStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 12),
      child: pw.Text(
        '$brandName • Page ${context.pageNumber}/${context.pagesCount}',
        style: _fontStyle(fontSize: 9, color: PdfColors.grey600),
      ),
    );
  }

  pw.Widget _buildSummarySection(ContentGenerationResponse content) {
    final metadata = [
      _buildKeyValueRow('Content Type', content.contentType),
      _buildKeyValueRow('Word Count', '${content.actualWordCount} words'),
      _buildKeyValueRow(
        'Estimated Read',
        '${content.estimatedReadTime} minute(s)',
      ),
      _buildKeyValueRow(
        'Quality Score',
        '${content.qualityMetrics.overallScore.toStringAsFixed(1)}/10',
      ),
      _buildKeyValueRow(
        'Generated At',
        _formatReadableTimestamp(content.createdAt),
      ),
    ];

    final metaDescription = content.metaDescription?.trim();

    return _buildCard(
      title: 'Content Overview',
      children: [
        ...metadata,
        if (metaDescription != null && metaDescription.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Text('Meta Description', style: _pdfLabelStyle),
          pw.Text(metaDescription, style: _pdfBodyStyle),
        ],
      ],
    );
  }

  pw.Widget _buildQualitySection(QualityMetrics metrics) {
    final normalized = _normalizeQuality(metrics.overallScore);
    final grade = _qualityGrade(normalized);
    final descriptor = _qualityDescriptor(normalized);
    final percentLabel = '${(normalized * 100).toStringAsFixed(0)}%';
    final badgeColor = _qualityColor(normalized);
    final badgeBackground = _qualityBackgroundColor(normalized);
    final breakdownRows = _qualityMetricRows(metrics);
    final extraSignals = _qualitySignals(metrics);

    return _buildCard(
      title: 'Quality Score Insights',
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: badgeBackground,
            borderRadius: pw.BorderRadius.circular(10),
            border: pw.Border.all(color: badgeColor, width: 0.8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Overall Quality', style: _pdfLabelStyle),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '$grade ($percentLabel)',
                    style: _fontStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(descriptor, style: _pdfBodyStyle),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Score', style: _pdfLabelStyle),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '${metrics.overallScore.toStringAsFixed(1)}/10',
                    style: _fontStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: const ['Metric', 'Score', 'Assessment'],
          data: breakdownRows,
          headerStyle: _fontStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
          ),
          cellStyle: _pdfBodyStyle,
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
          border: pw.TableBorder.symmetric(
            inside: const pw.BorderSide(color: PdfColors.grey300, width: 0.4),
            outside: const pw.BorderSide(color: PdfColors.grey300, width: 0.6),
          ),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 4,
          ),
        ),
        if (extraSignals.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text('Additional Signals', style: _pdfLabelStyle),
          pw.SizedBox(height: 4),
          ...extraSignals.map(
            (signal) => pw.Bullet(text: signal, style: _pdfBodyStyle),
          ),
        ],
      ],
    );
  }

  pw.Widget _buildFactCheckSection(FactCheckResults factCheck) {
    final claimWidgets = factCheck.claims
        .asMap()
        .entries
        .map((entry) => _buildFactClaimCard(entry.value, entry.key))
        .toList();

    return _buildCard(
      title: 'Fact-Check Summary',
      children: [
        _buildFactOverviewGrid(factCheck),
        pw.SizedBox(height: 12),
        ...claimWidgets,
      ],
    );
  }

  pw.Widget _buildFactOverviewGrid(FactCheckResults factCheck) {
    final tiles = <pw.Widget>[
      _buildFactOverviewTile(
        'Claims Verified',
        '${factCheck.claimsVerified}/${factCheck.claimsFound}',
        'Confirmed statements',
      ),
      _buildFactOverviewTile(
        'Overall Confidence',
        '${factCheck.overallConfidence.toStringAsFixed(0)}%',
        'Average verification certainty',
      ),
      _buildFactOverviewTile(
        'Verification Time',
        '${factCheck.verificationTime.toStringAsFixed(1)}s',
        'Time spent validating',
      ),
      _buildFactOverviewTile(
        'Searches Used',
        '${factCheck.totalSearchesUsed} Google CSE queries',
        'Cross-referenced sources',
      ),
    ];

    return pw.Wrap(spacing: 12, runSpacing: 12, children: tiles);
  }

  pw.Widget _buildFactOverviewTile(String label, String value, String subtext) {
    return pw.Container(
      width: 220,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.blue200, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: _pdfLabelStyle),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: _fontStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            subtext,
            style: _fontStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFactClaimCard(FactCheckClaim claim, int index) {
    final confidence = _confidenceToPercent(claim.confidence);
    final statusColor = claim.verified
        ? PdfColors.green700
        : PdfColors.orange700;
    final statusBackground = claim.verified
        ? PdfColors.green50
        : PdfColors.orange50;
    final statusLabel = claim.verified ? 'Verified' : 'Needs Review';

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.blue100),
        boxShadow: [
          pw.BoxShadow(
            blurRadius: 6,
            color: PdfColors.blueGrey100,
            offset: const PdfPoint(0, 1),
          ),
        ],
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Claim #${index + 1}', style: _pdfLabelStyle),
                    pw.SizedBox(height: 4),
                    pw.Text(claim.claim, style: _pdfBodyStyle),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: statusBackground,
                  borderRadius: pw.BorderRadius.circular(16),
                  border: pw.Border.all(color: statusColor, width: 0.5),
                ),
                child: pw.Text(
                  '$statusLabel • ${confidence.toStringAsFixed(0)}% confidence',
                  style: _fontStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: statusColor,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
          if (claim.evidence.trim().isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text('Evidence Highlights', style: _pdfLabelStyle),
            pw.SizedBox(height: 2),
            pw.Text(claim.evidence.trim(), style: _pdfBodyStyle),
          ],
          if (claim.sources.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Text('Sources (${claim.sources.length})', style: _pdfLabelStyle),
            pw.SizedBox(height: 4),
            ...claim.sources.map(_buildFactSourceEntry),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildFactSourceEntry(FactCheckSource source) {
    final url = source.url.trim();
    final hasUrl = url.isNotEmpty;
    final authority = source.authorityLevel.trim();
    final domainLine = authority.isNotEmpty
        ? '${source.domain} • $authority'
        : source.domain;
    final titleWidget = hasUrl
        ? pw.UrlLink(
            destination: url,
            child: pw.Text(
              source.title,
              style: _fontStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue700,
              ),
            ),
          )
        : pw.Text(
            source.title,
            style: _fontStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          );

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue100),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          titleWidget,
          if (hasUrl)
            pw.Text(
              url,
              style: _fontStyle(fontSize: 9, color: PdfColors.blue500),
            ),
          pw.SizedBox(height: 4),
          pw.Text(
            domainLine,
            style: _fontStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          if (source.snippet.trim().isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text(source.snippet.trim(), style: _pdfBodyStyle),
          ],
        ],
      ),
    );
  }

  List<List<String>> _qualityMetricRows(QualityMetrics metrics) {
    return [
      _qualityMetricRow('Readability', metrics.readabilityScore),
      _qualityMetricRow('Completeness', metrics.completenessScore),
      _qualityMetricRow('SEO Optimization', metrics.seoScore),
      _qualityMetricRow('Grammar & Style', metrics.grammarScore),
      _qualityMetricRow('Originality Safeguards', metrics.originalityScore),
      _qualityMetricRow('Fact-Check Alignment', metrics.factCheckScore),
      _qualityMetricRow('AI Detection Shield', metrics.aiDetectionScore),
    ];
  }

  List<String> _qualityMetricRow(String label, double score) {
    final normalized = _normalizeQuality(score);
    final percent = (normalized * 100).round();
    final assessment = _qualityDescriptor(normalized);
    return [label, '${score.toStringAsFixed(1)}/10', '$assessment ($percent%)'];
  }

  List<String> _qualitySignals(QualityMetrics metrics) {
    final signals = <String>[];
    void addSignal(String label, double value) {
      final percent = _qualityPercent(value);
      if (percent > 0) {
        signals.add('$label at $percent% confidence');
      }
    }

    addSignal('Originality safeguards', metrics.originalityScore);
    addSignal('Fact-check reinforcement', metrics.factCheckScore);
    addSignal('AI detection mitigation', metrics.aiDetectionScore);
    return signals;
  }

  double _normalizeQuality(double score) {
    if (score.isNaN) {
      return 0;
    }
    final bounded = score.clamp(0, 10).toDouble();
    return bounded / 10;
  }

  int _qualityPercent(double score) {
    return (_normalizeQuality(score) * 100).round();
  }

  String _qualityGrade(double normalized) {
    if (normalized >= 0.95) return 'A+';
    if (normalized >= 0.85) return 'A';
    if (normalized >= 0.70) return 'B';
    if (normalized >= 0.60) return 'C';
    return 'D';
  }

  String _qualityDescriptor(double normalized) {
    if (normalized >= 0.95) return 'Excellent';
    if (normalized >= 0.85) return 'Great';
    if (normalized >= 0.70) return 'Good';
    if (normalized >= 0.60) return 'Fair';
    return 'Needs Improvement';
  }

  PdfColor _qualityColor(double normalized) {
    if (normalized >= 0.85) return PdfColors.green800;
    if (normalized >= 0.70) return PdfColors.blue700;
    if (normalized >= 0.60) return PdfColors.orange700;
    return PdfColors.red700;
  }

  PdfColor _qualityBackgroundColor(double normalized) {
    if (normalized >= 0.85) return PdfColors.green50;
    if (normalized >= 0.70) return PdfColors.blue50;
    if (normalized >= 0.60) return PdfColors.orange50;
    return PdfColors.red50;
  }

  pw.Widget _buildHumanizationSection(HumanizationResult result) {
    final improvement = (result.beforeScore - result.afterScore).clamp(
      -999,
      999,
    );
    final improvementPercent = result.beforeScore == 0
        ? 0
        : (improvement / result.beforeScore * 100);
    final levelLabel = (result.level?.isNotEmpty ?? false)
        ? result.level!
        : 'balanced';

    return _buildCard(
      title: 'Humanization Summary',
      children: [
        _buildKeyValueRow(
          'Level',
          levelLabel[0].toUpperCase() + levelLabel.substring(1),
        ),
        _buildKeyValueRow(
          'AI Score (Before)',
          '${result.beforeScore.toStringAsFixed(0)}%',
        ),
        _buildKeyValueRow(
          'AI Score (After)',
          '${result.afterScore.toStringAsFixed(0)}%',
        ),
        _buildKeyValueRow(
          'Improvement',
          '${improvement.toStringAsFixed(1)} pts (${improvementPercent.toStringAsFixed(1)}% reduction)',
        ),
        if (result.processingTime > 0)
          _buildKeyValueRow(
            'Processing Time',
            '${result.processingTime.toStringAsFixed(1)}s',
          ),
        if (result.humanizedAt != null)
          _buildKeyValueRow(
            'Humanized On',
            _formatReadableTimestamp(result.humanizedAt!),
          ),
      ],
    );
  }

  pw.Widget _buildContentSection(String markdown) {
    final contentBlocks = _markdownToPdf(markdown);

    return _buildCard(
      title: 'Generated Content',
      children: contentBlocks.isNotEmpty
          ? contentBlocks
          : [pw.Text('No content available', style: _pdfBodyStyle)],
    );
  }

  List<pw.Widget> _markdownToPdf(String markdown) {
    final document = md.Document(
      encodeHtml: false,
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );
    final nodes = document.parseLines(const LineSplitter().convert(markdown));
    final widgets = <pw.Widget>[];

    for (final node in nodes) {
      final block = _buildMarkdownBlock(node);
      if (block != null) {
        widgets.add(block);
      }
    }

    return widgets;
  }

  pw.Widget? _buildMarkdownBlock(md.Node node) {
    if (node is md.Element) {
      switch (node.tag) {
        case 'h1':
          return _buildMarkdownHeading(node, 1);
        case 'h2':
          return _buildMarkdownHeading(node, 2);
        case 'h3':
          return _buildMarkdownHeading(node, 3);
        case 'h4':
          return _buildMarkdownHeading(node, 4);
        case 'h5':
          return _buildMarkdownHeading(node, 5);
        case 'h6':
          return _buildMarkdownHeading(node, 6);
        case 'p':
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: _buildParagraphFromNodes(node.children),
          );
        case 'ul':
          return _buildMarkdownList(node, ordered: false);
        case 'ol':
          return _buildMarkdownList(node, ordered: true);
        case 'blockquote':
          return _buildMarkdownBlockquote(node);
        case 'pre':
          return _buildMarkdownCodeBlock(node);
        case 'hr':
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8),
            child: pw.Divider(color: PdfColors.grey400, thickness: 0.6),
          );
        case 'table':
          return _buildMarkdownTable(node);
        default:
          if (node.children != null && node.children!.isNotEmpty) {
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: _buildParagraphFromNodes(node.children),
            );
          }
      }
    } else if (node is md.Text) {
      final text = node.text.trim();
      if (text.isNotEmpty) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(text, style: _pdfBodyStyle),
        );
      }
    }
    return null;
  }

  pw.Widget _buildMarkdownHeading(md.Element element, int level) {
    final text = element.textContent.trim();
    final fontSizes = {1: 20.0, 2: 17.0, 3: 15.0, 4: 13.0, 5: 12.0, 6: 11.0};
    return pw.Padding(
      padding: pw.EdgeInsets.only(top: level == 1 ? 16 : 10, bottom: 6),
      child: pw.Text(
        text,
        style: _fontStyle(
          fontSize: fontSizes[level] ?? 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey900,
        ),
      ),
    );
  }

  pw.Widget _buildMarkdownList(md.Element element, {required bool ordered}) {
    final items =
        element.children
            ?.whereType<md.Element>()
            .where((child) => child.tag == 'li')
            .toList() ??
        <md.Element>[];

    if (items.isEmpty) {
      return pw.SizedBox.shrink();
    }

    final children = <pw.Widget>[];
    for (var i = 0; i < items.length; i++) {
      children.add(_buildMarkdownListItem(items[i], index: ordered ? i : null));
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Column(children: children),
    );
  }

  pw.Widget _buildMarkdownListItem(md.Element element, {int? index}) {
    final inlineNodes = <md.Node>[];
    final nestedBlocks = <pw.Widget>[];

    for (final child in element.children ?? []) {
      if (child is md.Element && (child.tag == 'ul' || child.tag == 'ol')) {
        final nested = _buildMarkdownList(child, ordered: child.tag == 'ol');
        nestedBlocks.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 18, top: 4),
            child: nested,
          ),
        );
      } else {
        inlineNodes.add(child);
      }
    }

    final bullet = index != null ? '${index + 1}.' : '•';
    final primaryContent = inlineNodes.isNotEmpty
        ? _buildParagraphFromNodes(inlineNodes)
        : pw.SizedBox.shrink();

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 18,
                child: pw.Text(bullet, style: _pdfBodyStyle),
              ),
              pw.Expanded(child: primaryContent),
            ],
          ),
          ...nestedBlocks,
        ],
      ),
    );
  }

  pw.Widget _buildMarkdownBlockquote(md.Element element) {
    final children = <pw.Widget>[];
    for (final child in element.children ?? []) {
      final block = _buildMarkdownBlock(child);
      if (block != null) {
        children.add(block);
      }
    }

    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 6),
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border(
          left: pw.BorderSide(color: PdfColors.blue200, width: 3),
        ),
      ),
      child: children.isNotEmpty
          ? pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: children,
            )
          : pw.Text(
              element.textContent.trim(),
              style: _fontStyle(
                fontSize: 11,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.blueGrey800,
              ),
            ),
    );
  }

  pw.Widget _buildMarkdownCodeBlock(md.Element element) {
    final codeText = element.textContent.trimRight();
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.symmetric(vertical: 6),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Text(
        codeText,
        style: _fontStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.normal,
          color: PdfColors.grey800,
        ),
      ),
    );
  }

  pw.Widget? _buildMarkdownTable(md.Element element) {
    final rows = <List<String>>[];

    void collectRows(md.Element parent) {
      for (final child in parent.children ?? []) {
        if (child is md.Element && child.tag == 'tr') {
          final cells = <String>[];
          for (final cell in child.children ?? []) {
            if (cell is md.Element && (cell.tag == 'th' || cell.tag == 'td')) {
              cells.add(cell.textContent.trim());
            }
          }
          if (cells.isNotEmpty) {
            rows.add(cells);
          }
        } else if (child is md.Element) {
          collectRows(child);
        }
      }
    }

    collectRows(element);

    if (rows.isEmpty) {
      return null;
    }

    final headers = rows.first;
    final remainingRows = rows.length > 1 ? rows.sublist(1) : <List<String>>[];
    final hasHeaders = headers.isNotEmpty;
    final data = hasHeaders ? remainingRows : rows;

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.TableHelper.fromTextArray(
        headers: hasHeaders ? headers : null,
        data: data,
        headerStyle: _fontStyle(fontWeight: pw.FontWeight.bold),
        cellStyle: _pdfBodyStyle,
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
        cellAlignment: pw.Alignment.centerLeft,
      ),
    );
  }

  pw.Widget _buildParagraphFromNodes(List<md.Node>? nodes) {
    final spans = <pw.InlineSpan>[];
    if (nodes != null) {
      for (final child in nodes) {
        spans.addAll(_buildInlineSpans(child));
      }
    }

    if (spans.isEmpty) {
      return pw.SizedBox.shrink();
    }

    return pw.RichText(
      text: pw.TextSpan(style: _pdfBodyStyle, children: spans),
    );
  }

  List<pw.InlineSpan> _buildInlineSpans(
    md.Node node, {
    _MarkdownInlineStyle style = const _MarkdownInlineStyle(),
  }) {
    if (node is md.Text) {
      final text = node.text;
      if (text.isEmpty) {
        return const <pw.InlineSpan>[];
      }
      return [pw.TextSpan(text: text, style: _markdownTextStyle(style))];
    }

    if (node is! md.Element) {
      return const <pw.InlineSpan>[];
    }

    var nextStyle = style;
    switch (node.tag) {
      case 'strong':
      case 'b':
        nextStyle = nextStyle.copyWith(bold: true);
        break;
      case 'em':
      case 'i':
        nextStyle = nextStyle.copyWith(italic: true);
        break;
      case 'code':
        nextStyle = nextStyle.copyWith(isCode: true);
        break;
      case 'a':
        nextStyle = nextStyle.copyWith(isLink: true);
        break;
      case 'br':
        return [pw.TextSpan(text: '\n', style: _markdownTextStyle(nextStyle))];
    }

    final spans = <pw.InlineSpan>[];
    if (node.children != null && node.children!.isNotEmpty) {
      for (final child in node.children!) {
        spans.addAll(_buildInlineSpans(child, style: nextStyle));
      }
    } else if (node.textContent.isNotEmpty) {
      spans.add(
        pw.TextSpan(
          text: node.textContent,
          style: _markdownTextStyle(nextStyle),
        ),
      );
    }

    if (node.tag == 'a' && node.attributes['href'] != null) {
      final url = node.attributes['href']!;
      spans.add(
        pw.TextSpan(
          text: ' ($url)',
          style: _fontStyle(fontSize: 9, color: PdfColors.blue700),
        ),
      );
    }

    return spans;
  }

  pw.TextStyle _markdownTextStyle(_MarkdownInlineStyle style) {
    return _fontStyle(
      fontSize: style.isCode ? 10 : 11,
      fontWeight: style.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      fontStyle: style.italic ? pw.FontStyle.italic : pw.FontStyle.normal,
      color: style.isLink ? PdfColors.blue700 : PdfColors.grey800,
    );
  }

  pw.Widget _buildCard({
    required String title,
    required List<pw.Widget> children,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 18),
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: _pdfSectionTitleStyle),
          pw.SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _buildKeyValueRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 120,
            child: pw.Text(label, style: _pdfLabelStyle),
          ),
          pw.Expanded(child: pw.Text(value, style: _pdfBodyStyle)),
        ],
      ),
    );
  }

  String _buildFileName(
    ContentGenerationResponse content,
    DateTime generatedOn,
  ) {
    final raw = content.title?.isNotEmpty == true
        ? content.title!
        : content.contentType;
    final sanitized = raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp('_+'), '_')
        .trim();
    final idLength = content.id.length > 8 ? 8 : content.id.length;
    final slug = sanitized.isEmpty
        ? content.id.substring(0, idLength)
        : sanitized;
    return 'ai_content_${slug}_${_formatDateStamp(generatedOn)}.pdf';
  }

  String _formatDateStamp(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatReadableTimestamp(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[date.month - 1];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$month ${date.day}, ${date.year} • $hour:$minute $period';
  }

  double _confidenceToPercent(double confidence) {
    return confidence <= 1 ? confidence * 100 : confidence;
  }

  pw.TextStyle _fontStyle({
    double fontSize = 11,
    PdfColor color = PdfColors.grey800,
    pw.FontWeight fontWeight = pw.FontWeight.normal,
    double? height,
    pw.FontStyle fontStyle = pw.FontStyle.normal,
  }) {
    final fonts = _cachedFonts;
    pw.Font? selectedFont;
    if (fontStyle == pw.FontStyle.italic) {
      selectedFont = fonts?.italic;
    } else if (fontWeight == pw.FontWeight.bold) {
      selectedFont = fonts?.bold;
    } else {
      selectedFont = fonts?.regular;
    }

    return pw.TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      font: selectedFont,
      fontStyle: fontStyle,
      fontFallback: fonts != null ? [fonts.regular] : const [],
      height: height,
    );
  }

  pw.TextStyle get _pdfBodyStyle =>
      _fontStyle(fontSize: 11, height: 1.3, color: PdfColors.grey800);

  pw.TextStyle get _pdfLabelStyle => _fontStyle(
    fontSize: 10,
    color: PdfColors.grey600,
    fontWeight: pw.FontWeight.bold,
  );

  pw.TextStyle get _pdfSectionTitleStyle => _fontStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue900,
  );

  Future<_PdfFonts> _loadFonts() async {
    if (_cachedFonts != null) return _cachedFonts!;

    final regularData = await rootBundle.load('fonts/Inter-Regular.ttf');
    final boldData = await rootBundle.load('fonts/Inter-SemiBold.ttf');
    final mediumData = await rootBundle.load('fonts/Inter-Medium.ttf');

    _cachedFonts = _PdfFonts(
      regular: pw.Font.ttf(regularData),
      bold: pw.Font.ttf(boldData),
      italic: pw.Font.ttf(mediumData),
    );

    return _cachedFonts!;
  }
}

class _PdfFonts {
  final pw.Font regular;
  final pw.Font bold;
  final pw.Font italic;

  const _PdfFonts({
    required this.regular,
    required this.bold,
    required this.italic,
  });
}

class _MarkdownInlineStyle {
  final bool bold;
  final bool italic;
  final bool isCode;
  final bool isLink;

  const _MarkdownInlineStyle({
    this.bold = false,
    this.italic = false,
    this.isCode = false,
    this.isLink = false,
  });

  _MarkdownInlineStyle copyWith({
    bool? bold,
    bool? italic,
    bool? isCode,
    bool? isLink,
  }) {
    return _MarkdownInlineStyle(
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      isCode: isCode ?? this.isCode,
      isLink: isLink ?? this.isLink,
    );
  }
}
