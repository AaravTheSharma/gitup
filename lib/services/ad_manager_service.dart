import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'inmobi_ad_service.dart';
import 'ad_config.dart';

class AdManagerService {
  static final AdManagerService _instance = AdManagerService._internal();
  factory AdManagerService() => _instance;
  AdManagerService._internal();

  final InMobiAdService _adService = InMobiAdService();
  
  // 应用启动时间
  DateTime? _appStartTime;
  
  // 上次显示插页广告的时间
  DateTime? _lastInterstitialShownTime;
  
  // 广告展示间隔
  static const Duration _interstitialInterval = AdConfig.interstitialInterval;
  
  // 应用启动后不显示广告的时间
  static const Duration _initialNoAdPeriod = AdConfig.initialNoAdPeriod;
  
  // 是否已经初始化
  bool _isInitialized = false;

  /// 初始化广告管理服务
  void initialize() {
    if (_isInitialized) return;
    
    _appStartTime = DateTime.now();
    _isInitialized = true;
    
    // 初始化InMobi广告服务
    _adService.initialize();
    
    if (AdConfig.enableAdLogs) {
      print('广告管理服务已初始化，启动时间: $_appStartTime');
    }
  }

  /// 检查是否应该显示插页广告
  bool _shouldShowInterstitial() {
    if (_appStartTime == null) {
      if (AdConfig.enableAdLogs) {
        print('应用启动时间未设置，不显示广告');
      }
      return false;
    }

    final now = DateTime.now();
    final timeSinceAppStart = now.difference(_appStartTime!);
    
    // 检查是否在应用启动后的前两分钟内
    if (timeSinceAppStart < _initialNoAdPeriod) {
      if (AdConfig.enableAdLogs) {
        print('应用启动后前两分钟内，不显示插页广告');
      }
      return false;
    }

    // 检查是否满足间隔要求
    if (_lastInterstitialShownTime != null) {
      final timeSinceLastAd = now.difference(_lastInterstitialShownTime!);
      if (timeSinceLastAd < _interstitialInterval) {
        if (AdConfig.enableAdLogs) {
          print('距离上次插页广告不足${_interstitialInterval.inSeconds}秒，不显示广告');
        }
        return false;
      }
    }

    return true;
  }

  /// 显示插页广告（如果满足条件）
  Future<void> showInterstitialAdIfEligible() async {
    if (!_shouldShowInterstitial()) {
      return;
    }

    try {
      if (AdConfig.enableAdLogs) {
        print('显示插页广告');
      }
      await _adService.showInterstitialAd();
      _lastInterstitialShownTime = DateTime.now();
      if (AdConfig.enableAdLogs) {
        print('插页广告显示完成，记录时间: $_lastInterstitialShownTime');
      }
    } catch (e) {
      if (AdConfig.enableAdLogs) {
        print('显示插页广告失败: $e');
      }
    }
  }

  /// 获取距离下次可以显示广告的剩余时间
  Duration? getTimeUntilNextAdEligible() {
    if (_appStartTime == null) return null;

    final now = DateTime.now();
    final timeSinceAppStart = now.difference(_appStartTime!);
    
    // 如果还在前两分钟内
    if (timeSinceAppStart < _initialNoAdPeriod) {
      return _initialNoAdPeriod - timeSinceAppStart;
    }

    // 如果距离上次广告不足15秒
    if (_lastInterstitialShownTime != null) {
      final timeSinceLastAd = now.difference(_lastInterstitialShownTime!);
      if (timeSinceLastAd < _interstitialInterval) {
        return _interstitialInterval - timeSinceLastAd;
      }
    }

    return Duration.zero; // 可以立即显示
  }
}
