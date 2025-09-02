import 'package:flutter/material.dart';
import '../../../data/services/storage_service.dart';
import '../../../core/app_constants.dart';
import '../../../utils/helpers.dart';
import '../../widgets/custom_card.dart';
import 'about_us_screen.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';
import 'help_screen.dart';
import 'feedback_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  StorageService? _storageService;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _storageService = await StorageService.getInstance();
  }

  Future<void> _clearAllData() async {
    if (_storageService == null) return;

    final confirmed = await Helpers.showConfirmationDialog(
      context,
      'Clear All Data',
      'Are you sure you want to delete all your decisions and data? This action cannot be undone.',
      confirmText: 'Clear All',
      cancelText: 'Cancel',
    );

    if (!confirmed) return;

    try {
      await _storageService!.clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared successfully'),
            backgroundColor: Color(AppConstants.secondaryColor),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your app preferences and information.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.paddingXLarge),

            // Information Section
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Information',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text('About Us'),
                    subtitle: const Text('Learn more about Clarity'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AboutUsScreen()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.description_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text('Terms of Service'),
                    subtitle: const Text('Read our terms and conditions'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text('Privacy Policy'),
                    subtitle: const Text('How we protect your privacy'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Support Section
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.help_outline,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text('Help & FAQ'),
                    subtitle: const Text('Get help using the app'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HelpScreen()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.feedback_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text('Feedback & Suggestions'),
                    subtitle: const Text('Share your thoughts with us'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Data Management Section
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Management',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.delete_forever,
                      color: Color(AppConstants.dangerColor),
                    ),
                    title: const Text(
                      'Clear All Data',
                      style: TextStyle(color: Color(AppConstants.dangerColor)),
                    ),
                    subtitle: const Text('Permanently delete all decisions'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _clearAllData,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}