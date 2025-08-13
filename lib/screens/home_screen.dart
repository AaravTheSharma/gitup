import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/women_health_screen.dart';
import '../screens/fashion_expense_screen.dart';
import '../screens/storage_organizer_screen.dart';
import '../screens/settings_screen.dart';
import '../models/cycle_model.dart';
import '../repositories/cycle_repository.dart';
import '../models/expense_model.dart';
import '../repositories/expense_repository.dart';
import '../models/item_model.dart';
import '../repositories/item_repository.dart';
import '../services/ad_manager_service.dart';
import '../services/rewarded_video_manager.dart';

class HomeScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const HomeScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<WomenHealthScreenState> _womenHealthScreenKey =
      GlobalKey<WomenHealthScreenState>();
  final GlobalKey<FashionExpenseScreenState> _fashionExpenseScreenKey =
      GlobalKey<FashionExpenseScreenState>();
  final GlobalKey<StorageOrganizerScreenState> _storageOrganizerScreenKey =
      GlobalKey<StorageOrganizerScreenState>();

  // 标记是否需要刷新各个界面
  bool _needRefreshStorage = false;

  // 激励视频管理器
  late RewardedVideoManager _rewardedVideoManager;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _rewardedVideoManager = RewardedVideoManager();
    _screens = [
      WomenHealthScreen(key: _womenHealthScreenKey, prefs: widget.prefs),
      FashionExpenseScreen(key: _fashionExpenseScreenKey, prefs: widget.prefs),
      StorageOrganizerScreen(
        key: _storageOrganizerScreenKey,
        prefs: widget.prefs,
      ),
      SettingsScreen(prefs: widget.prefs),
    ];
  }

  void _refreshWomenHealthScreen() {
    // First update the screen reference if needed
    setState(() {
      _screens[0] = WomenHealthScreen(
        key: _womenHealthScreenKey,
        prefs: widget.prefs,
      );
    });

    // Then trigger a refresh on the existing screen if it's mounted
    if (_womenHealthScreenKey.currentState != null) {
      // Use Future.delayed to ensure the refresh happens after the current build cycle
      Future.delayed(Duration.zero, () {
        if (_womenHealthScreenKey.currentState != null) {
          _womenHealthScreenKey.currentState!.refreshData();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for transparent bottom navigation
      body: _screens[_currentIndex],
      floatingActionButton: _currentIndex != 3
          ? FloatingActionButton(
              onPressed: () {
                _showAddDialog();
              },
              backgroundColor: const Color(0xFF00B4A0),
              foregroundColor: const Color(0xFF121212),
              child: const Icon(Icons.add),
              elevation: 8,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFF0A2E36).withOpacity(0.8),
            selectedItemColor: const Color(0xFF00B4A0),
            unselectedItemColor: const Color(0xFFB0BEC5),
            currentIndex: _currentIndex,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            onTap: (index) async {
              // 记录切换前的索引
              final previousIndex = _currentIndex;

              setState(() {
                _currentIndex = index;
              });

              // 检查是否需要刷新Storage界面
              if (_currentIndex == 2 && _needRefreshStorage) {
                _needRefreshStorage = false;
                Future.microtask(() {
                  _storageOrganizerScreenKey?.currentState?.refreshData();
                });
              }

              // 如果切换到了不同的界面，在界面切换完成后显示插页广告
              if (previousIndex != index) {
                // 使用 Future.delayed 确保界面切换完成后再显示广告
                Future.delayed(const Duration(milliseconds: 300), () {
                  AdManagerService().showInterstitialAdIfEligible();
                });
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.female),
                label: 'Health',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.style),
                label: 'Fashion',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2),
                label: 'Storage',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 显示激励视频广告对话框
  void _showRewardedVideoDialog() async {
    print('📱 [弹窗] 开始显示"No Available Uses"弹窗');
    // 显示横幅广告
    print('📱 [弹窗] 准备显示横幅广告');
    await _rewardedVideoManager.showBannerAd();

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
              onPressed: () async {
                print('📱 [弹窗] 用户点击Cancel按钮');
                Navigator.of(context).pop();
                // 隐藏横幅广告
                print('📱 [弹窗] 准备隐藏横幅广告');
                await _rewardedVideoManager.hideBannerAd();
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
              onPressed: () async {
                print('📱 [弹窗] 用户点击Watch Video按钮');
                Navigator.of(context).pop();
                // 隐藏横幅广告
                print('📱 [弹窗] 准备隐藏横幅广告');
                await _rewardedVideoManager.hideBannerAd();
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
    print('🎬 [激励视频] 开始显示激励视频广告');
    _rewardedVideoManager.showRewardedVideoAd(
      onResult: (bool success) {
        print('🎬 [激励视频] 视频观看结果: ${success ? "成功" : "失败"}');
        if (success) {
          _showRewardResultDialog(true);
        } else {
          _showRewardResultDialog(false);
        }
        // 刷新Women Health界面的可用次数显示
        _womenHealthScreenKey.currentState?.refreshData();
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
              onPressed: () async {
                print('📱 [弹窗] 用户点击奖励结果对话框的OK按钮');
                Navigator.of(context).pop();
                // 确保横幅广告被隐藏
                print('📱 [弹窗] 确保横幅广告被隐藏');
                await _rewardedVideoManager.hideBannerAd();
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

  void _showAddDialog() async {
    print('📱 [主界面] 用户点击"+"按钮');
    // 如果是Women Health界面，检查可用次数
    if (_currentIndex == 0) {
      print('📱 [主界面] 当前在Women Health界面，检查可用次数');
      final canUse = await _rewardedVideoManager.canUse();
      if (!canUse) {
        print('📱 [主界面] 可用次数不足，显示激励视频广告对话框');
        // 显示激励视频广告对话框
        _showRewardedVideoDialog();
        return;
      } else {
        print('📱 [主界面] 可用次数充足，继续显示添加记录对话框');
      }
    } else {
      print('📱 [主界面] 不在Women Health界面，直接显示添加记录对话框');
    }

    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissal by tapping outside
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside input fields
            FocusScope.of(context).unfocus();
          },
          child: Dialog(
            backgroundColor: const Color(0xFF0F1A2F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add New Record',
                    style: TextStyle(
                      color: Color(0xFFE0F7FA),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDialogOption(
                        icon: Icons.calendar_month,
                        label: 'Cycle',
                        onTap: () async {
                          print('📱 [主界面] 用户选择添加Cycle记录');
                          Navigator.pop(context);
                          // 如果是Women Health界面，消耗一次使用机会
                          if (_currentIndex == 0) {
                            print('📱 [主界面] 在Women Health界面，消耗一次使用机会');
                            await _rewardedVideoManager.consumeUse();
                            // 刷新Women Health界面的可用次数显示
                            _womenHealthScreenKey.currentState?.refreshData();
                          } else {
                            print('📱 [主界面] 不在Women Health界面，不消耗使用次数');
                          }
                          _showInputDialog(_buildCycleInputForm());
                        },
                      ),
                      _buildDialogOption(
                        icon: Icons.attach_money,
                        label: 'Expense',
                        onTap: () {
                          Navigator.pop(context);
                          _showInputDialog(_buildExpenseInputForm());
                        },
                      ),
                      _buildDialogOption(
                        icon: Icons.inventory_2,
                        label: 'Item',
                        onTap: () {
                          Navigator.pop(context);
                          _showInputDialog(_buildItemInputForm());
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showInputDialog(Widget content) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissal by tapping outside
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside input fields
            FocusScope.of(context).unfocus();
          },
          child: Dialog(
            backgroundColor: const Color(0xFF0F1A2F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Padding(padding: const EdgeInsets.all(20), child: content),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCycleInputForm() {
    final cycleRepository = CycleRepository(widget.prefs);
    final lastPeriodDate = DateTime.now().subtract(const Duration(days: 1));
    final cycleDurationController = TextEditingController(text: '28');
    final periodDurationController = TextEditingController(text: '5');
    final dateController = TextEditingController(
      text:
          '${lastPeriodDate.year}-${lastPeriodDate.month.toString().padLeft(2, '0')}-${lastPeriodDate.day.toString().padLeft(2, '0')}',
    );

    DateTime selectedDate = lastPeriodDate;
    final cycleFocusNode = FocusNode();
    final periodFocusNode = FocusNode();

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF00B4A0),
                onPrimary: Colors.white,
                surface: Color(0xFF0F1A2F),
                onSurface: Color(0xFFE0F7FA),
              ),
              dialogBackgroundColor: const Color(0xFF0F1A2F),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != selectedDate) {
        selectedDate = picked;
        dateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      }
    }

    // Function to unfocus and dismiss keyboard
    void _unfocus() {
      cycleFocusNode.unfocus();
      periodFocusNode.unfocus();
      FocusScope.of(context).unfocus();
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: _unfocus,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add/Update Period Data',
                style: TextStyle(
                  color: Color(0xFFE0F7FA),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Last period date
              const Text(
                'Last Period Start Date',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  _unfocus();
                  _selectDate(context);
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateController,
                    style: const TextStyle(color: Color(0xFFE0F7FA)),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF00B4A0),
                      ),
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
                      filled: true,
                      fillColor: const Color(0xFF0F1A2F).withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cycle duration
              const Text(
                'Cycle Duration',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: cycleDurationController,
                focusNode: cycleFocusNode,
                style: const TextStyle(color: Color(0xFFE0F7FA)),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                    2,
                  ), // Limit to 2 digits (max 99)
                ],
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(periodFocusNode);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.loop, color: Color(0xFF00B4A0)),
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
                  filled: true,
                  fillColor: const Color(0xFF0F1A2F).withOpacity(0.5),
                  hintText: 'Usually 21-35 days',
                  hintStyle: TextStyle(
                    color: const Color(0xFFB0BEC5).withOpacity(0.5),
                  ),
                  errorText: _validateCycleDuration(
                    cycleDurationController.text,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Period duration
              const Text(
                'Period Duration',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: periodDurationController,
                focusNode: periodFocusNode,
                style: const TextStyle(color: Color(0xFFE0F7FA)),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                    1,
                  ), // Limit to 1 digit (max 9)
                ],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _unfocus(),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.opacity,
                    color: Color(0xFF00B4A0),
                  ),
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
                  filled: true,
                  fillColor: const Color(0xFF0F1A2F).withOpacity(0.5),
                  hintText: 'Usually 3-7 days',
                  hintStyle: TextStyle(
                    color: const Color(0xFFB0BEC5).withOpacity(0.5),
                  ),
                  errorText: _validatePeriodDuration(
                    periodDurationController.text,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    _unfocus();

                    // Validate input
                    final cycleDuration = int.tryParse(
                      cycleDurationController.text,
                    );
                    final periodDuration = int.tryParse(
                      periodDurationController.text,
                    );

                    if (cycleDuration == null ||
                        cycleDuration < 21 ||
                        cycleDuration > 35) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a valid cycle duration (21-35)',
                          ),
                        ),
                      );
                      return;
                    }

                    if (periodDuration == null ||
                        periodDuration < 1 ||
                        periodDuration > 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a valid period duration (1-10)',
                          ),
                        ),
                      );
                      return;
                    }

                    // Initialize cycle with user input
                    final success = await cycleRepository.initializeCycle(
                      lastPeriodDate: selectedDate,
                      cycleDuration: cycleDuration,
                      periodDuration: periodDuration,
                    );

                    // Close dialog and refresh screen
                    if (context.mounted) {
                      Navigator.pop(context);

                      // Show a loading indicator while refreshing
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Updating cycle data...'),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      // Refresh the women's health screen with a slight delay
                      // to ensure the loading indicator is shown
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _refreshWomenHealthScreen();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4A0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Validation functions
  String? _validateCycleDuration(String value) {
    if (value.isEmpty) {
      return 'Please enter cycle length';
    }
    final duration = int.tryParse(value);
    if (duration == null) {
      return 'Please enter a number';
    }
    if (duration < 21 || duration > 35) {
      return 'Cycle length should be between 21-35 days';
    }
    return null;
  }

  String? _validatePeriodDuration(String value) {
    if (value.isEmpty) {
      return 'Please enter period duration';
    }
    final duration = int.tryParse(value);
    if (duration == null) {
      return 'Please enter a number';
    }
    if (duration < 1 || duration > 10) {
      return 'Period duration should be between 1-10 days';
    }
    return null;
  }

  Widget _buildExpenseInputForm() {
    // Create focus nodes for text fields
    final descriptionFocusNode = FocusNode();
    final amountFocusNode = FocusNode();

    // Controllers for text fields
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

    // Selected category and date
    String selectedCategory = 'Clothing';
    DateTime selectedDate = DateTime.now();

    // Form validation state
    bool descriptionError = false;
    bool amountError = false;
    String descriptionErrorText = '';
    String amountErrorText = '';

    // Function to unfocus and dismiss keyboard
    void _unfocus() {
      descriptionFocusNode.unfocus();
      amountFocusNode.unfocus();
      FocusScope.of(context).unfocus();
    }

    return StatefulBuilder(
      builder: (context, setState) {
        // Validation functions
        void validateDescription() {
          if (descriptionController.text.isEmpty) {
            setState(() {
              descriptionError = true;
              descriptionErrorText = 'Description cannot be empty';
            });
          } else if (descriptionController.text.length > 50) {
            setState(() {
              descriptionError = true;
              descriptionErrorText = 'Description too long (max 50 characters)';
            });
          } else {
            setState(() {
              descriptionError = false;
              descriptionErrorText = '';
            });
          }
        }

        void validateAmount() {
          if (amountController.text.isEmpty) {
            setState(() {
              amountError = true;
              amountErrorText = 'Amount cannot be empty';
            });
            return;
          }

          final amount = double.tryParse(amountController.text);
          if (amount == null) {
            setState(() {
              amountError = true;
              amountErrorText = 'Please enter a valid number';
            });
          } else if (amount <= 0) {
            setState(() {
              amountError = true;
              amountErrorText = 'Amount must be greater than 0';
            });
          } else if (amount > 1000000) {
            setState(() {
              amountError = true;
              amountErrorText = 'Amount too large';
            });
          } else {
            setState(() {
              amountError = false;
              amountErrorText = '';
            });
          }
        }

        Future<void> _selectDate(BuildContext context) async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF00B4A0),
                    onPrimary: Colors.white,
                    surface: Color(0xFF0F1A2F),
                    onSurface: Color(0xFFE0F7FA),
                  ),
                  dialogBackgroundColor: const Color(0xFF0F1A2F),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            setState(() {
              selectedDate = picked;
            });
          }
        }

        return GestureDetector(
          onTap: _unfocus,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Expense Record',
                style: TextStyle(
                  color: Color(0xFFE0F7FA),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Description field
              const Text(
                'Description',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                focusNode: descriptionFocusNode,
                style: const TextStyle(color: Color(0xFFE0F7FA)),
                textInputAction: TextInputAction.next,
                maxLength: 50,
                onChanged: (_) => validateDescription(),
                onSubmitted: (_) {
                  validateDescription();
                  FocusScope.of(context).requestFocus(amountFocusNode);
                },
                decoration: InputDecoration(
                  hintText: 'Enter description',
                  hintStyle: TextStyle(
                    color: const Color(0xFFB0BEC5).withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0F1A2F).withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: descriptionError
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF00B4A0).withOpacity(0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: descriptionError
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF00B4A0).withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: descriptionError
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF00B4A0),
                    ),
                  ),
                  errorText: descriptionError ? descriptionErrorText : null,
                  errorStyle: const TextStyle(color: Color(0xFFD32F2F)),
                  counterStyle: const TextStyle(color: Color(0xFFB0BEC5)),
                ),
              ),
              const SizedBox(height: 16),

              // Amount field
              const Text(
                'Amount',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                focusNode: amountFocusNode,
                style: const TextStyle(color: Color(0xFFE0F7FA)),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                onChanged: (_) => validateAmount(),
                onSubmitted: (_) {
                  validateAmount();
                  _unfocus();
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  hintStyle: TextStyle(
                    color: const Color(0xFFB0BEC5).withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0F1A2F).withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: amountError
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF00B4A0).withOpacity(0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: amountError
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF00B4A0).withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: amountError
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF00B4A0),
                    ),
                  ),
                  errorText: amountError ? amountErrorText : null,
                  errorStyle: const TextStyle(color: Color(0xFFD32F2F)),
                  prefixText: '¥ ',
                  prefixStyle: const TextStyle(color: Color(0xFFE0F7FA)),
                ),
              ),
              const SizedBox(height: 16),

              // Category dropdown
              const Text(
                'Category',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1A2F).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00B4A0).withOpacity(0.5),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    dropdownColor: const Color(0xFF0F1A2F),
                    style: const TextStyle(color: Color(0xFFE0F7FA)),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF00B4A0),
                    ),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      }
                    },
                    items: <String>['Clothing', 'Shoes', 'Accessories', 'Bags']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date picker
              const Text(
                'Date',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1A2F).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00B4A0).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
                        style: const TextStyle(color: Color(0xFFE0F7FA)),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF00B4A0),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFB0BEC5),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      // Validate all fields before submitting
                      validateDescription();
                      validateAmount();

                      if (!descriptionError && !amountError) {
                        final amount = double.tryParse(amountController.text);
                        if (amount != null) {
                          // Create expense object
                          final expense = Expense(
                            description: descriptionController.text,
                            amount: amount,
                            category: selectedCategory,
                            date: selectedDate,
                          );

                          // Get the FashionExpenseScreen state and add expense
                          final expenseRepository = ExpenseRepository(
                            widget.prefs,
                          );
                          final success = await expenseRepository.addExpense(
                            expense,
                          );

                          if (success) {
                            // Show success message
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Expense added successfully'),
                                  backgroundColor: Color(0xFF00B4A0),
                                ),
                              );
                            }

                            // Refresh the FashionExpenseScreen
                            if (_fashionExpenseScreenKey.currentState != null) {
                              _fashionExpenseScreenKey.currentState!
                                  .refreshData();
                            }

                            Navigator.of(context).pop();
                          } else {
                            // Show error message
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to add expense'),
                                  backgroundColor: Color(0xFFD32F2F),
                                ),
                              );
                            }
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B4A0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemInputForm() {
    // Create focus nodes for text fields
    final nameFocusNode = FocusNode();
    final subLocationFocusNode = FocusNode();

    // Controllers for text fields
    final nameController = TextEditingController();
    final subLocationController = TextEditingController();

    // Default values
    String selectedLocation = 'Bedroom';
    String selectedIcon = 'inventory_2';

    // Form validation state
    bool nameError = false;
    String nameErrorText = '';

    void validateName() {
      if (nameController.text.isEmpty) {
        nameError = true;
        nameErrorText = 'Name cannot be empty';
      } else if (nameController.text.length > 30) {
        nameError = true;
        nameErrorText = 'Name too long (max 30 characters)';
      } else {
        nameError = false;
        nameErrorText = '';
      }
    }

    // Function to unfocus and dismiss keyboard
    void _unfocus() {
      nameFocusNode.unfocus();
      subLocationFocusNode.unfocus();
      FocusScope.of(context).unfocus();
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: _unfocus,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Item',
                style: TextStyle(
                  color: Color(0xFFE0F7FA),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Item name field
              const Text(
                'Item Name',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                focusNode: nameFocusNode,
                style: const TextStyle(color: Color(0xFFE0F7FA)),
                textInputAction: TextInputAction.next,
                maxLength: 30,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                    RegExp(r'^\s'),
                  ), // No leading spaces
                ],
                onChanged: (_) => setState(() => validateName()),
                onSubmitted: (_) {
                  setState(() => validateName());
                  FocusScope.of(context).requestFocus(subLocationFocusNode);
                },
                decoration: InputDecoration(
                  hintText: 'Enter item name',
                  hintStyle: TextStyle(
                    color: const Color(0xFFB0BEC5).withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0F1A2F).withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: nameError
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF00B4A0).withOpacity(0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: nameError
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF00B4A0).withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: nameError
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF00B4A0),
                    ),
                  ),
                  errorText: nameError ? nameErrorText : null,
                  errorStyle: const TextStyle(color: Color(0xFFD32F2F)),
                  counterStyle: const TextStyle(color: Color(0xFFB0BEC5)),
                ),
              ),
              const SizedBox(height: 16),

              // Location dropdown
              const Text(
                'Location',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1A2F).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00B4A0).withOpacity(0.5),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedLocation,
                    dropdownColor: const Color(0xFF0F1A2F),
                    style: const TextStyle(color: Color(0xFFE0F7FA)),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF00B4A0),
                    ),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedLocation = newValue;
                        });
                      }
                    },
                    items: <String>[
                      'Bedroom',
                      'Living Room',
                      'Kitchen',
                      'Closet',
                      'Bathroom',
                      'Study',
                      'Other',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sub-location field
              const Text(
                'Sub-location',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: subLocationController,
                focusNode: subLocationFocusNode,
                style: const TextStyle(color: Color(0xFFE0F7FA)),
                textInputAction: TextInputAction.done,
                maxLength: 30,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                    RegExp(r'^\s'),
                  ), // No leading spaces
                ],
                onSubmitted: (_) => _unfocus(),
                decoration: InputDecoration(
                  hintText: 'Enter sub-location (e.g., drawer, shelf)',
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
              ),
              const SizedBox(height: 16),

              // Icon selection
              const Text(
                'Icon',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2E36).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00B4A0).withOpacity(0.5),
                  ),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _itemIcons.length,
                  itemBuilder: (context, index) {
                    final iconKey = _itemIcons.keys.elementAt(index);
                    final iconData = _itemIcons[iconKey];
                    final isSelected = selectedIcon == iconKey;

                    return InkWell(
                      onTap: () => setState(() => selectedIcon = iconKey),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00B4A0).withOpacity(0.3)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00B4A0)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          iconData,
                          color: isSelected
                              ? const Color(0xFF00B4A0)
                              : const Color(0xFFB0BEC5),
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _unfocus();
                    setState(() => validateName());

                    if (!nameError && nameController.text.isNotEmpty) {
                      // Create new item
                      final newItem = Item(
                        name: nameController.text,
                        location: selectedLocation,
                        subLocation: subLocationController.text.isNotEmpty
                            ? subLocationController.text
                            : '未指定', // Default if empty
                        addedDate: DateTime.now(),
                        icon: selectedIcon,
                      );

                      // Save the item
                      final itemRepository = ItemRepository(widget.prefs);

                      // 先直接添加到UI，然后异步保存到存储
                      if (_currentIndex == 2 &&
                          _storageOrganizerScreenKey?.currentState != null) {
                        // 直接添加到当前界面的状态中
                        _storageOrganizerScreenKey!.currentState!
                            .addItemDirectly(newItem);
                        Navigator.pop(context);
                      }

                      // 异步保存到存储
                      itemRepository.addItem(newItem).then((success) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item added successfully'),
                              backgroundColor: Color(0xFF00B4A0),
                            ),
                          );

                          // 如果不是当前标签页，设置标志，等切换到该标签页时刷新
                          if (_currentIndex != 2) {
                            _needRefreshStorage = true;
                          }
                        } else {
                          // 如果保存失败，通知界面回滚更改
                          if (_currentIndex == 2 &&
                              _storageOrganizerScreenKey?.currentState !=
                                  null) {
                            _storageOrganizerScreenKey!.currentState!
                                .removeItemDirectly(newItem);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to add item'),
                              backgroundColor: Color(0xFFD32F2F),
                            ),
                          );
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4A0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Map of item icons
  final Map<String, IconData> _itemIcons = {
    'inventory_2': Icons.inventory_2,
    'bed': Icons.bed,
    'lightbulb': Icons.lightbulb,
    'watch': Icons.watch,
    'wifi_tethering': Icons.wifi_tethering,
    'book': Icons.book,
    'local_cafe': Icons.local_cafe,
    'kitchen': Icons.kitchen,
    'shopping_bag': Icons.shopping_bag,
    'checkroom': Icons.checkroom,
    'backpack': Icons.backpack,
    'devices': Icons.devices,
    'sports_esports': Icons.sports_esports,
    'fitness_center': Icons.fitness_center,
    'brush': Icons.brush,
  };

  Widget _buildDialogOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A2E36).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00B4A0).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF00B4A0), size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Color(0xFFE0F7FA), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
