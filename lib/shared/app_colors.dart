import 'package:flutter/material.dart';

class AppColors {
  // 品牌颜色
  static const Color brandTeal = Color(0xFF44D7D0);
  static const Color brandDark = Color(0xFF0F1520);
  static const Color brandBlack = Color(0xFF000000);

  // 文本颜色
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8E8E93);

  // 背景颜色
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [brandDark, brandBlack],
  );

  // 卡片颜色
  static Color glassCardBackground = Colors.white.withOpacity(0.08);
  static Color glassCardBorder = Colors.white.withOpacity(0.1);

  // 状态颜色
  static const Color success = Color(0xFF4CD964);
  static const Color warning = Color(0xFFFFCC00);
  static const Color error = Color(0xFFFF3B30);
}
