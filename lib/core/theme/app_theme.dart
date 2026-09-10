import 'package:flutter/material.dart';
import 'package:com.tara.passenger/core/theme/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.main,
      primaryColorLight: AppColors.lighter,
      fontFamily: "KantumruyPro",
      primaryColorDark: AppColors.darker,
      hintColor: AppColors.subtitle,
      scaffoldBackgroundColor: AppColors.light4,
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.main,
        secondary: AppColors.lighter,
        error: AppColors.error,
        surface: AppColors.light3,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        onError: Colors.white,
      ).copyWith(error: AppColors.error),
    );
  }
}
