import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_buttons.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';
import '../widgets/form_divider.dart';
import '../widgets/social_auth_button.dart';

/// Sign In Form Widget
///
/// Email, password fields, remember me, forgot password, sign in button
class SignInForm extends StatelessWidget {
  const SignInForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Form(
      key: controller.signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          CustomTextFormField(
            controller: controller.emailController,
            hint: 'Enter your email',
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: controller.validateEmail,
          ),
          Gap(AppTheme.spacing16),

          // Password field
          Obx(
            () => CustomTextFormField(
              controller: controller.passwordController,
              hint: 'Enter your password',
              label: 'Password',
              obscureText: !controller.passwordVisible.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.passwordVisible.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
          ),
          Gap(AppTheme.spacing16),

          // Remember me and Forgot password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remember me checkbox
              Row(
                children: [
                  Obx(
                    () => Checkbox(
                      value: controller.rememberMe.value,
                      onChanged: controller.toggleRememberMe,
                      activeColor: AppTheme.primary,
                    ),
                  ),
                  BodyTextSmall('Remember me'),
                ],
              ),

              // Forgot password link
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to forgot password page
                    context.go(AppRouter.forgotPassword);
                  },
                  child: BodyTextSmall(
                    'Forgot password?',
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          Gap(AppTheme.spacing24),

          // Error message
          Obx(
            () => controller.errorMessage.value.isNotEmpty
                ? Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppTheme.spacing12),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.1),
                          border: Border.all(color: AppTheme.error, width: 1),
                          borderRadius: AppTheme.borderRadiusMD,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppTheme.error,
                              size: 20,
                            ),
                            Gap(AppTheme.spacing8),
                            Expanded(
                              child: BodyTextSmall(
                                controller.errorMessage.value,
                                color: AppTheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(AppTheme.spacing16),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          // Sign in button
          Obx(
            () => PrimaryButton(
              text: 'Sign In',
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.signIn(context),
              isLoading: controller.isLoading.value,
            ),
          ),
          Gap(AppTheme.spacing24),

          // Divider
          const FormDivider(),
          Gap(AppTheme.spacing24),

          // Google sign in button
          Obx(
            () => SocialAuthButton(
              text: 'Continue with Google',
              icon: Icons.g_mobiledata,
              onPressed: () => controller.signInWithGoogle(context),
              isLoading: controller.isLoading.value,
            ),
          ),
          Gap(AppTheme.spacing24),

          // Sign up link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BodyTextSmall('Don\'t have an account? '),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    controller.clearFields();
                    context.go(AppRouter.signUp);
                  },
                  child: BodyTextSmall('Sign Up', color: AppTheme.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
