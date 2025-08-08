import 'package:flutter/material.dart';
import 'dart:async';
import '../shared/app_colors.dart';
import '../shared/app_text_styles.dart';
import '../shared/glass_card_widget.dart';
import '../shared/ad_manager.dart';
import '../tea_tracker/usage_manager.dart';

class AdTestDialog extends StatefulWidget {
  const AdTestDialog({super.key});

  @override
  State<AdTestDialog> createState() => _AdTestDialogState();
}

class _AdTestDialogState extends State<AdTestDialog> {
  final AdManager _adManager = AdManager.instance;
  final UsageManager _usageManager = UsageManager.instance;
  Map<String, bool> _adLoadStatus = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAdStatus();
    _setupRewardedAdCallbacks();
  }

  @override
  void dispose() {
    // 清理回调，避免内存泄漏
    _adManager.setRewardedAdSuccessCallback(null);
    _adManager.setRewardedAdFailedCallback(null);
    super.dispose();
  }

  void _setupRewardedAdCallbacks() {
    // 设置激励视频成功回调
    _adManager.setRewardedAdSuccessCallback(() {
      print('AdTestDialog: 收到激励视频成功回调');
      _onRewardedAdSuccess();
    });
    
    // 设置激励视频失败回调
    _adManager.setRewardedAdFailedCallback(() {
      print('AdTestDialog: 收到激励视频失败回调');
      _onRewardedAdFailed();
    });
  }

  void _onRewardedAdSuccess() {
    // 视频观看完成，增加使用次数
    _addRewardUsage();
    _showRewardDialog(true);
  }

  void _onRewardedAdFailed() {
    // 视频未观看完成，不增加使用次数
    _showRewardDialog(false);
  }

  Future<void> _addRewardUsage() async {
    final newCount = await _usageManager.addUsage(_usageManager.rewardUsageCount);
    print('AdTestDialog: 奖励使用次数已添加，当前总次数: $newCount');
  }

  void _showRewardDialog(bool success) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.brandDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: success ? AppColors.brandTeal.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle : Icons.info,
                color: success ? AppColors.brandTeal : Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                success ? 'Reward Earned!' : 'Video Not Completed',
                style: AppTextStyles.headingMedium.copyWith(
                  color: success ? AppColors.brandTeal : Colors.orange,
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
    );
    
    // 3秒后自动关闭对话框
    Timer(const Duration(seconds: 3), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _loadAdStatus() async {
    final status = await _adManager.getAdLoadStatus();
    if (mounted) {
      setState(() {
        _adLoadStatus = status;
      });
    }
  }

  Future<void> _showBannerAd() async {
    setState(() => _isLoading = true);
    try {
      await _adManager.adMobService.showBannerAd();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _hideBannerAd() async {
    setState(() => _isLoading = true);
    try {
      await _adManager.adMobService.hideBannerAd();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showInterstitialAd() async {
    setState(() => _isLoading = true);
    try {
      await _adManager.forceShowInterstitialAd();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showRewardedAd() async {
    setState(() => _isLoading = true);
    try {
      await _adManager.showRewardedAd();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildAdButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isLoaded,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: _isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isLoaded 
                      ? AppColors.brandTeal.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isLoaded ? AppColors.brandTeal : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isLoaded ? Colors.white : Colors.grey,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isLoaded ? Colors.grey : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandTeal),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  color: isLoaded ? AppColors.brandTeal : Colors.grey,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题栏
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '广告测试面板',
                      style: AppTextStyles.headingMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '测试各种广告类型的显示效果',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              
              // 广告按钮
              _buildAdButton(
                title: '展示横幅',
                subtitle: '',
                icon: Icons.view_headline,
                onPressed: _showBannerAd,
                isLoaded: _adLoadStatus['banner'] == true,
              ),
              
              _buildAdButton(
                title: '隐藏横幅',
                subtitle: '',
                icon: Icons.visibility_off,
                onPressed: _hideBannerAd,
                isLoaded: true, // 总是可用
              ),
              
              _buildAdButton(
                title: '展示插页',
                subtitle: '',
                icon: Icons.fullscreen,
                onPressed: _showInterstitialAd,
                isLoaded: _adLoadStatus['interstitial'] == true,
              ),
              
              _buildAdButton(
                title: '展示视频激励',
                subtitle: '',
                icon: Icons.play_circle_filled,
                onPressed: _showRewardedAd,
                isLoaded: _adLoadStatus['rewarded'] == true,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 