import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_radius.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';

/// Generic card container (`.card`) — component spec §6.
class TaCard extends StatelessWidget {
  const TaCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color = TaColors.surface,
    this.borderRadius = TaRadius.radiusLg,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: TaShadows.shadowMd,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: card,
    );
  }
}