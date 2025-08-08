import 'package:flutter/material.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_styles.dart';
import '../../shared/glass_card_widget.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title:
            const Text('Terms of Service', style: AppTextStyles.headingLarge),
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
                  'Terms of Service',
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
                            title: '1. Acceptance of Terms',
                            content:
                                'By accessing or using Florsovivexa, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.',
                          ),
                          _buildSection(
                            title: '2. Description of Service',
                            content:
                                'Florsovivexa provides tools for photo editing, journaling, and tracking beverage consumption. The service is provided "as is" and may change without prior notice.',
                          ),
                          _buildSection(
                            title: '3. User Responsibilities',
                            content:
                                'You are responsible for maintaining the confidentiality of your device and data. You agree not to use the service for any illegal or unauthorized purpose.',
                          ),
                          _buildSection(
                            title: '4. Content Ownership',
                            content:
                                'You retain all ownership rights to the content you create using our application. We do not claim ownership of your photos, journal entries, or other data.',
                          ),
                          _buildSection(
                            title: '5. Data Storage',
                            content:
                                'All data is stored locally on your device. We recommend regularly backing up your data to prevent loss.',
                          ),
                          _buildSection(
                            title: '6. Prohibited Activities',
                            content:
                                'You agree not to engage in any activity that interferes with or disrupts the service or servers connected to the service.',
                          ),
                          _buildSection(
                            title: '7. Termination',
                            content:
                                'We reserve the right to terminate or suspend access to our service immediately, without prior notice, for conduct that we believe violates these Terms of Service.',
                          ),
                          _buildSection(
                            title: '8. Limitation of Liability',
                            content:
                                'To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the service.',
                          ),
                          _buildSection(
                            title: '9. Changes to Terms',
                            content:
                                'We reserve the right to modify these terms at any time. We will provide notification of significant changes through the application.',
                          ),
                          _buildSection(
                            title: '10. Governing Law',
                            content:
                                'These Terms shall be governed by the laws of the jurisdiction in which the application is operated, without regard to its conflict of law provisions.',
                          ),
                          _buildSection(
                            title: '11. Contact',
                            content:
                                'If you have any questions about these Terms, please contact us through the Feedback section in the app.',
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
