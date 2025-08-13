import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

class DoraplexisApp extends StatelessWidget {
  final SharedPreferences prefs;

  const DoraplexisApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 设置状态栏为透明色
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'Doraplexis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212), // obsidianBlack
        primaryColor: const Color(0xFF0A2E36), // deepSeaTeal
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00B4A0), // tealAccent
          secondary: Color(0xFF00B4A0), // tealAccent
          background: Color(0xFF121212), // obsidianBlack
          surface: Color(0xFF0F1A2F), // twilightBlue
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Color(0xFFE0F7FA), // lightCyan
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Color(0xFFE0F7FA), // lightCyan
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFFB0BEC5), // softGray
            fontSize: 14,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFFB0BEC5), // softGray
            fontSize: 14,
          ),
        ),
      ),
      home: _AppNavigator(prefs: prefs),
    );
  }
}

class _AppNavigator extends StatefulWidget {
  final SharedPreferences prefs;

  const _AppNavigator({Key? key, required this.prefs}) : super(key: key);

  @override
  State<_AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<_AppNavigator> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onComplete: () {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                HomeScreen(prefs: widget.prefs),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
    );
  }
}
