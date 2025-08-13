import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final SharedPreferences prefs;

  const PrivacyPolicyScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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

              _buildPolicySection(
                title: 'Introduction',
                content:
                    'Welcome to Doraplexis ("we," "our," or "us"). We are committed to protecting your privacy and ensuring you have a positive experience when using our application. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.',
              ),

              _buildPolicySection(
                title: 'Information We Collect',
                content:
                    'Our app is designed to work without collecting personal data from our servers. All data you input into the application is stored locally on your device. This includes:\n\n• Menstrual cycle information\n• Fashion expense records\n• Storage organization data\n\nWe do not collect, transmit, or store this information on external servers.',
              ),

              _buildPolicySection(
                title: 'How We Use Your Information',
                content:
                    'Since all data is stored locally on your device, we do not use your information for any purpose. The app processes your data solely on your device to provide you with the functionality you expect.',
              ),

              _buildPolicySection(
                title: 'Data Security',
                content:
                    'We implement appropriate technical and organizational measures to protect the data you store in our application. However, please be aware that no security system is impenetrable, and we cannot guarantee the absolute security of your locally stored data.',
              ),

              _buildPolicySection(
                title: 'Third-Party Services',
                content:
                    'Our application does not integrate with third-party services that would access your personal data.',
              ),

              _buildPolicySection(
                title: 'Children\'s Privacy',
                content:
                    'Our application is not directed to children under the age of 13. We do not knowingly collect personal information from children under 13.',
              ),

              _buildPolicySection(
                title: 'Changes to This Privacy Policy',
                content:
                    'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.',
              ),

              _buildPolicySection(
                title: 'Contact Us',
                content:
                    'If you have any questions about this Privacy Policy, please contact us at privacy@doraplexis.com.',
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

  Widget _buildPolicySection({required String title, required String content}) {
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
