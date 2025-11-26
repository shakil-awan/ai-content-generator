/// Font Sizes for Summarly Application
/// Based on Figma Design System
/// Platform: Web (Responsive) + Mobile
/// Last Updated: November 26, 2025
library;

class FontSizes {
  FontSizes._();

  // ============================================================
  // DISPLAY HEADINGS (Hero sections, Landing pages)
  // ============================================================

  /// Display Extra Large - 60px
  /// Usage: Hero headlines on landing page
  /// Example: "Generate Verified Content in Minutes"
  static const double displayXL = 60.0;

  /// Display Large - 48px
  /// Usage: Section titles, major page headings
  /// Example: "They Trust Us"
  static const double displayLarge = 48.0;

  /// Display Medium - 36px
  /// Usage: Sub-headings in hero sections
  /// Example: "Stop Gambling With Your Content Reputation"
  static const double displayMedium = 36.0;

  /// Display Small - 30px
  /// Usage: Card titles in features
  /// Example: "Fact-Checking Layer"
  static const double displaySmall = 30.0;

  // ============================================================
  // HEADINGS (Body content, cards, sections)
  // ============================================================

  /// Heading 1 - 24px (Bold/SemiBold)
  /// Usage: Page titles in dashboard, modal headers
  /// Example: "Create New Content", "Settings"
  static const double h1 = 24.0;

  /// Heading 2 - 20px (SemiBold)
  /// Usage: Section headings, card titles
  /// Example: "Recent Generations", "Quality Score"
  static const double h2 = 20.0;

  /// Heading 3 - 18px (SemiBold)
  /// Usage: Sub-section headings, feature names
  /// Example: "AI Detection Bypass", "Multilingual Support"
  static const double h3 = 18.0;

  /// Heading 4 - 16px (Medium)
  /// Usage: Small section headers, list titles
  /// Example: "Blog Posts (40%)", "Generation History"
  static const double h4 = 16.0;

  // ============================================================
  // BODY TEXT (Paragraphs, descriptions)
  // ============================================================

  /// Body Large - 18px (Regular)
  /// Usage: Lead paragraphs, important descriptions
  /// Example: Landing page subheadlines, pricing descriptions
  static const double bodyLarge = 18.0;

  /// Body Regular - 16px (Regular) - DEFAULT
  /// Usage: Standard body text, form labels, buttons
  /// Example: General content, descriptions, navigation items
  static const double bodyRegular = 16.0;

  /// Body Small - 14px (Regular)
  /// Usage: Secondary text, helper text, metadata
  /// Example: "Last updated 2 hours ago", "5 generations left"
  static const double bodySmall = 14.0;

  // ============================================================
  // CAPTIONS & LABELS (Small text, badges, tags)
  // ============================================================

  /// Caption Large - 13px (Regular/Medium)
  /// Usage: Timestamps, badges, tags
  /// Example: "Nov 26, 2025", "PRO", "Verified"
  static const double captionLarge = 13.0;

  /// Caption Regular - 12px (Regular)
  /// Usage: Small helper text, footnotes, disclaimers
  /// Example: "No credit card required", "Terms apply"
  static const double captionRegular = 12.0;

  /// Caption Small - 11px (Regular)
  /// Usage: Tiny labels, status indicators
  /// Example: "BETA", "NEW", tooltip text
  static const double captionSmall = 11.0;

  // ============================================================
  // BUTTONS (Call-to-action text)
  // ============================================================

  /// Button Large - 18px (SemiBold)
  /// Usage: Primary CTAs, hero buttons
  /// Example: "Get Started Free", "Sign Up"
  static const double buttonLarge = 18.0;

  /// Button Regular - 16px (SemiBold/Medium)
  /// Usage: Standard buttons, form actions
  /// Example: "Generate Content", "Save", "Cancel"
  static const double buttonRegular = 16.0;

  /// Button Small - 14px (Medium)
  /// Usage: Secondary buttons, icon buttons with text
  /// Example: "Learn More →", "View Details"
  static const double buttonSmall = 14.0;

  // ============================================================
  // SPECIAL USE CASES
  // ============================================================

  /// Input Text - 16px (Regular)
  /// Usage: Text inside input fields, textareas
  /// Example: Form inputs, search bars, text editors
  static const double inputText = 16.0;

  /// Input Label - 14px (Medium)
  /// Usage: Labels above input fields
  /// Example: "Email Address", "Password", "Content Topic"
  static const double inputLabel = 14.0;

  /// Input Placeholder - 16px (Regular, muted color)
  /// Usage: Placeholder text in inputs
  /// Example: "Enter your email...", "Describe your content..."
  static const double inputPlaceholder = 16.0;

  /// Navigation Item - 15px (Medium)
  /// Usage: Top navigation menu items, sidebar items
  /// Example: "Dashboard", "Pricing", "Features"
  static const double navigationItem = 15.0;

  /// Tab Label - 14px (SemiBold)
  /// Usage: Tab navigation labels
  /// Example: "Blog Posts", "Social Media", "Email Campaigns"
  static const double tabLabel = 14.0;

  /// Tooltip - 12px (Regular)
  /// Usage: Tooltip text, hover information
  /// Example: "Click to copy", "This feature requires Pro plan"
  static const double tooltip = 12.0;

  /// Badge - 11px (SemiBold)
  /// Usage: Count badges, notification indicators
  /// Example: "5", "NEW", pill badges
  static const double badge = 11.0;

  // ============================================================
  // RESPONSIVE BREAKPOINT ADJUSTMENTS
  // ============================================================

  /// Get scaled font size based on screen width
  /// For responsive web implementation
  ///
  /// Usage:
  /// ```dart
  /// fontSize: FontSizes.getResponsive(
  ///   context: context,
  ///   mobile: FontSizes.displayMedium,
  ///   tablet: FontSizes.displayLarge,
  ///   desktop: FontSizes.displayXL,
  /// )
  /// ```
  static double getResponsive({
    required double mobile,
    required double tablet,
    required double desktop,
    required double screenWidth,
  }) {
    if (screenWidth < 768) {
      return mobile; // Mobile
    } else if (screenWidth < 1024) {
      return tablet; // Tablet
    } else {
      return desktop; // Desktop
    }
  }

  // ============================================================
  // BREAKPOINTS (for reference)
  // ============================================================
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;

  // ============================================================
  // LINE HEIGHTS (multipliers)
  // ============================================================

  /// Tight line height - 1.25
  /// Usage: Headings, display text
  static const double lineHeightTight = 1.25;

  /// Normal line height - 1.5 (default)
  /// Usage: Body text, most content
  static const double lineHeightNormal = 1.5;

  /// Relaxed line height - 1.75
  /// Usage: Long-form content, blog posts
  static const double lineHeightRelaxed = 1.75;

  /// Loose line height - 2.0
  /// Usage: Poetry, special formatted text
  static const double lineHeightLoose = 2.0;
}
