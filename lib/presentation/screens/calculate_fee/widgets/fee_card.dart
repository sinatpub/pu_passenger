import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/utils/booking_vehicle_info.dart';
import 'package:com.tara.passenger/core/utils/fee_presentation.dart';
import 'package:com.tara.passenger/core/utils/initials.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 10 — Fee (CalculateFee)'s trip summary: who drove, where, and how
/// far and how long — three bordered cards, the same ones the ride sheet
/// uses for the driver and the trip.
///
/// Extracted from `calculate_fee_screen.dart` (C6) — as C3 and C5 did — so the
/// degrade cases are widget-testable without `Get.put`ting the real
/// `CalculateFeeLogic`. Takes the model directly: nothing here reads a
/// controller.
class FeeCard extends StatelessWidget {
  const FeeCard({super.key, required this.data});

  final Data? data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        /// Spec: no rating and no plate on the fee card — the trip is over,
        /// so identifying the vehicle no longer helps. The car is named once,
        /// here, rather than again in a "Vehicle" row.
        TaDriverCard(
          bordered: true,
          name: data?.driver?.name ?? AppLocale.unKnown.tr,
          initials: initialsFromName(data?.driver?.name),
          vehicleInfo: bookingVehicleInfo(data),
        ),
        const SizedBox(height: 10),

        /// The screen this replaced printed `endAddress` in *both* rows, so
        /// the pickup line showed the destination. Each row reads its own
        /// field; a trip booked without a drop-off says so.
        TaTripCard(
          pickupLabel: AppLocale.pickup.tr,
          pickup: feeDisplayValue(data?.startAddress),
          dropOffLabel: AppLocale.destination.tr,
          dropOff: feeOptionalValue(data?.endAddress),
          noDropOffText: AppLocale.noDropOffMeter.tr,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: TaColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TaColors.border),
          ),
          child: Column(
            children: [
              TaKVRow(
                label: AppLocale.distance.tr,
                value: feeDisplayValue(data?.payment?.distance),
              ),
              TaKVRow(
                label: AppLocale.duration.tr,
                value: feeDisplayValue(data?.payment?.duration),
              ),
              TaKVRow(
                label: AppLocale.dateTime.tr,
                value: feeDateTime(data?.startTime),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
