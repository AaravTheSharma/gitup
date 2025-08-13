import 'package:shared_preferences/shared_preferences.dart';
import 'inmobi_ad_service.dart';

class RewardedVideoManager {
  static final RewardedVideoManager _instance = RewardedVideoManager._internal();
  factory RewardedVideoManager() => _instance;
  RewardedVideoManager._internal();

  final InMobiAdService _adService = InMobiAdService();
  
  // 存储键
  static const String _availableUsesKey = 'women_health_available_uses';
  static const int _initialUses = 3;
  static const int _rewardUses = 10;
  
  // 横幅广告状态
  bool _isBannerAdVisible = false;

  /// 获取当前可用次数
  Future<int> getAvailableUses() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_availableUsesKey) ?? _initialUses;
  }

  /// 设置可用次数
  Future<void> setAvailableUses(int uses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_availableUsesKey, uses);
  }

  /// 消耗一次使用机会
  Future<bool> consumeUse() async {
    final currentUses = await getAvailableUses();
    print('🔢 [可用次数] 当前可用次数: $currentUses');
    if (currentUses > 0) {
      await setAvailableUses(currentUses - 1);
      print('🔢 [可用次数] 消耗1次，剩余次数: ${currentUses - 1}');
      return true;
    }
    print('🔢 [可用次数] 可用次数不足，无法消耗');
    return false;
  }

  /// 增加使用次数
  Future<void> addUses(int uses) async {
    final currentUses = await getAvailableUses();
    print('🔢 [可用次数] 增加次数前: $currentUses');
    await setAvailableUses(currentUses + uses);
    print('🔢 [可用次数] 增加$uses次，当前总次数: ${currentUses + uses}');
  }

  /// 重置为初始次数
  Future<void> resetToInitial() async {
    await setAvailableUses(_initialUses);
  }

  /// 检查是否可以使用
  Future<bool> canUse() async {
    final uses = await getAvailableUses();
    final canUse = uses > 0;
    print('🔢 [可用次数] 检查是否可用: $uses次 -> ${canUse ? "可用" : "不可用"}');
    return canUse;
  }

  /// 显示激励视频广告
  Future<void> showRewardedVideoAd({
    required Function(bool success) onResult,
  }) async {
    try {
      print('🎬 [激励视频] 设置视频观看完成回调');
      // 设置回调
      _adService.onRewardVideoWatched = () {
        print('🎬 [激励视频] 视频观看完成，给予${_rewardUses}次奖励');
        // 视频观看完成，给予奖励
        addUses(_rewardUses);
        onResult(true);
      };
      
      print('🎬 [激励视频] 设置视频观看失败回调');
      _adService.onRewardVideoFailed = () {
        print('🎬 [激励视频] 视频观看失败或未完成');
        // 视频观看失败或未完成
        onResult(false);
      };

      print('🎬 [激励视频] 调用原生广告服务显示激励视频');
      // 显示激励视频广告
      await _adService.showRewardedVideoAd();
    } catch (e) {
      print('❌ [激励视频] 显示激励视频广告失败: $e');
      onResult(false);
    }
  }

  /// 获取奖励次数
  int get rewardUses => _rewardUses;
  
  /// 显示横幅广告
  Future<void> showBannerAd() async {
    if (!_isBannerAdVisible) {
      print('🟢 [横幅广告] 开始显示横幅广告');
      await _adService.showBannerAd();
      _isBannerAdVisible = true;
      print('🟢 [横幅广告] 横幅广告显示完成，状态: $_isBannerAdVisible');
    } else {
      print('🟡 [横幅广告] 横幅广告已经显示，跳过重复显示');
    }
  }
  
  /// 隐藏横幅广告
  Future<void> hideBannerAd() async {
    if (_isBannerAdVisible) {
      print('🔴 [横幅广告] 开始隐藏横幅广告');
      await _adService.hideBannerAd();
      _isBannerAdVisible = false;
      print('🔴 [横幅广告] 横幅广告隐藏完成，状态: $_isBannerAdVisible');
    } else {
      print('🟡 [横幅广告] 横幅广告已经隐藏，跳过重复隐藏');
    }
  }
  
  /// 获取横幅广告显示状态
  bool get isBannerAdVisible => _isBannerAdVisible;
}
