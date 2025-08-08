import 'package:flutter/material.dart';

// 导入屏幕
import 'photo_editor/photo_editor_screen.dart';
import 'journal/journal_screen.dart';
import 'tea_tracker/tea_tracker_screen.dart';
import 'settings/settings_screen.dart';
import 'splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String photoEditor = '/photo-editor';
  static const String journal = '/journal';
  static const String teaTracker = '/tea-tracker';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      photoEditor: (context) => const PhotoEditorScreen(),
      journal: (context) => const JournalScreen(),
      teaTracker: (context) => const TeaTrackerScreen(),
      settings: (context) => const SettingsScreen(),
    };
  }
}
