import 'package:flutter/material.dart';
import '../../../core/app_constants.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/primary_button.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  String _selectedCategory = 'General Feedback';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'General Feedback',
    'Bug Report',
    'Feature Request',
    'User Experience',
    'Performance Issue',
    'Question/Support',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simulate submission delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your feedback! We appreciate your input.'),
        backgroundColor: Color(AppConstants.secondaryColor),
      ),
    );

    // Clear form
    _feedbackController.clear();
    setState(() {
      _selectedCategory = 'General Feedback';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback & Suggestions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.feedback,
                          color: Theme.of(context).primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          'We Value Your Input',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Your feedback helps us improve Clarity and make it more useful for everyone. Whether you\'ve found a bug, have an idea for a new feature, or just want to share your experience, we\'d love to hear from you!',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),

              // Feedback Form
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Your Feedback',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Category Selection
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          items: _categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Feedback Text
                    Text(
                      'Your Message',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    TextFormField(
                      controller: _feedbackController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Please share your thoughts, suggestions, or describe any issues you\'ve encountered...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                        ),
                        contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your feedback';
                        }
                        if (value.trim().length < 10) {
                          return 'Please provide more detailed feedback (at least 10 characters)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: _isSubmitting ? 'Submitting...' : 'Submit Feedback',
                        onPressed: _isSubmitting ? null : _submitFeedback,
                        isLoading: _isSubmitting,
                      ),
                    ),
                  ],
                ),
              ),

              // Feedback Guidelines
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          'Feedback Guidelines',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _buildGuidelineItem(
                      context,
                      Icons.bug_report,
                      'Bug Reports',
                      'Describe what happened, what you expected, and steps to reproduce the issue.',
                    ),
                    _buildGuidelineItem(
                      context,
                      Icons.lightbulb,
                      'Feature Requests',
                      'Explain the feature you\'d like and how it would improve your experience.',
                    ),
                    _buildGuidelineItem(
                      context,
                      Icons.speed,
                      'Performance Issues',
                      'Let us know about slow loading, crashes, or other performance problems.',
                    ),
                    _buildGuidelineItem(
                      context,
                      Icons.thumb_up,
                      'General Feedback',
                      'Share what you love about the app or areas for improvement.',
                    ),
                  ],
                ),
              ),

              // Privacy Notice
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.privacy_tip,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          'Privacy Notice',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Note: This is a demonstration feedback form.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'In a real implementation, feedback would be sent securely to our support team. We would only collect the information you provide and use it solely to improve the app and respond to your feedback.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(BuildContext context, IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 16,
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