import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cycle_model.dart';
import '../repositories/cycle_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CycleTrackerWidget extends StatefulWidget {
  final Cycle cycle;
  final SharedPreferences prefs;
  final GlobalKey<_CycleTrackerWidgetState>? trackerKey;

  const CycleTrackerWidget({
    Key? key,
    required this.cycle,
    required this.prefs,
    this.trackerKey,
  }) : super(key: key);

  // Public method to force an update
  void forceUpdate(BuildContext context) {
    final state = context.findAncestorStateOfType<_CycleTrackerWidgetState>();
    if (state != null) {
      state.forceUpdate();
    }
  }

  @override
  State<CycleTrackerWidget> createState() => _CycleTrackerWidgetState();
}

class _CycleTrackerWidgetState extends State<CycleTrackerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Timer _updateTimer;
  late CycleRepository _cycleRepository;
  late Cycle _currentCycle;

  @override
  void initState() {
    super.initState();
    _currentCycle = widget.cycle;
    _cycleRepository = CycleRepository(widget.prefs);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);

    // Set up a timer to update cycle data every minute
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateCycleData();
    });

    // Also update once at startup after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _updateCycleData();
    });
  }

  Future<void> _updateCycleData() async {
    await _cycleRepository.updateCycleDay();
    final updatedCycle = await _cycleRepository.getCycle();
    if (updatedCycle != null && mounted) {
      setState(() {
        _currentCycle = updatedCycle;
      });
    }
  }

  // Public method to force an immediate update
  void forceUpdate() {
    _updateCycleData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cycle Tracker',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE0F7FA),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF00B4A0).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.female, color: Color(0xFF00B4A0)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLunarDisc(context),
        ],
      ),
    );
  }

  Widget _buildLunarDisc(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0F1A2F).withOpacity(0.8),
                    const Color(0xFF0A2E36).withOpacity(0.8),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00B4A0).withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B4A0).withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
            // Phase indicators
            _buildPhaseIndicator(
              'Ovulation',
              const Offset(0, -1),
              const Color(0xFFFFB300),
            ),
            _buildPhaseIndicator(
              'Safe Period',
              const Offset(1, 0),
              const Color(0xFF00B4A0),
            ),
            _buildPhaseIndicator(
              'Menstruation',
              const Offset(0, 1),
              const Color(0xFFD32F2F),
            ),
            _buildPhaseIndicator(
              'Luteal Phase',
              const Offset(-1, 0),
              const Color(0xFFB0BEC5),
            ),
            // Inner ring with current day
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _animation,
                    child: Text(
                      '${_currentCycle.currentDay}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00B4A0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Day ${_currentCycle.currentDay} of Cycle',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB0BEC5),
                    ),
                  ),
                ],
              ),
            ),
            // Progress indicator
            SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: CycleProgressPainter(
                  progress:
                      _currentCycle.currentDay / _currentCycle.cycleDuration,
                  color: _getColorForPhase(_currentCycle.phase),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPhaseIndicator(String label, Offset position, Color color) {
    // Calculate position on the circle
    const radius = 105.0; // Distance from center
    final x = position.dx * radius;
    final y = position.dy * radius;

    return Positioned(
      left: 120 + x - 15, // Center x + offset x - half of indicator width
      top: 120 + y - 15, // Center y + offset y - half of indicator height
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1),
        ),
        child: Center(
          child: Icon(_getIconForPhase(label), color: color, size: 16),
        ),
      ),
    );
  }

  IconData _getIconForPhase(String phase) {
    switch (phase) {
      case 'Ovulation':
        return Icons.brightness_1; // Changed from egg_alt to brightness_1
      case 'Safe Period':
        return Icons.check_circle_outline;
      case 'Menstruation':
        return Icons.opacity; // Changed from water_drop to opacity
      case 'Luteal Phase':
        return Icons.hourglass_empty;
      default:
        return Icons.circle;
    }
  }

  Color _getColorForPhase(String phase) {
    switch (phase) {
      case 'Ovulation':
        return const Color(0xFFFFB300);
      case 'Safe Period':
        return const Color(0xFF00B4A0);
      case 'Menstruation':
        return const Color(0xFFD32F2F);
      case 'Luteal Phase':
        return const Color(0xFFB0BEC5);
      default:
        return const Color(0xFFB0BEC5);
    }
  }
}

class CycleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CycleProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const startAngle = -pi / 2; // Start from the top (12 o'clock position)
    final sweepAngle = 2 * pi * progress;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CycleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
