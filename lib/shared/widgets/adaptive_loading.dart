import 'package:flutter/material.dart';

import '../../core/constants/font_sizes.dart';
import '../../core/theme/app_theme.dart';

/// Adaptive Loading Widget
/// Automatically uses Material or Cupertino style based on platform
/// Uses Flutter's built-in CircularProgressIndicator.adaptive()
///
/// TODO: Dark Mode Implementation
/// When adding dark mode, get theme brightness with:
/// final isDark = Theme.of(context).brightness == Brightness.dark;
/// Then use theme-aware colors from AppTheme (AppTheme.textSecondaryDark, etc.)
class AdaptiveLoading extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const AdaptiveLoading({super.key, this.message, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    // TODO: Add dark mode support
    // final textColor = Theme.of(context).brightness == Brightness.dark
    //     ? AppTheme.textSecondaryDark
    //     : AppTheme.textSecondary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppTheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: AppTheme.spacing16),
            Text(
              message!,
              style: TextStyle(
                fontSize: FontSizes.bodyRegular,
                color: AppTheme.textSecondary, // TODO: Use theme-aware color
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Small Inline Loader (for buttons, cards, etc.)
/// Automatically adaptive for platform
class SmallLoader extends StatelessWidget {
  final Color? color;

  const SmallLoader({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    // TODO: Add dark mode support when implementing theme switcher

    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppTheme.primary),
      ),
    );
  }
}

/// Full Screen Loading Overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    // TODO: Add dark mode support
    // final isDark = Theme.of(context).brightness == Brightness.dark;
    // final overlayColor = isDark ? Colors.black.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.5);

    return Container(
      color: Colors.black.withValues(
        alpha: 0.5,
      ), // TODO: Use theme-aware overlay color
      child: AdaptiveLoading(message: message),
    );
  }
}
