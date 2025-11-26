import 'package:flutter/material.dart';

import '../../core/constants/font_sizes.dart';
import '../../core/theme/app_theme.dart';

/// Custom Error Widget
/// Shows error state with optional retry button
///
/// TODO: Dark Mode Implementation
/// Add theme-aware colors for error states in dark mode

/// Reusable Error Widget
class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplayWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    // TODO: Add dark mode support
    // final textColor = Theme.of(context).brightness == Brightness.dark
    //     ? AppTheme.textPrimaryDark
    //     : AppTheme.textPrimary;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.error),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: FontSizes.h3,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary, // TODO: Use theme-aware color
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              message,
              style: TextStyle(
                fontSize: FontSizes.bodyRegular,
                color: AppTheme.textSecondary, // TODO: Use theme-aware color
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppTheme.spacing24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh),
                label: Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
