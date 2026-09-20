import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

import 'ta_avatar.dart';

/// Driver info row (`.driver`) — component spec §15.
class TaDriverCard extends StatelessWidget {
  const TaDriverCard({
    super.key,
    required this.name,
    required this.vehicleInfo,
    required this.initials,
    this.rating,
    this.plateNumber,
  });

  final String name;
  final String vehicleInfo;
  final String initials;
  final String? rating;
  final String? plateNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TaColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          TaAvatar(variant: TaAvatarVariant.driver, initials: initials),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: TaColors.textPrimary,
                        ),
                      ),
                    ),
                    if (rating != null) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.star, size: 15, color: Color(0xFFF5A623)),
                      const SizedBox(width: 2),
                      Text(
                        rating!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: TaColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  vehicleInfo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: TaColors.textSecondary),
                ),
              ],
            ),
          ),
          if (plateNumber != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: TaColors.dark,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                plateNumber!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}