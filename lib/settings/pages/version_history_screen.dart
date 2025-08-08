import 'package:flutter/material.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_styles.dart';
import '../../shared/glass_card_widget.dart';

class VersionHistoryScreen extends StatelessWidget {
  const VersionHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<VersionInfo> versions = [
      VersionInfo(
        version: '1.0.0',
        releaseDate: 'June 1, 2023',
        changes: [
          'Initial release',
          'Photo editor with stickers and cropping',
          'Journal module for recording positive events',
          'Tea tracker for monitoring consumption',
          'Dark and light theme support',
        ],
        isCurrent: true,
      ),
      VersionInfo(
        version: '0.9.5',
        releaseDate: 'May 15, 2023',
        changes: [
          'Beta release with limited features',
          'Bug fixes and performance improvements',
          'UI refinements based on user feedback',
          'Added support for different device sizes',
        ],
      ),
      VersionInfo(
        version: '0.9.0',
        releaseDate: 'April 30, 2023',
        changes: [
          'Alpha release for internal testing',
          'Basic functionality implementation',
          'Core modules development',
          'Initial design implementation',
        ],
      ),
      VersionInfo(
        version: '0.8.0',
        releaseDate: 'April 1, 2023',
        changes: [
          'Prototype version',
          'Concept validation',
          'Architecture planning',
          'Initial UI mockups',
        ],
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Version History', style: AppTextStyles.headingLarge),
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
                  'Version History',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.brandTeal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'See how the app has evolved over time',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: versions.length,
                    itemBuilder: (context, index) {
                      return _buildVersionCard(versions[index]);
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

  Widget _buildVersionCard(VersionInfo version) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Version ${version.version}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandTeal,
                  ),
                ),
                if (version.isCurrent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandTeal.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Current',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.brandTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  version.releaseDate,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.white10),
            const SizedBox(height: 12),
            ...version.changes
                .map((change) => _buildChangeItem(change))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeItem(String change) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: AppTextStyles.bodyMedium),
          Expanded(
            child: Text(
              change,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class VersionInfo {
  final String version;
  final String releaseDate;
  final List<String> changes;
  final bool isCurrent;

  VersionInfo({
    required this.version,
    required this.releaseDate,
    required this.changes,
    this.isCurrent = false,
  });
}
