import 'package:flutter/material.dart';
import '../shared/app_colors.dart';
import '../shared/app_text_styles.dart';
import '../shared/glass_card_widget.dart';
import '../models/journal_entry.dart';
import 'journal_controller.dart';
import 'ad_test_dialog.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalController _controller = JournalController();
  List<JournalEntry> _entries = [];
  List<JournalEntry> _filteredEntries = [];
  int _streakDays = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  
  // 快速点击相关变量
  int _tapCount = 0;
  DateTime? _lastTapTime;
  static const Duration _tapTimeout = Duration(milliseconds: 2000);
  static const int _requiredTaps = 10;

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _searchController.addListener(_filterEntries);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterEntries);
    _searchController.dispose();
    super.dispose();
  }

  void _filterEntries() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredEntries = _entries;
      });
      return;
    }

    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEntries = _entries.where((entry) {
        return entry.content.toLowerCase().contains(query) ||
            entry.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    });
  }

  // 处理快速点击
  void _handleQuickTap() {
    // 隐藏键盘
    FocusScope.of(context).unfocus();
    
    final now = DateTime.now();
    
    // 如果是第一次点击或距离上次点击时间超过超时时间，重置计数
    if (_lastTapTime == null || 
        now.difference(_lastTapTime!) > _tapTimeout) {
      _tapCount = 1;
      _lastTapTime = now;
      return;
    }
    
    // 增加点击计数
    _tapCount++;
    _lastTapTime = now;
    
    // 如果达到要求的点击次数，显示广告测试dialog
    if (_tapCount >= _requiredTaps) {
      _showAdTestDialog();
      // 重置计数
      _tapCount = 0;
      _lastTapTime = null;
    }
  }

  // 显示广告测试dialog
  void _showAdTestDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 防止点击外部关闭
      builder: (context) => const AdTestDialog(),
    );
  }

  Future<void> _loadEntries() async {
    final entries = await _controller.getEntries();
    final streakDays = await _controller.getStreakDays();
    if (mounted) {
      setState(() {
        _entries = entries;
        _filteredEntries = entries;
        _streakDays = streakDays;
      });
    }
  }

  void _showEntryOptions(JournalEntry entry) {
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
              title: Text('Delete Entry', style: AppTextStyles.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(entry);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.brandDark,
        title: Text('Delete Entry', style: AppTextStyles.headingMedium),
        content: Text(
          'Are you sure you want to delete this entry?',
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
              final success = await _controller.deleteEntry(entry.id);
              if (success && mounted) {
                _loadEntries();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Entry deleted'),
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

  void _showEntryDetails(JournalEntry entry) {
    // Format the date for display
    final DateTime entryDate = entry.timestamp;
    final String formattedDate =
        '${entryDate.year}-${entryDate.month.toString().padLeft(2, '0')}-${entryDate.day.toString().padLeft(2, '0')}';
    final String formattedTime =
        '${entryDate.hour.toString().padLeft(2, '0')}:${entryDate.minute.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.brandDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20.0),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: AppTextStyles.headingMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(entry);
                    },
                  ),
                ],
              ),

              // Category badge
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brandTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  entry.category,
                  style: TextStyle(color: AppColors.brandTeal),
                ),
              ),

              const SizedBox(height: 16),

              // Date and time
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.brandTeal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$formattedDate at $formattedTime',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Rating stars
              Row(
                children: [
                  Text('Rating: ', style: AppTextStyles.bodyMedium),
                  const SizedBox(width: 8),
                  ...List.generate(5, (index) {
                    return Icon(
                      index < entry.rating ? Icons.star : Icons.star_border,
                      color: index < entry.rating
                          ? AppColors.brandTeal
                          : Colors.grey,
                      size: 20,
                    );
                  }),
                ],
              ),

              const SizedBox(height: 24),

              // Content
              Text('Description:',
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(entry.content, style: AppTextStyles.bodyMedium),
              ),

              const SizedBox(height: 24),

              // Tags
              if (entry.tags.isNotEmpty) ...[
                Text('Tags:',
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          backgroundColor: AppColors.brandTeal.withOpacity(0.2),
                          labelStyle: TextStyle(color: AppColors.brandTeal),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEntryDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    final List<String> selectedTags = [];
    String selectedCategory = 'Happy Moment';
    int selectedRating = 3; // Default rating (1-5)

    final List<String> availableTags = [
      'Achievement',
      'Joy',
      'Warmth',
      'Gratitude',
      'Growth',
      'Success',
      'Kindness',
      'Surprise',
      'Learning',
      'Health',
    ];

    final List<String> categories = [
      'Happy Moment',
      'Achievement',
      'Gratitude',
      'Personal Growth',
      'Beautiful Sight',
      'Kindness Received',
      'Kindness Given',
      'Memorable Experience',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.brandDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: StatefulBuilder(
          builder: (context, setState) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Record Good Moment',
                        style: AppTextStyles.headingMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title field
                  Text('Title', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    style: AppTextStyles.bodyLarge,
                    maxLines: 1,
                    maxLength: 50,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Give your moment a title',
                      hintStyle: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: AppColors.glassCardBorder),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category selection
                  Text('Category', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassCardBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        dropdownColor: AppColors.brandDark,
                        style: AppTextStyles.bodyMedium,
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Content field
                  Text('Description', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: contentController,
                    style: AppTextStyles.bodyLarge,
                    maxLines: 5,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText:
                          'What good things happened? How did it make you feel?',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: AppColors.glassCardBorder),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rating
                  Text('How good was this moment? (1-5)',
                      style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final rating = index + 1;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedRating = rating;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            rating <= selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: rating <= selectedRating
                                ? AppColors.brandTeal
                                : Colors.grey,
                            size: 36,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Tags
                  Text('Add Tags', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableTags.map((tag) {
                      final isSelected = selectedTags.contains(tag);
                      return FilterChip(
                        label: Text('#$tag'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedTags.add(tag);
                            } else {
                              selectedTags.remove(tag);
                            }
                          });
                        },
                        backgroundColor: Colors.white.withOpacity(0.05),
                        selectedColor: AppColors.brandTeal.withOpacity(0.3),
                        labelStyle: TextStyle(
                          color:
                              isSelected ? AppColors.brandTeal : Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (titleController.text.trim().isEmpty ||
                              contentController.text.trim().isEmpty)
                          ? null
                          : () async {
                              final title = titleController.text.trim();
                              final content = contentController.text.trim();

                              final newEntry = await _controller.addEntry(
                                title,
                                content,
                                selectedTags.map((tag) => '#$tag').toList(),
                                selectedCategory,
                                selectedRating,
                                null, // No image for now
                              );

                              if (!mounted) return;
                              Navigator.pop(context);

                              if (newEntry != null) {
                                _loadEntries();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Journal entry saved'),
                                    backgroundColor: AppColors.brandTeal,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                        disabledForegroundColor: Colors.grey,
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search entries...',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                ),
              )
            : const Text('Journal', style: AppTextStyles.headingLarge),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                },
              )
            : null,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (!_isSearching)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '$_streakDays Day Streak 🔥',
                  style: TextStyle(
                    color: AppColors.brandTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_isSearching && _searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: GestureDetector(
        // 检测快速点击以显示广告测试dialog
        onTap: _handleQuickTap,
        // Dismiss keyboard when tapping outside input area
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Record your happy moments, achievements, and things to be grateful for. Add details, categorize, and rate your experiences to cultivate positivity.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: _filteredEntries.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isSearching &&
                                            _searchController.text.isNotEmpty
                                        ? Icons.search_off
                                        : Icons.sentiment_satisfied_alt,
                                    size: 64,
                                    color: AppColors.brandTeal,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _isSearching &&
                                            _searchController.text.isNotEmpty
                                        ? 'No results found for "${_searchController.text}"'
                                        : 'No entries yet. Start recording good moments!',
                                    style: AppTextStyles.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredEntries.length,
                              itemBuilder: (context, index) {
                                final entry = _filteredEntries[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () => _showEntryDetails(entry),
                                      onLongPress: () =>
                                          _showEntryOptions(entry),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  entry.title,
                                                  style: AppTextStyles.bodyLarge
                                                      .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.brandTeal
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  entry.category,
                                                  style: AppTextStyles.bodySmall
                                                      .copyWith(
                                                    color: AppColors.brandTeal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            entry.content,
                                            style: AppTextStyles.bodyMedium,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              // Rating stars
                                              Row(
                                                children:
                                                    List.generate(5, (index) {
                                                  return Icon(
                                                    index < entry.rating
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    color: index < entry.rating
                                                        ? AppColors.brandTeal
                                                        : Colors.grey,
                                                    size: 16,
                                                  );
                                                }),
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                '·',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                entry.getFormattedTime(),
                                                style: AppTextStyles.bodySmall,
                                              ),
                                              if (entry.tags.isNotEmpty) ...[
                                                const SizedBox(width: 8),
                                                const Text(
                                                  '·',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    entry.tags
                                                        .take(2)
                                                        .join(' '),
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.brandTeal,
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
        backgroundColor: AppColors.brandTeal,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
