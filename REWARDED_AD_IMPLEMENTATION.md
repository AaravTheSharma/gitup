# Tea Tracker 激励视频广告实现

## 功能概述

在Tea Tracker界面中实现了完整的激励视频广告功能，满足以下需求：

1. **视频看完没看完都要回调** - 无论用户是否完整观看视频，都会触发相应的回调
2. **根据回调响应处理逻辑** - 成功观看增加可用次数，失败不增加
3. **英文弹窗提示** - 显示英文奖励结果提示
4. **自动消失弹窗** - 弹窗显示1秒后自动消失，无需用户操作

## 实现细节

### iOS端实现 (AppDelegate.swift)

#### 激励视频广告显示
```swift
@objc func showRewardedAd(result: @escaping FlutterResult) {
    // 重置奖励状态
    rewardedAdRewardEarned = false
    
    // 设置委托处理观看完成和关闭事件
    rewardedAd.fullScreenContentDelegate = self
    
    rewardedAd.present(from: rootViewController) {
        // 用户完整观看视频，获得奖励
        self.rewardedAdRewardEarned = true
        self.notifyRewardedAdSuccess()
    }
}
```

#### 广告关闭处理
```swift
func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    if ad is RewardedAd {
        // 如果没有获得奖励，说明用户提前关闭了视频
        if !rewardedAdRewardEarned {
            notifyRewardedAdFailed()
        }
    }
}
```

### Flutter端实现

#### 回调设置 (TeaTrackerScreen)
```dart
void _setupAdCallbacks() {
  // 设置激励视频成功回调
  _adManager.setRewardedAdSuccessCallback(() {
    print('Tea Tracker: 收到激励视频成功回调');
    _onRewardedAdSuccess();
  });
  
  // 设置激励视频失败回调
  _adManager.setRewardedAdFailedCallback(() {
    print('Tea Tracker: 收到激励视频失败回调');
    _onRewardedAdFailed();
  });
}
```

#### 回调处理逻辑
```dart
/// 处理激励视频观看成功
void _onRewardedAdSuccess() {
  // 增加可用次数
  _addRewardUsage();
  // 显示成功弹窗
  _showRewardDialog(true);
}

/// 处理激励视频观看失败或未完成
void _onRewardedAdFailed() {
  // 不增加可用次数，只显示失败弹窗
  _showRewardDialog(false);
}
```

#### 弹窗显示
```dart
void _showRewardDialog(bool success) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          // 弹窗内容...
        ),
      ),
    ),
  );
  
  // 1秒后自动关闭对话框
  Timer(const Duration(seconds: 1), () {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  });
}
```

## 用户流程

1. **用户点击"Add New Record"按钮**
2. **检查可用次数**
   - 如果有可用次数：直接显示添加记录对话框
   - 如果没有可用次数：显示激励视频广告选项对话框
3. **用户选择观看视频**
4. **显示激励视频广告**
5. **用户观看结果**
   - **完整观看**：触发成功回调 → 增加10次可用次数 → 显示"Reward Earned!"弹窗
   - **提前关闭**：触发失败回调 → 不增加次数 → 显示"Video Not Completed"弹窗
6. **弹窗自动消失**：1秒后自动关闭，无需用户操作

## 技术特点

- **完整的回调处理**：确保无论用户如何操作都会收到相应回调
- **状态跟踪**：iOS端使用`rewardedAdRewardEarned`标志跟踪奖励状态
- **自动弹窗**：无需用户交互，1秒后自动消失
- **英文界面**：所有提示信息使用英文显示
- **详细日志**：添加了完整的调试日志便于问题排查

## 测试要点

1. **完整观看测试**：观看完整视频，验证是否获得奖励
2. **提前关闭测试**：在视频播放过程中关闭，验证是否不获得奖励
3. **弹窗显示测试**：验证弹窗是否正确显示并自动消失
4. **次数更新测试**：验证可用次数是否正确更新 