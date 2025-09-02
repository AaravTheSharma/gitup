import 'dart:async';
import 'package:flutter/material.dart';

class Helpers {
  /// Format date to readable string
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }

  /// Format date for reports
  static String formatReportDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'in-progress':
        return const Color(0xFF3B82F6);
      case 'archived':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF64748B);
    }
  }

  /// Get status background color
  static Color getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981).withValues(alpha: 0.1);
      case 'in-progress':
        return const Color(0xFF3B82F6).withValues(alpha: 0.1);
      case 'archived':
        return const Color(0xFF64748B).withValues(alpha: 0.1);
      default:
        return const Color(0xFF64748B).withValues(alpha: 0.1);
    }
  }

  /// Get formatted status text
  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'in-progress':
        return 'In Progress';
      case 'archived':
        return 'Archived';
      default:
        return 'Unknown';
    }
  }

  /// Get icon for criterion
  static IconData getCriterionIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'coins':
      case 'salary':
        return Icons.attach_money;
      case 'chart-line':
      case 'growth':
        return Icons.trending_up;
      case 'heart':
      case 'happiness':
        return Icons.favorite;
      case 'balance-scale':
      case 'work-life':
        return Icons.balance;
      case 'users':
      case 'culture':
        return Icons.people;
      case 'map-marker-alt':
      case 'commute':
        return Icons.location_on;
      case 'shield-alt':
      case 'security':
        return Icons.security;
      case 'graduation-cap':
      case 'learning':
        return Icons.school;
      case 'home':
        return Icons.home;
      case 'briefcase':
        return Icons.work;
      case 'dollar-sign':
        return Icons.monetization_on;
      case 'plus-circle':
        return Icons.add_circle;
      default:
        return Icons.circle;
    }
  }

  /// Get template icon
  static IconData getTemplateIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'briefcase':
        return Icons.work;
      case 'home':
        return Icons.home;
      case 'heart':
        return Icons.favorite;
      case 'dollar-sign':
        return Icons.monetization_on;
      case 'plus-circle':
        return Icons.add_circle;
      default:
        return Icons.help_outline;
    }
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Generate random color
  static Color generateRandomColor() {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFFA855F7),
      const Color(0xFF06B6D4),
      const Color(0xFF84CC16),
      const Color(0xFFF97316),
    ];
    return colors[(DateTime.now().millisecondsSinceEpoch % colors.length)];
  }

  /// Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Format score for display
  static String formatScore(double score) {
    return score.toStringAsFixed(1);
  }

  /// Get progress color
  static Color getProgressColor(double progress) {
    if (progress < 0.3) {
      return const Color(0xFFEF4444);
    } else if (progress < 0.7) {
      return const Color(0xFFF59E0B);
    } else {
      return const Color(0xFF10B981);
    }
  }

  /// Debounce function calls
  static Timer? _debounceTimer;
  static void debounce(VoidCallback callback, Duration delay) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Calculate percentage
  static double calculatePercentage(int part, int total) {
    if (total == 0) return 0.0;
    return (part / total) * 100;
  }

  /// Get contrast color for background
  static Color getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

