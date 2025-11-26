import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Terms of Service Page
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: H2('Terms of Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacing24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyTextSmall(
                'Last updated: November 26, 2025',
                color: AppTheme.textSecondary,
              ),
              Gap(AppTheme.spacing32),
              
              H2('1. Acceptance of Terms'),
              Gap(AppTheme.spacing16),
              BodyText(
                'By accessing and using Summarly AI Content Generator, you accept and agree to be bound by the terms and provision of this agreement.',
              ),
              Gap(AppTheme.spacing24),
              
              H2('2. Use License'),
              Gap(AppTheme.spacing16),
              BodyText(
                'Permission is granted to temporarily download one copy of the materials on Summarly for personal, non-commercial transitory viewing only.',
              ),
              Gap(AppTheme.spacing24),
              
              H2('3. Service Description'),
              Gap(AppTheme.spacing16),
              BodyText(
                'Summarly provides AI-powered content generation services with built-in fact-checking and humanization features. We reserve the right to modify or discontinue the service at any time.',
              ),
              Gap(AppTheme.spacing24),
              
              H2('4. User Responsibilities'),
              Gap(AppTheme.spacing16),
              BodyText(
                'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
              ),
              Gap(AppTheme.spacing24),
              
              H2('5. Content Ownership'),
              Gap(AppTheme.spacing16),
              BodyText(
                'You retain all rights to the content you create using Summarly. We claim no intellectual property rights over the material you provide to or create with the service.',
              ),
              Gap(AppTheme.spacing24),
              
              H2('6. Prohibited Uses'),
              Gap(AppTheme.spacing16),
              BodyText(
                'You may not use Summarly to create content that is illegal, harmful, threatening, abusive, harassing, defamatory, or otherwise objectionable.',
              ),
              Gap(AppTheme.spacing24),
              
              H2('7. Limitation of Liability'),
              Gap(AppTheme.spacing16),
              BodyText(
                'Summarly shall not be liable for any damages arising from the use or inability to use the service, including but not limited to direct, indirect, incidental, punitive, and consequential damages.',
              ),
              Gap(AppTheme.spacing24),
              
              H2('8. Contact Information'),
              Gap(AppTheme.spacing16),
              BodyText(
                'For questions about these Terms, please contact us at support@summarly.com',
              ),
              Gap(AppTheme.spacing48),
            ],
          ),
        ),
      ),
    );
  }
}
