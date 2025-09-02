import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';
import '../../widgets/custom_card.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
                    'Terms of Service',
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
                  Text(
                    'Please read these Terms of Service carefully before using the Clarity application.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            // Acceptance of Terms
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Acceptance of Terms',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'By downloading, installing, or using the Clarity application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            // Description of Service
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2. Description of Service',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'Clarity is a decision-making application that helps users evaluate options using multi-criteria analysis. The app provides tools for:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildBulletPoint(context, 'Creating and managing decision scenarios'),
                  _buildBulletPoint(context, 'Setting criteria and weights for evaluation'),
                  _buildBulletPoint(context, 'Scoring options against defined criteria'),
                  _buildBulletPoint(context, 'Generating reports and insights'),
                  _buildBulletPoint(context, 'Tracking decision-making patterns'),
                ],
              ),
            ),

            // User Responsibilities
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '3. User Responsibilities',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'You are responsible for:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildBulletPoint(context, 'Using the application in accordance with these terms'),
                  _buildBulletPoint(context, 'Ensuring the accuracy of data you input'),
                  _buildBulletPoint(context, 'Making your own informed decisions based on the app\'s analysis'),
                  _buildBulletPoint(context, 'Keeping your device secure and protected'),
                ],
              ),
            ),

            // Limitations and Disclaimers
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '4. Limitations and Disclaimers',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                      border: Border.all(
                        color: const Color(0xFFF59E0B),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber,
                              color: Color(0xFF92400E),
                              size: 20,
                            ),
                            const SizedBox(width: AppConstants.paddingSmall),
                            Text(
                              'Important Notice',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF92400E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          'Clarity is a decision-support tool only. The application does not provide professional advice and should not be used as a substitute for professional consultation in legal, financial, medical, or other specialized areas.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'We provide the application "as is" without warranties of any kind. We do not guarantee that the application will be error-free or uninterrupted.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            // Privacy and Data
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '5. Privacy and Data',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'All data created and stored within the Clarity application remains on your local device. We do not collect, transmit, or store your personal decision data on external servers.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'For complete details about data handling, please refer to our Privacy Policy.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Intellectual Property
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '6. Intellectual Property',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'The Clarity application, including its design, functionality, and content, is protected by intellectual property laws. You may not copy, modify, distribute, or reverse engineer the application.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            // Termination
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '7. Termination',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'You may stop using the application at any time by uninstalling it from your device. These terms will remain in effect until terminated.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            // Changes to Terms
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '8. Changes to Terms',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'We reserve the right to modify these Terms of Service at any time. Updated terms will be made available within the application. Continued use of the application after changes constitutes acceptance of the new terms.',
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
                    '9. Contact Information',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'If you have questions about these Terms of Service, please contact us through the Feedback & Suggestions section in the app settings.',
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