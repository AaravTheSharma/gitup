import 'package:flutter/services.dart';

class InMobiAdService {
  static const MethodChannel _channel = MethodChannel('inmobi_ads');
  
  // 单例模式
  static final InMobiAdService _instance = InMobiAdService._internal();
  factory InMobiAdService() => _instance;
  InMobiAdService._internal();
  
  // 回调函数
  Function()? onRewardVideoWatched;
  Function()? onRewardVideoFailed;
  
  // 初始化
  void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }
  
  // 处理来自原生端的方法调用
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onRewardVideoWatched':
        onRewardVideoWatched?.call();
        break;
      case 'onRewardVideoFailed':
        onRewardVideoFailed?.call();
        break;
      default:
        print('未知的方法调用: ${call.method}');
    }
  }
  
  // 显示横幅广告
  Future<void> showBannerAd() async {
    try {
      await _channel.invokeMethod('showBannerAd');
    } catch (e) {
      print('显示横幅广告失败: $e');
    }
  }
  
  // 隐藏横幅广告
  Future<void> hideBannerAd() async {
    try {
      await _channel.invokeMethod('hideBannerAd');
    } catch (e) {
      print('隐藏横幅广告失败: $e');
    }
  }
  
  // 显示插页广告
  Future<void> showInterstitialAd() async {
    try {
      await _channel.invokeMethod('showInterstitialAd');
    } catch (e) {
      print('显示插页广告失败: $e');
    }
  }
  
  // 显示激励视频广告
  Future<void> showRewardedVideoAd() async {
    try {
      await _channel.invokeMethod('showRewardedVideoAd');
    } catch (e) {
      print('显示激励视频广告失败: $e');
    }
  }
  
  // 检查激励视频是否准备好
  Future<bool> isRewardedVideoReady() async {
    try {
      final bool isReady = await _channel.invokeMethod('isRewardedVideoReady');
      return isReady;
    } catch (e) {
      print('检查激励视频状态失败: $e');
      return false;
    }
  }
}
