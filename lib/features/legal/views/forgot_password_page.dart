import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../auth/controllers/auth_controller.dart';

/// Forgot Password Page
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      appBar: AppBar(
        title: H2('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            isMobile ? AppTheme.spacing24 : AppTheme.spacing48,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_reset,
                  size: 64,
                  color: AppTheme.primary,
                ),
                Gap(AppTheme.spacing24),
                
                H1('Forgot Your Password?'),
                Gap(AppTheme.spacing16),
                BodyText(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  color: AppTheme.textSecondary,
                  textAlign: TextAlign.center,
                ),
                Gap(AppTheme.spacing32),
                
                CustomTextFormField(
                  controller: controller.emailController,
                  hint: 'Enter your email',
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: controller.validateEmail,
                ),
                Gap(AppTheme.spacing24),
                
                Obx(
                  () => PrimaryButton(
                    text: 'Send Reset Link',
                    onPressed: controller.isLoading.value ? null : () {
                      // TODO: Implement password reset logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password reset link sent to your email'),
                        ),
                      );
                    },
                    isLoading: controller.isLoading.value,
                  ),
                ),
                Gap(AppTheme.spacing24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BodyTextSmall('Remember your password? '),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => context.go(AppRouter.signIn),
                        child: BodyTextSmall(
                          'Sign In',
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
