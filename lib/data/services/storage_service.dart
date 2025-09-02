import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/decision_model.dart';
import '../../core/app_constants.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Decision management
  Future<List<Decision>> loadDecisions() async {
    try {
      final String? decisionsJson = _preferences?.getString(AppConstants.keyDecisions);
      if (decisionsJson == null || decisionsJson.isEmpty) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(decisionsJson);
      return decodedList
          .map((json) => Decision.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading decisions: $e');
      return [];
    }
  }

  Future<bool> saveDecisions(List<Decision> decisions) async {
    try {
      final List<Map<String, dynamic>> jsonList = 
          decisions.map((decision) => decision.toJson()).toList();
      final String decisionsJson = jsonEncode(jsonList);
      return await _preferences?.setString(AppConstants.keyDecisions, decisionsJson) ?? false;
    } catch (e) {
      debugPrint('Error saving decisions: $e');
      return false;
    }
  }

  Future<bool> saveDecision(Decision decision) async {
    try {
      final List<Decision> decisions = await loadDecisions();
      final int existingIndex = decisions.indexWhere((d) => d.id == decision.id);
      
      if (existingIndex >= 0) {
        decisions[existingIndex] = decision;
      } else {
        decisions.add(decision);
      }
      
      return await saveDecisions(decisions);
    } catch (e) {
      debugPrint('Error saving decision: $e');
      return false;
    }
  }

  Future<bool> deleteDecision(String decisionId) async {
    try {
      final List<Decision> decisions = await loadDecisions();
      decisions.removeWhere((decision) => decision.id == decisionId);
      return await saveDecisions(decisions);
    } catch (e) {
      debugPrint('Error deleting decision: $e');
      return false;
    }
  }

  Future<Decision?> getDecision(String decisionId) async {
    try {
      final List<Decision> decisions = await loadDecisions();
      return decisions.firstWhere(
        (decision) => decision.id == decisionId,
        orElse: () => throw StateError('Decision not found'),
      );
    } catch (e) {
      debugPrint('Error getting decision: $e');
      return null;
    }
  }

  // Theme management
  Future<bool> saveThemeMode(bool isDarkMode) async {
    try {
      return await _preferences?.setBool(AppConstants.keyThemeMode, isDarkMode) ?? false;
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
      return false;
    }
  }

  Future<bool> loadThemeMode() async {
    try {
      return _preferences?.getBool(AppConstants.keyThemeMode) ?? false;
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
      return false;
    }
  }

  // Data management
  Future<bool> clearAllData() async {
    try {
      await _preferences?.remove(AppConstants.keyDecisions);
      return true;
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      return false;
    }
  }

  Future<String> exportAllData() async {
    try {
      final List<Decision> decisions = await loadDecisions();
      final bool isDarkMode = await loadThemeMode();
      
      final Map<String, dynamic> exportData = {
        'decisions': decisions.map((d) => d.toJson()).toList(),
        'themeMode': isDarkMode,
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
      
      return jsonEncode(exportData);
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return '';
    }
  }

  Future<bool> importData(String jsonData) async {
    try {
      final Map<String, dynamic> importData = jsonDecode(jsonData);
      
      if (importData.containsKey('decisions')) {
        final List<dynamic> decisionsJson = importData['decisions'];
        final List<Decision> decisions = decisionsJson
            .map((json) => Decision.fromJson(json as Map<String, dynamic>))
            .toList();
        await saveDecisions(decisions);
      }
      
      if (importData.containsKey('themeMode')) {
        await saveThemeMode(importData['themeMode'] as bool);
      }
      
      return true;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }

  // Statistics
  Future<Map<String, int>> getCriteriaUsageStats() async {
    try {
      final List<Decision> decisions = await loadDecisions();
      final Map<String, int> stats = {};
      
      for (final decision in decisions) {
        for (final criterion in decision.criteria) {
          stats[criterion.name] = (stats[criterion.name] ?? 0) + 1;
        }
      }
      
      return stats;
    } catch (e) {
      debugPrint('Error getting criteria usage stats: $e');
      return {};
    }
  }

  Future<Map<String, int>> getCategoryStats() async {
    try {
      final List<Decision> decisions = await loadDecisions();
      final Map<String, int> stats = {};
      
      for (final decision in decisions) {
        stats[decision.category] = (stats[decision.category] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      debugPrint('Error getting category stats: $e');
      return {};
    }
  }

  // Additional insights methods
  Future<Map<String, double>> getAverageScoresByOption() async {
    try {
      final List<Decision> decisions = await loadDecisions();
      final Map<String, List<double>> optionScores = {};
      
      for (final decision in decisions) {
        for (final option in decision.options) {
          if (!optionScores.containsKey(option.name)) {
            optionScores[option.name] = [];
          }
          
          // Calculate average score for this option across all criteria
          double totalScore = 0;
          int criteriaCount = 0;
          for (final criterion in decision.criteria) {
            totalScore += option.getScore(criterion.id);
            criteriaCount++;
          }
          
          if (criteriaCount > 0) {
            optionScores[option.name]!.add(totalScore / criteriaCount);
          }
        }
      }
      
      // Calculate averages
      final Map<String, double> averages = {};
      optionScores.forEach((optionName, scores) {
        if (scores.isNotEmpty) {
          averages[optionName] = scores.reduce((a, b) => a + b) / scores.length;
        }
      });
      
      return averages;
    } catch (e) {
      debugPrint('Error getting average scores by option: $e');
      return {};
    }
  }

  Future<int> getTotalDecisionsCount() async {
    try {
      final List<Decision> decisions = await loadDecisions();
      return decisions.length;
    } catch (e) {
      debugPrint('Error getting total decisions count: $e');
      return 0;
    }
  }

  Future<int> getCompletedDecisionsCount() async {
    try {
      final List<Decision> decisions = await loadDecisions();
      return decisions.where((decision) => decision.isCompleted).length;
    } catch (e) {
      debugPrint('Error getting completed decisions count: $e');
      return 0;
    }
  }
}