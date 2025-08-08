import 'dart:async';
import 'admob_service.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  final AdMobService _adMobService = AdMobService();
  
  // 插页广告显示间隔控制
  DateTime? _lastInterstitialShown;
  static const Duration _interstitialInterval = Duration(seconds: 15);
  
  // 广告显示统计
  int _interstitialShownCount = 0;
  int _interstitialAttemptCount = 0;
  
  // 回调函数
  Function()? _onRewardedAdSuccess;
  Function()? _onRewardedAdFailed;
  Function(Map<String, bool>)? _onAdLoadStatusChanged;
  
  // 获取单例实例
  static AdManager get instance => _instance;
  
  // 获取AdMob服务实例
  AdMobService get adMobService => _adMobService;
  
  /// 尝试显示插页广告（带15秒间隔检查）
  /// 返回true表示广告已显示，false表示由于间隔限制未显示
  Future<bool> tryShowInterstitialAd() async {
    _interstitialAttemptCount++;
    
    // 检查是否满足15秒间隔条件
    if (!_canShowInterstitialAd()) {
      print('插页广告：距离上次显示不足15秒，跳过显示');
      return false;
    }
    
    // 检查广告是否已加载
    if (!_adMobService.isInterstitialLoaded) {
      print('插页广告：广告未加载完成，跳过显示');
      return false;
    }
    
    // 显示插页广告
    final success = await _adMobService.showInterstitialAd();
    
    if (success) {
      _interstitialShownCount++;
      _lastInterstitialShown = DateTime.now();
      print('插页广告：显示成功 (第$_interstitialShownCount次)');
      return true;
    } else {
      print('插页广告：显示失败');
      return false;
    }
  }
  
  /// 检查是否可以显示插页广告（满足15秒间隔）
  bool _canShowInterstitialAd() {
    if (_lastInterstitialShown == null) {
      return true; // 首次显示
    }
    
    final timeSinceLastShow = DateTime.now().difference(_lastInterstitialShown!);
    return timeSinceLastShow >= _interstitialInterval;
  }
  
  /// 获取距离下次可以显示插页广告的剩余时间（秒）
  int get remainingInterstitialCooldown {
    if (_lastInterstitialShown == null) {
      return 0;
    }
    
    final timeSinceLastShow = DateTime.now().difference(_lastInterstitialShown!);
    final remaining = _interstitialInterval - timeSinceLastShow;
    
    return remaining.isNegative ? 0 : remaining.inSeconds;
  }
  
  /// 获取插页广告统计信息
  Map<String, dynamic> get interstitialStats {
    return {
      'shownCount': _interstitialShownCount,
      'attemptCount': _interstitialAttemptCount,
      'successRate': _interstitialAttemptCount > 0 
          ? (_interstitialShownCount / _interstitialAttemptCount * 100).toStringAsFixed(1)
          : '0.0',
      'lastShown': _lastInterstitialShown?.toIso8601String(),
      'remainingCooldown': remainingInterstitialCooldown,
      'canShow': _canShowInterstitialAd(),
    };
  }
  
  /// 重置插页广告统计
  void resetInterstitialStats() {
    _interstitialShownCount = 0;
    _interstitialAttemptCount = 0;
    _lastInterstitialShown = null;
  }
  
  /// 强制显示插页广告（忽略间隔限制，用于测试）
  Future<bool> forceShowInterstitialAd() async {
    if (!_adMobService.isInterstitialLoaded) {
      print('插页广告：广告未加载完成，无法强制显示');
      return false;
    }
    
    final success = await _adMobService.showInterstitialAd();
    
    if (success) {
      _interstitialShownCount++;
      _lastInterstitialShown = DateTime.now();
      print('插页广告：强制显示成功 (第$_interstitialShownCount次)');
      return true;
    } else {
      print('插页广告：强制显示失败');
      return false;
    }
  }
  
  /// 显示激励视频广告（带回调处理）
  Future<bool> showRewardedAd() async {
    try {
      print('AdManager: 开始显示激励视频广告');
      final success = await _adMobService.showRewardedAd();
      
      if (success) {
        print('AdManager: 激励视频广告显示成功，等待用户观看结果');
        // 注意：成功/失败回调会在AdMobService中通过原生回调触发
        // 回调会在用户完成或中断视频观看时自动调用
        return true;
      } else {
        print('AdManager: 激励视频广告显示失败');
        // 调用失败回调
        _onRewardedAdFailed?.call();
        return false;
      }
    } catch (e) {
      print('AdManager: 激励视频广告显示异常: $e');
      // 调用失败回调
      _onRewardedAdFailed?.call();
      return false;
    }
  }
  
  /// 预加载所有广告
  Future<bool> preloadAds() async {
    return await _adMobService.preloadAds();
  }
  
  /// 获取广告加载状态
  Future<Map<String, bool>> getAdLoadStatus() async {
    return await _adMobService.getAdLoadStatus();
  }
  
  /// 设置激励视频成功回调
  void setRewardedAdSuccessCallback(Function()? callback) {
    _onRewardedAdSuccess = callback;
    // 同时设置到AdMobService
    _adMobService.setRewardedAdSuccessCallback(callback);
  }
  
  /// 设置激励视频失败回调
  void setRewardedAdFailedCallback(Function()? callback) {
    _onRewardedAdFailed = callback;
    // 同时设置到AdMobService
    _adMobService.setRewardedAdFailedCallback(callback);
  }
  
  /// 设置广告加载状态变化回调
  void setAdLoadStatusCallback(Function(Map<String, bool>) callback) {
    _onAdLoadStatusChanged = callback;
    _adMobService.setAdLoadStatusCallback(callback);
  }
} 