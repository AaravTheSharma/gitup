import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/ad_manager_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences for local storage
  final prefs = await SharedPreferences.getInstance();
  
  // Initialize Ad Manager Service
  AdManagerService().initialize();

  runApp(DoraplexisApp(prefs: prefs));
}
