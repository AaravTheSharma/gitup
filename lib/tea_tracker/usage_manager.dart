import 'package:shared_preferences/shared_preferences.dart';

class UsageManager {
  static final UsageManager _instance = UsageManager._internal();
  factory UsageManager() => _instance;
  UsageManager._internal();

  static const String _usageKey = 'tea_tracker_usage_count';
  static const int _initialUsageCount = 5;
  static const int _rewardUsageCount = 10;

  // 获取单例实例
  static UsageManager get instance => _instance;

  /// 获取当前可用次数
  Future<int> getUsageCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_usageKey) ?? _initialUsageCount;
  }

  /// 设置可用次数
  Future<void> setUsageCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_usageKey, count);
  }

  /// 减少使用次数
  Future<int> decrementUsage() async {
    final currentCount = await getUsageCount();
    final newCount = (currentCount - 1).clamp(0, currentCount);
    await setUsageCount(newCount);
    return newCount;
  }

  /// 增加使用次数
  Future<int> addUsage(int count) async {
    final currentCount = await getUsageCount();
    final newCount = currentCount + count;
    await setUsageCount(newCount);
    return newCount;
  }

  /// 重置使用次数为初始值
  Future<void> resetUsage() async {
    await setUsageCount(_initialUsageCount);
  }

  /// 检查是否可以使用（次数大于0）
  Future<bool> canUse() async {
    final count = await getUsageCount();
    return count > 0;
  }

  /// 获取奖励次数
  int get rewardUsageCount => _rewardUsageCount;

  /// 获取初始次数
  int get initialUsageCount => _initialUsageCount;
} 