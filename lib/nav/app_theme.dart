import 'package:flutter/material.dart';

class AppColors {
  static const orange = Color(0xFFFF6A00);
  static const bg = Color(0xFF1E1E1E);       // 전체 배경 (수정됨)
  static const surface = Color(0xFF2A2B31);  // 하단바 배경
  static const textPrimary = Color(0xFFE6E6E6);
  static const textSecondary = Color(0xFF9FA3A7);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.orange,
      surface: AppColors.surface,
      background: AppColors.bg,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.orange,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,


      selectedLabelStyle: TextStyle(
        fontFamily: 'NotoSans',
        fontWeight: FontWeight.w600, // SemiBold
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'NotoSans',
        fontWeight: FontWeight.w600, // SemiBold 동일 적용
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      bodySmall: TextStyle(color: AppColors.textSecondary),
    ),
  );
}
