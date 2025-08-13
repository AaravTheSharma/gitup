import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings/help_center_screen.dart';
import 'settings/privacy_policy_screen.dart';
import 'settings/terms_of_service_screen.dart';
import 'settings/feedback_screen.dart';
import 'settings/update_log_screen.dart';
import 'settings/user_guide_screen.dart';
import 'settings/about_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const SettingsScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
              _buildSectionTitle('Support'),
              _buildCard([
                _buildListItem(
                  icon: Icons.help_outline,
                  iconColor: Colors.blue,
                  title: 'Help Center',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HelpCenterScreen(prefs: widget.prefs),
                    ),
                  ),
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.feedback_outlined,
                  iconColor: Colors.amber,
                  title: 'Feedback',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedbackScreen(prefs: widget.prefs),
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 20),
              _buildSectionTitle('Legal'),
              _buildCard([
                _buildListItem(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: Colors.green,
                  title: 'Privacy Policy',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PrivacyPolicyScreen(prefs: widget.prefs),
                    ),
                  ),
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.gavel_outlined,
                  iconColor: Colors.purple,
                  title: 'Terms of Service',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TermsOfServiceScreen(prefs: widget.prefs),
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 20),
              _buildSectionTitle('Information'),
              _buildCard([
                _buildListItem(
                  icon: Icons.update,
                  iconColor: Colors.teal,
                  title: 'Update Log',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UpdateLogScreen(prefs: widget.prefs),
                    ),
                  ),
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.lightbulb_outline,
                  iconColor: Colors.orange,
                  title: 'User Guide',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UserGuideScreen(prefs: widget.prefs),
                    ),
                  ),
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.info_outline,
                  iconColor: Colors.lightBlue,
                  title: 'About Us',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutUsScreen(prefs: widget.prefs),
                    ),
                  ),
                ),
              ]),
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

  Widget _buildCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Color(0xFFE0F7FA), fontSize: 16),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFB0BEC5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: const Color(0xFF00B4A0).withOpacity(0.1),
      thickness: 1,
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
