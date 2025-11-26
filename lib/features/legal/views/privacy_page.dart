import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';

/// Privacy Policy Page
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: H2('Privacy Policy'),
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
              
              H2('1. Information We Collect'),
              Gap(AppTheme.spacing16),
              BodyText(
                'We collect information that you provide directly to us, including:\n\n'
                '• Name and email address\n'
                '• Account credentials\n'
                '• Content you create using our service\n'
                '• Usage data and analytics',
              ),
              Gap(AppTheme.spacing24),
              
              H2('2. How We Use Your Information'),
              Gap(AppTheme.spacing16),
              BodyText(
                'We use the information we collect to:\n\n'
                '• Provide, maintain, and improve our services\n'
                '• Process your transactions\n'
                '• Send you technical notices and support messages\n'
                '• Respond to your comments and questions\n'
                '• Protect against fraudulent or illegal activity',
              ),
              Gap(AppTheme.spacing24),
              
              H2('3. Information Sharing'),
              Gap(AppTheme.spacing16),
              BodyText(
                'We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:\n\n'
                '• With your consent\n'
                '• To comply with legal obligations\n'
                '• To protect our rights and safety',
              ),
              Gap(AppTheme.spacing24),
              
              H2('4. Data Security'),
              Gap(AppTheme.spacing16),
              BodyText(
                'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
              ),
              Gap(AppTheme.spacing24),
              
              H2('5. Data Retention'),
              Gap(AppTheme.spacing16),
              BodyText(
                'We retain your personal information for as long as necessary to provide our services and fulfill the purposes outlined in this privacy policy.',
              ),
              Gap(AppTheme.spacing24),
              
              H2('6. Your Rights'),
              Gap(AppTheme.spacing16),
              BodyText(
                'You have the right to:\n\n'
                '• Access your personal information\n'
                '• Correct inaccurate data\n'
                '• Request deletion of your data\n'
                '• Object to data processing\n'
                '• Data portability',
              ),
              Gap(AppTheme.spacing24),
              
              H2('7. Cookies and Tracking'),
              Gap(AppTheme.spacing16),
              BodyText(
                'We use cookies and similar tracking technologies to track activity on our service and hold certain information. You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent.',
              ),
              Gap(AppTheme.spacing24),
              
              H2('8. Contact Us'),
              Gap(AppTheme.spacing16),
              BodyText(
                'If you have questions about this Privacy Policy, please contact us at privacy@summarly.com',
              ),
              Gap(AppTheme.spacing48),
            ],
          ),
        ),
      ),
    );
  }
}
