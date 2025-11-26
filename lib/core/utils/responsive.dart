import 'package:flutter/material.dart';

/// Responsive breakpoints (matches FontSizes constants)
/// Use these values consistently across the app
class Breakpoints {
  // Align with existing FontSizes breakpoints
  static const double mobile = 768.0; // FontSizes.mobileBreakpoint
  static const double tablet = 1024.0; // FontSizes.tabletBreakpoint
  static const double desktop = 1440.0; // FontSizes.desktopBreakpoint
}

/// Responsive helper class for adaptive layouts
/// NOTE: The landing page uses inline checks like:
///   final isMobile = screenWidth < FontSizes.mobileBreakpoint;
/// This class provides the SAME logic but as reusable methods.
/// Use whichever pattern fits your component best.
class Responsive {
  /// Check if screen is mobile (< 768px)
  /// Matches: screenWidth < FontSizes.mobileBreakpoint
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < Breakpoints.mobile;
  }

  /// Check if screen is tablet (768px - 1024px)
  /// Matches: screenWidth >= FontSizes.mobileBreakpoint && screenWidth < FontSizes.tabletBreakpoint
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= Breakpoints.mobile && width < Breakpoints.tablet;
  }

  /// Check if screen is desktop (>= 1024px)
  /// Matches: screenWidth >= FontSizes.tabletBreakpoint
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.tablet;
  }

  /// Get responsive value based on screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  /// Get screen width
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get responsive padding
  static EdgeInsets padding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32);
    } else {
      return const EdgeInsets.symmetric(horizontal: 64);
    }
  }

  /// Get max content width (for centered containers)
  static double maxWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 768;
    } else {
      return 1280;
    }
  }

  /// Get responsive font size
  static double fontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return value(context, mobile: mobile, tablet: tablet, desktop: desktop);
  }

  /// Get number of columns for grid layouts
  static int gridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }
}

/// Responsive widget builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)
  mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
  desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktop) {
          return (desktop ?? tablet ?? mobile)(context, constraints);
        } else if (constraints.maxWidth >= Breakpoints.tablet) {
          return (tablet ?? mobile)(context, constraints);
        } else {
          return mobile(context, constraints);
        }
      },
    );
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;

  const ResponsivePadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: Responsive.padding(context), child: child);
  }
}

/// Responsive centered container with max width
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Responsive.maxWidth(context),
        ),
        child: Padding(
          padding: padding ?? Responsive.padding(context),
          child: child,
        ),
      ),
    );
  }
}
