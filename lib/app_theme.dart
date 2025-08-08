import 'package:flutter/material.dart';
import 'shared/app_colors.dart';
import 'shared/app_text_styles.dart';

class AppTheme {
  // 暗色主题
  static ThemeData darkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: AppColors.brandTeal,
      scaffoldBackgroundColor: AppColors.brandDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.brandDark.withOpacity(0.85),
        selectedItemColor: AppColors.brandTeal,
        unselectedItemColor: Colors.grey,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headingLarge,
        headlineMedium: AppTextStyles.headingMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandTeal,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
    );
  }

  // 亮色主题
  static ThemeData lightTheme() {
    return ThemeData.light().copyWith(
      primaryColor: AppColors.brandTeal,
      scaffoldBackgroundColor: Colors.grey[100],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.brandTeal,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.brandTeal,
        unselectedItemColor: Colors.grey,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headingLarge.copyWith(
          color: Colors.black87,
        ),
        headlineMedium: AppTextStyles.headingMedium.copyWith(
          color: Colors.black87,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: Colors.black87),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: Colors.black87),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
    );
  }
}
