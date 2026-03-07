import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryEmerald,
        primary: AppColors.primaryEmerald,
        secondary: AppColors.royalGold,
        onPrimary: Colors.white,
        surface: AppColors.lightBackground,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: ThemeData.light().textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.primaryEmerald,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          fontFamily: 'NotoKufiArabic',
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: AppColors.primaryEmerald,
        primary: AppColors.primaryEmerald,
        secondary: AppColors.royalGold,
        onPrimary: Colors.white,
        surface: AppColors.deepGradientGreen,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: ThemeData.dark().textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.royalGold,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          fontFamily: 'NotoKufiArabic',
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.deepGradientGreen.withValues(alpha: 0.15),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
