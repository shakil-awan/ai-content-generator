import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Social Auth Button Controller
class SocialAuthButtonController extends GetxController {
  final isHovered = false.obs;

  void setHovered(bool value) => isHovered.value = value;
}

/// Social authentication button
///
/// Used for Google, Facebook, Apple sign in
class SocialAuthButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SocialAuthButtonController(), tag: text);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => controller.setHovered(true),
      onExit: (_) => controller.setHovered(false),
      child: Obx(
        () => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppTheme.bgPrimary,
            border: Border.all(
              color: controller.isHovered.value
                  ? AppTheme.primary
                  : AppTheme.border,
              width: 1,
            ),
            borderRadius: AppTheme.borderRadiusMD,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onPressed,
              borderRadius: AppTheme.borderRadiusMD,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing24,
                  vertical: AppTheme.spacing16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primary,
                          ),
                        ),
                      )
                    else
                      Icon(icon, size: 20, color: AppTheme.textPrimary),
                    Gap(AppTheme.spacing8),
                    BodyText(text),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
