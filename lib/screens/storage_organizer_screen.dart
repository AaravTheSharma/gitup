import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/item_repository.dart';
import '../models/item_model.dart';
import '../widgets/pie_chart_widget.dart';

class StorageOrganizerScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const StorageOrganizerScreen({Key? key, required this.prefs})
    : super(key: key);

  @override
  State<StorageOrganizerScreen> createState() => StorageOrganizerScreenState();
}

class StorageOrganizerScreenState extends State<StorageOrganizerScreen> {
  late ItemRepository _itemRepository;
  List<Item> _items = [];
  List<Item> _filteredItems = [];
  List<Item> _recentItems = [];
  Map<String, double> _locationPercentages = {};
  int _totalItemCount = 0;
  int _recentItemCount = 0;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedLocation = 'All'; // Default to show all locations

  @override
  void initState() {
    super.initState();
    _itemRepository = ItemRepository(widget.prefs);
    _loadItemData();

    _searchController.addListener(() {
      _searchItems(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Function to unfocus and dismiss keyboard
  void _unfocus() {
    _searchFocusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  // Public method to refresh data from outside
  Future<void> refreshData() async {
    if (mounted) {
      // 先立即更新UI状态为加载中
      setState(() {
        _isLoading = true;
      });

      // 使用微任务确保状态更新后再加载数据
      Future.microtask(() async {
        // 获取所有物品
        _items = await _itemRepository.getAllItems();

        // 获取最近添加的物品
        _recentItems = await _itemRepository.getRecentlyAddedItems(limit: 4);

        // 获取位置百分比
        _locationPercentages = await _itemRepository.getLocationPercentages();

        // 获取物品数量
        _totalItemCount = await _itemRepository.getTotalItemCount();
        _recentItemCount = await _itemRepository.getRecentItemCount();

        // 应用筛选
        _filterItems();

        // 如果组件仍然挂载，更新UI
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  Future<void> _loadItemData() async {
    setState(() {
      _isLoading = true;
    });

    // Get all items
    _items = await _itemRepository.getAllItems();

    // Get recently added items
    _recentItems = await _itemRepository.getRecentlyAddedItems(limit: 4);

    // Get location percentages for pie chart
    _locationPercentages = await _itemRepository.getLocationPercentages();

    // Get item counts
    _totalItemCount = await _itemRepository.getTotalItemCount();
    _recentItemCount = await _itemRepository.getRecentItemCount();

    // Apply location filter
    _filterItems();

    setState(() {
      _isLoading = false;
    });
  }

  void _filterItems() {
    if (_selectedLocation == 'All') {
      _filteredItems = _items;
    } else {
      _filteredItems = _items
          .where((item) => item.location == _selectedLocation)
          .toList();
    }

    // Apply search query if exists
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      _filteredItems = _filteredItems.where((item) {
        return item.name.toLowerCase().contains(query) ||
            item.location.toLowerCase().contains(query) ||
            item.subLocation.toLowerCase().contains(query);
      }).toList();
    }
  }

  Future<void> _searchItems(String query) async {
    setState(() {
      _isLoading = true;
    });

    // Apply filtering
    _filterItems();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocus,
      child: Scaffold(
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildStatCards(),
                        const SizedBox(height: 24),
                        Center(
                          child: PieChartWidget(
                            locationPercentages: _locationPercentages,
                            totalItems: _totalItemCount, // 传入实际物品总数
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSearchBar(),
                        const SizedBox(height: 20),
                        _buildLocationFilter(),
                        const SizedBox(height: 24),
                        _buildRecentlyAdded(),
                        const SizedBox(height: 24),
                        _buildAllItems(),
                      ],
                    ),
                  ),
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddItemDialog(),
          backgroundColor: const Color(0xFF00B4A0),
          foregroundColor: Colors.white,
          elevation: 8,
          child: const Icon(Icons.add),
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
              'Storage House',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Manage and organize your items',
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
            Icons.inventory_2,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildAllItems() {
    if (_filteredItems.isEmpty) {
      return _buildEmptyState('No items found');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'All Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0F7FA),
              ),
            ),
            Text(
              '${_filteredItems.length} items',
              style: const TextStyle(fontSize: 14, color: Color(0xFFB0BEC5)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredItems.length,
          itemBuilder: (context, index) {
            final item = _filteredItems[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildItemCard(item),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A2F).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00B4A0).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: const Color(0xFFB0BEC5).withOpacity(0.5),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: const Color(0xFFB0BEC5).withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Item item) {
    return InkWell(
      onTap: () => _showItemDetailDialog(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF00B4A0).withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF00B4A0).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00B4A0).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                _getIconForName(item.icon),
                color: const Color(0xFF00B4A0),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE0F7FA),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getLocationColor(
                            item.location,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _getLocationColor(
                              item.location,
                            ).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          item.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getLocationColor(item.location),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.subLocation,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB0BEC5),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLocationColor(String location) {
    switch (location) {
      case 'Bedroom':
        return const Color(0xFF00B4A0); // teal
      case 'Living Room':
        return const Color(0xFF00C9B8); // lighter teal
      case 'Kitchen':
        return const Color(0xFF00A896); // darker teal
      case 'Closet':
        return const Color(0xFF00897B); // even darker teal
      case 'Bathroom':
        return const Color(0xFF26A69A); // another teal shade
      case 'Study':
        return const Color(0xFF009688); // another teal shade
      case 'Other':
        return const Color(0xFF00695C); // darkest teal
      default:
        return const Color(0xFFB0BEC5); // default gray
    }
  }

  Widget _buildRecentlyAdded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recently Added',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            Text(
              '${_recentItems.length} items',
              style: const TextStyle(fontSize: 14, color: Color(0xFFB0BEC5)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _recentItems.isEmpty
            ? _buildEmptyState('No recently added items')
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: _recentItems.length,
                itemBuilder: (context, index) {
                  final item = _recentItems[index];
                  return _buildItemCard(item);
                },
              ),
      ],
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Total Items', _totalItemCount.toString()),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('New Items', _recentItemCount.toString()),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F1A2F).withOpacity(0.7),
            const Color(0xFF0A2E36).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF00B4A0).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00B4A0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFFB0BEC5)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A2F).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00B4A0).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF00B4A0), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(color: Color(0xFFE0F7FA)),
              textInputAction: TextInputAction.search,
              maxLength: 30,
              onSubmitted: (_) {
                _unfocus();
                _searchItems(_searchController.text);
              },
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-Z0-9\u4e00-\u9fa5 _\-.,]'),
                ),
              ],
              decoration: InputDecoration(
                hintText: 'Search items...',
                hintStyle: TextStyle(
                  color: const Color(0xFFB0BEC5).withOpacity(0.7),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                counterText: '',
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Color(0xFFB0BEC5),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchItems('');
                          });
                          _unfocus();
                        },
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFilter() {
    // 使用与弹窗相同的位置选项，确保一致性
    final locations = [
      'All',
      'Bedroom',
      'Living Room',
      'Kitchen',
      'Wardrobe',
      'Bathroom',
      'Study',
      'Others',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Filter by Location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFFE0F7FA),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1A2F).withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF00B4A0).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: locations.map((location) {
                final isSelected =
                    _selectedLocation == _getChineseLocation(location);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: FilterChip(
                      label: Text(location),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedLocation = _getChineseLocation(location);
                          });
                          _filterItems();
                        }
                      },
                      backgroundColor: const Color(0xFF0A2E36).withOpacity(0.5),
                      selectedColor: const Color(0xFF00B4A0).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF00B4A0),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF00B4A0)
                            : const Color(0xFFE0F7FA),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF00B4A0)
                              : const Color(0xFF00B4A0).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // 添加辅助方法来转换中英文位置
  String _getChineseLocation(String englishLocation) {
    switch (englishLocation) {
      case 'All':
        return 'All';
      case 'Bedroom':
        return '卧室';
      case 'Living Room':
        return '客厅';
      case 'Kitchen':
        return '厨房';
      case 'Wardrobe':
        return '衣帽间';
      case 'Bathroom':
        return '浴室';
      case 'Study':
        return '书房';
      case 'Others':
        return '其他';
      default:
        return englishLocation;
    }
  }

  // 添加辅助方法来转换英文位置
  String _getEnglishLocation(String chineseLocation) {
    switch (chineseLocation) {
      case 'All':
        return 'All';
      case '卧室':
        return 'Bedroom';
      case '客厅':
        return 'Living Room';
      case '厨房':
        return 'Kitchen';
      case '衣帽间':
        return 'Wardrobe';
      case '浴室':
        return 'Bathroom';
      case '书房':
        return 'Study';
      case '其他':
        return 'Others';
      default:
        return chineseLocation;
    }
  }

  // 直接添加物品到UI，不经过存储操作
  void addItemDirectly(Item item) {
    if (mounted) {
      setState(() {
        // 添加到物品列表
        _items = [..._items, item];

        // 更新最近添加的物品
        _recentItems = [item, ..._recentItems.take(3)];

        // 更新计数
        _totalItemCount++;
        _recentItemCount++;

        // 更新位置百分比
        _recalculateLocationPercentages();

        // 应用筛选
        _filterItems();
      });
    }
  }

  // 从UI中移除物品，用于回滚操作
  void removeItemDirectly(Item item) {
    if (mounted) {
      setState(() {
        // 从物品列表中移除
        _items.removeWhere(
          (i) =>
              i.name == item.name &&
              i.location == item.location &&
              i.subLocation == item.subLocation &&
              i.addedDate.isAtSameMomentAs(item.addedDate),
        );

        // 从最近添加列表中移除
        _recentItems.removeWhere(
          (i) =>
              i.name == item.name &&
              i.location == item.location &&
              i.subLocation == item.subLocation &&
              i.addedDate.isAtSameMomentAs(item.addedDate),
        );

        // 更新计数
        _totalItemCount = _items.length;
        _recentItemCount = _items
            .where(
              (i) => i.addedDate.isAfter(
                DateTime.now().subtract(const Duration(days: 30)),
              ),
            )
            .length;

        // 更新位置百分比
        _recalculateLocationPercentages();

        // 应用筛选
        _filterItems();
      });
    }
  }

  void _showItemDetailDialog(Item item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1A2F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                _getIconForName(item.icon),
                color: const Color(0xFF00B4A0),
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    color: Color(0xFFE0F7FA),
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Location', _getEnglishLocation(item.location)),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Sub-location',
                item.subLocation == '未指定' ? 'Unspecified' : item.subLocation,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Added Date',
                '${item.addedDate.year}/${item.addedDate.month}/${item.addedDate.day}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _confirmDeleteItem(item),
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFD32F2F)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditItemDialog(item);
              },
              child: const Text(
                'Edit',
                style: TextStyle(color: Color(0xFF00B4A0)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFFB0BEC5)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB0BEC5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Color(0xFFE0F7FA))),
        ),
      ],
    );
  }

  IconData _getIconForName(String iconName) {
    switch (iconName) {
      case 'bed':
        return Icons.bed;
      case 'light':
        return Icons.lightbulb;
      case 'watch':
        return Icons.watch;
      case 'remote':
        return Icons.wifi_tethering; // Changed to an existing icon
      case 'book':
        return Icons.book;
      case 'coffee':
        return Icons.local_cafe; // Changed from coffee to local_cafe
      case 'kitchen':
        return Icons.kitchen;
      case 'scarf':
        return Icons.shopping_bag;
      case 'pants':
        return Icons.checkroom;
      case 'backpack':
        return Icons.backpack;
      default:
        return Icons.inventory_2;
    }
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final nameFocusNode = FocusNode();
    final subLocationController = TextEditingController();
    final subLocationFocusNode = FocusNode();
    String selectedLocation = 'Bedroom'; // Default location in English
    String selectedIcon = 'inventory_2'; // Default icon

    // 使用与编辑弹窗相同的位置选项列表
    final List<String> allLocations = [
      'Bedroom',
      'Living Room',
      'Kitchen',
      'Wardrobe',
      'Bathroom',
      'Study',
      'Others',
    ];

    // Form validation state
    bool nameError = false;
    String nameErrorText = '';

    void validateName() {
      if (nameController.text.isEmpty) {
        setState(() {
          nameError = true;
          nameErrorText = 'Name cannot be empty';
        });
      } else if (nameController.text.length > 30) {
        setState(() {
          nameError = true;
          nameErrorText = 'Name too long (max 30 characters)';
        });
      } else {
        setState(() {
          nameError = false;
          nameErrorText = '';
        });
      }
    }

    // Function to unfocus and dismiss keyboard in dialog
    void _dialogUnfocus() {
      nameFocusNode.unfocus();
      subLocationFocusNode.unfocus();
      FocusScope.of(context).unfocus();
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: _dialogUnfocus,
              child: AlertDialog(
                backgroundColor: const Color(0xFF0F1A2F),
                title: const Text(
                  'Add New Item',
                  style: TextStyle(color: Color(0xFFE0F7FA)),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item name field
                        const Text(
                          'Item Name',
                          style: TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 14,
                          ),
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
                            FocusScope.of(
                              context,
                            ).requestFocus(subLocationFocusNode);
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter item name',
                            hintStyle: TextStyle(
                              color: const Color(0xFFB0BEC5).withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0A2E36).withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: nameError
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFF00B4A0).withOpacity(0.5),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: nameError
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFF00B4A0).withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: nameError
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFF00B4A0),
                              ),
                            ),
                            errorText: nameError ? nameErrorText : null,
                            errorStyle: const TextStyle(
                              color: Color(0xFFD32F2F),
                            ),
                            counterStyle: const TextStyle(
                              color: Color(0xFFB0BEC5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Location dropdown
                        const Text(
                          'Location',
                          style: TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A2E36).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
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
                              items: allLocations.map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Sub-location field
                        const Text(
                          'Sub-location',
                          style: TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 14,
                          ),
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
                          onSubmitted: (_) => _dialogUnfocus(),
                          decoration: InputDecoration(
                            hintText:
                                'Enter sub-location (e.g., drawer, shelf)',
                            hintStyle: TextStyle(
                              color: const Color(0xFFB0BEC5).withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0A2E36).withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color(0xFF00B4A0).withOpacity(0.5),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color(0xFF00B4A0).withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF00B4A0),
                              ),
                            ),
                            counterStyle: const TextStyle(
                              color: Color(0xFFB0BEC5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Icon selection
                        const Text(
                          'Icon',
                          style: TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: _buildIconSelector(selectedIcon, (icon) {
                            setState(() {
                              selectedIcon = icon;
                            });
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _dialogUnfocus();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFFB0BEC5)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _dialogUnfocus();
                      validateName();

                      if (!nameError && nameController.text.isNotEmpty) {
                        final newItem = Item(
                          name: nameController.text,
                          location: _getChineseLocation(selectedLocation),
                          subLocation: subLocationController.text.isNotEmpty
                              ? subLocationController.text
                              : 'Unspecified', // Default if empty
                          addedDate: DateTime.now(),
                          icon: selectedIcon,
                        );

                        _addItem(newItem);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Color(0xFF00B4A0)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIconSelector(
    String selectedIcon,
    Function(String) onIconSelected,
  ) {
    final icons = {
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

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF0A2E36).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00B4A0).withOpacity(0.5)),
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
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final iconKey = icons.keys.elementAt(index);
          final iconData = icons[iconKey];
          final isSelected = selectedIcon == iconKey;

          return InkWell(
            onTap: () => onIconSelected(iconKey),
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
    );
  }

  Future<void> _addItem(Item item) async {
    setState(() {
      // 先乐观地更新UI，假设添加成功
      _items = [..._items, item];
      _recentItems = [item, ..._recentItems.take(3)];
      _totalItemCount++;
      _recentItemCount++;

      // 更新位置百分比
      final locationCount = _items
          .where((i) => i.location == item.location)
          .length;
      final totalCount = _items.length;
      _locationPercentages = Map.from(_locationPercentages);
      _locationPercentages[item.location] = (locationCount / totalCount) * 100;

      // 应用筛选
      _filterItems();
    });

    // 异步保存到存储
    final success = await _itemRepository.addItem(item);

    if (!success && mounted) {
      // 如果保存失败，回滚UI更改
      setState(() {
        _items.remove(item);
        _recentItems.remove(item);
        _totalItemCount--;
        _recentItemCount--;

        // 重新加载正确的数据
        _loadItemData();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add item'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item added successfully'),
          backgroundColor: Color(0xFF00B4A0),
        ),
      );
    }
  }

  void _showEditItemDialog(Item item) {
    final nameController = TextEditingController(text: item.name);
    final nameFocusNode = FocusNode();
    final subLocationController = TextEditingController(
      text: item.subLocation == '未指定' ? 'Unspecified' : item.subLocation,
    );
    final subLocationFocusNode = FocusNode();
    String selectedLocation = item.location;
    String selectedIcon = item.icon;

    // 定义所有可能的位置选项，确保包含当前项的位置
    final List<String> allLocations = [
      'Bedroom',
      'Living Room',
      'Kitchen',
      'Wardrobe',
      'Bathroom',
      'Study',
      'Others',
    ];

    // 如果当前项的位置不在预定义列表中，添加它
    if (!allLocations.contains(_getEnglishLocation(selectedLocation))) {
      allLocations.add(_getEnglishLocation(selectedLocation));
    }

    // Form validation state
    bool nameError = false;
    String nameErrorText = '';

    void validateName() {
      if (nameController.text.isEmpty) {
        setState(() {
          nameError = true;
          nameErrorText = 'Name cannot be empty';
        });
      } else if (nameController.text.length > 30) {
        setState(() {
          nameError = true;
          nameErrorText = 'Name too long (max 30 characters)';
        });
      } else {
        setState(() {
          nameError = false;
          nameErrorText = '';
        });
      }
    }

    // Function to unfocus and dismiss keyboard in dialog
    void _dialogUnfocus() {
      nameFocusNode.unfocus();
      subLocationFocusNode.unfocus();
      FocusScope.of(context).unfocus();
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: _dialogUnfocus,
              child: AlertDialog(
                backgroundColor: const Color(0xFF0F1A2F),
                title: const Text(
                  'Edit Item',
                  style: TextStyle(color: Color(0xFFE0F7FA)),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item name field
                        const Text(
                          'Item Name',
                          style: TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 14,
                          ),
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
                            FocusScope.of(
                              context,
                            ).requestFocus(subLocationFocusNode);
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter item name',
                            hintStyle: TextStyle(
                              color: const Color(0xFFB0BEC5).withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0A2E36).withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: nameError
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFF00B4A0).withOpacity(0.5),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: nameError
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFF00B4A0).withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: nameError
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFF00B4A0),
                              ),
                            ),
                            errorText: nameError ? nameErrorText : null,
                            errorStyle: const TextStyle(
                              color: Color(0xFFD32F2F),
                            ),
                            counterStyle: const TextStyle(
                              color: Color(0xFFB0BEC5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Location dropdown
                        const Text(
                          'Location',
                          style: TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A2E36).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00B4A0).withOpacity(0.5),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _getEnglishLocation(selectedLocation),
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
                                    selectedLocation = _getChineseLocation(
                                      newValue,
                                    );
                                  });
                                }
                              },
                              items: allLocations.map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Sub-location field
                        const Text(
                          'Sub-location',
                          style: TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 14,
                          ),
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
                          onSubmitted: (_) => _dialogUnfocus(),
                          decoration: InputDecoration(
                            hintText:
                                'Enter sub-location (e.g., drawer, shelf)',
                            hintStyle: TextStyle(
                              color: const Color(0xFFB0BEC5).withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0A2E36).withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color(0xFF00B4A0).withOpacity(0.5),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: const Color(0xFF00B4A0).withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF00B4A0),
                              ),
                            ),
                            counterStyle: const TextStyle(
                              color: Color(0xFFB0BEC5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Icon selection
                        const Text(
                          'Icon',
                          style: TextStyle(
                            color: Color(0xFFB0BEC5),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: _buildIconSelector(selectedIcon, (icon) {
                            setState(() {
                              selectedIcon = icon;
                            });
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _dialogUnfocus();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFFB0BEC5)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _dialogUnfocus();
                      validateName();

                      if (!nameError && nameController.text.isNotEmpty) {
                        final updatedItem = Item(
                          name: nameController.text,
                          location: selectedLocation,
                          subLocation: subLocationController.text.isNotEmpty
                              ? subLocationController.text
                              : 'Unspecified', // Default if empty
                          addedDate: item.addedDate, // Keep original date
                          icon: selectedIcon,
                        );

                        _updateItem(item, updatedItem);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(color: Color(0xFF00B4A0)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateItem(Item oldItem, Item newItem) async {
    // 保存旧状态以便回滚
    final oldItems = List<Item>.from(_items);
    final oldRecentItems = List<Item>.from(_recentItems);
    final oldLocationPercentages = Map<String, double>.from(
      _locationPercentages,
    );

    setState(() {
      // 乐观地更新UI
      final index = _items.indexWhere(
        (item) =>
            item.name == oldItem.name &&
            item.location == oldItem.location &&
            item.subLocation == oldItem.subLocation &&
            item.addedDate.isAtSameMomentAs(oldItem.addedDate),
      );

      if (index != -1) {
        _items[index] = newItem;

        // 更新最近添加的物品
        final recentIndex = _recentItems.indexWhere(
          (item) =>
              item.name == oldItem.name &&
              item.location == oldItem.location &&
              item.subLocation == oldItem.subLocation &&
              item.addedDate.isAtSameMomentAs(oldItem.addedDate),
        );

        if (recentIndex != -1) {
          _recentItems[recentIndex] = newItem;
        }

        // 重新计算位置百分比
        _recalculateLocationPercentages();

        // 应用筛选
        _filterItems();
      }
    });

    // 异步保存到存储
    final success = await _itemRepository.updateItem(oldItem, newItem);

    if (!success && mounted) {
      // 如果保存失败，回滚UI更改
      setState(() {
        _items = oldItems;
        _recentItems = oldRecentItems;
        _locationPercentages = oldLocationPercentages;

        // 应用筛选
        _filterItems();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update item'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item updated successfully'),
          backgroundColor: Color(0xFF00B4A0),
        ),
      );
    }
  }

  // 重新计算位置百分比
  void _recalculateLocationPercentages() {
    final locationCounts = <String, int>{};
    final totalCount = _items.length;

    // 计算每个位置的物品数量
    for (final item in _items) {
      locationCounts[item.location] = (locationCounts[item.location] ?? 0) + 1;
    }

    // 计算百分比
    _locationPercentages = {};
    locationCounts.forEach((location, count) {
      _locationPercentages[location] = (count / totalCount) * 100;
    });
  }

  Future<void> _deleteItem(Item item) async {
    // 保存旧状态以便回滚
    final oldItems = List<Item>.from(_items);
    final oldRecentItems = List<Item>.from(_recentItems);
    final oldTotalItemCount = _totalItemCount;
    final oldRecentItemCount = _recentItemCount;
    final oldLocationPercentages = Map<String, double>.from(
      _locationPercentages,
    );

    setState(() {
      // 乐观地更新UI
      _items.removeWhere(
        (i) =>
            i.name == item.name &&
            i.location == item.location &&
            i.subLocation == item.subLocation &&
            i.addedDate.isAtSameMomentAs(item.addedDate),
      );

      _recentItems.removeWhere(
        (i) =>
            i.name == item.name &&
            i.location == item.location &&
            i.subLocation == item.subLocation &&
            i.addedDate.isAtSameMomentAs(item.addedDate),
      );

      _totalItemCount = _items.length;
      _recentItemCount = _items
          .where(
            (i) => i.addedDate.isAfter(
              DateTime.now().subtract(const Duration(days: 30)),
            ),
          )
          .length;

      // 重新计算位置百分比
      _recalculateLocationPercentages();

      // 应用筛选
      _filterItems();
    });

    // 异步保存到存储
    final success = await _itemRepository.deleteItemByReference(item);

    if (!success && mounted) {
      // 如果保存失败，回滚UI更改
      setState(() {
        _items = oldItems;
        _recentItems = oldRecentItems;
        _totalItemCount = oldTotalItemCount;
        _recentItemCount = oldRecentItemCount;
        _locationPercentages = oldLocationPercentages;

        // 应用筛选
        _filterItems();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete item'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item deleted successfully'),
          backgroundColor: Color(0xFF00B4A0),
        ),
      );
    }
  }

  void _confirmDeleteItem(Item item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F1A2F),
          title: const Text(
            'Confirm Delete',
            style: TextStyle(color: Color(0xFFE0F7FA)),
          ),
          content: Text(
            'Are you sure you want to delete "${item.name}"?',
            style: const TextStyle(color: Color(0xFFB0BEC5)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFFB0BEC5)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation dialog
                Navigator.of(context).pop(); // Close detail dialog
                _deleteItem(item);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFD32F2F)),
              ),
            ),
          ],
        );
      },
    );
  }
}
