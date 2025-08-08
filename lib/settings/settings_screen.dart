import 'package:flutter/material.dart';
import '../shared/app_colors.dart';
import '../shared/app_text_styles.dart';
import '../shared/glass_card_widget.dart';
import '../models/user_profile.dart';
import 'settings_controller.dart';

// 导入各个设置页面
import 'pages/faq_screen.dart';
import 'pages/terms_screen.dart';
import 'pages/privacy_screen.dart';
import 'pages/version_history_screen.dart';
import 'pages/feedback_screen.dart';
import 'pages/update_log_screen.dart';
import 'pages/about_screen.dart';
import 'pages/tutorial_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsController _controller = SettingsController();
  UserProfile _userProfile = UserProfile.defaultProfile();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    final profile = await _controller.getUserProfile();

    if (mounted) {
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings', style: AppTextStyles.headingLarge),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.brandTeal),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 应用设置卡片

                        // 帮助与支持卡片
                        _buildSectionTitle('Help & Support'),
                        const SizedBox(height: 8),
                        _buildSettingsCard([
                          _buildSettingItem(
                            icon: Icons.help_outline,
                            iconColor: Colors.blue,
                            title: 'FAQ',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FAQScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, color: Colors.white10),
                          _buildSettingItem(
                            icon: Icons.feedback,
                            iconColor: Colors.orange,
                            title: 'Feedback',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FeedbackScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, color: Colors.white10),
                          _buildSettingItem(
                            icon: Icons.school,
                            iconColor: Colors.green,
                            title: 'Tutorial',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TutorialScreen(),
                                ),
                              );
                            },
                          ),
                        ]),

                        const SizedBox(height: 24),

                        // 信息卡片
                        _buildSectionTitle('Information'),
                        const SizedBox(height: 8),
                        _buildSettingsCard([
                          _buildSettingItem(
                            icon: Icons.history,
                            iconColor: Colors.teal,
                            title: 'Version History',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const VersionHistoryScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, color: Colors.white10),
                          _buildSettingItem(
                            icon: Icons.update,
                            iconColor: Colors.indigo,
                            title: 'Update Log',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UpdateLogScreen(),
                                ),
                              );
                            },
                          ),
                        ]),

                        const SizedBox(height: 24),

                        // 法律与政策卡片
                        _buildSectionTitle('Legal & Policies'),
                        const SizedBox(height: 8),
                        _buildSettingsCard([
                          _buildSettingItem(
                            icon: Icons.gavel,
                            iconColor: Colors.brown,
                            title: 'Terms of Service',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TermsScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, color: Colors.white10),
                          _buildSettingItem(
                            icon: Icons.privacy_tip,
                            iconColor: Colors.red,
                            title: 'Privacy Policy',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PrivacyScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, color: Colors.white10),
                          _buildSettingItem(
                            icon: Icons.info,
                            iconColor: Colors.cyan,
                            title: 'About Us',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutScreen(),
                                ),
                              );
                            },
                          ),
                        ]),

                        const SizedBox(height: 24),

                        // 版本信息
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              'Version 1.0.0',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: AppTextStyles.headingSmall.copyWith(
          color: AppColors.brandTeal,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
