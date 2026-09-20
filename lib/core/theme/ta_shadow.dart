import 'package:flutter/material.dart';

/// Taarraa design tokens — Elevation / shadows (roadmap F1).
///
/// Levels extracted from `docs/ux-redesign/02-design-system.md` §Elevation:
/// `shadowSm` 0 2 6 rgba(20,22,30,.08) · `shadowMd` 0 4 14 rgba(20,22,30,.10)
/// · `shadowLg` 0 12 34 rgba(20,22,30,.18).
abstract final class TaShadows {
  static const Color _shadowColor = Color.fromRGBO(20, 22, 30, 1);

  static final List<BoxShadow> shadowSm = [
    BoxShadow(
      color: _shadowColor.withValues(alpha: 0.08),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> shadowMd = [
    BoxShadow(
      color: _shadowColor.withValues(alpha: 0.10),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> shadowLg = [
    BoxShadow(
      color: _shadowColor.withValues(alpha: 0.18),
      blurRadius: 34,
      offset: const Offset(0, 12),
    ),
  ];
}