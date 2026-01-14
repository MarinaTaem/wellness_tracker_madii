import 'package:flutter/material.dart';
import 'package:wellness_tracker/core/app_color.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColor.primaryColor,
    scaffoldBackgroundColor: AppColor.backgroundColor,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColor.textPrimary),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColor.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 18,
        color: AppColor.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColor.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColor.textPrimary,
      ),
    ),
    // cardTheme: CardTheme(
    //   elevation: 2,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(12),
    //   ),
    // ),
  );
}
