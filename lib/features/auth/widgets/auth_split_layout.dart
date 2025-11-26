import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Split layout for authentication pages
///
/// Left side: Branding panel
/// Right side: Form content
class AuthSplitLayout extends StatelessWidget {
  final Widget brandingPanel;
  final Widget formContent;

  const AuthSplitLayout({
    super.key,
    required this.brandingPanel,
    required this.formContent,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Branding panel (40% width on desktop)
            Expanded(flex: 4, child: brandingPanel),
            // Form content (60% width on desktop)
            Expanded(flex: 6, child: formContent),
          ],
        ),
      );
    } else if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            // Branding panel (35% width on tablet)
            Expanded(flex: 35, child: brandingPanel),
            // Form content (65% width on tablet)
            Expanded(flex: 65, child: formContent),
          ],
        ),
      );
    } else {
      // Mobile: Show only form content with logo at top
      return Scaffold(
        backgroundColor: AppTheme.bgPrimary,
        body: SafeArea(child: formContent),
      );
    }
  }
}
