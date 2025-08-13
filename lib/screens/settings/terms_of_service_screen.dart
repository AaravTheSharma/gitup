import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TermsOfServiceScreen extends StatelessWidget {
  final SharedPreferences prefs;

  const TermsOfServiceScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
              _buildLastUpdated('Last Updated: June 1, 2023'),
              const SizedBox(height: 24),

              _buildTermsSection(
                title: 'Acceptance of Terms',
                content:
                    'By downloading, installing, or using the Doraplexis application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.',
              ),

              _buildTermsSection(
                title: 'Use of the Application',
                content:
                    'Doraplexis grants you a personal, non-exclusive, non-transferable, revocable license to use the application for your personal, non-commercial purposes. You may not use the application for any illegal or unauthorized purpose.',
              ),

              _buildTermsSection(
                title: 'User Content',
                content:
                    'All data you input into the application is stored locally on your device. You retain all rights to your data. We do not claim ownership over any content you provide to the application.',
              ),

              _buildTermsSection(
                title: 'Intellectual Property',
                content:
                    'The application and its original content, features, and functionality are owned by Doraplexis and are protected by international copyright, trademark, patent, trade secret, and other intellectual property or proprietary rights laws.',
              ),

              _buildTermsSection(
                title: 'Disclaimer of Warranties',
                content:
                    'The application is provided on an "AS IS" and "AS AVAILABLE" basis. Doraplexis disclaims all warranties of any kind, whether express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, and non-infringement.',
              ),

              _buildTermsSection(
                title: 'Limitation of Liability',
                content:
                    'In no event shall Doraplexis be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the application.',
              ),

              _buildTermsSection(
                title: 'Changes to Terms',
                content:
                    'We reserve the right to modify or replace these Terms at any time. If a revision is material, we will provide at least 30 days\' notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.',
              ),

              _buildTermsSection(
                title: 'Contact Us',
                content:
                    'If you have any questions about these Terms, please contact us at legal@doraplexis.com.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastUpdated(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFB0BEC5),
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildTermsSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFE0F7FA),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
            child: Text(
              content,
              style: const TextStyle(
                color: Color(0xFFB0BEC5),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
