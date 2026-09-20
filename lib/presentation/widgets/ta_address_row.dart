import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

/// Pickup/destination display row (`.addr-row`) — component spec §22.
class TaAddressRow extends StatelessWidget {
  const TaAddressRow({
    super.key,
    required this.type,
    required this.label,
    required this.name,
    this.sub,
  });

  final TaAddressType type;
  final String label;
  final String name;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final isPickup = type == TaAddressType.pickup;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: isPickup ? TaColors.dark : TaColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isPickup
                      ? const Color(0xFFE3E5EC)
                      : TaColors.primaryBorder,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: TaColors.textMuted,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: TaColors.textPrimary,
                  ),
                ),
                if (sub != null)
                  Text(
                    sub!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TaColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum TaAddressType { pickup, destination }