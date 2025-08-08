import 'package:flutter/material.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_styles.dart';
import '../../shared/glass_card_widget.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Privacy Policy', style: AppTextStyles.headingLarge),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Policy',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.brandTeal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last updated: June 1, 2023',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GlassCard(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(
                            title: 'Introduction',
                            content:
                                'We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our application.',
                          ),
                          _buildSection(
                            title: 'Information We Collect',
                            content:
                                'Our app collects minimal personal information. We only store data that you explicitly provide, such as your preferences, journal entries, and photos you choose to edit. All data is stored locally on your device.',
                          ),
                          _buildSection(
                            title: 'How We Use Your Information',
                            content:
                                'We use your information solely to provide and improve our services. Your data is not shared with third parties or used for marketing purposes.',
                          ),
                          _buildSection(
                            title: 'Data Storage and Security',
                            content:
                                'All user data is stored locally on your device. We do not transmit your personal data to external servers. We recommend using your device\'s built-in security features to protect your data.',
                          ),
                          _buildSection(
                            title: 'Camera and Photo Library Access',
                            content:
                                'Our app requests access to your camera and photo library solely for the purpose of allowing you to take and edit photos. We do not access or use your photos for any other purpose.',
                          ),
                          _buildSection(
                            title: 'Notifications',
                            content:
                                'If you enable notifications, we will send you local notifications based on your preferences. These notifications are processed entirely on your device and are not transmitted elsewhere.',
                          ),
                          _buildSection(
                            title: 'Children\'s Privacy',
                            content:
                                'Our application is not directed to children under the age of 13. We do not knowingly collect personal information from children under 13.',
                          ),
                          _buildSection(
                            title: 'Changes to This Privacy Policy',
                            content:
                                'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy in the application.',
                          ),
                          _buildSection(
                            title: 'Your Rights',
                            content:
                                'You have the right to access, update, or delete your information at any time. Since all data is stored locally, you can manage your data directly through the application or your device settings.',
                          ),
                          _buildSection(
                            title: 'Contact Us',
                            content:
                                'If you have any questions about this Privacy Policy, please contact us through the Feedback section in the app.',
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.brandTeal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
