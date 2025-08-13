import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutUsScreen extends StatelessWidget {
  final SharedPreferences prefs;

  const AboutUsScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
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
              _buildAppInfoSection(),
              const SizedBox(height: 24),
              _buildOurMissionSection(),
              const SizedBox(height: 24),
              _buildOurTeamSection(),
              const SizedBox(height: 24),
              _buildContactSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F1A2F), Color(0xFF00B4A0)],
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
          ),
          child: const Center(
            child: Icon(Icons.spa, color: Colors.white, size: 60),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Doraplexis',
          style: TextStyle(
            color: Color(0xFFE0F7FA),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Version 1.2.0',
          style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 16),
        ),
        const SizedBox(height: 16),
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
          child: const Text(
            'Doraplexis is an all-in-one lifestyle management app designed to help women track their health, manage fashion expenses, and organize personal items.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB0BEC5),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOurMissionSection() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flag,
                  color: Colors.lightBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Our Mission',
                  style: TextStyle(
                    color: Color(0xFFE0F7FA),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'We believe in empowering women to take control of their health and lifestyle through intuitive digital tools. Our mission is to create a seamless experience that integrates various aspects of daily life into one elegant solution.',
            style: TextStyle(
              color: Color(0xFFB0BEC5),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Our core values:',
            style: TextStyle(
              color: Color(0xFFE0F7FA),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildValueItem('Privacy-first approach to personal data'),
          _buildValueItem('User-centered design for intuitive experience'),
          _buildValueItem('Continuous improvement based on user feedback'),
          _buildValueItem('Elegant solutions to everyday challenges'),
        ],
      ),
    );
  }

  Widget _buildValueItem(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: Color(0xFF00B4A0),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOurTeamSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            'Our Team',
            style: TextStyle(
              color: Color(0xFFE0F7FA),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildTeamMemberCard(
          name: 'Lily Chen',
          role: 'Founder & Lead Designer',
          bio:
              'With over 10 years of experience in UX/UI design, Lily founded Doraplexis with a vision to create beautiful, functional apps that enhance daily life.',
          avatarColor: Colors.pink,
        ),
        _buildTeamMemberCard(
          name: 'David Wang',
          role: 'Lead Developer',
          bio:
              'David is a Flutter expert with a passion for creating smooth, responsive mobile experiences. He oversees all technical aspects of the app.',
          avatarColor: Colors.blue,
        ),
        _buildTeamMemberCard(
          name: 'Sarah Johnson',
          role: 'Health & Wellness Advisor',
          bio:
              'As a certified women\'s health practitioner, Sarah ensures that our health tracking features are accurate, useful, and based on sound medical principles.',
          avatarColor: Colors.green,
        ),
        _buildTeamMemberCard(
          name: 'Michael Zhang',
          role: 'Product Manager',
          bio:
              'Michael coordinates between our design, development, and advisory teams to ensure that Doraplexis meets the highest standards of quality and user satisfaction.',
          avatarColor: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildTeamMemberCard({
    required String name,
    required String role,
    required String bio,
    required Color avatarColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: avatarColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: avatarColor, width: 2),
            ),
            child: Center(
              child: Text(
                name.substring(0, 1),
                style: TextStyle(
                  color: avatarColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFFE0F7FA),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: TextStyle(
                    color: avatarColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bio,
                  style: const TextStyle(
                    color: Color(0xFFB0BEC5),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.contact_mail,
                  color: Colors.amber,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Get In Touch',
                  style: TextStyle(
                    color: Color(0xFFE0F7FA),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.email_outlined,
            title: 'Email',
            content: 'contact@doraplexis.com',
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.language,
            title: 'Website',
            content: 'www.doraplexis.com',
            iconColor: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.location_on_outlined,
            title: 'Address',
            content: '123 Innovation Street, Tech City, 100101',
            iconColor: Colors.red,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(Icons.facebook, Colors.blue),
              const SizedBox(width: 16),
              _buildSocialButton(Icons.camera_alt_outlined, Colors.purple),
              const SizedBox(width: 16),
              _buildSocialButton(Icons.chat_bubble_outline, Colors.green),
              const SizedBox(width: 16),
              _buildSocialButton(Icons.tiktok, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFE0F7FA),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
