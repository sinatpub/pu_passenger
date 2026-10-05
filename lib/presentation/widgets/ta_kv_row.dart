import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

/// Key-value pair display row (`.kv`) — component spec §23.
///
/// Presentational: takes pre-formatted [value] strings (no formatting logic).
class TaKVRow extends StatelessWidget {
  const TaKVRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: TaColors.textSecondary),
          ),
          const SizedBox(width: 16),
          // A long value wraps under itself, right-aligned, rather than
          // running off the edge of the card.
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}