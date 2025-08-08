# AdMob 集成说明

## 概述
本项目已成功集成Google AdMob SDK，支持横幅广告、插页广告和激励视频广告，并实现了应用启动时的广告预加载功能。插页广告具有智能显示规则和15秒间隔限制，激励视频广告在Tea Tracker界面实现了使用次数管理系统。

## 已完成的配置

### 1. iOS端配置
- ✅ 创建了 `AdMobManager` 管理类（集成在AppDelegate.swift中）
- ✅ 修改了 `AppDelegate.swift` 集成AdMob
- ✅ 更新了 `Podfile` 添加Google-Mobile-Ads-SDK依赖
- ✅ 配置了 `Info.plist` 包含必要的权限和SKAdNetworkItems
- ✅ 实现了应用启动时的广告预加载功能

### 2. Flutter端配置
- ✅ 创建了 `AdMobService` 服务类
- ✅ 创建了 `AdManager` 广告管理器
- ✅ 创建了 `UsageManager` 使用次数管理器
- ✅ 实现了与iOS端的通信接口
- ✅ 创建了测试页面 `AdMobTestScreen`
- ✅ 添加了广告加载状态管理
- ✅ 实现了插页广告显示规则和间隔控制
- ✅ 实现了激励视频广告和横幅广告在Tea Tracker界面的显示规则

## 核心功能

### 🚀 广告预加载系统
- **应用启动时自动预加载**：所有三个广告位在应用启动时自动开始加载
- **智能重试机制**：广告加载失败时自动重试（最多3次）
- **实时状态监控**：实时监控每个广告位的加载状态
- **自动重新加载**：广告展示后自动预加载下一个广告

### 📊 广告加载状态管理
- 横幅广告加载状态
- 插页广告加载状态  
- 激励视频广告加载状态
- 整体加载进度显示

### 🎯 插页广告显示规则
- **触发条件**：点击主界面底部4个按钮（Photo、Journal、Tea、Settings）切换界面时
- **间隔限制**：15秒间隔，避免频繁显示影响用户体验
- **智能判断**：只有在不同标签间切换时才显示，点击当前标签不显示
- **状态监控**：实时显示剩余冷却时间和显示统计

### 🎁 激励视频广告显示规则（Tea Tracker）
- **使用次数系统**：初始5次使用机会，每次添加记录消耗1次
- **触发条件**：当使用次数为0时，点击"Add New Record"按钮
- **奖励机制**：观看完整视频获得10次额外使用机会
- **回调处理**：视频观看成功/失败都有相应回调处理
- **用户提示**：英文界面提示用户观看视频获得奖励
- **界面优化**：取消"Available uses"显示，按钮保持正常状态

### 📱 横幅广告显示规则（Tea Tracker）
- **触发条件**：当使用次数为0时，点击"Add New Record"按钮同时显示
- **显示位置**：界面底部
- **智能控制**：避免重复显示

## 安装步骤

### 1. 安装iOS依赖
```bash
cd ios
pod install
```

### 2. 更新广告位ID
在 `ios/Runner/AppDelegate.swift` 中，将测试广告ID替换为您的真实广告位ID：

```swift
// 横幅广告
private let bannerAdUnitID = "您的横幅广告位ID"

// 插页广告  
private let interstitialAdUnitID = "您的插页广告位ID"

// 激励视频广告
private let rewardedAdUnitID = "您的激励视频广告位ID"
```

### 3. 更新应用ID
在 `ios/Runner/Info.plist` 中，将测试应用ID替换为您的真实应用ID：

```xml
<key>GADApplicationIdentifier</key>
<string>您的AdMob应用ID</string>
```

## 使用方法

### 1. 在Flutter代码中使用
```dart
import 'package:your_app/shared/ad_manager.dart';
import 'package:your_app/tea_tracker/usage_manager.dart';

final adManager = AdManager.instance;
final usageManager = UsageManager.instance;

// 预加载所有广告
await adManager.preloadAds();

// 获取广告加载状态
final status = await adManager.getAdLoadStatus();
print('横幅广告: ${status['banner']}');
print('插页广告: ${status['interstitial']}');
print('激励视频广告: ${status['rewarded']}');

// 尝试显示插页广告（带15秒间隔检查）
final success = await adManager.tryShowInterstitialAd();

// 强制显示插页广告（忽略间隔限制，用于测试）
final forced = await adManager.forceShowInterstitialAd();

// 显示激励视频广告（带回调处理）
await adManager.showRewardedAd();

// 显示横幅广告
await adManager.adMobService.showBannerAd();

// 隐藏横幅广告
await adManager.adMobService.hideBannerAd();

// 设置激励视频成功回调
adManager.setRewardedAdSuccessCallback(() {
  print('用户观看激励视频成功，给予奖励');
});

// 设置激励视频失败回调
adManager.setRewardedAdFailedCallback(() {
  print('用户未完成激励视频观看');
});

// 设置广告加载状态变化回调
adManager.setAdLoadStatusCallback((status) {
  print('广告加载状态变化: $status');
});
```

### 2. 使用次数管理（Tea Tracker）
```dart
// 获取当前使用次数
final usageCount = await usageManager.getUsageCount();

// 检查是否可以使用
final canUse = await usageManager.canUse();

// 减少使用次数
final newCount = await usageManager.decrementUsage();

// 增加使用次数
final updatedCount = await usageManager.addUsage(10);

// 重置使用次数
await usageManager.resetUsage();
```

### 3. 插页广告统计和状态
```dart
// 获取插页广告统计信息
final stats = adManager.interstitialStats;
print('显示次数: ${stats['shownCount']}');
print('尝试次数: ${stats['attemptCount']}');
print('成功率: ${stats['successRate']}%');
print('剩余冷却时间: ${stats['remainingCooldown']}秒');
print('是否可以显示: ${stats['canShow']}');

// 重置插页广告统计
adManager.resetInterstitialStats();
```

### 4. 广告加载状态监控
```dart
// 检查所有广告是否已加载
bool allLoaded = adManager.adMobService.areAllAdsLoaded;

// 获取加载进度 (0.0 - 1.0)
double progress = adManager.adMobService.loadProgress;

// 检查单个广告状态
bool bannerLoaded = adManager.adMobService.isBannerLoaded;
bool interstitialLoaded = adManager.adMobService.isInterstitialLoaded;
bool rewardedLoaded = adManager.adMobService.isRewardedLoaded;
```

### 5. 测试广告功能
运行应用后，可以通过以下方式测试：
- 在设置页面添加AdMob测试入口
- 或直接导航到 `AdMobTestScreen`
- 测试插页广告间隔功能
- 在Tea Tracker界面测试激励视频和横幅广告

## 广告类型说明

### 1. 横幅广告 (Banner Ad)
- 显示在屏幕底部的矩形广告
- 可以随时显示/隐藏
- 适合持续展示
- **预加载**：应用启动时自动预加载
- **Tea Tracker规则**：使用次数为0时点击按钮同时显示

### 2. 插页广告 (Interstitial Ad)
- 全屏显示的广告
- 用户必须点击关闭才能继续使用应用
- 适合在页面切换时展示
- **预加载**：应用启动时自动预加载，展示后自动重新加载
- **显示规则**：点击底部导航栏切换界面时显示
- **间隔限制**：15秒间隔，避免频繁显示

### 3. 激励视频广告 (Rewarded Ad)
- 用户观看完整视频后获得奖励
- 需要实现回调函数处理奖励逻辑
- 适合游戏或需要激励用户行为的场景
- **预加载**：应用启动时自动预加载，展示后自动重新加载
- **Tea Tracker规则**：使用次数为0时触发，观看完整获得10次使用机会

## Tea Tracker使用次数系统详解

### 🎯 系统设计
- **初始次数**：5次免费使用机会
- **消耗机制**：每次添加记录消耗1次
- **奖励机制**：观看激励视频获得10次额外机会
- **持久化存储**：使用SharedPreferences保存使用次数

### ⚡ 触发流程
1. **正常使用**：用户有使用次数时，点击"Add New Record"直接进入添加界面
2. **次数不足**：使用次数为0时，点击按钮触发以下流程：
   - 显示"使用次数不足"对话框（英文）
   - 同时显示横幅广告
   - 提供"观看视频"选项
3. **激励视频**：用户选择观看视频后：
   - 显示激励视频广告
   - 根据观看结果调用相应回调
   - 成功观看：增加10次使用机会，显示成功提示
   - 未完成观看：显示失败提示

### 📱 用户界面
- **按钮显示**：`Add New Record (5)` 格式显示当前次数
- **按钮状态**：始终保持正常状态，不会变灰
- **简洁设计**：取消"Available uses"显示卡片，界面更简洁
- **视觉反馈**：通过按钮文字显示剩余次数

### 🔄 回调处理
```dart
// 成功回调
void _onRewardedAdSuccess() {
  // 增加使用次数
  _addRewardUsage();
  // 显示成功提示
  _showRewardDialog(true);
}

// 失败回调
void _onRewardedAdFailed() {
  // 显示失败提示
  _showRewardDialog(false);
}
```

## 插页广告显示规则详解

### 🎯 触发条件
- **界面切换**：用户点击底部导航栏的4个按钮（Photo、Journal、Tea、Settings）
- **不同标签**：只有在不同标签间切换时才显示，点击当前选中的标签不显示
- **广告就绪**：插页广告必须已加载完成

### ⏱️ 间隔控制
- **15秒间隔**：两次插页广告显示之间必须间隔至少15秒
- **实时监控**：实时显示剩余冷却时间
- **智能跳过**：如果未满足间隔条件，自动跳过显示

### 📈 统计功能
- **显示次数**：记录成功显示的插页广告次数
- **尝试次数**：记录尝试显示的次数（包括因间隔限制而跳过的）
- **成功率**：计算显示成功率
- **冷却状态**：实时显示是否可以显示广告

## 预加载系统特性

### 🎯 自动预加载
- 应用启动时自动开始加载所有广告
- AdMob SDK初始化完成后立即开始预加载
- 无需手动调用预加载方法

### 🔄 智能重试
- 广告加载失败时自动重试
- 最多重试3次，每次间隔5秒
- 避免因网络问题导致的广告加载失败

### 📈 状态监控
- 实时监控每个广告位的加载状态
- 提供加载进度百分比
- 支持Flutter端实时状态更新

### ⚡ 性能优化
- 广告展示后立即预加载下一个
- 避免用户等待广告加载
- 提高广告展示成功率

## 注意事项

1. **测试阶段**：当前使用的是Google提供的测试广告ID，正式发布前需要替换为真实ID
2. **网络权限**：确保应用有网络访问权限
3. **用户隐私**：遵守GDPR等隐私法规，在适当时候请求用户同意
4. **广告频率**：插页广告有15秒间隔限制，避免影响用户体验
5. **预加载时机**：广告预加载在应用启动时进行，可能需要几秒钟时间
6. **界面切换**：插页广告只在真正的界面切换时显示，提升用户体验
7. **使用次数**：Tea Tracker的使用次数系统需要合理设计，避免过度限制用户体验
8. **激励机制**：激励视频的奖励机制应该对用户有足够的吸引力
9. **界面简洁**：取消"Available uses"显示，保持界面简洁美观

## 故障排除

### 常见问题
1. **广告不显示**：检查网络连接和广告位ID是否正确
2. **编译错误**：确保已运行 `pod install`
3. **权限问题**：检查Info.plist配置是否完整
4. **预加载失败**：检查网络连接，系统会自动重试
5. **插页广告不显示**：检查是否满足15秒间隔条件
6. **激励视频不工作**：检查回调函数是否正确设置
7. **使用次数不保存**：检查SharedPreferences权限

### 调试技巧
- 查看Xcode控制台输出的AdMob日志
- 使用测试设备进行调试
- 检查网络连接状态
- 监控广告加载状态变化
- 使用测试页面的统计功能查看插页广告状态
- 在Tea Tracker界面测试使用次数系统

## 下一步
请告诉我其他广告展示的具体规则，我将帮您实现相应的展示逻辑。 