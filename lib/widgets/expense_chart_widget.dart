import 'package:flutter/material.dart';

class ExpenseChartWidget extends StatefulWidget {
  final Map<String, double> categoryTotals;

  const ExpenseChartWidget({Key? key, required this.categoryTotals})
    : super(key: key);

  @override
  State<ExpenseChartWidget> createState() => _ExpenseChartWidgetState();
}

class _ExpenseChartWidgetState extends State<ExpenseChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Column(
        children: [
          const SizedBox(height: 30),
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _buildBars(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBars() {
    final categories = <String>['Clothing', 'Shoes', 'Accessories', 'Bags'];
    final maxValue = _getMaxValue();

    return categories.map((category) {
      // Handle both English and Chinese category names for backward compatibility
      double amount = 0.0;
      if (widget.categoryTotals.containsKey(category)) {
        amount = widget.categoryTotals[category] ?? 0.0;
      } else {
        // Check for Chinese category names
        final chineseCategory = _getChineseCategoryName(category);
        amount = widget.categoryTotals[chineseCategory] ?? 0.0;
      }

      final percentage = maxValue > 0 ? amount / maxValue : 0.0;
      final height = 150 * percentage * _animation.value;

      return _buildBar(category, amount, height);
    }).toList();
  }

  // Helper method to get Chinese category name for backward compatibility
  String _getChineseCategoryName(String englishCategory) {
    switch (englishCategory) {
      case 'Clothing':
        return '服装';
      case 'Shoes':
        return '鞋子';
      case 'Accessories':
        return '首饰';
      case 'Bags':
        return '包';
      default:
        return englishCategory;
    }
  }

  Widget _buildBar(String category, double amount, double height) {
    return GestureDetector(
      onTap: () {
        // Show detail information
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          // Add hover effect in the future if needed
        },
        onExit: (_) {
          // Reset hover effect in the future if needed
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              category,
              style: const TextStyle(fontSize: 12, color: Color(0xFFB0BEC5)),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40,
              height: height > 0 ? height : 2, // At least show a thin line
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFF00B4A0), Color(0xFF00C9B8)],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B4A0).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¥${amount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE0F7FA),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxValue() {
    double max = 0;
    widget.categoryTotals.forEach((_, value) {
      if (value > max) {
        max = value;
      }
    });
    return max;
  }
}
