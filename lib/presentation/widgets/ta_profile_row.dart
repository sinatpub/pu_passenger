import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';

import 'ta_pressable.dart';

/// Settings/menu row (`.prow`) — component spec §11.
class TaProfileRow extends StatelessWidget {
  const TaProfileRow({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.isDanger = false,
  });

  final Widget icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return TaPressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        decoration: BoxDecoration(
          color: TaColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: TaShadows.shadowSm,
        ),
        child: Row(
          children: [
            IconTheme(
              data: IconThemeData(
                size: 22,
                color: isDanger ? TaColors.error : TaColors.primary,
              ),
              child: icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDanger ? TaColors.error : TaColors.textPrimary,
                ),
              ),
            ),
            if (!isDanger)
              trailing ??
                  const Icon(Icons.chevron_right, size: 22, color: TaColors.textMuted),
          ],
        ),
      ),
    );
  }
}