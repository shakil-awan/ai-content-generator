import 'package:flutter/material.dart';

import '../../core/constants/font_sizes.dart';
import '../../core/theme/app_theme.dart';

/// Custom Button Widgets
/// Automatically applies theme styling and responds to light/dark mode
///
/// TODO: Dark Mode Implementation
/// When adding dark mode, buttons will automatically adapt through MaterialApp's ThemeData
/// For manual control, use Theme.of(context).brightness to detect dark mode
/// and adjust button colors accordingly (e.g., lighter primary in dark mode)

/// Primary Button
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.textOnPrimary,
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing24,
            vertical: AppTheme.spacing16,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusMD),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AppTheme.textOnPrimary,
                  strokeWidth: 2,
                ),
              )
            : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20),
                  SizedBox(width: AppTheme.spacing8),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: FontSizes.buttonRegular,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: FontSizes.buttonRegular,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Secondary/Outlined Button
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primary,
          side: BorderSide(color: AppTheme.primary),
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing24,
            vertical: AppTheme.spacing16,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusMD),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                  strokeWidth: 2,
                ),
              )
            : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20),
                  SizedBox(width: AppTheme.spacing8),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: FontSizes.buttonRegular,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: FontSizes.buttonRegular,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Text Button
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color ?? AppTheme.primary),
                SizedBox(width: AppTheme.spacing4),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: FontSizes.bodyRegular,
                    color: color ?? AppTheme.primary,
                  ),
                ),
              ],
            )
          : Text(
              text,
              style: TextStyle(
                fontSize: FontSizes.bodyRegular,
                color: color ?? AppTheme.primary,
              ),
            ),
    );
  }
}
