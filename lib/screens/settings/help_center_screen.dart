import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpCenterScreen extends StatelessWidget {
  final SharedPreferences prefs;

  const HelpCenterScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: const Color(0xFF0A2E36),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF0A2E36), const Color(0xFF121212)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Frequently Asked Questions'),
              const SizedBox(height: 16),
              _buildFaqItem(
                question: 'How do I track my menstrual cycle?',
                answer:
                    'Navigate to the Women\'s Health section by tapping the first tab in the bottom navigation. You can add or update your cycle data using the + button in the bottom right corner.',
              ),
              _buildFaqItem(
                question: 'How do I add a new fashion expense?',
                answer:
                    'Go to the Fashion Expense section (second tab) and tap the + button to add a new expense record. Fill in the required details and save.',
              ),
              _buildFaqItem(
                question: 'How can I organize my items in storage?',
                answer:
                    'In the Storage Organizer section (third tab), you can add new items by tapping the + button. You can categorize them and add details like location and quantity.',
              ),
              _buildFaqItem(
                question: 'Is my data stored securely?',
                answer:
                    'Yes, all your data is stored locally on your device. We don\'t collect or transmit your personal information to any external servers.',
              ),
              _buildFaqItem(
                question: 'How can I backup my data?',
                answer:
                    'Currently, data backup functionality is in development. In future updates, you\'ll be able to export your data to cloud storage services.',
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Contact Us'),
              const SizedBox(height: 16),
              _buildContactCard(
                icon: Icons.email_outlined,
                title: 'Email Support',
                content: 'support@doraplexis.com',
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildContactCard(
                icon: Icons.chat_bubble_outline,
                title: 'Live Chat',
                content: 'Available Monday-Friday, 9AM-5PM',
                iconColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFE0F7FA),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F1A2F).withOpacity(0.7),
            const Color(0xFF0A2E36).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF00B4A0).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            color: Color(0xFFE0F7FA),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconColor: const Color(0xFF00B4A0),
        collapsedIconColor: const Color(0xFFB0BEC5),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              answer,
              style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F1A2F).withOpacity(0.7),
            const Color(0xFF0A2E36).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF00B4A0).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFE0F7FA),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    color: Color(0xFFB0BEC5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
