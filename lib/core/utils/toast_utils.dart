import 'package:flutter/material.dart';

import '../constants/font_sizes.dart';
import '../theme/app_theme.dart';

/// Toast/Snackbar Utilities
/// Use these for non-blocking notifications
/// Note: Uses GetX when available, otherwise falls back to Material SnackBar
class ToastUtils {
  ToastUtils._();

  /// Show a success toast
  static void showSuccess(
    BuildContext context,
    String message, {
    String? title,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppTheme.success,
      icon: Icons.check_circle,
    );
  }

  /// Show an error toast
  static void showError(BuildContext context, String message, {String? title}) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppTheme.error,
      icon: Icons.error_outline,
    );
  }

  /// Show a warning toast
  static void showWarning(
    BuildContext context,
    String message, {
    String? title,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppTheme.warning,
      icon: Icons.warning_amber,
    );
  }

  /// Show an info toast
  static void showInfo(BuildContext context, String message, {String? title}) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppTheme.info,
      icon: Icons.info_outline,
    );
  }

  /// Internal method to show SnackBar
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: FontSizes.bodyRegular,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        margin: EdgeInsets.all(AppTheme.spacing16),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
