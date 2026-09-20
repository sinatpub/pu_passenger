import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

import 'ta_pressable.dart';

/// Selectable tag chip (`.chip`) — component spec §18.
class TaChip extends StatelessWidget {
  const TaChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TaPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? TaColors.primaryBg : TaColors.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isSelected ? TaColors.primary : TaColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? TaColors.primaryDark : TaColors.textSecondary,
          ),
        ),
      ),
    );
  }
}