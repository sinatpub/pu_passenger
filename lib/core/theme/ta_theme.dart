import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';

/// Taarraa theme built entirely from design tokens (roadmap F1).
///
/// Replaced `AppTheme`, which was deleted at S5, and consumes
/// `TaColors`/`TaTextStyles` only — no primitive values leak in here.
abstract final class TaTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: TaColors.primary,
        secondary: TaColors.primaryLight,
        error: TaColors.error,
        surface: TaColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        onError: Colors.white,
      ),
      primaryColor: TaColors.primary,
      primaryColorLight: TaColors.primaryLight,
      primaryColorDark: TaColors.primaryDark,
      scaffoldBackgroundColor: TaColors.background,
      fontFamily: 'KantumruyPro',
      hintColor: TaColors.textMuted,
      textTheme: TaTextStyles.textTheme,
      useMaterial3: true,
    );
  }
}