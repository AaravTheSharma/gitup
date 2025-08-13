/// 广告配置文件
/// 用于统一管理所有广告类型的配置和规则
class AdConfig {
  // 插页广告配置
  static const Duration interstitialInterval = Duration(seconds: 15);
  static const Duration initialNoAdPeriod = Duration(minutes: 2);
  
  // 横幅广告配置
  static const bool enableBannerAd = true;
  static const Duration bannerRefreshInterval = Duration(minutes: 1);
  
  // 激励视频广告配置
  static const bool enableRewardedVideo = true;
  static const Duration rewardedVideoCooldown = Duration(minutes: 5);
  
  // 广告触发场景配置
  static const Map<String, bool> adTriggers = {
    'screen_switch': true,        // 界面切换
    'app_launch': false,          // 应用启动
    'user_action': false,         // 用户操作
    'time_based': false,          // 基于时间
  };
  
  // 广告展示规则
  static const Map<String, dynamic> adRules = {
    'interstitial': {
      'enabled': true,
      'interval': 15, // 秒
      'initial_delay': 120, // 秒
      'max_per_session': 10,
    },
    'banner': {
      'enabled': true,
      'position': 'bottom',
      'auto_refresh': true,
    },
    'rewarded_video': {
      'enabled': true,
      'cooldown': 300, // 秒
      'max_per_session': 5,
    },
  };
  
  // 调试模式配置
  static const bool debugMode = false;
  static const bool enableAdLogs = true;
  
  // 广告平台配置
  static const String adPlatform = 'inmobi';
  static const Map<String, String> adPlacementIds = {
    'banner': '10000445873',
    'interstitial': '10000445864',
    'rewarded_video': '10000445875',
  };
}
