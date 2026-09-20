import 'package:flutter/material.dart';

/// Taarraa design tokens — Typography (roadmap F1).
///
/// 12 named type roles from `docs/ux-redesign/02-design-system.md` §Typography
/// ("Flutter Text Style Mapping"), all on the `KantumruyPro` variable font.
///
/// Weight axis note (roadmap F1 risk): the variable font's `wght` axis is
/// driven explicitly via `FontVariation` so w600/w700/w800 resolve; whether a
/// given build actually renders the varied weight is verified in P3.
abstract final class TaTextStyles {
  static const String _family = 'KantumruyPro';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _family,
    fontSize: 30,
    height: 1.2,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 800)],
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _family,
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 800)],
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _family,
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    height: 1.3,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
  );

  static const TextStyle overline = TextStyle(
    fontFamily: _family,
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
  );

  static TextTheme get textTheme => const TextTheme(
        displayLarge: displayLarge,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}