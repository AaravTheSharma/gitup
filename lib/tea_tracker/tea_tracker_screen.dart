import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../shared/app_colors.dart';
import '../shared/app_text_styles.dart';
import '../shared/glass_card_widget.dart';
import '../shared/ad_manager.dart';
import '../models/tea_record.dart';
import 'tea_tracker_controller.dart';
import 'usage_manager.dart';

class TeaTrackerScreen extends StatefulWidget {
  const TeaTrackerScreen({Key? key}) : super(key: key);

  @override
  State<TeaTrackerScreen> createState() => _TeaTrackerScreenState();
}

class _TeaTrackerScreenState extends State<TeaTrackerScreen> {
  final TeaTrackerController _controller = TeaTrackerController();
  final AdManager _adManager = AdManager.instance;
  final UsageManager _usageManager = UsageManager.instance;
  
  List<TeaRecord> _records = [];
  int _monthlyCount = 0;
  double _monthlySpending = 0;
  int _usageCount = 5;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupAdCallbacks();
  }

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

  @override
  void dispose() {
    // 清理回调，避免内存泄漏
    _adManager.setRewardedAdSuccessCallback(null);
    _adManager.setRewardedAdFailedCallback(null);
    super.dispose();
  }

  Future<void> _loadData() async {
    final records = await _controller.getRecentRecords();
    final stats = await _controller.getMonthlyStats();
    final usageCount = await _usageManager.getUsageCount();

    if (mounted) {
      setState(() {
        _records = records;
        _monthlyCount = stats['count'] ?? 0;
        _monthlySpending = stats['spending'] ?? 0;
        _usageCount = usageCount;
      });
    }
  }

  /// 处理激励视频观看成功
  void _onRewardedAdSuccess() {
    print('Tea Tracker: 处理激励视频观看成功');
    // 增加可用次数
    _addRewardUsage();
    // 显示成功弹窗
    _showRewardDialog(true);
  }

  /// 处理激励视频观看失败或未完成
  void _onRewardedAdFailed() {
    print('Tea Tracker: 处理激励视频观看失败或未完成');
    // 不增加可用次数，只显示失败弹窗
    _showRewardDialog(false);
  }

  /// 添加奖励使用次数
  Future<void> _addRewardUsage() async {
    final newCount = await _usageManager.addUsage(_usageManager.rewardUsageCount);
    setState(() {
      _usageCount = newCount;
    });
  }

  /// 显示奖励结果对话框（1秒后自动消失）
  void _showRewardDialog(bool success) {
    print('Tea Tracker: 显示奖励结果弹窗 - 成功: $success');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.brandDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: success ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.info,
                  color: success ? Colors.green : Colors.orange,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  success ? 'Reward Earned!' : 'Video Not Completed',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: success ? Colors.green : Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  success 
                      ? 'You have earned ${_usageManager.rewardUsageCount} more uses!'
                      : 'Please watch the complete video to earn rewards.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    // 3秒后自动关闭对话框
    Timer(const Duration(seconds: 3), () {
      if (mounted && Navigator.of(context).canPop()) {
        print('Tea Tracker: 自动关闭奖励结果弹窗');
        Navigator.of(context).pop();
      }
    });
  }

  /// 显示使用次数不足对话框
  void _showInsufficientUsageDialog() {
    // 弹窗弹出时立即显示真正的横幅广告
    _showRealBannerAd();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          // 横幅广告显示在屏幕最底部，与弹窗同一层级
          Positioned(
            bottom: 0, // 显示在屏幕最底部
            left: 0,
            right: 0,
            child: Container(
              height: 50,
              child: _buildBannerAdWidget(),
            ),
          ),
          // 弹窗内容
          Center(
            child: AlertDialog(
              backgroundColor: AppColors.brandDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'No Uses Remaining',
                style: AppTextStyles.headingMedium.copyWith(color: Colors.orange),
              ),
              content: Text(
                'You have 0 uses remaining. Would you like to watch a video to earn ${_usageManager.rewardUsageCount} more uses?',
                style: AppTextStyles.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _hideRealBannerAd();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _hideRealBannerAd();
                    Navigator.of(context).pop();
                    _showRewardedAd();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandTeal,
                    foregroundColor: Colors.black,
                  ),
                  child: Text('Watch Video'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 显示真正的横幅广告
  Future<void> _showRealBannerAd() async {
    try {
      await _adManager.adMobService.showBannerAd();
    } catch (e) {
      print('Tea Tracker: 显示横幅广告时发生错误: $e');
    }
  }

  /// 隐藏真正的横幅广告
  Future<void> _hideRealBannerAd() async {
    try {
      await _adManager.adMobService.hideBannerAd();
    } catch (e) {
      print('Tea Tracker: 隐藏横幅广告时发生错误: $e');
    }
  }

  /// 构建横幅广告Widget
  Widget _buildBannerAdWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'AdMob Banner Ad Loading...',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 显示激励视频广告
  Future<void> _showRewardedAd() async {
    // 先隐藏横幅广告，避免遮挡激励视频
    await _hideRealBannerAd();
    // 显示激励视频广告
    await _adManager.showRewardedAd();
  }

  /// 处理添加记录按钮点击
  Future<void> _handleAddRecordClick() async {
    final canUse = await _usageManager.canUse();
    
    if (canUse) {
      // 可以使用，减少使用次数并显示添加对话框
      final newCount = await _usageManager.decrementUsage();
      setState(() {
        _usageCount = newCount;
      });
      
      _showAddRecordDialog();
    } else {
      // 使用次数不足，显示对话框
      _showInsufficientUsageDialog();
    }
  }

  void _showAddRecordDialog() {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final priceController = TextEditingController();
    int rating = 3;
    String type = 'Bubble Tea';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.brandDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // 确保点击任何区域都能收起键盘
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add New Beverage', style: AppTextStyles.headingMedium),
                const SizedBox(height: 16),

                // 饮品类型选择
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => type = 'Bubble Tea'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: type == 'Bubble Tea'
                                ? AppColors.brandTeal.withOpacity(0.3)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Bubble Tea',
                              style: TextStyle(
                                color: type == 'Bubble Tea'
                                    ? AppColors.brandTeal
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => type = 'Coffee'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: type == 'Coffee'
                                ? AppColors.brandTeal.withOpacity(0.3)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Coffee',
                              style: TextStyle(
                                color: type == 'Coffee'
                                    ? AppColors.brandTeal
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 饮品名称
                TextField(
                  controller: nameController,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'Beverage Name',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.brandTeal),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 品牌和价格
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: brandController,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'Brand',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.brandTeal),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        style: AppTextStyles.bodyMedium,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Price (\$)',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.brandTeal),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 评分
                Text('Rating', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => setState(() => rating = index + 1),
                      child: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // 保存按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isNotEmpty &&
                          brandController.text.isNotEmpty &&
                          priceController.text.isNotEmpty) {
                        await _controller.addRecord(
                          name: nameController.text,
                          brand: brandController.text,
                          price: double.parse(priceController.text),
                          rating: rating,
                          type: type,
                        );
                        Navigator.of(context).pop();
                        _loadData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandTeal,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Save Record'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRecordDetails(TeaRecord record) {
    final DateTime recordDate = record.timestamp;
    final String formattedDate =
        '${recordDate.year}-${recordDate.month.toString().padLeft(2, '0')}-${recordDate.day.toString().padLeft(2, '0')}';
    final String formattedTime =
        '${recordDate.hour.toString().padLeft(2, '0')}:${recordDate.minute.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.brandDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // 确保点击任何区域都能收起键盘
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Beverage Details', style: AppTextStyles.headingMedium),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(record);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.brandTeal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$formattedDate $formattedTime',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 饮品信息卡片
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            record.type == 'Bubble Tea'
                                ? Icons.wine_bar
                                : Icons.coffee,
                            color: AppColors.brandTeal,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.name,
                              style: AppTextStyles.headingSmall,
                            ),
                            Text(
                              record.brand,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type', style: AppTextStyles.bodySmall),
                            Text(record.type, style: AppTextStyles.bodyMedium),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Price', style: AppTextStyles.bodySmall),
                            Text(
                              '\$${record.price.toStringAsFixed(2)}',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.brandTeal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Rating', style: AppTextStyles.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < record.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                    if (record.notes != null && record.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Notes', style: AppTextStyles.bodySmall),
                      const SizedBox(height: 4),
                      Text(record.notes!, style: AppTextStyles.bodyMedium),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordOptions(TeaRecord record) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.brandDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text('Delete Record', style: AppTextStyles.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(record);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(TeaRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.brandDark,
        title: Text('Delete Record', style: AppTextStyles.headingMedium),
        content: Text(
          'Are you sure you want to delete this record? This action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _controller.deleteRecord(record.id);
              if (success && mounted) {
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Record deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Tea Tracker', style: AppTextStyles.headingLarge),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // 确保点击任何区域都能收起键盘
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your sweet daily ritual, every cup is worth recording.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 月度统计卡片
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'This Month',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$_monthlyCount',
                                  style: AppTextStyles.headingLarge.copyWith(
                                    color: AppColors.brandTeal,
                                  ),
                                ),
                                Text(
                                  'Beverages',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Spent',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '\$${_monthlySpending.toStringAsFixed(0)}',
                                        style: AppTextStyles.headingLarge.copyWith(
                                          color: AppColors.brandTeal,
                                        ),
                                      ),
                                      Text(
                                        'USD',
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 最近记录标题
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Records',
                        style: AppTextStyles.headingMedium,
                      ),
                      if (_records.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            // TODO: 显示所有记录页面
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(color: AppColors.brandTeal),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 记录列表
                  Expanded(
                    child: _records.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_cafe_outlined,
                                  size: 64,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No records yet',
                                  style: AppTextStyles.headingLarge.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start tracking your beverages!',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _records.length,
                            itemBuilder: (context, index) {
                              final record = _records[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: GlassCard(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // 图标
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[800],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            record.type == 'Bubble Tea'
                                                ? Icons.wine_bar
                                                : Icons.coffee,
                                            color: AppColors.brandTeal,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        // 信息
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                record.name,
                                                style: AppTextStyles.bodyLarge
                                                    .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                '${record.brand} · \$${record.price.toStringAsFixed(0)}',
                                                style: AppTextStyles.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),

                                        // 评分和时间
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Row(
                                              children: List.generate(5, (
                                                index,
                                              ) {
                                                return Icon(
                                                  index < record.rating
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 14,
                                                );
                                              }),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              record.getFormattedTime(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // 添加按钮
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text('Add New Record (${_usageCount})'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.brandTeal,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: _handleAddRecordClick,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
