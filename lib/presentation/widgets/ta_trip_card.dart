import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';

/// A trip's two ends in one bordered card: pickup over drop-off, one line
/// each. Shared by the ride sheet, the fare page and the Thank you page so
/// they cannot drift.
///
/// A null [dropOff] is a trip booked without a destination; the row then
/// shows [noDropOffText], muted, or is left out when that is null too.
/// Presentational: every string arrives translated.
class TaTripCard extends StatelessWidget {
  const TaTripCard({
    super.key,
    required this.pickupLabel,
    required this.pickup,
    required this.dropOffLabel,
    required this.dropOff,
    required this.noDropOffText,
  });

  final String pickupLabel;
  final String pickup;
  final String dropOffLabel;
  final String? dropOff;
  final String? noDropOffText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: TaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TaColors.border),
      ),
      child: TaTripRows(
        pickupLabel: pickupLabel,
        pickup: pickup,
        dropOffLabel: dropOffLabel,
        dropOff: dropOff,
        noDropOffText: noDropOffText,
      ),
    );
  }
}

/// The pickup and drop-off rows on their own, for a card that already has
/// its border — a booking in the history list.
///
/// With no [dropOff], the second row shows [noDropOffText]; when that is
/// null too, the row is left out.
class TaTripRows extends StatelessWidget {
  const TaTripRows({
    super.key,
    required this.pickupLabel,
    required this.pickup,
    required this.dropOffLabel,
    required this.dropOff,
    this.noDropOffText,
  });

  final String pickupLabel;
  final String pickup;
  final String dropOffLabel;
  final String? dropOff;
  final String? noDropOffText;

  @override
  Widget build(BuildContext context) {
    final second = dropOff ?? noDropOffText;
    return Column(
      children: [
        _row(
          label: pickupLabel,
          text: pickup,
          color: TaColors.dark,
          round: true,
        ),
        if (second != null) ...[
          const SizedBox(height: 10),
          _row(
            label: dropOffLabel,
            text: second,
            color: TaColors.primary,
            round: false,
            muted: dropOff == null,
          ),
        ],
      ],
    );
  }

  /// The marker says which end of the trip this is only to the eye, so the
  /// row announces [label] with it.
  Widget _row({
    required String label,
    required String text,
    required Color color,
    required bool round,
    bool muted = false,
  }) {
    return Semantics(
      label: '$label: $text',
      child: ExcludeSemantics(
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: round ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: round ? null : BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TaTextStyles.labelLarge.copyWith(
                  color: muted ? TaColors.textSecondary : TaColors.textPrimary,
                  fontWeight: muted ? FontWeight.w500 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
