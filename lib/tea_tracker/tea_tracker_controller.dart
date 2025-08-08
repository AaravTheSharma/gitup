import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tea_record.dart';

class TeaTrackerController {
  static const String _recordsKey = 'tea_records';

  // Get recent records
  Future<List<TeaRecord>> getRecentRecords({int limit = 10}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getStringList(_recordsKey) ?? [];

      final records = recordsJson
          .map((json) => TeaRecord.fromJson(jsonDecode(json)))
          .toList();

      // 按时间倒序排列
      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // 限制返回数量
      if (records.length > limit) {
        return records.sublist(0, limit);
      }

      return records;
    } catch (e) {
      print('Failed to get tea records: $e');
      return [];
    }
  }

  // Add new record
  Future<bool> addRecord({
    required String name,
    required String brand,
    required double price,
    required int rating,
    String? notes,
    String? imagePath,
    required String type,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getStringList(_recordsKey) ?? [];

      final newRecord = TeaRecord.create(
        name: name,
        brand: brand,
        price: price,
        rating: rating,
        notes: notes,
        imagePath: imagePath,
        type: type,
      );

      recordsJson.add(jsonEncode(newRecord.toJson()));

      return await prefs.setStringList(_recordsKey, recordsJson);
    } catch (e) {
      print('Failed to add beverage record: $e');
      return false;
    }
  }

  // Delete record
  Future<bool> deleteRecord(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getStringList(_recordsKey) ?? [];

      final records = recordsJson
          .map((json) => TeaRecord.fromJson(jsonDecode(json)))
          .toList();

      final filteredRecords = records
          .where((record) => record.id != id)
          .toList();

      if (filteredRecords.length < records.length) {
        final newRecordsJson = filteredRecords
            .map((record) => jsonEncode(record.toJson()))
            .toList();

        return await prefs.setStringList(_recordsKey, newRecordsJson);
      }

      return false;
    } catch (e) {
      print('Failed to delete beverage record: $e');
      return false;
    }
  }

  // Get monthly statistics
  Future<Map<String, dynamic>> getMonthlyStats() async {
    try {
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);

      final records = await getRecentRecords(limit: 1000);
      final monthlyRecords = records.where((record) {
        final recordMonth = DateTime(
          record.timestamp.year,
          record.timestamp.month,
        );
        return recordMonth.isAtSameMomentAs(currentMonth);
      }).toList();

      final count = monthlyRecords.length;
      final spending = monthlyRecords.fold<double>(
        0,
        (sum, record) => sum + record.price,
      );

      return {'count': count, 'spending': spending};
    } catch (e) {
      print('Failed to get monthly statistics: $e');
      return {'count': 0, 'spending': 0.0};
    }
  }

  // Get statistics by type
  Future<Map<String, int>> getTypeStats() async {
    try {
      final records = await getRecentRecords(limit: 1000);
      final typeStats = <String, int>{};

      for (final record in records) {
        final type = record.type;
        typeStats[type] = (typeStats[type] ?? 0) + 1;
      }

      return typeStats;
    } catch (e) {
      print('Failed to get type statistics: $e');
      return {};
    }
  }

  // Get statistics by brand
  Future<Map<String, int>> getBrandStats() async {
    try {
      final records = await getRecentRecords(limit: 1000);
      final brandStats = <String, int>{};

      for (final record in records) {
        final brand = record.brand;
        brandStats[brand] = (brandStats[brand] ?? 0) + 1;
      }

      return brandStats;
    } catch (e) {
      print('Failed to get brand statistics: $e');
      return {};
    }
  }
}
