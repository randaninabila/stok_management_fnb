
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor:
        AppColors.primaryBackground,

    fontFamily: 'Roboto',

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryBackground,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryBackground,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),

      elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryButton,
      foregroundColor: AppColors.textPrimary,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
  
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackground,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.inputBorder,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.inputBorder,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.primaryButton,
          width: 1.5,
        ),
      ),
    ),
  );
}
