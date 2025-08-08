import 'package:flutter/services.dart';

class AdMobService {
  static const MethodChannel _channel = MethodChannel('com.florsovivexa.admob');
  
  // 单例模式
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal() {
    _setupMethodCallHandler();
  }
  
  // 回调函数类型定义
  Function()? onRewardedAdSuccess;
  Function()? onRewardedAdFailed;
  Function(Map<String, bool>)? onAdLoadStatusChanged;
  
  // 广告加载状态
  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;
  
  // 获取广告加载状态
  bool get isBannerLoaded => _isBannerLoaded;
  bool get isInterstitialLoaded => _isInterstitialLoaded;
  bool get isRewardedLoaded => _isRewardedLoaded;
  
  // 设置方法调用处理器
  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onRewardedAdSuccess':
          print('AdMobService: 收到激励视频成功回调 - 用户完整观看视频');
          onRewardedAdSuccess?.call();
          break;
        case 'onRewardedAdFailed':
          print('AdMobService: 收到激励视频失败回调 - 用户未完整观看视频');
          onRewardedAdFailed?.call();
          break;
        case 'onAdLoadStatusChanged':
          final Map<String, dynamic> status = Map<String, dynamic>.from(call.arguments);
          _updateAdLoadStatus(status);
          onAdLoadStatusChanged?.call(_getAdLoadStatus());
          break;
        default:
          throw PlatformException(
            code: 'Unimplemented',
            details: 'Method ${call.method} not implemented',
          );
      }
    });
  }
  
  // 更新广告加载状态
  void _updateAdLoadStatus(Map<String, dynamic> status) {
    _isBannerLoaded = status['banner'] ?? false;
    _isInterstitialLoaded = status['interstitial'] ?? false;
    _isRewardedLoaded = status['rewarded'] ?? false;
  }
  
  // 获取广告加载状态
  Map<String, bool> _getAdLoadStatus() {
    return {
      'banner': _isBannerLoaded,
      'interstitial': _isInterstitialLoaded,
      'rewarded': _isRewardedLoaded,
    };
  }
  
  // 预加载所有广告
  Future<bool> preloadAds() async {
    try {
      final bool result = await _channel.invokeMethod('preloadAds');
      return result;
    } on PlatformException catch (e) {
      print('预加载广告失败: ${e.message}');
      return false;
    }
  }
  
  // 获取广告加载状态
  Future<Map<String, bool>> getAdLoadStatus() async {
    try {
      final Map<String, dynamic> status = Map<String, dynamic>.from(
        await _channel.invokeMethod('getAdLoadStatus')
      );
      _updateAdLoadStatus(status);
      return _getAdLoadStatus();
    } on PlatformException catch (e) {
      print('获取广告加载状态失败: ${e.message}');
      return _getAdLoadStatus();
    }
  }
  
  // 显示横幅广告
  Future<bool> showBannerAd() async {
    try {
      final bool result = await _channel.invokeMethod('showBannerAd');
      return result;
    } on PlatformException catch (e) {
      print('显示横幅广告失败: ${e.message}');
      return false;
    }
  }
  
  // 隐藏横幅广告
  Future<bool> hideBannerAd() async {
    try {
      final bool result = await _channel.invokeMethod('hideBannerAd');
      return result;
    } on PlatformException catch (e) {
      print('隐藏横幅广告失败: ${e.message}');
      return false;
    }
  }
  
  // 显示插页广告
  Future<bool> showInterstitialAd() async {
    try {
      final bool result = await _channel.invokeMethod('showInterstitialAd');
      return result;
    } on PlatformException catch (e) {
      print('显示插页广告失败: ${e.message}');
      return false;
    }
  }
  
  // 显示激励视频广告
  Future<bool> showRewardedAd() async {
    try {
      final bool result = await _channel.invokeMethod('showRewardedAd');
      return result;
    } on PlatformException catch (e) {
      print('显示激励视频广告失败: ${e.message}');
      return false;
    }
  }
  
  // 设置激励视频成功回调
  void setRewardedAdSuccessCallback(Function()? callback) {
    onRewardedAdSuccess = callback;
  }
  
  // 设置激励视频失败回调
  void setRewardedAdFailedCallback(Function()? callback) {
    onRewardedAdFailed = callback;
  }
  
  // 设置广告加载状态变化回调
  void setAdLoadStatusCallback(Function(Map<String, bool>) callback) {
    onAdLoadStatusChanged = callback;
  }
  
  // 检查所有广告是否已加载
  bool get areAllAdsLoaded => _isBannerLoaded && _isInterstitialLoaded && _isRewardedLoaded;
  
  // 获取加载进度
  double get loadProgress {
    int loadedCount = 0;
    if (_isBannerLoaded) loadedCount++;
    if (_isInterstitialLoaded) loadedCount++;
    if (_isRewardedLoaded) loadedCount++;
    return loadedCount / 3.0;
  }
} 