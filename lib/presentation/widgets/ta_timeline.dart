import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

/// Ride progress stepper (`.timeline`) — component spec §13.
///
/// Steps before [currentStep] show a check, the current step shows its number
/// highlighted, later steps show pending numbers.
class TaTimeline extends StatelessWidget {
  const TaTimeline({
    super.key,
    this.steps = const ['Accepted', 'Arriving', 'On trip'],
    required this.currentStep,
  });

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: ConnectorLine(
                active: i <= currentStep,
              ),
            ),
          _Step(
            label: steps[i],
            number: i + 1,
            isDone: i < currentStep,
            isActive: i == currentStep,
          ),
        ],
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.number, required this.isDone, required this.isActive});

  final String label;
  final int number;
  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? TaColors.primary : const Color(0xFFE7E8EE),
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: TaColors.primary.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: isDone
                ? const Icon(Icons.check, size: 15, color: Colors.white)
                : Text(
                    isActive ? '$number' : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isActive ? TaColors.primaryDark : TaColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class ConnectorLine extends StatelessWidget {
  const ConnectorLine({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: active ? TaColors.primary : const Color(0xFFE7E8EE),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}