import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  final SharedPreferences _prefs;

  StorageHelper(this._prefs);

  // Store a string
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  // Retrieve a string
  String? getString(String key) {
    return _prefs.getString(key);
  }

  // Store an int
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  // Retrieve an int
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // Store a double
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  // Retrieve a double
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  // Store a boolean
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  // Retrieve a boolean
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // Store a list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  // Retrieve a list of strings
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  // Store an object
  Future<bool> setObject<T>(String key, T value) async {
    final jsonString = jsonEncode(value);
    return await _prefs.setString(key, jsonString);
  }

  // Retrieve an object
  T? getObject<T>(String key, T Function(Map<String, dynamic> json) fromJson) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) {
      return null;
    }

    try {
      final Map<String, dynamic> json =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      print('Error retrieving object: $e');
      return null;
    }
  }

  // Store a list of objects
  Future<bool> setObjectList<T>(String key, List<T> value) async {
    final jsonString = jsonEncode(value);
    return await _prefs.setString(key, jsonString);
  }

  // Retrieve a list of objects
  List<T>? getObjectList<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) {
      return null;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error retrieving object list: $e');
      return null;
    }
  }

  // Remove a key
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  // Check if a key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Clear all data
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // Get all keys
  Set<String> getKeys() {
    return _prefs.getKeys();
  }
}
