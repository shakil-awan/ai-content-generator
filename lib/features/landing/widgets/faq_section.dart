import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/constants/font_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controllers/landing_controller.dart';

/// FAQ Section
/// Accordion with frequently asked questions
class FAQSection extends StatelessWidget {
  const FAQSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LandingController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < FontSizes.mobileBreakpoint;

    return Container(
      width: double.infinity,
      color: AppTheme.bgSecondary,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppTheme.spacing16 : AppTheme.spacing48,
        vertical: AppTheme.spacing64,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              H1('Frequently Asked Questions', textAlign: TextAlign.center),
              Gap(AppTheme.spacing16),
              BodyTextLarge(
                'Everything you need to know about Summarly',
                color: AppTheme.textSecondary,
                textAlign: TextAlign.center,
              ),
              Gap(AppTheme.spacing48),
              ..._faqs().asMap().entries.map((entry) {
                final index = entry.key;
                final faq = entry.value;
                return _buildFaqItem(controller, index, faq);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(LandingController controller, int index, _FAQ faq) {
    return Obx(() {
      final isExpanded = controller.isFaqExpanded(index);

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(bottom: AppTheme.spacing16),
          decoration: BoxDecoration(
            color: AppTheme.bgPrimary,
            borderRadius: AppTheme.borderRadiusMD,
            border: Border.all(
              color: isExpanded ? AppTheme.primary : AppTheme.border,
              width: isExpanded ? 2 : 1,
            ),
            boxShadow: isExpanded ? AppTheme.shadowMD : [],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => controller.toggleFaq(index),
                borderRadius: AppTheme.borderRadiusMD,
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacing16),
                  child: Row(
                    children: [
                      Expanded(child: H3(faq.question)),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppTheme.spacing16,
                    0,
                    AppTheme.spacing16,
                    AppTheme.spacing16,
                  ),
                  child: BodyText(faq.answer, color: AppTheme.textSecondary),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      );
    });
  }

  List<_FAQ> _faqs() {
    return [
      _FAQ(
        question: 'How does the fact-checking work?',
        answer:
            'Our AI cross-references every claim against trusted sources in real-time. We verify facts against academic databases, news sources, and official documents to ensure accuracy.',
      ),
      _FAQ(
        question: 'Can I try it for free?',
        answer:
            'Yes! Our Free plan includes 2,000 words per month with basic fact-checking. No credit card required. Upgrade anytime when you need more.',
      ),
      _FAQ(
        question: 'Does the content pass AI detection?',
        answer:
            'Yes. Our advanced humanization technology ensures your content passes all major AI detection tools including GPTZero, Originality.ai, and Turnitin.',
      ),
      _FAQ(
        question: 'Can I cancel anytime?',
        answer:
            'Absolutely. You can cancel your subscription at any time with no questions asked. Your access will continue until the end of your billing period.',
      ),
      _FAQ(
        question: 'What languages are supported?',
        answer:
            'We support 50+ languages including English, Spanish, French, German, Chinese, Japanese, and many more. The same quality standards apply to all languages.',
      ),
      _FAQ(
        question: 'Is my content stored securely?',
        answer:
            'Yes. We use bank-level encryption to protect your data. Your content is stored securely and never shared with third parties. You can delete your content at any time.',
      ),
    ];
  }
}

class _FAQ {
  final String question;
  final String answer;

  _FAQ({required this.question, required this.answer});
}
