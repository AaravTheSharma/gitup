import 'package:flutter/material.dart';

class ReminderCardWidget extends StatefulWidget {
  final String reminderText;

  const ReminderCardWidget({Key? key, required this.reminderText})
    : super(key: key);

  @override
  State<ReminderCardWidget> createState() => _ReminderCardWidgetState();
}

class _ReminderCardWidgetState extends State<ReminderCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFD32F2F).withOpacity(0.1),
                const Color(0xFFD32F2F).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD32F2F).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFD32F2F,
                ).withOpacity(0.2 * _animation.value),
                spreadRadius: 0,
                blurRadius: 8 * _animation.value,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: Color(0xFFD32F2F),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Reminder',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.reminderText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFB0BEC5),
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
