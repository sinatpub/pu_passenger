import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';

import 'ta_avatar.dart';
import 'ta_pressable.dart';
import 'ta_badge.dart';

/// History list item (`.hcard`) — component spec §10.
///
/// Presentational: [HistoryItem] carries pre-formatted strings only.
class TaHistoryCard extends StatelessWidget {
  const TaHistoryCard({
    super.key,
    required this.item,
    this.onTap,
    this.isCompleted = true,
    this.statusLabel,
  });

  final HistoryItem item;
  final VoidCallback? onTap;
  final bool isCompleted;

  /// The badge's text. Defaults to the English spec wording; callers in the
  /// app pass a localised string (S1).
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TaColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: TaShadows.shadowMd,
      ),
      child: Column(
        children: [
          Row(
            children: [
              TaAvatar(variant: TaAvatarVariant.history, initials: item.initials),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.invoice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: TaColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${item.driver} · ${item.date}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: TaColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: TaColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TaBadge(
              label: statusLabel ??
                  (isCompleted
                      ? AppLocale.completed.tr
                      : AppLocale.cancelled.tr),
              variant: isCompleted ? TaBadgeVariant.success : TaBadgeVariant.error,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: TaColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _routeRow(
                  dotColor: TaColors.dark,
                  haloColor: const Color(0xFFE3E5EC),
                  text: item.from,
                ),
                if (item.to != null) ...[
                  const SizedBox(height: 6),
                  _routeRow(
                    dotColor: TaColors.primary,
                    haloColor: TaColors.primaryBorder,
                    text: item.to!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.route, size: 14, color: TaColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                item.distance,
                style: const TextStyle(fontSize: 12, color: TaColors.textSecondary),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.access_time, size: 14, color: TaColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                item.duration,
                style: const TextStyle(fontSize: 12, color: TaColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );

    // `onTap` was declared but never wired, so the whole-card tap target that
    // S1 moves to (`03 §Screen 13`) silently did nothing.
    if (onTap == null) return card;
    return TaPressable(onTap: onTap, child: card);
  }

  Widget _routeRow({
    required Color dotColor,
    required Color haloColor,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 9,
          height: 9,
          margin: const EdgeInsets.only(top: 4, right: 10),
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: haloColor, spreadRadius: 2)],
          ),
        ),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: TaColors.textPrimary,
            ),
          ),
        ),
      ],
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
}