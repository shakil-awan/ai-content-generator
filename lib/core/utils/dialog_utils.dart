import 'package:flutter/material.dart';

import '../constants/font_sizes.dart';
import '../theme/app_theme.dart';

/// Custom Dialog Utilities
/// Use these for consistent dialogs across the app
class DialogUtils {
  DialogUtils._();

  /// Show a success dialog
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusLG),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.success, size: 28),
            SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: FontSizes.h3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: FontSizes.bodyRegular),
        ),
        actions: [
          ElevatedButton(
            onPressed: onPressed ?? () => Navigator.of(context).pop(),
            child: Text(buttonText ?? 'OK'),
          ),
        ],
      ),
    );
  }

  /// Show an error dialog
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusLG),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.error, size: 28),
            SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: FontSizes.h3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: FontSizes.bodyRegular),
        ),
        actions: [
          ElevatedButton(
            onPressed: onPressed ?? () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text(buttonText ?? 'OK'),
          ),
        ],
      ),
    );
  }

  /// Show a confirmation dialog
  static Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusLG),
        title: Text(
          title,
          style: TextStyle(fontSize: FontSizes.h3, fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: FontSizes.bodyRegular),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show a loading dialog
  static void showLoading(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusLG),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.primary),
              if (message != null) ...[
                SizedBox(height: AppTheme.spacing16),
                Text(
                  message,
                  style: TextStyle(fontSize: FontSizes.bodyRegular),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }
}
