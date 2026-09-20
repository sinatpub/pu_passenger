import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

/// Distance/duration/fare metrics bar (`.stat3`) — component spec §21.
class TaStatRow extends StatelessWidget {
  const TaStatRow({super.key, required this.items});

  final List<StatItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: TaColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 34,
                color: TaColors.border,
              ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    items[i].value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: TaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    items[i].label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: TaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StatItem {
  const StatItem({required this.value, required this.label});

  final String value;
  final String label;
}