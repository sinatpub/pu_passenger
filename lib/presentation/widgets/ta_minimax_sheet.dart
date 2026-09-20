import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

import 'ta_bottom_sheet.dart';
import 'ta_button.dart';
import 'ta_kv_row.dart';
import 'ta_pressable.dart';

/// Vehicle tariff detail bottom sheet (`tariff`) — component spec §32.
///
/// Renders the trigger pill and, on tap, the tariff sheet ("Vehicle · Tariff"
/// title, Min fee / Price per km / Seats KV rows, "Got it").
class TaMinMaxSheet extends StatelessWidget {
  const TaMinMaxSheet({
    super.key,
    required this.vehicleName,
    required this.minFee,
    required this.pricePerKm,
    required this.seats,
    this.onGotIt,
  });

  final String vehicleName;
  final String minFee;
  final String pricePerKm;
  final String seats;
  final VoidCallback? onGotIt;

  @override
  Widget build(BuildContext context) {
    return TaPressable(
      onTap: () => open(
        context,
        vehicleName: vehicleName,
        minFee: minFee,
        pricePerKm: pricePerKm,
        seats: seats,
        onGotIt: onGotIt,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: TaColors.primaryBg,
          borderRadius: BorderRadius.circular(99),
        ),
        child: const Text(
          'Tariff',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: TaColors.primary,
          ),
        ),
      ),
    );
  }

  /// Opens just the tariff sheet ("Vehicle · Tariff" + KV rows + "Got it"),
  /// so callers with their own tariff trigger (e.g. the Map sheet's compact
  /// vehicle row) share the same presentation.
  static Future<void> open(
    BuildContext context, {
    required String vehicleName,
    required String minFee,
    required String pricePerKm,
    required String seats,
    VoidCallback? onGotIt,
  }) {
    return TaBottomSheet.show(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$vehicleName · Tariff',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: TaColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          TaKVRow(label: AppLocale.minimumFee.tr, value: minFee),
          TaKVRow(label: AppLocale.pricePerKM.tr, value: pricePerKm),
          TaKVRow(label: AppLocale.seats.tr, value: seats),
          const SizedBox(height: 18),
          TaButton(
            label: AppLocale.gotIt.tr,
            onTap: () {
              Navigator.of(context).pop();
              onGotIt?.call();
            },
          ),
        ],
      ),
    );
  }
}