import 'package:flutter/foundation.dart';

/// Structured dev-only test data for the content generation forms.
///
/// These seeds let engineers populate every form with realistic sample
/// information instantly so manual typing isn't needed during iterative UI
/// work. The first seed is returned deterministically for predictable initial
/// state, subsequent requests iterate through the remaining seeds once before
/// falling back to random picks to keep coverage varied.
class ContentGenerationTestSeeder {
  ContentGenerationTestSeeder({List<ContentGenerationTestData>? customSeeds})
    : _seeds = customSeeds ?? _defaultSeeds;

  final List<ContentGenerationTestData> _seeds;
  int _cursor = 0;

  /// Returns the very first seed so the UI always boots with known data.
  ContentGenerationTestData initialSeed() {
    _cursor = 0;
    return _seeds[_cursor];
  }

  /// Moves forward through the curated samples, wrapping once we reach the end.
  ContentGenerationTestData nextSeed() {
    _cursor = (_cursor + 1) % _seeds.length;
    return _seeds[_cursor];
  }

  /// Moves backwards through the curated samples, wrapping to the end if needed.
  ContentGenerationTestData previousSeed() {
    _cursor = (_cursor - 1) % _seeds.length;
    if (_cursor < 0) {
      _cursor += _seeds.length;
    }
    return _seeds[_cursor];
  }

  static bool get isEnabled => kDebugMode;
}

class ContentGenerationTestData {
  final BlogTestSeed blog;
  final SocialTestSeed social;
  final EmailTestSeed email;
  final VideoTestSeed video;

  const ContentGenerationTestData({
    required this.blog,
    required this.social,
    required this.email,
    required this.video,
  });
}

class BlogTestSeed {
  final String title;
  final String wordCountLabel;
  final String tone;
  final String writingStyle;
  final String? targetAudience;
  final List<String> keyPoints;
  final List<String> seoKeywords;
  final bool includeExamples;
  final bool autoFactCheck;
  final bool includeVisuals;

  const BlogTestSeed({
    required this.title,
    required this.wordCountLabel,
    required this.tone,
    required this.writingStyle,
    required this.targetAudience,
    required this.keyPoints,
    required this.seoKeywords,
    this.includeExamples = true,
    this.autoFactCheck = true,
    this.includeVisuals = false,
  });
}

class SocialTestSeed {
  final String topic;
  final String platform;
  final String tone;
  final bool includeHashtags;
  final bool includeEmoji;
  final bool includeCallToAction;

  const SocialTestSeed({
    required this.topic,
    required this.platform,
    required this.tone,
    this.includeHashtags = true,
    this.includeEmoji = true,
    this.includeCallToAction = true,
  });
}

class EmailTestSeed {
  final String type;
  final String tone;
  final String subject;
  final String? audience;
  final String message;
  final String? callToAction;

  const EmailTestSeed({
    required this.type,
    required this.tone,
    required this.subject,
    required this.audience,
    required this.message,
    required this.callToAction,
  });
}

class VideoTestSeed {
  final String topic;
  final String platform;
  final String duration;
  final String tone;
  final String? audience;

  const VideoTestSeed({
    required this.topic,
    required this.platform,
    required this.duration,
    required this.tone,
    required this.audience,
  });
}

const List<ContentGenerationTestData> _defaultSeeds = [
  ContentGenerationTestData(
    blog: BlogTestSeed(
      title: '11 AI Workflows Every SaaS Marketer Should Automate in 2025',
      wordCountLabel: '1500',
      tone: 'Professional',
      writingStyle: 'Listicle',
      targetAudience: 'B2B SaaS growth teams',
      keyPoints: [
        'Lead scoring with GPT-4o mini',
        'SEO brief generation',
        'Churn-risk outreach automation',
      ],
      seoKeywords: [
        'ai marketing automation',
        'saas workflow templates',
        '2025 ai tools',
      ],
      includeExamples: true,
      autoFactCheck: true,
      includeVisuals: false,
    ),
    social: SocialTestSeed(
      topic: 'Launching a 7-day "Inbox Zero with AI" sprint for founders',
      platform: 'Twitter',
      tone: 'Inspirational',
      includeEmoji: true,
      includeHashtags: true,
      includeCallToAction: true,
    ),
    email: EmailTestSeed(
      type: 'Newsletter',
      tone: 'Friendly',
      subject: '🧠 Workflow of the Week: AI-First Launch Checklists',
      audience: '4,800 early-access subscribers',
      message:
          'Break down how our new checklist builder keeps product launches on schedule with AI nudges, QA gates, and fact-checks.',
      callToAction: 'Preview the template →',
    ),
    video: VideoTestSeed(
      topic: 'YouTube script: “Can AI Run Your Weekly Marketing Standup?”',
      platform: 'YouTube',
      duration: '5 minutes',
      tone: 'Professional',
      audience: 'Marketing leads at startups',
    ),
  ),
  ContentGenerationTestData(
    blog: BlogTestSeed(
      title: 'From Prompt to Prototype: Building MVPs with AI Pairing',
      wordCountLabel: '2000',
      tone: 'Friendly',
      writingStyle: 'How-to',
      targetAudience: 'Indie developers and product hackers',
      keyPoints: [
        'Ideation prompts that uncover real pains',
        'Wireframing with multimodal copilots',
        'Shipping experiments without engineers',
      ],
      seoKeywords: ['ai mvp guide', 'prompt engineering tips', 'nocode ai'],
      includeExamples: true,
      autoFactCheck: false,
      includeVisuals: true,
    ),
    social: SocialTestSeed(
      topic:
          'Thread: lessons from pairing Gemini + FlutterFlow on a fintech MVP',
      platform: 'Twitter',
      tone: 'Professional',
    ),
    email: EmailTestSeed(
      type: 'Announcement',
      tone: 'Professional',
      subject: 'New: AI Pair Programming Kits for Product Teams',
      audience: 'Product managers evaluating AI tools',
      message:
          'We bundled prompts, QA scorecards, and governance policies so you can deploy AI copilots with confidence.',
      callToAction: 'Download the rollout kit',
    ),
    video: VideoTestSeed(
      topic: 'Case study recap: 48-hour fintech MVP build',
      platform: 'LinkedIn',
      duration: '3 minutes',
      tone: 'Professional',
      audience: 'Innovation leads at banks',
    ),
  ),
  ContentGenerationTestData(
    blog: BlogTestSeed(
      title: 'Designing Humane AI Onboarding Flows for Non-Technical Users',
      wordCountLabel: '2500',
      tone: 'Formal',
      writingStyle: 'Case-study',
      targetAudience: 'Enterprise product designers',
      keyPoints: [
        'Progressive disclosure UI patterns',
        'Consent dashboards and transparency logs',
        'When to escalate to human support',
      ],
      seoKeywords: [
        'ai onboarding ux',
        'responsible ai patterns',
        'enterprise adoption playbook',
      ],
      includeExamples: true,
      autoFactCheck: true,
      includeVisuals: true,
    ),
    social: SocialTestSeed(
      topic: 'Carousel: 3 accessibility fails we fixed in our AI onboarding',
      platform: 'LinkedIn',
      tone: 'Professional',
      includeEmoji: false,
    ),
    email: EmailTestSeed(
      type: 'Promotional',
      tone: 'Formal',
      subject: 'See how Acme Bank onboarded 12k staff to AI safely',
      audience: 'Enterprise innovation directors',
      message:
          'We unpack the governance stack, change management workshops, and trust dashboards that kept auditors happy.',
      callToAction: 'Reserve a 20-min walkthrough',
    ),
    video: VideoTestSeed(
      topic: 'Internal comms video: “Your AI copilot safety net”',
      platform: 'YouTube',
      duration: '4 minutes',
      tone: 'Friendly',
      audience: 'Non-technical employees',
    ),
  ),
  ContentGenerationTestData(
    blog: BlogTestSeed(
      title: 'Zero-Click SEO: Turning Fact-Checked Answers into Revenue',
      wordCountLabel: '1000',
      tone: 'Professional',
      writingStyle: 'Comparison',
      targetAudience: 'Content marketing managers',
      keyPoints: [
        'Owning featured snippets with verified stats',
        'Repurposing Q&A for chatbot search',
        'Attribution tracking for AI answer boxes',
      ],
      seoKeywords: [
        'zero click seo strategy',
        'ai fact checking content',
        'featured snippet optimization',
      ],
      includeExamples: true,
      autoFactCheck: true,
      includeVisuals: false,
    ),
    social: SocialTestSeed(
      topic: 'Poll: Does AI rewrite your snippets or kill them?',
      platform: 'LinkedIn',
      tone: 'Professional',
      includeEmoji: false,
    ),
    email: EmailTestSeed(
      type: 'Newsletter',
      tone: 'Professional',
      subject: 'Zero-Click SEO Playbook + Template Download',
      audience: 'Subscribers focused on organic growth',
      message:
          'This issue covers schema tweaks, fact-check automations, and KPI dashboards that prove value in a low-click world.',
      callToAction: 'Grab the Notion template',
    ),
    video: VideoTestSeed(
      topic: 'Whiteboard breakdown: fact-checking workflows for SEO teams',
      platform: 'YouTube',
      duration: '6 minutes',
      tone: 'Professional',
      audience: 'SEO leads',
    ),
  ),
  ContentGenerationTestData(
    blog: BlogTestSeed(
      title: 'How Boutique Agencies Productize AI Services Without Burning Out',
      wordCountLabel: '1800',
      tone: 'Friendly',
      writingStyle: 'Narrative',
      targetAudience: 'Agency founders under 15 people',
      keyPoints: [
        'Build once, sell twice frameworks',
        'Transparent pricing calculators',
        'Client education packs',
      ],
      seoKeywords: [
        'ai services pricing',
        'agency playbooks',
        'productized ai',
      ],
      includeExamples: true,
      autoFactCheck: false,
      includeVisuals: false,
    ),
    social: SocialTestSeed(
      topic: 'Swipe copy: 30-day launch plan for an AI content retainer',
      platform: 'Instagram',
      tone: 'Friendly',
      includeHashtags: true,
      includeEmoji: true,
      includeCallToAction: false,
    ),
    email: EmailTestSeed(
      type: 'Welcome',
      tone: 'Friendly',
      subject: 'Welcome! Here’s your AI agency starter kit',
      audience: 'New subscribers from our workshop',
      message:
          'Inside you will find workflows, sample scopes, and objection-handling scripts to productize AI services fast.',
      callToAction: 'Download starter kit',
    ),
    video: VideoTestSeed(
      topic: 'Reel script: “3 mistakes agencies make packaging AI offers”',
      platform: 'Instagram',
      duration: '60 seconds',
      tone: 'Humorous',
      audience: 'Creative agency owners',
    ),
  ),
  ContentGenerationTestData(
    blog: BlogTestSeed(
      title: 'The Carbon Cost of Prompt Engineering (and How to Offset It)',
      wordCountLabel: '1200',
      tone: 'Formal',
      writingStyle: 'Case-study',
      targetAudience: 'Sustainability leads at AI-first companies',
      keyPoints: [
        'Benchmarking GPU emissions per prompt',
        'Caching strategies for greener inference',
        'Investing in verifiable offsets',
      ],
      seoKeywords: [
        'ai sustainability',
        'green prompt engineering',
        'gpu offsets',
      ],
      includeExamples: true,
      autoFactCheck: true,
      includeVisuals: true,
    ),
    social: SocialTestSeed(
      topic: 'Infographic tease: “What one million prompts emit”',
      platform: 'LinkedIn',
      tone: 'Professional',
      includeEmoji: false,
    ),
    email: EmailTestSeed(
      type: 'Announcement',
      tone: 'Formal',
      subject: 'New research: Measuring AI carbon debt in real time',
      audience: 'CSOs + AI platform leaders',
      message:
          'We partnered with GridZero to release an open dashboard that translates inference usage into CO₂e.',
      callToAction: 'Access the live dashboard',
    ),
    video: VideoTestSeed(
      topic: 'Conference teaser: Greener AI stack in 5 steps',
      platform: 'LinkedIn',
      duration: '2 minutes',
      tone: 'Professional',
      audience: 'Tech sustainability teams',
    ),
  ),
  ContentGenerationTestData(
    blog: BlogTestSeed(
      title: 'AI Sales Battlecards: Turning Gong Calls into Close-Ready Copy',
      wordCountLabel: '900',
      tone: 'Casual',
      writingStyle: 'How-to',
      targetAudience: 'Revenue enablement managers',
      keyPoints: [
        'Surfacing objections automatically',
        'Personalizing proof points',
        'Routing insights to SDR scripts',
      ],
      seoKeywords: ['ai battlecards', 'sales enablement automation'],
      includeExamples: true,
      autoFactCheck: false,
      includeVisuals: false,
    ),
    social: SocialTestSeed(
      topic: 'Hot take: SDR scripts shouldn’t sound robotic in 2025',
      platform: 'LinkedIn',
      tone: 'Casual',
    ),
    email: EmailTestSeed(
      type: 'Promotional',
      tone: 'Professional',
      subject: 'Battlecard Automations Now Ship with Call Snippets',
      audience: 'RevOps leaders evaluating AI tools',
      message:
          'Send us a Gong workspace and we’ll return persona-specific cards with verified stats in <48 hours.',
      callToAction: 'See sample cards',
    ),
    video: VideoTestSeed(
      topic: 'Webinar pitch: “AI Battlecards in under 30 minutes”',
      platform: 'YouTube',
      duration: '8 minutes',
      tone: 'Professional',
      audience: 'Revenue teams',
    ),
  ),
  ContentGenerationTestData(
    blog: BlogTestSeed(
      title: 'Community-Led Product Research Powered by AI Moderators',
      wordCountLabel: '1600',
      tone: 'Friendly',
      writingStyle: 'Narrative',
      targetAudience: 'Community managers + UX researchers',
      keyPoints: [
        'Screening superusers with AI',
        'Running async interviews in Slack',
        'Synthesizing insights into product briefs',
      ],
      seoKeywords: [
        'community product research',
        'ai moderators',
        'ugc insight workflow',
      ],
      includeExamples: true,
      autoFactCheck: true,
      includeVisuals: false,
    ),
    social: SocialTestSeed(
      topic: 'Story: How our AI host pulled 187 insights from Discord',
      platform: 'Twitter',
      tone: 'Friendly',
      includeEmoji: true,
    ),
    email: EmailTestSeed(
      type: 'Newsletter',
      tone: 'Casual',
      subject: 'Community AMA Playbook + Automation Stack',
      audience: 'Product-led community groups',
      message:
          'Deep dive on prompts, guardrails, and scorecards for running always-on AMAs without burning moderators out.',
      callToAction: 'Steal the playbook',
    ),
    video: VideoTestSeed(
      topic: 'Case study montage: Discord → roadmap wins',
      platform: 'YouTube',
      duration: '3 minutes',
      tone: 'Friendly',
      audience: 'Community teams',
    ),
  ),
  ContentGenerationTestData(
    blog: BlogTestSeed(
      title: 'The AI Compliance Survival Kit for Fractional CMOs',
      wordCountLabel: '1400',
      tone: 'Professional',
      writingStyle: 'Comparison',
      targetAudience: 'Fractional CMOs in regulated industries',
      keyPoints: [
        'Regional policy tracker',
        'Approval workflows with traceability',
        'Crisis response macros',
      ],
      seoKeywords: ['ai compliance marketing', 'regulated ai content'],
      includeExamples: true,
      autoFactCheck: true,
      includeVisuals: false,
    ),
    social: SocialTestSeed(
      topic: 'Compliance meme: When legal finally trusts your AI stack',
      platform: 'LinkedIn',
      tone: 'Humorous',
      includeEmoji: true,
    ),
    email: EmailTestSeed(
      type: 'Announcement',
      tone: 'Professional',
      subject: 'New compliance control room for AI marketers',
      audience: 'Agency clients in finance + healthcare',
      message:
          'See how we capture approvals, audit trails, and fact-check receipts in a single dashboard.',
      callToAction: 'Book a sandbox tour',
    ),
    video: VideoTestSeed(
      topic: 'Explainer: “How our AI compliance control room works”',
      platform: 'LinkedIn',
      duration: '4 minutes',
      tone: 'Professional',
      audience: 'Marketing leaders + legal',
    ),
  ),
  ContentGenerationTestData(
    blog: BlogTestSeed(
      title: 'Hyperlocal AI Newsletters: Scaling City Launches in 48 Hours',
      wordCountLabel: '1700',
      tone: 'Professional',
      writingStyle: 'How-to',
      targetAudience: 'Local media startups',
      keyPoints: [
        'Data sources for neighborhood credibility',
        'Fact-checking municipal stats automatically',
        'Monetizing with dynamic sponsorship blocks',
      ],
      seoKeywords: ['hyperlocal newsletter playbook', 'ai local media'],
      includeExamples: true,
      autoFactCheck: true,
      includeVisuals: true,
    ),
    social: SocialTestSeed(
      topic: 'Sneak peek: Philly launch stats powered by AI fact-checking',
      platform: 'Facebook',
      tone: 'Professional',
      includeEmoji: false,
      includeHashtags: false,
      includeCallToAction: true,
    ),
    email: EmailTestSeed(
      type: 'Promotional',
      tone: 'Professional',
      subject: 'Launch 3 hyperlocal newsletters this month',
      audience: 'Local media founders',
      message:
          'We package templates, verified data packs, and ad ops automation so you can open new cities fast.',
      callToAction: 'Claim your city kit',
    ),
    video: VideoTestSeed(
      topic: 'Pitch deck walkthrough: Hyperlocal AI newsroom',
      platform: 'YouTube',
      duration: '7 minutes',
      tone: 'Professional',
      audience: 'Media investors',
    ),
  ),
];
