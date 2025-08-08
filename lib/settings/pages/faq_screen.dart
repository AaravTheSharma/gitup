import 'package:flutter/material.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_styles.dart';
import '../../shared/glass_card_widget.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I edit a photo?',
      answer:
          'To edit a photo, go to the Photo Editor tab, select an image from your gallery or take a new photo. You can then add stickers, crop the image, and save your creation to your device.',
    ),
    FAQItem(
      question: 'How do I add a journal entry?',
      answer:
          'To add a journal entry, navigate to the Journal tab and tap the "+" button. Enter your thoughts, add tags if desired, and tap "Save" to record your entry.',
    ),
    FAQItem(
      question: 'How do I track my tea consumption?',
      answer:
          'In the Tea Tracker tab, tap the "Add New Record" button. Enter details about your beverage including name, brand, price, and rating. The app will automatically track your monthly consumption and spending.',
    ),
    FAQItem(
      question: 'Can I change the app theme?',
      answer:
          'Yes! Go to Settings > Appearance and toggle between light and dark mode according to your preference.',
    ),
    FAQItem(
      question: 'How do I enable or disable notifications?',
      answer:
          'You can manage notifications in Settings > Notifications. Toggle the switch to enable or disable app notifications.',
    ),
    FAQItem(
      question: 'Is my data backed up?',
      answer:
          'Currently, all data is stored locally on your device. We recommend regularly backing up your device to prevent data loss.',
    ),
    FAQItem(
      question: 'How can I delete my data?',
      answer:
          'You can delete individual entries from their respective sections. If you wish to reset all app data, please contact our support team.',
    ),
    FAQItem(
      question: 'How do I report a bug?',
      answer:
          'You can report bugs or issues through the Feedback section in Settings. Please provide as much detail as possible to help us resolve the issue quickly.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('FAQ', style: AppTextStyles.headingLarge),
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
                  'Frequently Asked Questions',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.brandTeal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find answers to common questions about using the app.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _faqItems.length,
                    itemBuilder: (context, index) {
                      return _buildFAQItem(_faqItems[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassCard(
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            title: Text(
              item.question,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            iconColor: AppColors.brandTeal,
            collapsedIconColor: Colors.grey,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                child: Text(
                  item.answer,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}
