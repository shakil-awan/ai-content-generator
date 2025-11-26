import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_split_layout.dart';
import '../widgets/branding_panel.dart';
import '../widgets/sign_up_form.dart';

/// Sign Up Page View
///
/// Displays split-screen layout with branding panel and sign up form
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize AuthController
    Get.put(AuthController());

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return AuthSplitLayout(
      brandingPanel: const BrandingPanel(),
      formContent: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            isMobile ? AppTheme.spacing24 : AppTheme.spacing48,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mobile: Show logo
                if (isMobile) ...[
                  Center(
                    child: Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: AppTheme.primary,
                    ),
                  ),
                  Gap(AppTheme.spacing24),
                ],

                // Page title
                H1('Create Account'),
                Gap(AppTheme.spacing8),
                BodyText(
                  'Sign up to start creating amazing content',
                  color: AppTheme.textSecondary,
                ),
                Gap(AppTheme.spacing32),

                // Sign up form
                const SignUpForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
