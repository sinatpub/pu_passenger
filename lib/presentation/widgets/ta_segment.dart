import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';

import 'ta_pressable.dart';

/// Segmented control (`.seg`) — component spec §7.
///
/// Used for language toggles and history tabs. Presents [options];
/// selection is reported through [onChanged].
class TaSegment extends StatelessWidget {
  const TaSegment({
    super.key,
    required this.options,
    required this.selectedIndex,
    this.onChanged,
    this.expanded = false,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  /// Shares the width it is given equally between the options — the history
  /// tabs — instead of hugging the labels, which leaves an empty track when
  /// the control is stretched.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF0),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            if (expanded) Expanded(child: _option(i)) else _option(i),
          ],
        ],
      ),
    );
  }

  Widget _option(int i) {
    return TaPressable(
      onTap: onChanged == null ? null : () => onChanged!(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: expanded ? Alignment.center : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selectedIndex == i ? TaColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          boxShadow: selectedIndex == i ? TaShadows.shadowSm : null,
        ),
        child: Text(
          options[i],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selectedIndex == i
                ? TaColors.textPrimary
                : TaColors.textSecondary,
          ),
        ),
      ),
    );
  }
}