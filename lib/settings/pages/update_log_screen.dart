import 'package:flutter/material.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_styles.dart';
import '../../shared/glass_card_widget.dart';

class UpdateLogScreen extends StatelessWidget {
  const UpdateLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<UpdateInfo> updates = [
      UpdateInfo(
        version: '1.0.0',
        releaseDate: 'June 1, 2023',
        features: [
          'Photo Editor: Added support for multiple sticker types',
          'Journal: Added tag filtering and search functionality',
          'Tea Tracker: Implemented detailed monthly statistics',
          'Settings: Added theme customization options',
        ],
        bugFixes: [
          'Fixed crash when saving large images',
          'Resolved UI layout issues on smaller devices',
          'Fixed keyboard overlap in text input fields',
          'Corrected date formatting in journal entries',
        ],
        improvements: [
          'Improved app startup time by 30%',
          'Enhanced UI animations for smoother transitions',
          'Optimized storage usage for journal entries',
          'Reduced memory usage when editing photos',
        ],
      ),
      UpdateInfo(
        version: '0.9.5',
        releaseDate: 'May 15, 2023',
        features: [
          'Added preliminary support for photo editing',
          'Implemented basic journal functionality',
          'Added initial version of tea tracking',
        ],
        bugFixes: [
          'Fixed several crash issues reported in beta testing',
          'Resolved data persistence problems',
        ],
        improvements: [
          'UI refinements based on user feedback',
          'Performance optimizations for smoother experience',
          'Improved compatibility with different screen sizes',
        ],
      ),
      UpdateInfo(
        version: '0.9.0',
        releaseDate: 'April 30, 2023',
        features: [
          'First beta release with core functionality',
          'Basic UI implementation',
          'Fundamental app structure',
        ],
        bugFixes: [],
        improvements: [],
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Update Log', style: AppTextStyles.headingLarge),
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
                  'Update Log',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.brandTeal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track the latest improvements and fixes',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: updates.length,
                    itemBuilder: (context, index) {
                      return _buildUpdateCard(updates[index]);
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

  Widget _buildUpdateCard(UpdateInfo update) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Version ${update.version}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandTeal,
                  ),
                ),
                const Spacer(),
                Text(
                  update.releaseDate,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Features section
            if (update.features.isNotEmpty) ...[
              _buildSectionTitle('New Features', Colors.green),
              const SizedBox(height: 8),
              ...update.features.map((item) => _buildLogItem(item)).toList(),
              const SizedBox(height: 16),
            ],

            // Bug fixes section
            if (update.bugFixes.isNotEmpty) ...[
              _buildSectionTitle('Bug Fixes', Colors.red),
              const SizedBox(height: 8),
              ...update.bugFixes.map((item) => _buildLogItem(item)).toList(),
              const SizedBox(height: 16),
            ],

            // Improvements section
            if (update.improvements.isNotEmpty) ...[
              _buildSectionTitle('Improvements', Colors.blue),
              const SizedBox(height: 8),
              ...update.improvements
                  .map((item) => _buildLogItem(item))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLogItem(String item) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: AppTextStyles.bodyMedium),
          Expanded(
            child: Text(
              item,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class UpdateInfo {
  final String version;
  final String releaseDate;
  final List<String> features;
  final List<String> bugFixes;
  final List<String> improvements;

  UpdateInfo({
    required this.version,
    required this.releaseDate,
    required this.features,
    required this.bugFixes,
    required this.improvements,
  });
}
