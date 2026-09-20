import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';

import 'ta_pressable.dart';

/// Place search result card (`.place`) — component spec §25.
class TaSearchResult extends StatelessWidget {
  const TaSearchResult({
    super.key,
    required this.name,
    required this.keyword,
    this.distance,
    this.onTap,
  });

  final String name;
  final String keyword;

  /// Optional distance badge (`.place` spec §25). Placeline searches have no
  /// distance in the payload, so the MapDrag page omits the badge rather than
  /// faking a number; hide it with `null`.
  final String? distance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TaPressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        width: double.infinity,
        decoration: BoxDecoration(
          color: TaColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: TaShadows.shadowSm,
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: TaColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: TaColors.textPrimary,
                    ),
                  ),
                  Text(
                    keyword,
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
            const SizedBox(width: 8),
            if (distance != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TaColors.primaryBg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  distance!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: TaColors.primaryDark,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}