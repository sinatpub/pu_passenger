import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

/// Status label badge (`.badge`) — component spec §9.
///
/// Takes a pre-formatted [label] string.
class TaBadge extends StatelessWidget {
  const TaBadge({
    super.key,
    required this.label,
    this.variant = TaBadgeVariant.success,
    this.icon,
  });

  final String label;
  final TaBadgeVariant variant;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: _foreground, size: 13),
              child: icon!,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _foreground,
            ),
          ),
        ],
      ),
    );
  }

  Color get _bg {
    switch (variant) {
      case TaBadgeVariant.success:
        return TaColors.successBg;
      case TaBadgeVariant.error:
        return TaColors.errorBg;
      case TaBadgeVariant.warning:
        return TaColors.warningBg;
      case TaBadgeVariant.brand:
        return TaColors.primaryBg;
    }
  }

  Color get _foreground {
    switch (variant) {
      case TaBadgeVariant.success:
        return TaColors.success;
      case TaBadgeVariant.error:
        return TaColors.error;
      case TaBadgeVariant.warning:
        return TaColors.warning;
      case TaBadgeVariant.brand:
        return TaColors.primaryDark;
    }
  }
}

enum TaBadgeVariant { success, error, warning, brand }