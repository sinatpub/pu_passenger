import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

/// Progress dots for auth screens (`.steps`) — component spec §8.
class TaStepIndicator extends StatelessWidget {
  const TaStepIndicator({
    super.key,
    this.steps = 3,
    required this.current,
  });

  final int steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < steps; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 26,
            height: 5,
            decoration: BoxDecoration(
              color: i <= current ? TaColors.primary : const Color(0xFFDCDDE5),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ],
      ],
    );
  }
}