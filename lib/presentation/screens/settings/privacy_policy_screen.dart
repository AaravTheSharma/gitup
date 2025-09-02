import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';
import '../../widgets/custom_card.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'Last updated: January 2025',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                      border: Border.all(
                        color: const Color(0xFF10B981),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user,
                          color: Color(0xFF059669),
                          size: 24,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Expanded(
                          child: Text(
                            'Privacy First: All your data stays on your device. We don\'t collect, store, or transmit your personal information.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF059669),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Information We Don't Collect
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Information We Don\'t Collect',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'Clarity is designed with privacy as a core principle. We do not collect, store, or transmit any of the following:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildBulletPoint(context, 'Your decision data or personal choices'),
                  _buildBulletPoint(context, 'Personal identification information'),
                  _buildBulletPoint(context, 'Usage analytics or behavioral data'),
                  _buildBulletPoint(context, 'Device information or identifiers'),
                  _buildBulletPoint(context, 'Location data'),
                  _buildBulletPoint(context, 'Contact information'),
                  _buildBulletPoint(context, 'Any other personal or sensitive information'),
                ],
              ),
            ),

            // Local Data Storage
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2. Local Data Storage',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'All data created within the Clarity application is stored locally on your device using secure storage mechanisms provided by your operating system.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'This includes:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildBulletPoint(context, 'Your decision scenarios and options'),
                  _buildBulletPoint(context, 'Criteria and scoring data'),
                  _buildBulletPoint(context, 'App preferences and settings'),
                  _buildBulletPoint(context, 'Generated reports and insights'),
                ],
              ),
            ),

            // Data Control
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '3. Your Data Control',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'You have complete control over your data:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildBulletPoint(context, 'View all stored data within the application'),
                  _buildBulletPoint(context, 'Delete individual decisions or all data'),
                  _buildBulletPoint(context, 'Export your data for backup purposes'),
                  _buildBulletPoint(context, 'Uninstall the app to remove all data'),
                ],
              ),
            ),

            // No Third-Party Services
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '4. No Third-Party Data Sharing',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'Clarity does not integrate with or share data with any third-party services, analytics platforms, or advertising networks. Your data remains completely private and isolated on your device.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            // Security Measures
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '5. Security Measures',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'While we don\'t have access to your data, we\'ve implemented security best practices in the app design:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildBulletPoint(context, 'Secure local storage using platform-provided encryption'),
                  _buildBulletPoint(context, 'No network communication for data transmission'),
                  _buildBulletPoint(context, 'Regular security updates and patches'),
                  _buildBulletPoint(context, 'Minimal app permissions required'),
                ],
              ),
            ),

            // Device Permissions
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '6. Device Permissions',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'Clarity requires minimal device permissions to function:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildBulletPoint(context, 'Storage access: To save your decisions locally'),
                  _buildBulletPoint(context, 'No internet permission: We don\'t access the network'),
                  _buildBulletPoint(context, 'No camera or microphone access'),
                  _buildBulletPoint(context, 'No location or contact access'),
                ],
              ),
            ),

            // Children's Privacy
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '7. Children\'s Privacy',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'Since we don\'t collect any personal information, Clarity is safe for users of all ages. However, we recommend parental guidance for children under 13 when making important decisions.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            // Changes to Privacy Policy
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '8. Changes to This Policy',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'If we make changes to this Privacy Policy, we will update the "Last updated" date and notify users through the application. We will never change our core commitment to keeping your data private and local.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            // Contact Information
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '9. Contact Us',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'If you have questions about this Privacy Policy or our privacy practices, please contact us through the Feedback & Suggestions section in the app settings.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}