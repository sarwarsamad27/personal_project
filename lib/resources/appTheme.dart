// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:new_brand/resources/appColor.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColor.primaryColor,
    scaffoldBackgroundColor: AppColor.screenBgColor,
    colorScheme: ColorScheme.light(
      primary: AppColor.primaryColor,
      secondary: AppColor.secondaryColor,
      surface: AppColor.whiteColor,
      error: AppColor.errorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.whiteColor,
      foregroundColor: AppColor.textPrimaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColor.textPrimaryColor,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColor.textPrimaryColor, fontSize: 16),
      bodyMedium: TextStyle(color: AppColor.textSecondaryColor, fontSize: 14),
      titleLarge: TextStyle(
        color: AppColor.textPrimaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColor.whiteColor,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColor.underlineColor),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColor.underlineColor),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColor.primaryColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColor.bottomNavBarColor,
      selectedItemColor: AppColor.primaryColor,
      unselectedItemColor: AppColor.textSecondaryColor,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
