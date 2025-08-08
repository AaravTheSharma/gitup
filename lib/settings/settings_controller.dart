import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class SettingsController {
  static const String _userProfileKey = 'user_profile';

  // Get user profile
  Future<UserProfile> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_userProfileKey);

      if (profileJson != null) {
        return UserProfile.fromJson(jsonDecode(profileJson));
      }

      // If no saved profile, return default
      return UserProfile.defaultProfile();
    } catch (e) {
      print('Failed to get user profile: $e');
      return UserProfile.defaultProfile();
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(profile.toJson());

      return await prefs.setString(_userProfileKey, profileJson);
    } catch (e) {
      print('Failed to update user profile: $e');
      return false;
    }
  }

  // Update theme mode
  Future<bool> updateThemeMode(bool isDarkMode) async {
    try {
      final profile = await getUserProfile();
      final updatedProfile = profile.copyWithThemeMode(isDarkMode);

      return await updateUserProfile(updatedProfile);
    } catch (e) {
      print('Failed to update theme mode: $e');
      return false;
    }
  }

  // Update notification settings
  Future<bool> updateNotificationSettings(bool enableNotifications) async {
    try {
      final profile = await getUserProfile();
      final updatedProfile = profile.copyWithNotificationSettings(
        enableNotifications,
      );

      return await updateUserProfile(updatedProfile);
    } catch (e) {
      print('Failed to update notification settings: $e');
      return false;
    }
  }

  // Clear all data (reset app)
  Future<bool> resetApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e) {
      print('Failed to reset app: $e');
      return false;
    }
  }
}
