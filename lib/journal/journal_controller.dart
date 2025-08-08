import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';

class JournalController {
  static const String _entriesKey = 'journal_entries';
  static const String _streakKey = 'journal_streak';
  static const String _lastEntryDateKey = 'last_entry_date';

  // Get all journal entries
  Future<List<JournalEntry>> getEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList(_entriesKey) ?? [];

      final entries = entriesJson
          .map((json) => JournalEntry.fromJson(jsonDecode(json)))
          .toList();

      // Sort by time in descending order
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return entries;
    } catch (e) {
      print('Failed to get journal entries: $e');
      return [];
    }
  }

  // Add new journal entry
  Future<JournalEntry?> addEntry(
    String title,
    String content,
    List<String> tags,
    String category,
    int rating,
    String? imageUrl,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList(_entriesKey) ?? [];

      final newEntry = JournalEntry.create(
        title,
        content,
        tags,
        category,
        rating,
        imageUrl,
      );
      entriesJson.add(jsonEncode(newEntry.toJson()));

      await prefs.setStringList(_entriesKey, entriesJson);

      // Update streak days
      await _updateStreakDays();

      return newEntry;
    } catch (e) {
      print('Failed to add journal entry: $e');
      return null;
    }
  }

  // Delete journal entry
  Future<bool> deleteEntry(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList(_entriesKey) ?? [];

      final entries = entriesJson
          .map((json) => JournalEntry.fromJson(jsonDecode(json)))
          .toList();

      final filteredEntries = entries.where((entry) => entry.id != id).toList();

      if (filteredEntries.length < entries.length) {
        final newEntriesJson =
            filteredEntries.map((entry) => jsonEncode(entry.toJson())).toList();

        await prefs.setStringList(_entriesKey, newEntriesJson);
        return true;
      }

      return false;
    } catch (e) {
      print('Failed to delete journal entry: $e');
      return false;
    }
  }

  // Get streak days
  Future<int> getStreakDays() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_streakKey) ?? 0;
    } catch (e) {
      print('Failed to get streak days: $e');
      return 0;
    }
  }

  // Update streak days
  Future<void> _updateStreakDays() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Get last entry date
      final lastEntryDateMillis = prefs.getInt(_lastEntryDateKey);
      final currentStreak = prefs.getInt(_streakKey) ?? 0;

      if (lastEntryDateMillis != null) {
        final lastEntryDate = DateTime.fromMillisecondsSinceEpoch(
          lastEntryDateMillis,
        );
        final lastDate = DateTime(
          lastEntryDate.year,
          lastEntryDate.month,
          lastEntryDate.day,
        );

        final difference = todayDate.difference(lastDate).inDays;

        if (difference == 0) {
          // Already recorded today, don't update streak
          return;
        } else if (difference == 1) {
          // Consecutive entry
          await prefs.setInt(_streakKey, currentStreak + 1);
        } else {
          // Streak broken, reset to 1
          await prefs.setInt(_streakKey, 1);
        }
      } else {
        // First entry
        await prefs.setInt(_streakKey, 1);
      }

      // Update last entry date
      await prefs.setInt(_lastEntryDateKey, todayDate.millisecondsSinceEpoch);
    } catch (e) {
      print('Failed to update streak days: $e');
    }
  }
}
