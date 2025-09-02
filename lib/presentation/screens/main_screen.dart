import 'package:flutter/material.dart';
import '../../core/app_constants.dart';
import 'dashboard/dashboard_screen.dart';
import 'archive/archive_screen.dart';
import 'insights/insights_screen.dart';
import 'settings/settings_screen.dart';
import 'new_decision/templates_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const DashboardScreen(),
    const ArchiveScreen(),
    const SizedBox.shrink(), // Placeholder for FAB
    const InsightsScreen(),
    const SettingsScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.archive),
      label: 'Archive',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.add, color: Colors.transparent),
      label: '',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.pie_chart),
      label: 'Insights',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (index == 2) return; // Skip FAB placeholder
    
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onFabPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TemplatesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            if (index != 2) {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        items: _navItems,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 8,
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              const Color(AppConstants.primaryDarkColor),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _onFabPressed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}