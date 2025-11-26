import 'package:flutter/material.dart';

import '../../core/constants/font_sizes.dart';
import '../../core/theme/app_theme.dart';

/// Empty State Widget
/// Shows when there's no data to display
///
/// TODO: Dark Mode Implementation
/// Add theme-aware colors for empty states in dark mode

/// Reusable Empty State Widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Add dark mode support
    // final iconColor = Theme.of(context).brightness == Brightness.dark
    //     ? AppTheme.neutral600Dark
    //     : AppTheme.neutral200;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppTheme.neutral200,
            ), // TODO: Use theme-aware color
            SizedBox(height: AppTheme.spacing24),
            Text(
              title,
              style: TextStyle(
                fontSize: FontSizes.h3,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary, // TODO: Use theme-aware color
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: FontSizes.bodyRegular,
                color: AppTheme.textSecondary, // TODO: Use theme-aware color
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppTheme.spacing24),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
