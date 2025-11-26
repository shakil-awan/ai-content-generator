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
import '../widgets/password_strength_indicator.dart';
import '../widgets/social_auth_button.dart';

/// Sign Up Form Widget
///
/// Name, email, password, confirm password, strength indicator, terms checkbox
class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Form(
      key: controller.signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name field
          CustomTextFormField(
            controller: controller.nameController,
            hint: 'Enter your full name',
            label: 'Full Name',
            keyboardType: TextInputType.name,
            validator: controller.validateName,
          ),
          Gap(AppTheme.spacing16),

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
              hint: 'Create a password',
              label: 'Password',
              obscureText: !controller.passwordVisible.value,
              onChanged: controller.calculatePasswordStrength,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.passwordVisible.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              validator: controller.validatePassword,
            ),
          ),
          Gap(AppTheme.spacing8),

          // Password strength indicator
          Obx(
            () => PasswordStrengthIndicator(
              strength: controller.passwordStrength.value,
            ),
          ),
          Gap(AppTheme.spacing16),

          // Confirm password field
          Obx(
            () => CustomTextFormField(
              controller: controller.confirmPasswordController,
              hint: 'Confirm your password',
              label: 'Confirm Password',
              obscureText: !controller.confirmPasswordVisible.value,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.confirmPasswordVisible.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
              validator: controller.validateConfirmPassword,
            ),
          ),
          Gap(AppTheme.spacing16),

          // Terms and conditions checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Checkbox(
                  value: controller.acceptedTerms.value,
                  onChanged: controller.toggleAcceptedTerms,
                  activeColor: AppTheme.primary,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: AppTheme.spacing12),
                  child: Row(
                    children: [
                      Expanded(child: BodyTextSmall('I agree to the ')),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to terms page
                            context.go(AppRouter.terms);
                          },
                          child: BodyTextSmall(
                            'Terms of Service',
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      BodyTextSmall(' and '),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to privacy page
                            context.go(AppRouter.privacy);
                          },
                          child: BodyTextSmall(
                            'Privacy Policy',
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
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

          // Sign up button
          Obx(
            () => PrimaryButton(
              text: 'Create Account',
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.signUp(context),
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

          // Sign in link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BodyTextSmall('Already have an account? '),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    controller.clearFields();
                    context.go(AppRouter.signIn);
                  },
                  child: BodyTextSmall('Sign In', color: AppTheme.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
