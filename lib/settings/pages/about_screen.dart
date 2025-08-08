import 'package:flutter/material.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_styles.dart';
import '../../shared/glass_card_widget.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('About Us', style: AppTextStyles.headingLarge),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App logo and name
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.brandTeal.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 60,
                            color: AppColors.brandTeal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Florsovivexa',
                          style: AppTextStyles.headingLarge.copyWith(
                            color: AppColors.brandTeal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Version 1.0.0',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Capture moments, track habits, find joy',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // About the app
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our Story',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandTeal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Florsovivexa was created with a simple mission: to help people capture beautiful moments, track daily habits, and find joy in the small things.',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Our app combines photo editing, journaling, and habit tracking in one seamless experience, designed to enhance your daily life and preserve your precious memories.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Features
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Key Features',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandTeal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem(
                          icon: Icons.camera_alt,
                          title: 'Photo Editor',
                          description:
                              'Edit photos with stickers and creative tools',
                        ),
                        const Divider(height: 24, color: Colors.white10),
                        _buildFeatureItem(
                          icon: Icons.auto_awesome,
                          title: 'Journal',
                          description:
                              'Record positive events and good news in your life',
                        ),
                        const Divider(height: 24, color: Colors.white10),
                        _buildFeatureItem(
                          icon: Icons.local_cafe,
                          title: 'Tea Tracker',
                          description:
                              'Track your beverage consumption and spending',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Team
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our Team',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandTeal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'We are a passionate team of designers and developers dedicated to creating beautiful, functional apps that make a positive impact on people\'s lives.',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Our diverse backgrounds and shared vision drive us to innovate and create experiences that delight our users.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Contact
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect With Us',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandTeal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildContactItem(
                          icon: Icons.email,
                          title: 'Email',
                          value: 'support@flowerlife.com',
                        ),
                        const Divider(height: 24, color: Colors.white10),
                        _buildContactItem(
                          icon: Icons.language,
                          title: 'Website',
                          value: 'www.flowerlife.com',
                        ),
                        const Divider(height: 24, color: Colors.white10),
                        _buildContactItem(
                          icon: Icons.forum,
                          title: 'Feedback',
                          value: 'Send us your thoughts',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Copyright
                  Center(
                    child: Text(
                      '© 2023 Florsovivexa Team. All rights reserved.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.brandTeal.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.brandTeal,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.brandTeal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.brandTeal,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.brandTeal,
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
