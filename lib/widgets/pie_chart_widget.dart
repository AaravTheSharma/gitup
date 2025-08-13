import 'dart:math';
import 'package:flutter/material.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, double> locationPercentages;
  final int totalItems; // 添加总数参数

  const PieChartWidget({
    Key? key,
    required this.locationPercentages,
    required this.totalItems, // 要求传入实际总数
  }) : super(key: key);

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
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
            color: Colors.black.withOpacity(0.2),
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
          // Title
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Item Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0F7FA),
              ),
            ),
          ),

          // Chart container
          SizedBox(
            height: 260,
            width: screenWidth - 32, // Full width minus padding
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pie chart
                SizedBox(
                  width: 200,
                  height: 200,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: PieChartPainter(
                          percentages: widget.locationPercentages,
                          animation: _animation.value,
                        ),
                      );
                    },
                  ),
                ),

                // Center circle with total items
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF00B4A0).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.totalItems.toString(), // 直接使用传入的总数
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE0F7FA),
                        ),
                      ),
                      const Text(
                        'Total Items',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB0BEC5),
                        ),
                      ),
                    ],
                  ),
                ),

                // Location labels
                ..._buildLocationLabels(screenWidth),
              ],
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLocationLabels(double screenWidth) {
    // 调整标签位置，使其更加合理
    final locations = {
      'Bedroom': const Offset(0.65, -0.65),
      'Living Room': const Offset(0.85, 0),
      'Kitchen': const Offset(0.65, 0.65),
      'Closet': const Offset(-0.65, 0.65),
      'Other': const Offset(-0.85, 0),
    };

    final List<Widget> labels = [];
    final radius = 120.0;
    final centerX = screenWidth / 2 - 16; // 考虑父容器的padding

    locations.forEach((location, position) {
      final percentage = widget.locationPercentages[location] ?? 0.0;
      if (percentage <= 0) return; // 跳过百分比为0的位置

      final x = position.dx * radius;
      final y = position.dy * radius;

      labels.add(
        Positioned(
          left: centerX + x - 40, // 调整位置使标签居中
          top: 130 + y - 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF121212).withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _getLocationColor(location).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              '$location ${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getLocationColor(location),
              ),
            ),
          ),
        ),
      );
    });

    return labels;
  }

  Widget _buildLegend() {
    final locations = ['Bedroom', 'Living Room', 'Kitchen', 'Closet', 'Other'];
    final List<Widget> legendItems = [];

    for (var location in locations) {
      final percentage = widget.locationPercentages[location] ?? 0.0;
      if (percentage <= 0) continue; // 跳过百分比为0的位置

      legendItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getLocationColor(location),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: const TextStyle(fontSize: 12, color: Color(0xFFE0F7FA)),
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(alignment: WrapAlignment.center, children: legendItems);
  }

  int _calculateTotalItems() {
    int total = 0;
    widget.locationPercentages.forEach((_, percentage) {
      // 不再使用百分比计算，而是直接使用传入的总数
      total += (percentage / 100 * 100).round(); // Simplified calculation
    });
    return total;
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
      case 'Other':
        return const Color(0xFF00695C); // darkest teal
      default:
        return const Color(0xFFB0BEC5); // default gray
    }
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> percentages;
  final double animation;

  PieChartPainter({required this.percentages, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const startAngle = -pi / 2; // Start from the top (12 o'clock position)

    double currentAngle = startAngle;
    final locations = ['Bedroom', 'Living Room', 'Kitchen', 'Closet', 'Other'];

    // 绘制外环阴影
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center, radius + 2, shadowPaint);

    // 绘制饼图
    for (var location in locations) {
      final percentage = percentages[location] ?? 0.0;
      if (percentage <= 0) continue;

      final sweepAngle = 2 * pi * (percentage / 100) * animation;

      // 绘制扇形
      final paint = Paint()
        ..color = _getLocationColor(location)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle,
        true,
        paint,
      );

      // 绘制扇形边框
      final strokePaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle,
        true,
        strokePaint,
      );

      currentAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) {
    return oldDelegate.percentages != percentages ||
        oldDelegate.animation != animation;
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
      case 'Other':
        return const Color(0xFF00695C); // darkest teal
      default:
        return const Color(0xFFB0BEC5); // default gray
    }
  }
}
