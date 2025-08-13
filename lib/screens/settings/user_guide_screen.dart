import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserGuideScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const UserGuideScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  State<UserGuideScreen> createState() => _UserGuideScreenState();
}

class _UserGuideScreenState extends State<UserGuideScreen> {
  final List<String> _categories = [
    'Getting Started',
    'Women\'s Health',
    'Fashion Expenses',
    'Storage Organizer',
    'Settings',
  ];

  String _selectedCategory = 'Getting Started';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Guide'),
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
        child: Column(
          children: [
            _buildCategorySelector(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: _buildSelectedContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A2F),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF00B4A0)
                      : const Color(0xFF00B4A0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00B4A0)
                        : const Color(0xFF00B4A0).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFFE0F7FA),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedCategory) {
      case 'Getting Started':
        return _buildGettingStartedGuide();
      case 'Women\'s Health':
        return _buildWomensHealthGuide();
      case 'Fashion Expenses':
        return _buildFashionExpensesGuide();
      case 'Storage Organizer':
        return _buildStorageOrganizerGuide();
      case 'Settings':
        return _buildSettingsGuide();
      default:
        return const SizedBox();
    }
  }

  Widget _buildGettingStartedGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGuideHeader(
          title: 'Welcome to Doraplexis',
          description:
              'Your all-in-one lifestyle management app. This guide will help you get started with the basic features.',
          icon: Icons.lightbulb_outline,
          iconColor: Colors.orange,
        ),
        const SizedBox(height: 24),
        _buildStepCard(
          step: 1,
          title: 'Navigation Basics',
          content:
              'Use the bottom navigation bar to switch between different sections of the app: Women\'s Health, Fashion Expenses, and Storage Organizer.',
          iconData: Icons.navigation,
        ),
        _buildStepCard(
          step: 2,
          title: 'Adding New Data',
          content:
              'In each section, use the + button in the bottom right corner to add new entries.',
          iconData: Icons.add_circle_outline,
        ),
        _buildStepCard(
          step: 3,
          title: 'Viewing Analytics',
          content:
              'Each section provides analytics and visualizations to help you understand your data better.',
          iconData: Icons.bar_chart,
        ),
        _buildStepCard(
          step: 4,
          title: 'Settings and Customization',
          content:
              'Access the settings menu to customize the app according to your preferences.',
          iconData: Icons.settings,
        ),
        const SizedBox(height: 16),
        _buildTipCard(
          'For more detailed instructions on specific features, select the corresponding category from the tabs above.',
        ),
      ],
    );
  }

  Widget _buildWomensHealthGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGuideHeader(
          title: 'Women\'s Health Tracking',
          description:
              'Track and analyze your menstrual cycle for better health management.',
          icon: Icons.female,
          iconColor: Colors.pink,
        ),
        const SizedBox(height: 24),
        _buildStepCard(
          step: 1,
          title: 'Recording Your Cycle',
          content:
              'Tap the + button to record the start date of your period. You can also add details like symptoms, mood, and flow intensity.',
          iconData: Icons.calendar_today,
        ),
        _buildStepCard(
          step: 2,
          title: 'Understanding the Lunar Disc',
          content:
              'The lunar disc visualization shows your current cycle phase. The outer ring represents the days of your cycle, while the inner ring shows your current day.',
          iconData: Icons.circle,
        ),
        _buildStepCard(
          step: 3,
          title: 'Viewing Predictions',
          content:
              'The app predicts your next period, fertile window, and ovulation day based on your historical data.',
          iconData: Icons.timeline,
        ),
        _buildStepCard(
          step: 4,
          title: 'Adding Symptoms',
          content:
              'Track symptoms throughout your cycle by selecting the day and adding relevant symptoms from the list.',
          iconData: Icons.healing,
        ),
        const SizedBox(height: 16),
        _buildTipCard(
          'The more consistently you track your cycle, the more accurate the predictions will become over time.',
        ),
      ],
    );
  }

  Widget _buildFashionExpensesGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGuideHeader(
          title: 'Fashion Expense Tracking',
          description:
              'Monitor and analyze your fashion-related expenses to better manage your budget.',
          icon: Icons.style,
          iconColor: Colors.purple,
        ),
        const SizedBox(height: 24),
        _buildStepCard(
          step: 1,
          title: 'Adding Expenses',
          content:
              'Tap the + button to add a new fashion expense. Enter details like item name, category, price, and purchase date.',
          iconData: Icons.add_shopping_cart,
        ),
        _buildStepCard(
          step: 2,
          title: 'Categorizing Items',
          content:
              'Assign categories to your purchases (e.g., Clothing, Accessories, Shoes) for better organization and analysis.',
          iconData: Icons.category,
        ),
        _buildStepCard(
          step: 3,
          title: 'Viewing Expense Charts',
          content:
              'The expense chart shows your spending patterns over time. You can filter by month, category, or price range.',
          iconData: Icons.pie_chart,
        ),
        _buildStepCard(
          step: 4,
          title: 'Setting Budgets',
          content:
              'Set monthly or category-specific budgets and track your progress against them.',
          iconData: Icons.account_balance_wallet,
        ),
        const SizedBox(height: 16),
        _buildTipCard(
          'Take photos of your receipts and attach them to expense entries for better record-keeping.',
        ),
      ],
    );
  }

  Widget _buildStorageOrganizerGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGuideHeader(
          title: 'Storage Organization',
          description:
              'Keep track of your items and their storage locations for easy retrieval.',
          icon: Icons.inventory_2,
          iconColor: Colors.amber,
        ),
        const SizedBox(height: 24),
        _buildStepCard(
          step: 1,
          title: 'Adding Items',
          content:
              'Tap the + button to add a new item to your inventory. Include details like name, category, quantity, and storage location.',
          iconData: Icons.add_box,
        ),
        _buildStepCard(
          step: 2,
          title: 'Creating Storage Locations',
          content:
              'Define storage locations (e.g., Closet, Drawer 1, Basement Box) to organize your items effectively.',
          iconData: Icons.place,
        ),
        _buildStepCard(
          step: 3,
          title: 'Using Tags',
          content: 'Add tags to your items for easier searching and filtering.',
          iconData: Icons.local_offer,
        ),
        _buildStepCard(
          step: 4,
          title: 'Viewing Distribution',
          content:
              'The pie chart shows the distribution of items across different locations or categories.',
          iconData: Icons.pie_chart,
        ),
        const SizedBox(height: 16),
        _buildTipCard(
          'Take photos of your items and storage locations to make identification easier.',
        ),
      ],
    );
  }

  Widget _buildSettingsGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGuideHeader(
          title: 'Settings and Customization',
          description:
              'Personalize your app experience and access additional resources.',
          icon: Icons.settings,
          iconColor: Colors.blue,
        ),
        const SizedBox(height: 24),
        _buildStepCard(
          step: 1,
          title: 'Accessing Settings',
          content:
              'Tap the settings icon in the bottom navigation bar to access the settings menu.',
          iconData: Icons.settings,
        ),
        _buildStepCard(
          step: 2,
          title: 'Getting Help',
          content:
              'Visit the Help Center for answers to frequently asked questions and troubleshooting guides.',
          iconData: Icons.help_outline,
        ),
        _buildStepCard(
          step: 3,
          title: 'Providing Feedback',
          content:
              'Use the Feedback option to share your thoughts, suggestions, or report issues.',
          iconData: Icons.feedback_outlined,
        ),
        _buildStepCard(
          step: 4,
          title: 'Checking for Updates',
          content:
              'View the Update Log to see what\'s new in the latest version of the app.',
          iconData: Icons.update,
        ),
        const SizedBox(height: 16),
        _buildTipCard(
          'Make sure to check the Privacy Policy and Terms of Service to understand how your data is handled.',
        ),
      ],
    );
  }

  Widget _buildGuideHeader({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
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
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFE0F7FA),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFFB0BEC5),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required int step,
    required String title,
    required String content,
    required IconData iconData,
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF00B4A0),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              step.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(iconData, color: const Color(0xFF00B4A0), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFFE0F7FA),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  content,
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

  Widget _buildTipCard(String tip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB300).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFB300).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Color(0xFFFFB300), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pro Tip',
                  style: TextStyle(
                    color: Color(0xFFFFB300),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: const TextStyle(
                    color: Color(0xFFE0F7FA),
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
}
