import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';
import '../../../utils/helpers.dart';
import '../../widgets/custom_card.dart';
import 'create_decision_screen.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  void _navigateToCreateDecision(BuildContext context, Map<String, dynamic> template) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateDecisionScreen(template: template),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decision Templates'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a template to get started quickly, or create a custom decision from scratch.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.paddingXLarge),
            ...AppConstants.decisionTemplates.map((template) {
              return CustomCard(
                onTap: () => _navigateToCreateDecision(context, template),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(template['color'] as int).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Helpers.getTemplateIcon(template['icon'] as String),
                        color: Color(template['color'] as int),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template['title'] as String,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            template['description'] as String,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 100), // Space for navigation
          ],
        ),
      ),
    );
  }
}