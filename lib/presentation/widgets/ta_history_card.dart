import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

import 'ta_pressable.dart';
import 'ta_trip_card.dart';

/// History list item (`.hcard`) — component spec §10.
///
/// One booking, compact: when it was and what it cost, the vehicle and
/// driver, the route, and — for a completed trip — how far and how long. The
/// tab above the list says whether these are completed or cancelled trips,
/// so the card carries no status badge.
///
/// Presentational: [HistoryItem] carries pre-formatted strings only.
class TaHistoryCard extends StatelessWidget {
  const TaHistoryCard({super.key, required this.item, this.onTap});

  final HistoryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: TaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _art(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.cardDate ?? item.date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: TaColors.textPrimary,
                      ),
                    ),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
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
              if (item.fare != null) ...[
                const SizedBox(width: 8),
                Text(
                  item.fare!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: TaColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          TaTripRows(
            pickupLabel: AppLocale.pickup.tr,
            pickup: item.from,
            dropOffLabel: AppLocale.destination.tr,
            dropOff: item.to,
            noDropOffText: item.noDropOffText,
          ),
          if (item.summary != null) ...[
            const SizedBox(height: 8),
            Text(
              item.summary!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: TaColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );

    // `onTap` was declared but never wired, so the whole-card tap target that
    // S1 moves to (`03 §Screen 13`) silently did nothing.
    if (onTap == null) return card;
    return TaPressable(onTap: onTap, child: card);
  }

  /// The drawing of the vehicle that made the trip, or a neutral car when the
  /// booking never got a vehicle — it was cancelled before a driver took it.
  Widget _art() {
    return ExcludeSemantics(
      child: SizedBox(
        width: 52,
        height: 32,
        child: item.art ??
            Container(
              decoration: BoxDecoration(
                color: TaColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.directions_car,
                color: TaColors.textMuted,
                size: 20,
              ),
            ),
      ),
    );
  }
}

class HistoryItem {
  const HistoryItem({
    required this.invoice,
    required this.driver,
    required this.date,
    required this.amount,
    required this.from,
    this.to,
    required this.distance,
    required this.duration,
    required this.initials,
    this.cardDate,
    this.subtitle,
    this.fare,
    this.summary,
    this.noDropOffText,
    this.art,
  });

  final String invoice;
  final String driver;
  final String date;
  final String amount;
  final String from;

  /// Null when the trip never had a destination — a cancelled booking often
  /// does not. The row is then dropped rather than printing "Unknown"
  /// (roadmap S1 Risk: "must not send a destination when none exists").
  final String? to;
  final String distance;
  final String duration;
  final String initials;

  // ---- The list card. The detail page reads the fields above. ----

  /// The card's headline date — shorter than [date]. Falls back to [date].
  final String? cardDate;

  /// "Classic Car · Sok Dara" — whichever of the two the booking has.
  final String? subtitle;

  /// What the trip cost. Null for a trip that was never charged: the card
  /// then shows no amount at all.
  final String? fare;

  /// "10.3 km · 28 min". Null when the trip covered no distance to report.
  final String? summary;

  /// What the drop-off row says when [to] is null. Null leaves the row out.
  final String? noDropOffText;

  /// The drawing of the trip's vehicle type.
  final Widget? art;
}