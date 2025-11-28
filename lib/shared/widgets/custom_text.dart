import 'package:flutter/material.dart';

import '../../core/constants/font_sizes.dart';
import '../../core/theme/app_theme.dart';

/// Custom Text Widgets - Use these instead of Text()
/// Automatically applies theme styling and responds to light/dark mode
///
/// TODO: Dark Mode Implementation
/// When adding dark mode support, update AppTheme with:
/// - AppTheme.textPrimaryDark, AppTheme.textSecondaryDark
/// Then use: Theme.of(context).brightness == Brightness.dark to detect theme
/// Or better: Configure MaterialApp with proper dark ThemeData in main.dart

/// Display Text (Hero Headlines)
class DisplayText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const DisplayText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Get theme-aware color when dark mode is implemented
    // final textColor = Theme.of(context).brightness == Brightness.dark
    //     ? AppTheme.textPrimaryDark
    //     : AppTheme.textPrimary;

    return Text(
      text,
      style: TextStyle(
        fontSize: FontSizes.displayLarge,
        fontWeight: fontWeight ?? FontWeight.bold,
        color: color ?? AppTheme.textPrimary, // TODO: Use theme-aware color
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// H1 Heading (Page Titles)
class H1 extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;

  const H1(this.text, {super.key, this.color, this.textAlign, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: FontSizes.h1,
        fontWeight: FontWeight.w600,
        color: color ?? AppTheme.textPrimary,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}

/// H2 Heading (Section Titles)
class H2 extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;

  const H2(this.text, {super.key, this.color, this.textAlign, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: FontSizes.h2,
        fontWeight: FontWeight.w600,
        color: color ?? AppTheme.textPrimary,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}

/// H3 Heading (Subsection Titles)
class H3 extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;

  const H3(this.text, {super.key, this.color, this.textAlign, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: FontSizes.h3,
        fontWeight: FontWeight.w600,
        color: color ?? AppTheme.textPrimary,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}

/// Body Text (Default)
class BodyText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final FontWeight? fontWeight;

  const BodyText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: FontSizes.bodyRegular,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color ?? AppTheme.textPrimary,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}

/// Body Text Large
class BodyTextLarge extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;

  const BodyTextLarge(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: FontSizes.bodyLarge,
        color: color ?? AppTheme.textPrimary,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}

/// Body Text Small
class BodyTextSmall extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;

  const BodyTextSmall(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: FontSizes.bodySmall,
        color: color ?? AppTheme.textSecondary,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}

/// Caption Text (Small, Secondary)
class CaptionText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;

  const CaptionText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: FontSizes.captionRegular,
        color: color ?? AppTheme.textSecondary,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}
