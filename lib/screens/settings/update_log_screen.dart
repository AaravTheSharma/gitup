import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateLogScreen extends StatelessWidget {
  final SharedPreferences prefs;

  const UpdateLogScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Log'),
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
              _buildHeader(),
              const SizedBox(height: 24),
              _buildVersionCard(
                version: '1.2.0',
                date: 'June 15, 2023',
                changes: [
                  'Added dark mode support',
                  'Improved menstrual cycle tracking with more detailed analytics',
                  'New expense categories for fashion items',
                  'Enhanced storage organization with location tagging',
                  'Bug fixes and performance improvements',
                ],
                isLatest: true,
              ),
              _buildVersionCard(
                version: '1.1.0',
                date: 'April 3, 2023',
                changes: [
                  'Added expense charts and analytics',
                  'Improved UI for better user experience',
                  'Added reminder notifications',
                  'Fixed bugs in cycle tracking',
                  'Performance optimizations',
                ],
              ),
              _buildVersionCard(
                version: '1.0.1',
                date: 'February 10, 2023',
                changes: [
                  'Fixed critical bugs in data storage',
                  'Improved app stability',
                  'Minor UI adjustments',
                ],
              ),
              _buildVersionCard(
                version: '1.0.0',
                date: 'January 1, 2023',
                changes: [
                  'Initial release',
                  'Core features: menstrual cycle tracking, fashion expense tracking, storage organization',
                  'Basic UI and functionality',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.update, color: Colors.teal, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'App Update History',
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
            'Track the evolution of Doraplexis with our update history. We continuously improve the app based on user feedback and technological advancements.',
            style: TextStyle(
              color: Color(0xFFB0BEC5),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard({
    required String version,
    required String date,
    required List<String> changes,
    bool isLatest = false,
  }) {
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
          color: isLatest
              ? const Color(0xFF00B4A0).withOpacity(0.3)
              : const Color(0xFF00B4A0).withOpacity(0.1),
          width: isLatest ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLatest
                  ? const Color(0xFF00B4A0).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Version $version',
                            style: const TextStyle(
                              color: Color(0xFFE0F7FA),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isLatest) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B4A0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Latest',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Released on $date',
                        style: const TextStyle(
                          color: Color(0xFFB0BEC5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.new_releases_outlined,
                  color: isLatest
                      ? const Color(0xFF00B4A0)
                      : const Color(0xFFB0BEC5),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFF0F1A2F)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What\'s New:',
                  style: TextStyle(
                    color: Color(0xFFE0F7FA),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ...changes.map((change) => _buildChangeItem(change)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeItem(String change) {
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
              change,
              style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
