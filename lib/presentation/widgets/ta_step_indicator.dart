import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

/// Progress dots for auth screens (`.steps`) — component spec §8.
///
/// [expanded] stretches the segments across the width available — the ride
/// sheet's "on the way / arrived / on trip" bar — instead of the auth
/// screens' fixed 26px dots.
class TaStepIndicator extends StatelessWidget {
  const TaStepIndicator({
    super.key,
    this.steps = 3,
    required this.current,
    this.expanded = false,
  });

  final int steps;
  final int current;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        for (var i = 0; i < steps; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          if (expanded) Expanded(child: _segment(i)) else _segment(i),
        ],
      ],
    );
  }

  Widget _segment(int i) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: expanded ? null : 26,
      height: 5,
      decoration: BoxDecoration(
        color: i <= current ? TaColors.primary : const Color(0xFFDCDDE5),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
