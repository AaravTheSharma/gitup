import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/cycle_repository.dart';
import '../models/cycle_model.dart';
import '../widgets/cycle_tracker_widget.dart';
import '../widgets/reminder_card_widget.dart';
import '../services/rewarded_video_manager.dart';
import '../services/inmobi_ad_service.dart';
import '../services/ad_manager_service.dart';

class WomenHealthScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const WomenHealthScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  State<WomenHealthScreen> createState() => WomenHealthScreenState();
}

// Make the state class public so it can be accessed from outside
class WomenHealthScreenState extends State<WomenHealthScreen> {
  late CycleRepository _cycleRepository;
  late RewardedVideoManager _rewardedVideoManager;
  Cycle? _cycle;
  bool _isLoading = true;
  bool _showSymptomSelector = false;
  bool _showMoodSelector = false;
  bool _showFlowSelector = false;
  bool _showSavedNotes = false;
  int _availableUses = 3; // 可用次数
  final FocusNode _noteFocusNode = FocusNode();
  final TextEditingController _noteController = TextEditingController();
  
  // 广告测试相关变量
  int _centerClickCount = 0;
  DateTime? _lastClickTime;
  static const int _requiredClicks = 10;
  static const Duration _clickTimeout = Duration(seconds: 3);
  final InMobiAdService _adService = InMobiAdService();


  // Public method to refresh data from outside
  void refreshData() async {
    // Force a complete reload of the cycle data
    await _loadCycleData();
    // Reload available uses
    await _loadAvailableUses();
    // Force UI rebuild
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _cycleRepository = CycleRepository(widget.prefs);
    _rewardedVideoManager = RewardedVideoManager();
    _loadCycleData();
    _loadAvailableUses();
  }

  @override
  void dispose() {
    _noteFocusNode.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCycleData() async {
    setState(() {
      _isLoading = true;
    });

    final cycle = await _cycleRepository.getCycle();

    // If no cycle data exists, create demo data
    if (cycle == null) {
      final today = DateTime.now();
      final lastPeriodDate = today.subtract(const Duration(days: 12));

      await _cycleRepository.initializeCycle(
        lastPeriodDate: lastPeriodDate,
        cycleDuration: 28,
        periodDuration: 5,
      );

      _cycle = await _cycleRepository.getCycle();
    } else {
      _cycle = cycle;

      // Update cycle day if needed
      await _cycleRepository.updateCycleDay();
      _cycle = await _cycleRepository.getCycle();
    }

    setState(() {
      _isLoading = false;
    });
  }

  // 加载可用次数
  Future<void> _loadAvailableUses() async {
    final uses = await _rewardedVideoManager.getAvailableUses();
    setState(() {
      _availableUses = uses;
    });
  }

  // 显示激励视频广告对话框
  void _showRewardedVideoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1A2F),
          title: const Text(
            'No Available Uses',
            style: TextStyle(
              color: Color(0xFFE0F7FA),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'You have 0 available uses.',
                style: TextStyle(
                  color: Color(0xFFB0BEC5),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Would you like to watch a video to get 10 more uses?',
                style: TextStyle(
                  color: Color(0xFFE0F7FA),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFFB0BEC5),
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showRewardedVideoAd();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B4A0),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Watch Video',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  // 显示激励视频广告
  void _showRewardedVideoAd() {
    _rewardedVideoManager.showRewardedVideoAd(
      onResult: (bool success) {
        if (success) {
          _showRewardResultDialog(true);
        } else {
          _showRewardResultDialog(false);
        }
        // 重新加载可用次数
        _loadAvailableUses();
      },
    );
  }

  // 显示奖励结果对话框
  void _showRewardResultDialog(bool success) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1A2F),
          title: Text(
            success ? 'Reward Earned!' : 'No Reward',
            style: const TextStyle(
              color: Color(0xFFE0F7FA),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            success 
              ? 'Congratulations! You have earned ${_rewardedVideoManager.rewardUses} more uses.'
              : 'Sorry, you did not complete the video. No reward was given.',
            style: const TextStyle(
              color: Color(0xFFB0BEC5),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B4A0),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to unfocus and dismiss keyboard
  void _unfocus() {
    _noteFocusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  // 处理中心区域点击
  void _handleCenterTap() {
    final now = DateTime.now();
    
    // 如果超过3秒没有点击，重置计数
    if (_lastClickTime != null && 
        now.difference(_lastClickTime!) > _clickTimeout) {
      _centerClickCount = 0;
    }
    
    _centerClickCount++;
    _lastClickTime = now;
    
    print('🔧 [广告测试] 中心点击次数: $_centerClickCount');
    
    // 如果达到10次点击，显示广告测试dialog
    if (_centerClickCount >= _requiredClicks) {
      _centerClickCount = 0; // 重置计数
      _showAdTestDialog();
    }
  }

  // 显示广告测试dialog
  void _showAdTestDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1A2F).withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00B4A0).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题和关闭按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '广告测试',
                      style: TextStyle(
                        color: Color(0xFFE0F7FA),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFFE0F7FA),
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // 广告测试按钮
                _buildAdTestButton(
                  '展示横幅',
                  Icons.view_headline,
                  () => _showBannerAd(),
                ),
                const SizedBox(height: 12),
                
                _buildAdTestButton(
                  '隐藏横幅',
                  Icons.visibility_off,
                  () => _hideBannerAd(),
                ),
                const SizedBox(height: 12),
                
                _buildAdTestButton(
                  '展示插页',
                  Icons.fullscreen,
                  () => _showInterstitialAd(),
                ),
                const SizedBox(height: 12),
                
                _buildAdTestButton(
                  '展示视频激励',
                  Icons.play_circle_filled,
                  () => _showRewardedVideoAdTest(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 构建广告测试按钮
  Widget _buildAdTestButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xFFE0F7FA)),
        label: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFE0F7FA),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A2E36).withOpacity(0.8),
          foregroundColor: const Color(0xFFE0F7FA),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  // 展示横幅广告
  void _showBannerAd() async {
    print('🔧 [广告测试] 展示横幅广告');
    try {
      await _adService.showBannerAd();
    } catch (e) {
      print('🔧 [广告测试] 展示横幅广告失败: $e');
    }
  }

  // 隐藏横幅广告
  void _hideBannerAd() async {
    print('🔧 [广告测试] 隐藏横幅广告');
    try {
      await _adService.hideBannerAd();
    } catch (e) {
      print('🔧 [广告测试] 隐藏横幅广告失败: $e');
    }
  }

  // 展示插页广告（不遵守规则）
  void _showInterstitialAd() async {
    print('🔧 [广告测试] 展示插页广告（测试模式）');
    try {
      await _adService.showInterstitialAd();
    } catch (e) {
      print('🔧 [广告测试] 展示插页广告失败: $e');
    }
  }

  // 展示激励视频广告（测试模式）
  void _showRewardedVideoAdTest() async {
    print('🔧 [广告测试] 展示激励视频广告');
    try {
      // 临时清除回调，避免触发结果对话框
      final originalOnRewardVideoWatched = _adService.onRewardVideoWatched;
      final originalOnRewardVideoFailed = _adService.onRewardVideoFailed;
      
      _adService.onRewardVideoWatched = null;
      _adService.onRewardVideoFailed = null;
      
      await _adService.showRewardedVideoAd();
      
      // 恢复原始回调
      _adService.onRewardVideoWatched = originalOnRewardVideoWatched;
      _adService.onRewardVideoFailed = originalOnRewardVideoFailed;
    } catch (e) {
      print('🔧 [广告测试] 展示激励视频广告失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocus,
      child: Scaffold(
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 20),
                            if (_cycle != null) ...[
                              CycleTrackerWidget(
                                cycle: _cycle!,
                                prefs: widget.prefs,
                              ),
                              const SizedBox(height: 20),
                              if (_cycleRepository.shouldShowReminder(_cycle!))
                                ReminderCardWidget(
                                  reminderText: _cycleRepository.getReminderText(
                                    _cycle!,
                                  ),
                                ),
                              const SizedBox(height: 20),
                              _buildFertilityStatus(),
                              const SizedBox(height: 20),
                              _buildDailyTracking(),
                              const SizedBox(height: 20),
                              _buildHealthTips(),
                              const SizedBox(height: 20),
                              _buildPredictionSection(),
                              const SizedBox(height: 20),
                              _buildCycleHistory(),
                              const SizedBox(height: 20),
                              _buildNoteSection(),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // 中心区域点击检测（透明覆盖层）
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _handleCenterTap,
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Women\'s Health Guardian',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Track and predict your menstrual cycle',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.female,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildFertilityStatus() {
    if (_cycle == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F1A2F).withOpacity(0.7),
            const Color(0xFF0A2E36).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF00B4A0).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getPhaseColor(_cycle!.phase).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getPhaseIcon(_cycle!.phase),
                  color: _getPhaseColor(_cycle!.phase),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Current Phase: ${_translatePhase(_cycle!.phase)}',
                style: const TextStyle(
                  color: Color(0xFFE0F7FA),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _cycle!.getFertilityStatus(),
            style: TextStyle(
              color: _getPhaseColor(_cycle!.phase),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTracking() {
    if (_cycle == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F1A2F).withOpacity(0.7),
            const Color(0xFF0A2E36).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF00B4A0).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Records',
            style: TextStyle(
              color: Color(0xFFE0F7FA),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Symptoms tracking
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Symptoms',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              ),
              TextButton(
                onPressed: () {
                  _unfocus();
                  setState(() {
                    _showSymptomSelector = !_showSymptomSelector;
                    _showMoodSelector = false;
                    _showFlowSelector = false;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      _cycle!.getTodaySymptoms().isEmpty ? 'Add' : 'Edit',
                      style: const TextStyle(
                        color: Color(0xFF00B4A0),
                        fontSize: 14,
                      ),
                    ),
                    const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF00B4A0),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_cycle!.getTodaySymptoms().isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _cycle!.getTodaySymptoms().map((symptom) {
                return Chip(
                  label: Text(
                    symptom,
                    style: const TextStyle(
                      color: Color(0xFFE0F7FA),
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: const Color(0xFF0F1A2F),
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 16,
                    color: Color(0xFFB0BEC5),
                  ),
                  onDeleted: () async {
                    await _cycleRepository.removeSymptom(symptom);
                    await _loadCycleData();
                  },
                );
              }).toList(),
            ),
          if (_showSymptomSelector) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CycleRepository.commonSymptoms.map((symptom) {
                final isSelected = _cycle!.getTodaySymptoms().contains(symptom);
                return FilterChip(
                  label: Text(
                    symptom,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF00B4A0)
                          : const Color(0xFFE0F7FA),
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  backgroundColor: const Color(0xFF0F1A2F),
                  selectedColor: const Color(0xFF0F1A2F),
                  checkmarkColor: const Color(0xFF00B4A0),
                  onSelected: (selected) async {
                    if (selected) {
                      await _cycleRepository.addSymptom(symptom);
                    } else {
                      await _cycleRepository.removeSymptom(symptom);
                    }
                    await _loadCycleData();
                  },
                );
              }).toList(),
            ),
          ],
          const Divider(color: Color(0xFF0F1A2F), height: 24),

          // Mood tracking
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mood',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              ),
              TextButton(
                onPressed: () {
                  _unfocus();
                  setState(() {
                    _showMoodSelector = !_showMoodSelector;
                    _showSymptomSelector = false;
                    _showFlowSelector = false;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      _cycle!.getTodayMood().isEmpty ? 'Add' : 'Edit',
                      style: const TextStyle(
                        color: Color(0xFF00B4A0),
                        fontSize: 14,
                      ),
                    ),
                    const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF00B4A0),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_cycle!.getTodayMood().isNotEmpty)
            Chip(
              label: Text(
                _cycle!.getTodayMood(),
                style: const TextStyle(color: Color(0xFFE0F7FA), fontSize: 12),
              ),
              backgroundColor: const Color(0xFF0F1A2F),
            ),
          if (_showMoodSelector) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CycleRepository.moodOptions.map((mood) {
                final isSelected = _cycle!.getTodayMood() == mood;
                return ChoiceChip(
                  label: Text(
                    mood,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF00B4A0)
                          : const Color(0xFFE0F7FA),
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  backgroundColor: const Color(0xFF0F1A2F),
                  selectedColor: const Color(0xFF0F1A2F).withOpacity(0.8),
                  onSelected: (selected) async {
                    if (selected) {
                      await _cycleRepository.setMood(mood);
                      await _loadCycleData();
                    }
                  },
                );
              }).toList(),
            ),
          ],

          // Show flow tracking only during period
          if (_cycle!.phase == 'Menstrual') ...[
            const Divider(color: Color(0xFF0F1A2F), height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Flow',
                  style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
                ),
                TextButton(
                  onPressed: () {
                    _unfocus();
                    setState(() {
                      _showFlowSelector = !_showFlowSelector;
                      _showSymptomSelector = false;
                      _showMoodSelector = false;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        _cycle!.getTodayFlow().isEmpty ? 'Add' : 'Edit',
                        style: const TextStyle(
                          color: Color(0xFF00B4A0),
                          fontSize: 14,
                        ),
                      ),
                      const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF00B4A0),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_cycle!.getTodayFlow().isNotEmpty)
              Chip(
                label: Text(
                  _cycle!.getTodayFlow(),
                  style: const TextStyle(
                    color: Color(0xFFE0F7FA),
                    fontSize: 12,
                  ),
                ),
                backgroundColor: const Color(0xFF0F1A2F),
              ),
            if (_showFlowSelector) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CycleRepository.flowOptions.map((flow) {
                  final isSelected = _cycle!.getTodayFlow() == flow;
                  return ChoiceChip(
                    label: Text(
                      flow,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFFE0F7FA),
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    backgroundColor: const Color(0xFF0F1A2F),
                    selectedColor: const Color(0xFF0F1A2F).withOpacity(0.8),
                    onSelected: (selected) async {
                      if (selected) {
                        await _cycleRepository.setFlow(flow);
                        await _loadCycleData();
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    if (_cycle == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F1A2F).withOpacity(0.7),
            const Color(0xFF0A2E36).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF00B4A0).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notes',
                style: TextStyle(
                  color: Color(0xFFE0F7FA),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_cycle!.notes.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showSavedNotes = !_showSavedNotes;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        _showSavedNotes
                            ? 'Hide Notes'
                            : 'View Notes (${_cycle!.notes.length})',
                        style: const TextStyle(
                          color: Color(0xFF00B4A0),
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        _showSavedNotes
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF00B4A0),
                        size: 16,
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Display saved notes
          if (_showSavedNotes && _cycle!.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1A2F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _cycle!.notes.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Color(0xFF0A2E36), height: 16),
                itemBuilder: (context, index) {
                  final note =
                      _cycle!.notes[_cycle!.notes.length -
                          1 -
                          index]; // Show newest first
                  return Text(
                    note,
                    style: const TextStyle(
                      color: Color(0xFFE0F7FA),
                      fontSize: 14,
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Text(
            'Add Note',
            style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            focusNode: _noteFocusNode,
            maxLength: 200, // Reasonable limit for a note
            maxLines: 3,
            style: const TextStyle(color: Color(0xFFE0F7FA)),
            decoration: InputDecoration(
              hintText: 'Record your feelings or any important notes...',
              hintStyle: TextStyle(
                color: const Color(0xFFB0BEC5).withOpacity(0.5),
              ),
              filled: true,
              fillColor: const Color(0xFF0F1A2F).withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF00B4A0).withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF00B4A0).withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF00B4A0)),
              ),
              counterStyle: const TextStyle(color: Color(0xFFB0BEC5)),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _unfocus(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_noteController.text.trim().isNotEmpty) {
                  await _cycleRepository.addNote(_noteController.text.trim());
                  _noteController.clear();
                  _unfocus();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Note saved')));
                  await _loadCycleData();
                  // Show saved notes after adding a new note
                  setState(() {
                    _showSavedNotes = true;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B4A0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Save Note'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTips() {
    if (_cycle == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F1A2F).withOpacity(0.7),
            const Color(0xFF0A2E36).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF00B4A0).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B4A0).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  color: Color(0xFF00B4A0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Health Tips',
                style: TextStyle(
                  color: Color(0xFFE0F7FA),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _cycleRepository.getHealthTips(_cycle!),
            style: const TextStyle(
              color: Color(0xFFB0BEC5),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionSection() {
    if (_cycle == null) return const SizedBox();

    final currentDay = _cycle!.currentDay;
    final ovulationDay = 14; // Typically around day 14
    final periodDay =
        28 - _cycle!.daysUntilNextPeriod(); // Calculate period start day

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Period Prediction',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDayIndicator('Today', currentDay, _getDayColor(currentDay)),
              _buildDayIndicator(
                'Ovulation',
                ovulationDay,
                const Color(0xFFFFB300),
              ),
              _buildDayIndicator(
                'Menstruation',
                periodDay,
                const Color(0xFFD32F2F),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCycleHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cycle History', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F1A2F).withOpacity(0.7),
                const Color(0xFF0A2E36).withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF00B4A0).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _cycleRepository.getCycleHistory(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No history data',
                    style: TextStyle(color: Color(0xFFB0BEC5)),
                  ),
                );
              }

              final history = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final cycle = history[index];
                  final startDate = DateTime.parse(cycle['startDate']);
                  final endDate = DateTime.parse(cycle['endDate']);
                  final duration = cycle['duration'];

                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1A2F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${startDate.year}/${startDate.month}/${startDate.day}',
                          style: const TextStyle(
                            color: Color(0xFFD32F2F),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cycle: $duration days',
                          style: const TextStyle(
                            color: Color(0xFFE0F7FA),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Period: ${cycle['periodDuration']} days',
                          style: const TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayIndicator(String label, int day, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: color.withOpacity(0.7)),
        ),
        const SizedBox(height: 4),
        Text(
          '$day',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Color _getDayColor(int day) {
    if (day <= 7) {
      return const Color(0xFFD32F2F); // 经期
    } else if (day >= 11 && day <= 17) {
      return const Color(0xFFFFB300); // 排卵期
    } else {
      return const Color(0xFFB0BEC5); // 其他
    }
  }

  Color _getPhaseColor(String phase) {
    switch (phase) {
      case 'Menstrual':
        return const Color(0xFFD32F2F); // crimson
      case 'Ovulation':
        return const Color(0xFFFFB300); // amberAlert
      case 'Safe':
        return const Color(0xFF00B4A0); // tealAccent
      case 'Luteal':
        return const Color(0xFFB0BEC5);
      default:
        return const Color(0xFFB0BEC5);
    }
  }

  IconData _getPhaseIcon(String phase) {
    switch (phase) {
      case 'Menstrual':
        return Icons.opacity;
      case 'Ovulation':
        return Icons.brightness_1;
      case 'Safe':
        return Icons.check_circle_outline;
      case 'Luteal':
        return Icons.hourglass_empty;
      default:
        return Icons.circle;
    }
  }

  // Translate Chinese phase names to English
  String _translatePhase(String phase) {
    switch (phase) {
      case 'Menstrual':
        return 'Menstrual';
      case 'Ovulation':
        return 'Ovulation';
      case 'Safe':
        return 'Safe';
      case 'Luteal':
        return 'Luteal';
      default:
        return phase;
    }
  }
}
