import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/expense_repository.dart';
import '../models/expense_model.dart';
import '../widgets/expense_chart_widget.dart';

class FashionExpenseScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const FashionExpenseScreen({Key? key, required this.prefs}) : super(key: key);

  @override
  FashionExpenseScreenState createState() => FashionExpenseScreenState();
}

class FashionExpenseScreenState extends State<FashionExpenseScreen> {
  late ExpenseRepository _expenseRepository;
  List<Expense> _expenses = [];
  List<Expense> _currentMonthExpenses = [];
  DateTime _selectedMonth = DateTime.now();
  Map<String, double> _categoryTotals = {};
  double _monthTotal = 0;
  double _monthlyChange = 0;
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Focus nodes for input fields
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _expenseRepository = ExpenseRepository(widget.prefs);
    _loadExpenseData();
  }

  // Public method to refresh data from outside
  void refreshData() {
    if (mounted) {
      _loadExpenseData();
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _amountFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Function to unfocus and dismiss keyboard
  void _unfocus() {
    _searchFocusNode.unfocus();
    _descriptionFocusNode.unfocus();
    _amountFocusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  Future<void> _loadExpenseData() async {
    setState(() {
      _isLoading = true;
    });

    // Get all expenses
    _expenses = await _expenseRepository.getAllExpenses();

    // Get expenses for selected month
    _currentMonthExpenses = await _expenseRepository.getMonthExpenses(
      _selectedMonth,
    );

    // Calculate totals for selected month
    _categoryTotals = await _expenseRepository.getCategoryTotals(
      _selectedMonth,
    );
    _monthTotal = await _expenseRepository.getMonthTotal(_selectedMonth);
    _monthlyChange = await _expenseRepository.getMonthlyChangePercentage(
      _selectedMonth,
    );

    setState(() {
      _isLoading = false;
    });
  }

  void _changeMonth(int months) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + months,
      );
      _selectedCategory = 'All';
    });
    _loadExpenseData();
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  List<Expense> get _filteredExpenses {
    List<Expense> result = _currentMonthExpenses;

    // Filter by category
    if (_selectedCategory != 'All') {
      result = result.where((expense) {
        // Handle both English and Chinese categories
        return expense.category == _selectedCategory ||
            _translateCategory(expense.category) == _selectedCategory;
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((expense) {
        final description = expense.description.toLowerCase();
        final category = _translateCategory(expense.category).toLowerCase();
        final amount = expense.amount.toString();

        return description.contains(query) ||
            category.contains(query) ||
            amount.contains(query);
      }).toList();
    }

    // Sort by date (newest first)
    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  // Helper method to translate categories
  String _translateCategory(String category) {
    switch (category) {
      case '服装':
        return 'Clothing';
      case '鞋子':
        return 'Shoes';
      case '首饰':
        return 'Accessories';
      case '包':
        return 'Bags';
      default:
        return category;
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
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildSearchBar(),
                        const SizedBox(height: 20),
                        _buildCategoryIcons(),
                        const SizedBox(height: 20),
                        ExpenseChartWidget(categoryTotals: _categoryTotals),
                        const SizedBox(height: 20),
                        _buildMonthSummary(),
                        const SizedBox(height: 20),
                        _buildMonthSelector(),
                        const SizedBox(height: 20),
                        _buildCategoryFilter(),
                        const SizedBox(height: 10),
                        _buildExpenseList(),
                      ],
                    ),
                  ),
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddExpenseDialog(),
          backgroundColor: const Color(0xFF00B4A0),
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
              'Fashion Expense Tracker',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Track your fashion spending',
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
            Icons.style,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A2F),
        borderRadius: BorderRadius.circular(16),
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
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: const TextStyle(color: Color(0xFFE0F7FA)),
        maxLength: 50,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _unfocus(),
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'^\s')), // No leading spaces
        ],
        decoration: InputDecoration(
          hintText: 'Search expenses...',
          hintStyle: TextStyle(color: const Color(0xFFB0BEC5).withOpacity(0.7)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00B4A0)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFFB0BEC5)),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          counterText: '', // Hide the character counter
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildCategoryIcons() {
    final categories = {
      'Clothing': Icons.checkroom,
      'Shoes': Icons.shopping_bag,
      'Accessories': Icons.auto_awesome,
      'Bags': Icons.shopping_bag,
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: categories.entries.map((entry) {
        return _buildCategoryIcon(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildCategoryIcon(String name, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 14, color: Color(0xFFB0BEC5)),
        ),
      ],
    );
  }

  Widget _buildMonthSummary() {
    final isPositiveChange = _monthlyChange <= 0;
    final changeText =
        '${isPositiveChange ? "↓" : "↑"}${_monthlyChange.abs().toStringAsFixed(0)}%';
    final changeColor = isPositiveChange
        ? const Color(0xFF4CAF50)
        : const Color(0xFFD32F2F);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Expenses',
              style: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5)),
            ),
            const SizedBox(height: 4),
            Text(
              '¥${_monthTotal.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00B4A0),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'vs Last Month',
              style: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5)),
            ),
            const SizedBox(height: 4),
            Text(
              changeText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: changeColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _changeMonth(-1),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_left,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Text(
          '${months[_selectedMonth.month - 1]} ${_selectedMonth.year}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFE0F7FA),
          ),
        ),
        GestureDetector(
          onTap: () => _changeMonth(1),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', 'Clothing', 'Shoes', 'Accessories', 'Bags'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter by Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFE0F7FA),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      _filterByCategory(category);
                    }
                  },
                  backgroundColor: const Color(0xFF0F1A2F),
                  selectedColor: const Color(0xFF00B4A0).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF00B4A0),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? const Color(0xFF00B4A0)
                        : const Color(0xFFE0F7FA),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseList() {
    if (_filteredExpenses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0),
          child: Text(
            'No expenses found for this month and category',
            style: TextStyle(color: Color(0xFFB0BEC5)),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expense Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFE0F7FA),
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredExpenses.length,
          itemBuilder: (context, index) {
            final expense = _filteredExpenses[index];
            return _buildExpenseItem(expense);
          },
        ),
      ],
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    final formattedDate =
        '${expense.date.month}/${expense.date.day}/${expense.date.year}';
    final category = _translateCategory(expense.category);

    return Dismissible(
      key: Key('${expense.description}-${expense.amount}-$formattedDate'),
      background: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD32F2F),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F1A2F),
              title: const Text(
                'Confirm Delete',
                style: TextStyle(color: Color(0xFFE0F7FA)),
              ),
              content: Text(
                'Are you sure you want to delete "${expense.description}" (¥${expense.amount.toStringAsFixed(0)})?',
                style: const TextStyle(color: Color(0xFFB0BEC5)),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFFB0BEC5)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Color(0xFFD32F2F)),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteExpense(expense);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.transparent,
        child: Container(
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
            border: Border.all(
              color: const Color(0xFF00B4A0).withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showEditExpenseDialog(expense),
            splashColor: const Color(0xFF00B4A0).withOpacity(0.1),
            highlightColor: const Color(0xFF00B4A0).withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B4A0).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(category),
                          color: const Color(0xFF00B4A0),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Description and details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.description,
                              style: const TextStyle(
                                color: Color(0xFFE0F7FA),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF00B4A0,
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      color: Color(0xFF00B4A0),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12,
                                  color: const Color(0xFFB0BEC5),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    color: Color(0xFFB0BEC5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Amount
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1A2F),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF00B4A0).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '¥${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF00B4A0),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Edit hint
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 12,
                            color: const Color(0xFFB0BEC5).withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tap to edit',
                            style: TextStyle(
                              color: const Color(0xFFB0BEC5).withOpacity(0.7),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.swipe_left,
                            size: 12,
                            color: const Color(0xFFB0BEC5).withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Swipe to delete',
                            style: TextStyle(
                              color: const Color(0xFFB0BEC5).withOpacity(0.7),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
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

  Future<void> _deleteExpense(Expense expense) async {
    final success = await _expenseRepository.deleteExpense(expense);

    if (success) {
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense deleted successfully'),
            backgroundColor: Color(0xFF00B4A0),
          ),
        );
      }

      // Reload data
      await _loadExpenseData();
    } else {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete expense'),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  void _showAddExpenseDialog() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Clothing';
    DateTime selectedDate = DateTime.now();

    // Form validation state
    bool descriptionError = false;
    bool amountError = false;
    String descriptionErrorText = '';
    String amountErrorText = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  descriptionErrorText =
                      'Description too long (max 50 characters)';
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

            return GestureDetector(
              onTap: _unfocus,
              child: AlertDialog(
                backgroundColor: const Color(0xFF0F1A2F),
                title: const Text(
                  'Add New Expense',
                  style: TextStyle(color: Color(0xFFE0F7FA)),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description field
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: Color(0xFFB0BEC5),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        focusNode: _descriptionFocusNode,
                        style: const TextStyle(color: Color(0xFFE0F7FA)),
                        textInputAction: TextInputAction.next,
                        maxLength: 50,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(
                            RegExp(r'^\s'),
                          ), // No leading spaces
                          LengthLimitingTextInputFormatter(50),
                        ],
                        onChanged: (_) => validateDescription(),
                        onSubmitted: (_) {
                          validateDescription();
                          FocusScope.of(context).requestFocus(_amountFocusNode);
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter description',
                          hintStyle: TextStyle(
                            color: const Color(0xFFB0BEC5).withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0A2E36).withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: descriptionError
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFF00B4A0).withOpacity(0.5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: descriptionError
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFF00B4A0).withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: descriptionError
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFF00B4A0),
                            ),
                          ),
                          errorText: descriptionError
                              ? descriptionErrorText
                              : null,
                          errorStyle: const TextStyle(color: Color(0xFFD32F2F)),
                          counterStyle: const TextStyle(
                            color: Color(0xFFB0BEC5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Amount field
                      const Text(
                        'Amount',
                        style: TextStyle(
                          color: Color(0xFFB0BEC5),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        focusNode: _amountFocusNode,
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
                          // Only allow digits and up to 2 decimal places
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                          // Limit total length to prevent overflow
                          LengthLimitingTextInputFormatter(10),
                          // Custom formatter to prevent multiple decimal points
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            if (newValue.text.isEmpty) {
                              return newValue;
                            }

                            // Count decimal points
                            int decimalCount = 0;
                            for (int i = 0; i < newValue.text.length; i++) {
                              if (newValue.text[i] == '.') {
                                decimalCount++;
                              }
                            }

                            if (decimalCount > 1) {
                              return oldValue;
                            }

                            // Prevent values over 1,000,000
                            if (newValue.text.contains('.')) {
                              final parts = newValue.text.split('.');
                              if (parts[0].length > 7) {
                                return oldValue;
                              }
                            } else if (newValue.text.length > 7) {
                              return oldValue;
                            }

                            return newValue;
                          }),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter amount',
                          hintStyle: TextStyle(
                            color: const Color(0xFFB0BEC5).withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0A2E36).withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: amountError
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFF00B4A0).withOpacity(0.5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: amountError
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFF00B4A0).withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: amountError
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFF00B4A0),
                            ),
                          ),
                          errorText: amountError ? amountErrorText : null,
                          errorStyle: const TextStyle(color: Color(0xFFD32F2F)),
                          prefixText: '¥ ',
                          prefixStyle: const TextStyle(
                            color: Color(0xFFE0F7FA),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category dropdown
                      const Text(
                        'Category',
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
                            items:
                                <String>[
                                  'Clothing',
                                  'Shoes',
                                  'Accessories',
                                  'Bags',
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

                      // Date picker
                      const Text(
                        'Date',
                        style: TextStyle(
                          color: Color(0xFFB0BEC5),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
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
                                  dialogBackgroundColor: const Color(
                                    0xFF0F1A2F,
                                  ),
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
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A2E36).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00B4A0).withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
                                style: const TextStyle(
                                  color: Color(0xFFE0F7FA),
                                ),
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
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _unfocus();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFFB0BEC5)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _unfocus();

                      // Validate all fields before submitting
                      validateDescription();
                      validateAmount();

                      if (!descriptionError && !amountError) {
                        final amount = double.tryParse(amountController.text);
                        if (amount != null) {
                          final newExpense = Expense(
                            description: descriptionController.text,
                            amount: amount,
                            category: selectedCategory,
                            date: selectedDate,
                          );
                          _addExpense(newExpense);
                          Navigator.of(context).pop();
                        }
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

  Future<void> _addExpense(Expense expense) async {
    final success = await _expenseRepository.addExpense(expense);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully'),
            backgroundColor: Color(0xFF00B4A0),
          ),
        );
      }
      await _loadExpenseData();
    } else {
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

  void _showEditExpenseDialog(Expense expense) {
    final descriptionController = TextEditingController(
      text: expense.description,
    );
    final amountController = TextEditingController(
      text: expense.amount.toString(),
    );
    String selectedCategory = _translateCategory(expense.category);
    DateTime selectedDate = expense.date;

    // Form validation state
    bool descriptionError = false;
    bool amountError = false;
    String descriptionErrorText = '';
    String amountErrorText = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  descriptionErrorText =
                      'Description too long (max 50 characters)';
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

            return GestureDetector(
              onTap: _unfocus,
              child: AlertDialog(
                backgroundColor: const Color(0xFF0F1A2F),
                title: const Text(
                  'Edit Expense',
                  style: TextStyle(color: Color(0xFFE0F7FA)),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description field
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: Color(0xFFB0BEC5),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        focusNode: _descriptionFocusNode,
                        style: const TextStyle(color: Color(0xFFE0F7FA)),
                        textInputAction: TextInputAction.next,
                        maxLength: 50,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(
                            RegExp(r'^\s'),
                          ), // No leading spaces
                          LengthLimitingTextInputFormatter(50),
                        ],
                        onChanged: (_) => validateDescription(),
                        onSubmitted: (_) {
                          validateDescription();
                          FocusScope.of(context).requestFocus(_amountFocusNode);
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter description',
                          hintStyle: TextStyle(
                            color: const Color(0xFFB0BEC5).withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0A2E36).withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: descriptionError
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFF00B4A0).withOpacity(0.5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: descriptionError
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFF00B4A0).withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: descriptionError
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFF00B4A0),
                            ),
                          ),
                          errorText: descriptionError
                              ? descriptionErrorText
                              : null,
                          errorStyle: const TextStyle(color: Color(0xFFD32F2F)),
                          counterStyle: const TextStyle(
                            color: Color(0xFFB0BEC5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Amount field
                      const Text(
                        'Amount',
                        style: TextStyle(
                          color: Color(0xFFB0BEC5),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        focusNode: _amountFocusNode,
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
                          // Only allow digits and up to 2 decimal places
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                          // Limit total length to prevent overflow
                          LengthLimitingTextInputFormatter(10),
                          // Custom formatter to prevent multiple decimal points
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            if (newValue.text.isEmpty) {
                              return newValue;
                            }

                            // Count decimal points
                            int decimalCount = 0;
                            for (int i = 0; i < newValue.text.length; i++) {
                              if (newValue.text[i] == '.') {
                                decimalCount++;
                              }
                            }

                            if (decimalCount > 1) {
                              return oldValue;
                            }

                            // Prevent values over 1,000,000
                            if (newValue.text.contains('.')) {
                              final parts = newValue.text.split('.');
                              if (parts[0].length > 7) {
                                return oldValue;
                              }
                            } else if (newValue.text.length > 7) {
                              return oldValue;
                            }

                            return newValue;
                          }),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter amount',
                          hintStyle: TextStyle(
                            color: const Color(0xFFB0BEC5).withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0A2E36).withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: amountError
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFF00B4A0).withOpacity(0.5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: amountError
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFF00B4A0).withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: amountError
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFF00B4A0),
                            ),
                          ),
                          errorText: amountError ? amountErrorText : null,
                          errorStyle: const TextStyle(color: Color(0xFFD32F2F)),
                          prefixText: '¥ ',
                          prefixStyle: const TextStyle(
                            color: Color(0xFFE0F7FA),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category dropdown
                      const Text(
                        'Category',
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
                            items:
                                <String>[
                                  'Clothing',
                                  'Shoes',
                                  'Accessories',
                                  'Bags',
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

                      // Date picker
                      const Text(
                        'Date',
                        style: TextStyle(
                          color: Color(0xFFB0BEC5),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
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
                                  dialogBackgroundColor: const Color(
                                    0xFF0F1A2F,
                                  ),
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
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A2E36).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00B4A0).withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
                                style: const TextStyle(
                                  color: Color(0xFFE0F7FA),
                                ),
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
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _unfocus();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFFB0BEC5)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _unfocus();

                      // Validate all fields before submitting
                      validateDescription();
                      validateAmount();

                      if (!descriptionError && !amountError) {
                        final amount = double.tryParse(amountController.text);
                        if (amount != null) {
                          final newExpense = Expense(
                            description: descriptionController.text,
                            amount: amount,
                            category: selectedCategory,
                            date: selectedDate,
                          );
                          _editExpense(expense, newExpense);
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: const Text(
                      'Save',
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

  Future<void> _editExpense(Expense oldExpense, Expense newExpense) async {
    final success = await _expenseRepository.editExpense(
      oldExpense,
      newExpense,
    );

    if (success) {
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense updated successfully'),
            backgroundColor: Color(0xFF00B4A0),
          ),
        );
      }

      // Reload data
      await _loadExpenseData();
    } else {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update expense'),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Clothing':
        return Icons.checkroom;
      case 'Shoes':
        return Icons.shopping_bag;
      case 'Accessories':
        return Icons.auto_awesome;
      case 'Bags':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }
}
