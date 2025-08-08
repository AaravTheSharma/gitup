import 'package:flutter/material.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_styles.dart';
import '../../shared/glass_card_widget.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({Key? key}) : super(key: key);

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      title: 'Welcome to Florsovivexa',
      description:
          'Your all-in-one app for photo editing, journaling, and tracking your favorite beverages.',
      icon: Icons.auto_awesome,
      color: Colors.purple,
    ),
    TutorialStep(
      title: 'Photo Editor',
      description:
          'Edit your photos with stickers, crop them to perfection, and save your creations to your gallery.',
      icon: Icons.camera_alt,
      color: Colors.blue,
      steps: [
        'Tap the Photo tab to access the editor',
        'Select a photo from your gallery or take a new one',
        'Add stickers by tapping the sticker button',
        'Crop your image using the crop tool',
        'Save your creation to your gallery',
      ],
    ),
    TutorialStep(
      title: 'Journal',
      description:
          'Record positive events and good news in your life to cultivate gratitude and positivity.',
      icon: Icons.auto_awesome,
      color: Colors.orange,
      steps: [
        'Navigate to the Journal tab',
        'Tap the + button to add a new entry',
        'Write about something positive that happened',
        'Add tags to categorize your entries',
        'View your entries in a timeline format',
      ],
    ),
    TutorialStep(
      title: 'Tea Tracker',
      description:
          'Keep track of your beverage consumption, spending, and preferences.',
      icon: Icons.local_cafe,
      color: Colors.green,
      steps: [
        'Go to the Tea Tracker tab',
        'Tap "Add New Record" to log a beverage',
        'Enter details like name, brand, price, and rating',
        'View your monthly consumption and spending',
        'Track your favorite drinks over time',
      ],
    ),
    TutorialStep(
      title: 'Settings',
      description:
          'Customize your app experience and access helpful resources.',
      icon: Icons.settings,
      color: Colors.teal,
      steps: [
        'Access Settings from the bottom navigation bar',
        'Toggle between light and dark themes',
        'Manage notification preferences',
        'Find help in the FAQ section',
        'Send feedback to help us improve',
      ],
    ),
    TutorialStep(
      title: 'You\'re All Set!',
      description:
          'Start exploring Florsovivexa and make the most of your experience.',
      icon: Icons.celebration,
      color: Colors.pink,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _tutorialSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Tutorial', style: AppTextStyles.headingLarge),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _tutorialSteps.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildTutorialPage(_tutorialSteps[index]);
                  },
                ),
              ),
              _buildPageIndicator(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: _previousPage,
                        child: const Text(
                          'Back',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      const SizedBox(width: 80),
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandTeal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        _currentPage == _tutorialSteps.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialPage(TutorialStep step) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: step.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                step.icon,
                size: 60,
                color: step.color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              step.title,
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.brandTeal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              step.description,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (step.steps != null && step.steps!.isNotEmpty)
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to use:',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...step.steps!.asMap().entries.map((entry) {
                      final index = entry.key;
                      final stepText = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: step.color.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: step.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                stepText,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_tutorialSteps.length, (index) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index
                  ? AppColors.brandTeal
                  : Colors.grey.withOpacity(0.3),
            ),
          );
        }),
      ),
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String>? steps;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.steps,
  });
}
