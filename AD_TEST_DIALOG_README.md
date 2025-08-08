# 广告测试Dialog功能说明

## 功能概述

在Journal界面中添加了一个隐藏的广告测试功能，可以通过快速点击屏幕来激活。

## 激活方式

1. 进入Journal界面（"好事发生"）
2. 在界面中间区域快速连续点击10次
3. 点击间隔必须在2秒内完成
4. 满足条件后会自动弹出广告测试dialog

## Dialog功能

### 界面布局
- **标题栏**：显示"广告测试面板"
- **关闭按钮**：右上角的X按钮，用于关闭dialog
- **四个广告测试按钮**：
  - 展示横幅
  - 隐藏横幅  
  - 展示插页
  - 显示视频激励
- **刷新按钮**：刷新广告加载状态

### 按钮功能

#### 1. 展示横幅
- 显示横幅广告
- 按钮状态会根据广告是否已加载而变化
- 显示成功/失败提示

#### 2. 隐藏横幅
- 隐藏当前显示的横幅广告
- 总是可用状态

#### 3. 展示插页
- 显示插页广告（强制显示，忽略15秒间隔限制）
- 按钮状态会根据广告是否已加载而变化
- 显示成功/失败提示

#### 4. 显示视频激励
- 显示激励视频广告
- 按钮状态会根据广告是否已加载而变化
- 显示成功/失败提示

### 状态指示

- **已加载状态**：按钮图标为品牌色（#44D7D0），文字为白色
- **未加载状态**：按钮图标为灰色，文字为灰色
- **加载中状态**：显示圆形进度指示器

### 交互特性

- Dialog不会因为点击外部区域而关闭
- 只能通过右上角的关闭按钮关闭
- 广告展示完成后dialog保持打开状态
- 可以连续测试多个广告类型

## 技术实现

### 文件结构
```
lib/journal/
├── journal_screen.dart      # 主界面，包含快速点击检测逻辑
└── ad_test_dialog.dart      # 广告测试dialog组件
```

### 关键代码

#### 快速点击检测
```dart
// 在JournalScreen中添加的变量
int _tapCount = 0;
DateTime? _lastTapTime;
static const Duration _tapTimeout = Duration(milliseconds: 2000);
static const int _requiredTaps = 10;

// 点击处理逻辑
void _handleQuickTap() {
  // 隐藏键盘
  FocusScope.of(context).unfocus();
  
  final now = DateTime.now();
  
  // 检查时间间隔和计数
  if (_lastTapTime == null || 
      now.difference(_lastTapTime!) > _tapTimeout) {
    _tapCount = 1;
    _lastTapTime = now;
    return;
  }
  
  _tapCount++;
  _lastTapTime = now;
  
  if (_tapCount >= _requiredTaps) {
    _showAdTestDialog();
    _tapCount = 0;
    _lastTapTime = null;
  }
}
```

#### Dialog显示
```dart
void _showAdTestDialog() {
  showDialog(
    context: context,
    barrierDismissible: false, // 防止点击外部关闭
    builder: (context) => const AdTestDialog(),
  );
}
```

## 使用场景

1. **开发测试**：在开发过程中测试各种广告类型的显示效果
2. **调试问题**：当广告显示出现问题时，可以快速测试各个广告位
3. **演示功能**：向用户或测试人员演示广告功能

## 注意事项

- 这是一个隐藏功能，普通用户不会轻易发现
- 快速点击检测不会影响正常的界面交互
- 广告测试功能依赖于AdManager和AdMobService的正常工作
- 建议在测试环境中使用，生产环境中可以保留此功能用于调试 