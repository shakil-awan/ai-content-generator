import 'package:flutter/material.dart';

import '../constants/font_sizes.dart';
import 'page_transitions.dart';

/// Summarly App Theme - Concise & AI-Friendly
/// Use this for consistent styling across the app
class AppTheme {
  AppTheme._();

  // ============================================================
  // CORE COLORS (Essential Only)
  // ============================================================

  // Brand Colors
  static const Color primary = Color(0xFF2563EB); // Blue
  static const Color secondary = Color(0xFF10B981); // Green
  static const Color accent = Color(0xFFF59E0B); // Amber

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutrals (Key Shades Only)
  static const Color neutral50 = Color(0xFFF9FAFB); // Lightest
  static const Color neutral200 = Color(0xFFE5E7EB); // Borders
  static const Color neutral500 = Color(0xFF6B7280); // Secondary text
  static const Color neutral900 = Color(0xFF111827); // Darkest/Primary text

  // Text Colors
  static const Color textPrimary = neutral900;
  static const Color textSecondary = neutral500;
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Background Colors
  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = neutral50;

  // Border Colors
  static const Color border = neutral200;

  // ============================================================
  // SPACING (8px Grid)
  // ============================================================

  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // ============================================================
  // BORDER RADIUS
  // ============================================================

  static const double radiusSM = 4.0;
  static const double radiusMD = 8.0; // Default for buttons/inputs
  static const double radiusLG = 12.0; // Cards
  static const double radiusXL = 16.0;
  static const double radiusFull = 9999.0;

  static BorderRadius borderRadiusMD = BorderRadius.circular(radiusMD);
  static BorderRadius borderRadiusLG = BorderRadius.circular(radiusLG);
  static BorderRadius borderRadiusXL = BorderRadius.circular(radiusXL);

  // ============================================================
  // SHADOWS
  // ============================================================

  static List<BoxShadow> shadowSM = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static List<BoxShadow> shadowMD = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      offset: const Offset(0, 4),
      blurRadius: 6,
    ),
  ];

  static List<BoxShadow> shadowLG = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      offset: const Offset(0, 10),
      blurRadius: 15,
    ),
  ];

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: secondary,
      tertiary: accent,
      error: error,
      surface: bgPrimary,
      onPrimary: textOnPrimary,
      onSurface: textPrimary,
    ),

    scaffoldBackgroundColor: bgPrimary,

    // Smooth web-style page transitions
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadePageTransitionsBuilder(),
        TargetPlatform.iOS: FadePageTransitionsBuilder(),
        TargetPlatform.linux: FadePageTransitionsBuilder(),
        TargetPlatform.macOS: FadePageTransitionsBuilder(),
        TargetPlatform.windows: FadePageTransitionsBuilder(),
      },
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: bgPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: FontSizes.h2,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      scrolledUnderElevation: 1,
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadiusLG,
        side: BorderSide(color: border, width: 1),
      ),
      margin: EdgeInsets.all(spacing16),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgPrimary,
      border: OutlineInputBorder(
        borderRadius: borderRadiusMD,
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadiusMD,
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadiusMD,
        borderSide: BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadiusMD,
        borderSide: BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadiusMD,
        borderSide: BorderSide(color: error, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing16,
      ),
      hoverColor: neutral50,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: textOnPrimary,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: spacing24,
              vertical: spacing16,
            ),
            shape: RoundedRectangleBorder(borderRadius: borderRadiusMD),
            textStyle: TextStyle(
              fontSize: FontSizes.buttonRegular,
              fontWeight: FontWeight.w600,
            ),
            // Smooth hover effect
            shadowColor: primary.withValues(alpha: 0.3),
          ).copyWith(
            elevation: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) return 2;
              if (states.contains(WidgetState.pressed)) return 0;
              return 0;
            }),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return Color(0xFF1D4ED8); // Darker blue on hover
              }
              if (states.contains(WidgetState.pressed)) {
                return Color(0xFF1E40AF); // Even darker on press
              }
              return primary;
            }),
          ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style:
          OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: BorderSide(color: primary),
            padding: EdgeInsets.symmetric(
              horizontal: spacing24,
              vertical: spacing16,
            ),
            shape: RoundedRectangleBorder(borderRadius: borderRadiusMD),
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return primary.withValues(alpha: 0.05);
              }
              if (states.contains(WidgetState.pressed)) {
                return primary.withValues(alpha: 0.1);
              }
              return Colors.transparent;
            }),
            side: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return BorderSide(color: primary, width: 2);
              }
              return BorderSide(color: primary);
            }),
          ),
    ),

    textButtonTheme: TextButtonThemeData(
      style:
          TextButton.styleFrom(
            foregroundColor: primary,
            padding: EdgeInsets.symmetric(
              horizontal: spacing16,
              vertical: spacing12,
            ),
            shape: RoundedRectangleBorder(borderRadius: borderRadiusMD),
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return primary.withValues(alpha: 0.05);
              }
              return Colors.transparent;
            }),
          ),
    ),

    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: FontSizes.displayLarge,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: FontSizes.h1,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: FontSizes.h2,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(fontSize: FontSizes.bodyLarge, color: textPrimary),
      bodyMedium: TextStyle(
        fontSize: FontSizes.bodyRegular,
        color: textPrimary,
      ),
      bodySmall: TextStyle(fontSize: FontSizes.bodySmall, color: textSecondary),
    ),

    dividerTheme: DividerThemeData(
      color: border,
      thickness: 1,
      space: spacing16,
    ),
  );

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      tertiary: accent,
      error: error,
      surface: Color(0xFF1F2937),
      onPrimary: textOnPrimary,
      onSurface: Color(0xFFF9FAFB),
    ),

    scaffoldBackgroundColor: Color(0xFF111827),

    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1F2937),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: FontSizes.h2,
        fontWeight: FontWeight.w600,
        color: Color(0xFFF9FAFB),
      ),
    ),

    cardTheme: CardThemeData(
      color: Color(0xFF1F2937),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadiusLG,
        side: BorderSide(color: Color(0xFF374151), width: 1),
      ),
      margin: EdgeInsets.all(spacing16),
    ),

    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: FontSizes.displayLarge,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF9FAFB),
      ),
      bodyMedium: TextStyle(
        fontSize: FontSizes.bodyRegular,
        color: Color(0xFFF9FAFB),
      ),
    ),
  );
}
