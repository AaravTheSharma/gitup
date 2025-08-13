# InMobi SDK 集成文档

## 概述
本文档描述了如何在 Doraplexis Flutter 应用中集成 InMobi SDK 来显示广告。

## 集成步骤

### 1. iOS 配置

#### 1.1 添加依赖
在 `ios/Podfile` 中添加：
```ruby
pod 'InMobiSDK'
```

#### 1.2 隐私权限配置
在 `ios/Runner/Info.plist` 中添加以下权限：
- `NSUserTrackingUsageDescription` - 用户追踪权限
- `NSLocationWhenInUseUsageDescription` - 位置权限
- `NSCameraUsageDescription` - 相机权限
- `NSMicrophoneUsageDescription` - 麦克风权限
- `NSPhotoLibraryUsageDescription` - 相册权限
- `NSBluetoothAlwaysUsageDescription` - 蓝牙权限
- `NSLocalNetworkUsageDescription` - 本地网络权限

#### 1.3 AppDelegate 配置
在 `ios/Runner/AppDelegate.swift` 中：
- 导入 InMobiSDK
- 在 `didFinishLaunchingWithOptions` 中初始化 SDK
- 添加与 Flutter 通信的方法

### 2. 原生代码

#### 2.1 MediaAdController.h
定义了广告控制器的接口，包括：
- 横幅广告显示/隐藏
- 插页广告展示
- 激励视频广告播放
- 广告状态检查

#### 2.2 MediaAdController.m
实现了广告控制器的具体功能：
- InMobi SDK 初始化
- 广告加载和展示
- 广告事件回调处理
- 与 Flutter 的通信

### 3. Flutter 端集成

#### 3.1 InMobiAdService
创建了 `lib/services/inmobi_ad_service.dart` 服务类：
- 提供广告操作的 Flutter 接口
- 处理原生端回调
- 管理广告状态

#### 3.2 初始化
在 `lib/main.dart` 中初始化广告服务：
```dart
InMobiAdService().initialize();
```

#### 3.3 测试页面
创建了 `lib/screens/ad_test_screen.dart` 用于测试各种广告类型。

## 广告类型

### 1. 横幅广告 (Banner Ad)
- 位置：屏幕底部
- 尺寸：320x50
- 功能：显示/隐藏

### 2. 插页广告 (Interstitial Ad)
- 类型：全屏广告
- 限制：15秒间隔
- 功能：展示

### 3. 激励视频广告 (Rewarded Video Ad)
- 类型：视频广告
- 功能：观看获得奖励
- 状态：可检查是否准备好

## 配置参数

### Account ID
```
40554dacd2664e479b98f1fc4a8b30b8
```

### Placement IDs
- 横幅广告：`10000450694`
- 插页广告：`10000450693`
- 激励视频：`10000450695`

## 使用方法

### 1. 显示横幅广告
```dart
await InMobiAdService().showBannerAd();
```

### 2. 隐藏横幅广告
```dart
await InMobiAdService().hideBannerAd();
```

### 3. 显示插页广告
```dart
await InMobiAdService().showInterstitialAd();
```

### 4. 显示激励视频
```dart
await InMobiAdService().showRewardedVideoAd();
```

### 5. 检查激励视频状态
```dart
bool isReady = await InMobiAdService().isRewardedVideoReady();
```

## 回调处理

### 激励视频回调
```dart
InMobiAdService().onRewardVideoWatched = () {
  // 用户观看完激励视频
};

InMobiAdService().onRewardVideoFailed = () {
  // 激励视频播放失败
};
```

## 测试

1. 运行 `cd ios && pod install` 安装依赖
2. 在代码中调用相应的广告方法进行测试
3. 测试各种广告类型的显示和隐藏

## 已完成的任务

✅ **iOS 配置完成**：
- Podfile 中添加了 InMobiSDK 依赖
- Info.plist 中添加了所有必要的隐私权限
- AppDelegate.swift 中配置了 SDK 初始化
- 桥接头文件中添加了 MediaAdController.h 引用

✅ **原生代码配置完成**：
- MediaAdController.h 和 MediaAdController.m 已配置
- 更新了 Account ID 和 Placement IDs
- 修复了编译错误

✅ **Flutter 端集成完成**：
- 创建了 InMobiAdService 服务类
- 在 main.dart 中初始化广告服务
- 移除了广告测试页面和设置入口

✅ **编译验证完成**：
- 项目可以正常编译
- 没有编译错误

## 注意事项

1. 确保网络连接正常
2. 插页广告有15秒间隔限制
3. 激励视频需要等待加载完成
4. 首次使用需要用户授权隐私权限

## 故障排除

### 常见问题
1. **广告不显示**：检查网络连接和 Placement ID
2. **权限错误**：确保 Info.plist 配置正确
3. **编译错误**：运行 `pod install` 重新安装依赖

### 日志查看
在 Xcode 控制台查看 InMobi SDK 的日志输出，帮助诊断问题。
