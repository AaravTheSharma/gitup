import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'routes.dart';
import 'photo_editor/photo_editor_screen.dart';
import 'journal/journal_screen.dart';
import 'tea_tracker/tea_tracker_screen.dart';
import 'settings/settings_screen.dart';
import 'settings/settings_controller.dart';
import 'splash_screen.dart';
import 'shared/ad_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置状态栏透明
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  // 获取用户配置（主题设置）
  final settingsController = SettingsController();
  final userProfile = await settingsController.getUserProfile();

  runApp(MyApp(isDarkMode: userProfile.isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;

  const MyApp({Key? key, this.isDarkMode = true}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Florsovivexa',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routes: {
        ...AppRoutes.getRoutes(),
        '/home': (context) => const MainScreen(),
      },
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final AdManager _adManager = AdManager.instance;

  final List<Widget> _screens = [
    const PhotoEditorScreen(),
    const JournalScreen(),
    const TeaTrackerScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 初始化广告管理器
    _initializeAdManager();
  }

  void _initializeAdManager() {
    // 设置广告加载状态变化回调
    _adManager.setAdLoadStatusCallback((status) {
      print('广告加载状态变化: $status');
    });
  }

  /// 处理底部导航栏点击事件
  void _onBottomNavTap(int index) {
    // 如果点击的是当前选中的标签，不显示广告
    if (index == _currentIndex) {
      return;
    }

    // 更新当前索引
    setState(() {
      _currentIndex = index;
    });

    // 尝试显示插页广告
    _showInterstitialAdOnTabChange();
  }

  /// 在标签切换时显示插页广告
  Future<void> _showInterstitialAdOnTabChange() async {
    try {
      final success = await _adManager.tryShowInterstitialAd();
      
      if (success) {
        print('标签切换时插页广告显示成功');
      } else {
        print('标签切换时插页广告未显示（间隔限制或未加载）');
      }
    } catch (e) {
      print('标签切换时显示插页广告失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.15), width: 1),
          ),
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onBottomNavTap, // 使用新的点击处理方法
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(
                context,
              ).bottomNavigationBarTheme.selectedItemColor,
              unselectedItemColor: Theme.of(
                context,
              ).bottomNavigationBarTheme.unselectedItemColor,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.camera_alt_outlined),
                  activeIcon: Icon(Icons.camera_alt),
                  label: 'Photo',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_awesome_outlined),
                  activeIcon: Icon(Icons.auto_awesome),
                  label: 'Journal',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_cafe_outlined),
                  activeIcon: Icon(Icons.local_cafe),
                  label: 'Tea',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
