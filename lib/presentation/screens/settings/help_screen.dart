import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';
import '../../widgets/custom_card.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
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
                    'Help & Frequently Asked Questions',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'Find answers to common questions and learn how to make the most of Clarity.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            // Getting Started
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Getting Started',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildFAQItem(
                    context,
                    'How do I create my first decision?',
                    'Tap the "+" button on the dashboard, choose a template or create a custom decision, add your options and criteria, then score each option against your criteria.',
                  ),
                  _buildFAQItem(
                    context,
                    'What are criteria and why are they important?',
                    'Criteria are the factors that matter to you when making a decision (e.g., cost, quality, convenience). They help you evaluate options objectively and consistently.',
                  ),
                  _buildFAQItem(
                    context,
                    'How do I set weights for criteria?',
                    'Weights determine how important each criterion is to your decision. Assign higher weights to more important factors. The app will normalize weights automatically.',
                  ),
                ],
              ),
            ),

            // Using the App
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Using the App',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildFAQItem(
                    context,
                    'How does the scoring system work?',
                    'Score each option from 1-10 for each criterion. Higher scores mean better performance. The app calculates weighted averages to determine the best option.',
                  ),
                  _buildFAQItem(
                    context,
                    'Can I modify a decision after creating it?',
                    'Yes! You can edit options, criteria, weights, and scores at any time. Changes will automatically update your results and reports.',
                  ),
                  _buildFAQItem(
                    context,
                    'What do the charts and reports show?',
                    'Reports show your final scores, performance comparisons, and analysis. The radar chart visualizes how each option performs across all criteria.',
                  ),
                  _buildFAQItem(
                    context,
                    'How do I archive completed decisions?',
                    'Completed decisions can be archived from the decision report screen. Archived decisions are moved to the Archive section for future reference.',
                  ),
                ],
              ),
            ),

            // Decision-Making Tips
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Decision-Making Tips',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildTipItem(
                    context,
                    Icons.lightbulb_outline,
                    'Start with clear criteria',
                    'Define what matters most to you before evaluating options. Good criteria are specific, measurable, and relevant to your decision.',
                  ),
                  _buildTipItem(
                    context,
                    Icons.balance,
                    'Be honest with scoring',
                    'Score options objectively based on facts, not emotions. If you\'re unsure, research more or ask for input from others.',
                  ),
                  _buildTipItem(
                    context,
                    Icons.trending_up,
                    'Review and adjust',
                    'If results don\'t feel right, review your criteria weights and scores. Your intuition combined with analysis leads to better decisions.',
                  ),
                  _buildTipItem(
                    context,
                    Icons.history,
                    'Learn from patterns',
                    'Use the Insights section to understand your decision-making patterns and improve future decisions.',
                  ),
                ],
              ),
            ),

            // Troubleshooting
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Troubleshooting',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  _buildFAQItem(
                    context,
                    'My data disappeared. What happened?',
                    'Data is stored locally on your device. If you cleared app data, reinstalled the app, or reset your device, the data may be lost. Always use the export feature for backups.',
                  ),
                  _buildFAQItem(
                    context,
                    'The app is running slowly. How can I fix this?',
                    'Try closing other apps, restarting the app, or clearing old decisions you no longer need. Large amounts of data can slow performance.',
                  ),
                  _buildFAQItem(
                    context,
                    'I can\'t see all my criteria in the chart.',
                    'Charts may truncate long names or show only top items to maintain readability. Tap on chart elements for full details.',
                  ),
                  _buildFAQItem(
                    context,
                    'How do I backup my decisions?',
                    'Currently, all data is stored locally. We recommend taking screenshots of important decisions or manually recording key information.',
                  ),
                ],
              ),
            ),

            // Best Practices
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Best Practices',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: AppConstants.paddingSmall),
                            Text(
                              'Pro Tips for Better Decisions',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        _buildBulletPoint(context, 'Limit criteria to 5-7 items for clarity'),
                        _buildBulletPoint(context, 'Include both quantitative and qualitative factors'),
                        _buildBulletPoint(context, 'Consider long-term consequences'),
                        _buildBulletPoint(context, 'Involve stakeholders in scoring when appropriate'),
                        _buildBulletPoint(context, 'Review decisions periodically to learn and improve'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Still Need Help
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Still Need Help?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'If you can\'t find the answer to your question here, we\'d love to help! Use the Feedback & Suggestions section in Settings to reach out to us.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'When contacting us, please include:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  _buildBulletPoint(context, 'A clear description of your question or issue'),
                  _buildBulletPoint(context, 'Steps you\'ve already tried'),
                  _buildBulletPoint(context, 'Your device type and app version'),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, IconData icon, String title, String description) {
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

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}