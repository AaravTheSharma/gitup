import 'package:flutter/material.dart';
import 'admob_service.dart';
import 'ad_manager.dart';
import 'dart:async'; // Added for Timer

class AdMobTestScreen extends StatefulWidget {
  const AdMobTestScreen({Key? key}) : super(key: key);

  @override
  State<AdMobTestScreen> createState() => _AdMobTestScreenState();
}

class _AdMobTestScreenState extends State<AdMobTestScreen> {
  final AdMobService _adMobService = AdMobService();
  final AdManager _adManager = AdManager.instance;
  
  bool _isBannerVisible = false;
  String _statusMessage = '';
  
  // 广告加载状态
  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;
  double _loadProgress = 0.0;
  
  // 插页广告统计
  Map<String, dynamic> _interstitialStats = {};
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _setupCallbacks();
    _loadInitialStatus();
    _startCooldownTimer();
  }
  
  @override
  void dispose() {
    _cooldownTimer?.cancel();
    // 清理回调，避免内存泄漏
    _adMobService.setRewardedAdSuccessCallback(null);
    _adMobService.setRewardedAdFailedCallback(null);
    _adMobService.setAdLoadStatusCallback(null);
    super.dispose();
  }

  void _setupCallbacks() {
    _adMobService.setRewardedAdSuccessCallback(() {
      setState(() {
        _statusMessage = '激励视频观看成功！用户获得奖励';
      });
      _showSnackBar('激励视频观看成功！');
    });
    
    _adMobService.setRewardedAdFailedCallback(() {
      setState(() {
        _statusMessage = '激励视频观看失败或未完成';
      });
      _showSnackBar('激励视频观看失败或未完成');
    });
    
    _adMobService.setAdLoadStatusCallback((status) {
      setState(() {
        _isBannerLoaded = status['banner'] ?? false;
        _isInterstitialLoaded = status['interstitial'] ?? false;
        _isRewardedLoaded = status['rewarded'] ?? false;
        _loadProgress = _adMobService.loadProgress;
      });
    });
  }
  
  void _startCooldownTimer() {
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _interstitialStats = _adManager.interstitialStats;
        });
      }
    });
  }
  
  Future<void> _loadInitialStatus() async {
    final status = await _adMobService.getAdLoadStatus();
    setState(() {
      _isBannerLoaded = status['banner'] ?? false;
      _isInterstitialLoaded = status['interstitial'] ?? false;
      _isRewardedLoaded = status['rewarded'] ?? false;
      _loadProgress = _adMobService.loadProgress;
      _interstitialStats = _adManager.interstitialStats;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _preloadAds() async {
    setState(() {
      _statusMessage = '正在预加载所有广告...';
    });

    final success = await _adMobService.preloadAds();
    
    setState(() {
      _statusMessage = success ? '预加载请求已发送' : '预加载请求失败';
    });

    if (success) {
      _showSnackBar('预加载请求已发送');
    } else {
      _showSnackBar('预加载请求失败');
    }
  }

  Future<void> _showBannerAd() async {
    setState(() {
      _statusMessage = '正在显示横幅广告...';
    });

    final success = await _adMobService.showBannerAd();
    
    setState(() {
      _isBannerVisible = success;
      _statusMessage = success ? '横幅广告显示成功' : '横幅广告显示失败';
    });

    if (success) {
      _showSnackBar('横幅广告显示成功');
    } else {
      _showSnackBar('横幅广告显示失败');
    }
  }

  Future<void> _hideBannerAd() async {
    setState(() {
      _statusMessage = '正在隐藏横幅广告...';
    });

    final success = await _adMobService.hideBannerAd();
    
    setState(() {
      _isBannerVisible = !success;
      _statusMessage = success ? '横幅广告隐藏成功' : '横幅广告隐藏失败';
    });

    if (success) {
      _showSnackBar('横幅广告隐藏成功');
    } else {
      _showSnackBar('横幅广告隐藏失败');
    }
  }

  Future<void> _showInterstitialAd() async {
    setState(() {
      _statusMessage = '正在显示插页广告...';
    });

    final success = await _adMobService.showInterstitialAd();
    
    setState(() {
      _statusMessage = success ? '插页广告显示成功' : '插页广告显示失败';
    });

    if (success) {
      _showSnackBar('插页广告显示成功');
    } else {
      _showSnackBar('插页广告显示失败');
    }
  }
  
  Future<void> _tryShowInterstitialAd() async {
    setState(() {
      _statusMessage = '正在尝试显示插页广告（带间隔检查）...';
    });

    final success = await _adManager.tryShowInterstitialAd();
    
    setState(() {
      _statusMessage = success ? '插页广告显示成功' : '插页广告未显示（间隔限制）';
    });

    if (success) {
      _showSnackBar('插页广告显示成功');
    } else {
      _showSnackBar('插页广告未显示（15秒间隔限制）');
    }
  }
  
  Future<void> _forceShowInterstitialAd() async {
    setState(() {
      _statusMessage = '正在强制显示插页广告（忽略间隔）...';
    });

    final success = await _adManager.forceShowInterstitialAd();
    
    setState(() {
      _statusMessage = success ? '插页广告强制显示成功' : '插页广告强制显示失败';
    });

    if (success) {
      _showSnackBar('插页广告强制显示成功');
    } else {
      _showSnackBar('插页广告强制显示失败');
    }
  }

  Future<void> _showRewardedAd() async {
    setState(() {
      _statusMessage = '正在显示激励视频广告...';
    });

    final success = await _adMobService.showRewardedAd();
    
    setState(() {
      _statusMessage = success ? '激励视频广告显示成功' : '激励视频广告显示失败';
    });

    if (success) {
      _showSnackBar('激励视频广告显示成功');
    } else {
      _showSnackBar('激励视频广告显示失败');
    }
  }
  
  void _resetInterstitialStats() {
    _adManager.resetInterstitialStats();
    setState(() {
      _interstitialStats = _adManager.interstitialStats;
      _statusMessage = '插页广告统计已重置';
    });
    _showSnackBar('插页广告统计已重置');
  }

  Widget _buildAdStatusCard(String title, bool isLoaded, String adType) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          isLoaded ? Icons.check_circle : Icons.pending,
          color: isLoaded ? Colors.green : Colors.orange,
        ),
        title: Text(title),
        subtitle: Text(isLoaded ? '已加载完成' : '加载中...'),
        trailing: Icon(
          isLoaded ? Icons.ready : Icons.hourglass_empty,
          color: isLoaded ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
  
  Widget _buildInterstitialStatsCard() {
    final canShow = _interstitialStats['canShow'] ?? false;
    final remainingCooldown = _interstitialStats['remainingCooldown'] ?? 0;
    final shownCount = _interstitialStats['shownCount'] ?? 0;
    final attemptCount = _interstitialStats['attemptCount'] ?? 0;
    final successRate = _interstitialStats['successRate'] ?? '0.0';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                const Text(
                  '插页广告统计',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _resetInterstitialStats,
                  tooltip: '重置统计',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('显示次数', '$shownCount', Colors.green),
                ),
                Expanded(
                  child: _buildStatItem('尝试次数', '$attemptCount', Colors.orange),
                ),
                Expanded(
                  child: _buildStatItem('成功率', '$successRate%', Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: canShow ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: canShow ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    canShow ? Icons.check_circle : Icons.timer,
                    color: canShow ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      canShow 
                          ? '可以显示插页广告'
                          : '冷却中，剩余 ${remainingCooldown} 秒',
                      style: TextStyle(
                        color: canShow ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdMob 测试'),
        backgroundColor: const Color(0xFF44D7D0),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _preloadAds,
            tooltip: '重新预加载广告',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 状态显示
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '状态: $_statusMessage',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '横幅广告: ${_isBannerVisible ? "显示中" : "隐藏"}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 广告加载状态
            const Text(
              '广告加载状态',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // 加载进度条
            LinearProgressIndicator(
              value: _loadProgress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _loadProgress == 1.0 ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '加载进度: ${(_loadProgress * 100).toInt()}% (${(_loadProgress * 3).toInt()}/3)',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            
            const SizedBox(height: 8),
            
            // 各广告状态
            _buildAdStatusCard('横幅广告', _isBannerLoaded, 'banner'),
            _buildAdStatusCard('插页广告', _isInterstitialLoaded, 'interstitial'),
            _buildAdStatusCard('激励视频广告', _isRewardedLoaded, 'rewarded'),
            
            const SizedBox(height: 16),
            
            // 预加载按钮
            ElevatedButton.icon(
              onPressed: _preloadAds,
              icon: const Icon(Icons.download),
              label: const Text('预加载所有广告'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 插页广告统计
            _buildInterstitialStatsCard(),
            
            const SizedBox(height: 16),
            
            // 横幅广告控制
            const Text(
              '横幅广告',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isBannerLoaded ? _showBannerAd : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF44D7D0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('显示横幅广告'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _hideBannerAd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('隐藏横幅广告'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 插页广告
            const Text(
              '插页广告',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isInterstitialLoaded ? _showInterstitialAd : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF44D7D0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('直接显示'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isInterstitialLoaded ? _tryShowInterstitialAd : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('间隔显示'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isInterstitialLoaded ? _forceShowInterstitialAd : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('强制显示（忽略间隔）'),
            ),
            
            const SizedBox(height: 24),
            
            // 激励视频广告
            const Text(
              '激励视频广告',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isRewardedLoaded ? _showRewardedAd : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF44D7D0),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('显示激励视频广告'),
            ),
            
            const SizedBox(height: 24),
            
            // 说明文字
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '说明:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• 应用启动时自动预加载所有广告'),
                  Text('• 广告加载完成后按钮才会启用'),
                  Text('• 横幅广告会显示在屏幕底部'),
                  Text('• 插页广告会全屏显示'),
                  Text('• 插页广告有15秒间隔限制'),
                  Text('• 激励视频广告需要完整观看才能获得奖励'),
                  Text('• 当前使用的是测试广告ID'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 