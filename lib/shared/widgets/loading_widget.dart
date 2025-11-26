import 'package:flutter/material.dart';

import '../../core/constants/font_sizes.dart';
import '../../core/theme/app_theme.dart';

/// Generic Loading Widget (Non-adaptive)
/// For adaptive loading that switches between Material/Cupertino, use AdaptiveLoading
///
/// TODO: Dark Mode Implementation
/// Add theme-aware colors when dark mode is implemented

/// Reusable Loading Widget
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;

  const LoadingWidget({super.key, this.message, this.size});

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
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 3,
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
