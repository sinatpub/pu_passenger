import 'package:flutter/material.dart';

/// Taarraa design tokens — Colors (roadmap F1).
///
/// Semantic values extracted verbatim from `docs/taarraa-ui-prototype.html`
/// `:root` variables, per `docs/ux-redesign/02-design-system.md` §Colors.
/// The single source of truth for colour. The legacy `AppColors` and
/// `ThemeConstands` tables were deleted at S5.
abstract final class TaColors {
  // Primary
  static const Color primary = Color(0xFFFF4500);
  static const Color primaryDark = Color(0xFFCC3700);
  static const Color primaryLight = Color(0xFFFFA84C);
  static const Color primaryBg = Color(0xFFFFF4ED);
  static const Color primaryBorder = Color(0xFFFFE4D3);

  // Surface
  static const Color background = Color(0xFFF6F6F7);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF191C24);
  static const Color textSecondary = Color(0xFF6B7588);
  static const Color textMuted = Color(0xFF9AA0B4);

  // Border
  static const Color border = Color(0xFFEBEBF0);

  // State
  static const Color success = Color(0xFF0EAF6B);
  static const Color successBg = Color(0xFFE6F8EF);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorBg = Color(0xFFFDECEC);
  static const Color warning = Color(0xFFB97A00);
  static const Color warningBg = Color(0xFFFFF4D6);
  static const Color info = Color(0xFF2F6BFF);

  // Dark accent (navy — dark buttons, status pill, plate badge, promo bg)
  static const Color dark = Color(0xFF232838);

  // Disabled
  static const Color disabledBg = Color(0xFFD8DBE3);
  static const Color disabledText = Color(0xFFFFFFFF);

  // Overlay / feedback
  static const Color overlay = Color.fromRGBO(15, 17, 25, 0.5);
  static const Color toastBg = Color(0xFF232838);
  static const Color toastIcon = Color(0xFF7CFFB2);
}