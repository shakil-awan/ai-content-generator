import 'package:flutter/foundation.dart';

/// Structured dev-only test data for the video script generation form.
///
/// These seeds let engineers populate the video script form with realistic sample
/// topics instantly so manual typing isn't needed during iterative UI work.

class VideoScriptTestData {
  final String topic;
  final String platform;
  final int duration;
  final String targetAudience;
  final List<String> keyPoints;
  final String cta;
  final String tone;
  final bool includeHooks;
  final bool includeCta;

  const VideoScriptTestData({
    required this.topic,
    required this.platform,
    required this.duration,
    this.targetAudience = '',
    this.keyPoints = const [],
    this.cta = '',
    this.tone = 'professional',
    this.includeHooks = true,
    this.includeCta = true,
  });
}

class VideoScriptTestSeeder {
  VideoScriptTestSeeder({List<VideoScriptTestData>? customSeeds})
    : _seeds = customSeeds ?? _defaultSeeds;

  final List<VideoScriptTestData> _seeds;
  int _cursor = 0;

  /// Returns the very first seed so the UI always boots with known data.
  VideoScriptTestData initialSeed() {
    _cursor = 0;
    return _seeds[_cursor];
  }

  /// Moves forward through the curated samples, wrapping once we reach the end.
  VideoScriptTestData nextSeed() {
    _cursor = (_cursor + 1) % _seeds.length;
    return _seeds[_cursor];
  }

  /// Moves backwards through the curated samples, wrapping to the end if needed.
  VideoScriptTestData previousSeed() {
    _cursor = (_cursor - 1) % _seeds.length;
    if (_cursor < 0) {
      _cursor += _seeds.length;
    }
    return _seeds[_cursor];
  }

  static bool get isEnabled => kDebugMode;
}

const List<VideoScriptTestData> _defaultSeeds = [
  VideoScriptTestData(
    topic: 'How to boost productivity with AI tools in 2025',
    platform: 'youtube',
    duration: 180,
    targetAudience: 'Marketing professionals and content creators',
    keyPoints: [
      'ChatGPT for content ideation',
      'Midjourney for visual assets',
      'Jasper for copywriting automation',
    ],
    cta: 'Visit our website for a free productivity toolkit',
    tone: 'professional',
    includeHooks: true,
    includeCta: true,
  ),
  VideoScriptTestData(
    topic: '5 AI mistakes that are costing you money',
    platform: 'youtube',
    duration: 300,
    targetAudience: 'Small business owners and entrepreneurs',
    keyPoints: [
      'Not training AI on your brand voice',
      'Skipping fact-checking automation',
      'Ignoring compliance requirements',
    ],
    cta: 'Download our AI cost calculator',
    tone: 'informative',
    includeHooks: true,
    includeCta: true,
  ),
  VideoScriptTestData(
    topic: 'Behind the scenes: How we built an AI-powered app',
    platform: 'youtube',
    duration: 480,
    targetAudience: 'Developers and tech enthusiasts',
    keyPoints: [
      'Choosing the right AI models',
      'Backend architecture decisions',
      'Cost optimization strategies',
    ],
    cta: 'Check out the GitHub repo for code samples',
    tone: 'casual',
    includeHooks: true,
    includeCta: true,
  ),
  VideoScriptTestData(
    topic: 'Quick tip: Automate your social media posts with AI',
    platform: 'tiktok',
    duration: 45,
    targetAudience: 'Content creators and influencers',
    keyPoints: ['Set up posting schedules', 'Generate captions automatically'],
    cta: 'Try it free today',
    tone: 'casual',
    includeHooks: true,
    includeCta: true,
  ),
  VideoScriptTestData(
    topic: 'Day in the life of an AI product manager',
    platform: 'instagram',
    duration: 60,
    targetAudience: 'Aspiring product managers',
    keyPoints: [
      'Morning standup with engineering',
      'Customer research synthesis',
      'Feature prioritization meeting',
    ],
    cta: 'Follow for more PM tips',
    tone: 'casual',
    includeHooks: true,
    includeCta: true,
  ),
  VideoScriptTestData(
    topic: 'AI compliance essentials for enterprise teams',
    platform: 'linkedin',
    duration: 180,
    targetAudience: 'Enterprise IT and legal teams',
    keyPoints: [
      'Data privacy regulations',
      'Audit trail requirements',
      'Vendor due diligence',
    ],
    cta: 'Book a compliance consultation',
    tone: 'professional',
    includeHooks: true,
    includeCta: true,
  ),
  VideoScriptTestData(
    topic: 'Transform your blog into video content with AI',
    platform: 'youtube',
    duration: 240,
    targetAudience: 'Bloggers and content marketers',
    keyPoints: [
      'Repurpose existing blog posts',
      'Generate scripts automatically',
      'Add voiceover and B-roll',
    ],
    cta: 'Start your free trial',
    tone: 'inspirational',
    includeHooks: true,
    includeCta: true,
  ),
  VideoScriptTestData(
    topic: 'Common AI myths debunked',
    platform: 'tiktok',
    duration: 60,
    targetAudience: 'General audience curious about AI',
    keyPoints: [
      'AI will not replace all jobs',
      'AI is not always accurate',
      'Anyone can learn to use AI tools',
    ],
    cta: 'Follow for more AI facts',
    tone: 'humorous',
    includeHooks: true,
    includeCta: true,
  ),
  VideoScriptTestData(
    topic: 'How to create a sustainable AI content workflow',
    platform: 'youtube',
    duration: 360,
    targetAudience: 'Marketing teams and agencies',
    keyPoints: [
      'Set up quality checkpoints',
      'Define brand guidelines',
      'Implement review processes',
    ],
    cta: 'Download our workflow template',
    tone: 'professional',
    includeHooks: true,
    includeCta: true,
  ),
  VideoScriptTestData(
    topic: 'AI tools that saved me 10 hours per week',
    platform: 'instagram',
    duration: 90,
    targetAudience: 'Busy professionals and entrepreneurs',
    keyPoints: [
      'Email automation with AI',
      'Meeting summary generation',
      'Automated reporting dashboards',
    ],
    cta: 'Link in bio for tool recommendations',
    tone: 'inspirational',
    includeHooks: true,
    includeCta: true,
  ),
];
