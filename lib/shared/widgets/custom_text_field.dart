import 'package:flutter/material.dart';

import '../../core/constants/font_sizes.dart';
import '../../core/theme/app_theme.dart';

/// Custom TextField - Use this instead of TextField
/// Automatically applies theme styling
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextDirection? textDirection;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Add dark mode support
    // When dark mode is implemented, use Theme.of(context) to get colors:
    // final isDark = Theme.of(context).brightness == Brightness.dark;
    // final fillColor = isDark ? AppTheme.bgPrimaryDark : AppTheme.bgPrimary;
    // final borderColor = isDark ? AppTheme.borderDark : AppTheme.border;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      textDirection: textDirection,
      style: TextStyle(
        fontSize: FontSizes.bodyRegular,
        color: AppTheme.textPrimary, // TODO: Use theme-aware color
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.bgPrimary, // TODO: Use theme-aware fill color
        border: OutlineInputBorder(
          borderRadius: AppTheme.borderRadiusMD,
          borderSide: BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTheme.borderRadiusMD,
          borderSide: BorderSide(
            color: AppTheme.border,
          ), // TODO: Use theme-aware border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTheme.borderRadiusMD,
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppTheme.borderRadiusMD,
          borderSide: BorderSide(color: AppTheme.error),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppTheme.borderRadiusMD,
          borderSide: BorderSide(
            color: AppTheme.neutral200,
          ), // TODO: Use theme-aware disabled color
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing16,
        ),
      ),
    );
  }
}

/// Custom TextFormField - Use this for forms with validation
/// Automatically applies theme styling
class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final AutovalidateMode? autovalidateMode;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Add dark mode support (same as CustomTextField above)

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      readOnly: readOnly,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      autovalidateMode: autovalidateMode,
      style: TextStyle(
        fontSize: FontSizes.bodyRegular,
        color: AppTheme.textPrimary, // TODO: Use theme-aware color
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.bgPrimary, // TODO: Use theme-aware fill color
        border: OutlineInputBorder(
          borderRadius: AppTheme.borderRadiusMD,
          borderSide: BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTheme.borderRadiusMD,
          borderSide: BorderSide(
            color: AppTheme.border,
          ), // TODO: Use theme-aware border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTheme.borderRadiusMD,
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppTheme.borderRadiusMD,
          borderSide: BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppTheme.borderRadiusMD,
          borderSide: BorderSide(color: AppTheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppTheme.borderRadiusMD,
          borderSide: BorderSide(
            color: AppTheme.neutral200,
          ), // TODO: Use theme-aware disabled color
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing16,
        ),
      ),
    );
  }
}
