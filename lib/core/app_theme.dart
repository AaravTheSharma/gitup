import 'package:flutter/material.dart';
import 'app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: MaterialColor(
        AppConstants.primaryColor,
        <int, Color>{
          50: const Color(0xFFEFF6FF),
          100: const Color(0xFFDBEAFE),
          200: const Color(0xFFBFDBFE),
          300: const Color(0xFF93C5FD),
          400: const Color(0xFF60A5FA),
          500: const Color(AppConstants.primaryColor),
          600: const Color(AppConstants.primaryDarkColor),
          700: const Color(0xFF1E40AF),
          800: const Color(0xFF1E3A8A),
          900: const Color(0xFF1E3A8A),
        },
      ),
      primaryColor: const Color(AppConstants.primaryColor),
      scaffoldBackgroundColor: const Color(AppConstants.backgroundColor),
      cardColor: const Color(AppConstants.surfaceColor),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(AppConstants.surfaceColor),
        selectedItemColor: Color(AppConstants.primaryColor),
        unselectedItemColor: Color(AppConstants.textSecondaryColor),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppConstants.primaryColor),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingXLarge,
            vertical: AppConstants.paddingMedium,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(AppConstants.primaryColor),
          side: const BorderSide(
            color: Color(AppConstants.primaryColor),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingXLarge,
            vertical: AppConstants.paddingMedium,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(AppConstants.surfaceColor),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: Color(AppConstants.primaryColor)),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(AppConstants.textPrimaryColor),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Color(AppConstants.textPrimaryColor),
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: Color(AppConstants.textPrimaryColor),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Color(AppConstants.textPrimaryColor),
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Color(AppConstants.textSecondaryColor),
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: Color(AppConstants.textSecondaryColor),
          fontSize: 12,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: MaterialColor(
        AppConstants.primaryColor,
        <int, Color>{
          50: const Color(0xFFEFF6FF),
          100: const Color(0xFFDBEAFE),
          200: const Color(0xFFBFDBFE),
          300: const Color(0xFF93C5FD),
          400: const Color(0xFF60A5FA),
          500: const Color(AppConstants.primaryColor),
          600: const Color(AppConstants.primaryDarkColor),
          700: const Color(0xFF1E40AF),
          800: const Color(0xFF1E3A8A),
          900: const Color(0xFF1E3A8A),
        },
      ),
      primaryColor: const Color(AppConstants.primaryColor),
      scaffoldBackgroundColor: const Color(AppConstants.darkBackgroundColor),
      cardColor: const Color(AppConstants.darkSurfaceColor),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(AppConstants.darkSurfaceColor),
        selectedItemColor: Color(AppConstants.primaryColor),
        unselectedItemColor: Color(AppConstants.darkTextSecondaryColor),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppConstants.primaryColor),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingXLarge,
            vertical: AppConstants.paddingMedium,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(AppConstants.primaryColor),
          side: const BorderSide(
            color: Color(AppConstants.primaryColor),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingXLarge,
            vertical: AppConstants.paddingMedium,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(AppConstants.darkSurfaceColor),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: Color(AppConstants.primaryColor)),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(AppConstants.darkTextPrimaryColor),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Color(AppConstants.darkTextPrimaryColor),
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: Color(AppConstants.darkTextPrimaryColor),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Color(AppConstants.darkTextPrimaryColor),
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Color(AppConstants.darkTextSecondaryColor),
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: Color(AppConstants.darkTextSecondaryColor),
          fontSize: 12,
        ),
      ),
    );
  }
}