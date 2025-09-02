import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';
import '../../widgets/custom_card.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
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
            // App Info Card
            CustomCard(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'Clarity',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'Navigate your choices with clarity and confidence',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Mission Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Text(
                        'Our Mission',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'We believe that making good decisions is one of the most important skills in life. Clarity is designed to help you make better decisions by providing a structured approach to evaluate your options.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'Our app helps you break down complex decisions into manageable criteria, weigh your options objectively, and gain insights into your decision-making patterns.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            // Features Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_outline,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Text(
                        'Key Features',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildFeatureItem(
                    context,
                    Icons.compare_arrows,
                    'Multi-Criteria Analysis',
                    'Evaluate options across multiple criteria with weighted scoring',
                  ),
                  _buildFeatureItem(
                    context,
                    Icons.insights,
                    'Decision Insights',
                    'Track your decision-making patterns and preferences',
                  ),
                  _buildFeatureItem(
                    context,
                    Icons.security,
                    'Privacy First',
                    'All data stored locally on your device - no cloud storage',
                  ),
                  _buildFeatureItem(
                    context,
                    Icons.dashboard,
                    'Visual Reports',
                    'Clear charts and reports to understand your decisions',
                  ),
                ],
              ),
            ),

            // Privacy Commitment Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Text(
                        'Privacy Commitment',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ],
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
                          size: 20,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Expanded(
                          child: Text(
                            'Your decisions and personal data never leave your device. We believe privacy is a fundamental right.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contact Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.contact_support_outlined,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Text(
                        'Get in Touch',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'We\'d love to hear from you! Whether you have questions, suggestions, or just want to share how Clarity has helped you make better decisions.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'Use the Feedback & Suggestions section in Settings to reach out to us.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
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

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}