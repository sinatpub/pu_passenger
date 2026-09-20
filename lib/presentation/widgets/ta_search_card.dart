import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';

import 'ta_pressable.dart';

/// Tappable search bar (`.where`) — component spec §5.
class TaSearchCard extends StatelessWidget {
  const TaSearchCard({
    super.key,
    this.label = 'Where to?',
    this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return TaPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: TaColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: TaShadows.shadowMd,
        ),
        child: Row(
          children: [
            IconTheme(
              data: const IconThemeData(size: 22, color: TaColors.primary),
              child: icon ?? const Icon(Icons.search),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TaColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}