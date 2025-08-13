# 广告系统使用说明

## 概述

本应用集成了InMobi广告平台，实现了智能的广告展示规则。广告系统会自动管理广告的展示时机，确保用户体验的同时最大化广告收益。

## 广告类型

### 1. 插页广告 (Interstitial Ad)
- **触发时机**: 用户切换界面时（Women Health、Fashion Expenses、Storage Organizer、Settings）
- **展示规则**:
  - 应用启动后前2分钟内不显示
  - 两次广告之间至少间隔15秒
  - 界面切换完成后300毫秒显示

### 2. 横幅广告 (Banner Ad)
- **位置**: 应用底部
- **触发时机**: 弹出"No Available Uses"弹窗时显示
- **同步显示**: 与弹窗同时出现和消失
- **自动刷新**: 每分钟自动刷新一次

### 3. 激励视频广告 (Rewarded Video Ad)
- **触发**: Women Health界面的"+"按钮可用次数为0时
- **奖励**: 观看完整视频获得10次可用次数
- **规则**: 
  - 初始可用次数为3次
  - 每次添加Cycle记录消耗1次
  - 可用次数为0时弹出激励视频广告对话框
  - 视频观看完成获得10次奖励
  - 视频未完成不获得奖励

## 配置文件

所有广告配置都在 `lib/services/ad_config.dart` 文件中：

```dart
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
  
  // 调试模式
  static const bool debugMode = false;
  static const bool enableAdLogs = true;
}
```

## 使用方法

### 1. 自动触发
插页广告会在用户切换界面时自动触发，无需手动调用。

### 2. 手动触发
如果需要手动触发广告，可以使用以下方法：

```dart
// 显示插页广告（遵循规则）
AdManagerService().showInterstitialAdIfEligible();

// 显示横幅广告
InMobiAdService().showBannerAd();

// 隐藏横幅广告
InMobiAdService().hideBannerAd();

// 显示激励视频广告
InMobiAdService().showRewardedVideoAd();

// 管理Women Health界面的可用次数
RewardedVideoManager().getAvailableUses(); // 获取可用次数
RewardedVideoManager().consumeUse(); // 消耗一次使用机会
RewardedVideoManager().addUses(10); // 增加使用次数

// 横幅广告控制
RewardedVideoManager().showBannerAd(); // 显示横幅广告
RewardedVideoManager().hideBannerAd(); // 隐藏横幅广告
RewardedVideoManager().isBannerAdVisible; // 检查横幅广告状态
```

## 新增广告类型

### 1. 修改配置文件
在 `lib/services/ad_config.dart` 中添加新广告类型的配置：

```dart
// 新广告类型配置
static const bool enableNewAdType = true;
static const Duration newAdInterval = Duration(minutes: 3);
```

### 2. 在广告管理服务中添加方法
在 `lib/services/ad_manager_service.dart` 中添加新广告类型的管理逻辑。

### 3. 在原生代码中添加支持
在iOS的 `MediaAdController.m` 中添加对应的原生方法。

## 注意事项

1. **用户体验优先**: 广告系统设计时优先考虑用户体验，避免过度展示广告
2. **自动管理**: 系统会自动管理广告展示时机，无需手动干预
3. **配置灵活**: 所有广告规则都可以通过配置文件调整
4. **调试友好**: 支持日志输出，便于调试和监控

## 技术架构

```
lib/services/
├── ad_config.dart              # 广告配置文件
├── ad_manager_service.dart     # 广告管理服务
├── inmobi_ad_service.dart      # InMobi广告服务
└── rewarded_video_manager.dart # 激励视频广告管理器

ios/
├── MediaAdController.h     # 原生广告控制器头文件
├── MediaAdController.m     # 原生广告控制器实现
└── AppDelegate.swift       # 应用代理，处理方法通道
```

## 故障排除

1. **广告不显示**: 检查网络连接和InMobi配置
2. **频繁显示**: 检查时间间隔配置
3. **原生错误**: 查看Xcode控制台日志
4. **Flutter错误**: 查看Flutter控制台日志

## 更新日志

- v1.0.0: 初始版本，支持插页广告、横幅广告、激励视频广告
- 实现了智能的广告展示规则
- 添加了完整的配置系统
- v1.1.0: 新增激励视频广告管理器
- 实现了Women Health界面的可用次数系统
- 添加了激励视频广告的完整流程
- v1.2.0: 新增横幅广告同步显示功能
- 实现了"No Available Uses"弹窗与横幅广告的同步显示
- 优化了广告展示的用户体验
