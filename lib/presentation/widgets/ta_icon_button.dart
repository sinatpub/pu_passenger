import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_radius.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';

import 'ta_pressable.dart';

/// Round-square icon button with optional notification dot (`.icon-btn`) —
/// component spec §2.
class TaIconButton extends StatelessWidget {
  const TaIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 42,
    this.showDot = false,
    this.color = TaColors.textPrimary,
    this.semanticLabel,
  });

  final Widget icon;
  final VoidCallback? onTap;
  final double size;
  final bool showDot;
  final Color color;

  /// What a screen reader announces. **An icon on its own says nothing**, so
  /// every tappable instance passes one (roadmap P3: "every icon-only button
  /// announces a label"). Left null only for a decorative, non-tappable icon.
  final String? semanticLabel;

  /// The minimum tappable square, independent of the drawn [size].
  ///
  /// The spec draws this button at 42px, under the 48px floor P3 sets. Rather
  /// than redraw it — the visual size is the spec's — the hit area is grown to
  /// 48 around the same artwork, which is what a finger actually needs.
  static const double minTapTarget = 48;

  @override
  Widget build(BuildContext context) {
    final button = TaPressable(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: TaColors.surface,
          borderRadius: BorderRadius.circular(TaRadius.radiusMd),
          boxShadow: TaShadows.shadowSm,
        ),
        child: IconTheme(
          data: IconThemeData(color: color, size: size * 0.48),
          child: icon,
        ),
      ),
    );

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      enabled: onTap != null,
      excludeSemantics: semanticLabel != null,
      child: Center(
        child: SizedBox(
          width: size < minTapTarget ? minTapTarget : size,
          height: size < minTapTarget ? minTapTarget : size,
          child: Center(child: button),
        ),
      ),
    );
  }

  /// Dot indicator rendered over the top-right corner.
  static Widget dot() => Positioned(
        top: 9,
        right: 10,
        child: Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: TaColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: TaColors.surface, width: 2),
          ),
        ),
      );
}

/// Wraps any child (e.g. [TaIconButton]) with the dot indicator badge.
class TaDotBadge extends StatelessWidget {
  const TaDotBadge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [child, TaIconButton.dot()],
    );
  }
}