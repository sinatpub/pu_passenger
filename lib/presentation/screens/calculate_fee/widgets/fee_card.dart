import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/utils/fee_presentation.dart';
import 'package:com.tara.passenger/core/utils/initials.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 10 — Fee (CalculateFee)'s receipt card: the driver row, the trip's
/// key/value rows and the route summary.
///
/// Extracted from `calculate_fee_screen.dart` (C6) — as C3 and C5 did — so the
/// degrade cases are widget-testable without `Get.put`ting the real
/// `CalculateFeeLogic`, which builds a network client in a field initializer.
/// Takes the model directly: nothing here reads a controller.
class FeeCard extends StatelessWidget {
  const FeeCard({super.key, required this.data});

  final Data? data;

  @override
  Widget build(BuildContext context) {
    return TaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Spec: no rating and no plate on the fee card — the trip is over,
          /// so identifying the vehicle no longer helps.
          TaDriverCard(
            name: data?.driver?.name ?? AppLocale.unKnown.tr,
            initials: initialsFromName(data?.driver?.name),
            vehicleInfo: data?.typeVehicle?.name ?? '---',
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: TaColors.border),
          const SizedBox(height: 10),
          TaKVRow(
            label: AppLocale.distance.tr,
            value: feeDisplayValue(data?.payment?.distance),
          ),
          TaKVRow(
            label: AppLocale.duration.tr,
            value: feeDisplayValue(data?.payment?.duration),
          ),
          TaKVRow(
            label: AppLocale.vehicle.tr,
            value: feeDisplayValue(data?.typeVehicle?.name),
          ),
          TaKVRow(
            label: AppLocale.dateTime.tr,
            value: feeDateTime(data?.startTime),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: TaColors.border),
          const SizedBox(height: 12),

          /// The screen this replaced printed `endAddress` in *both* rows, so
          /// the pickup line showed the destination. Each row now reads its
          /// own field.
          TaAddressRow(
            type: TaAddressType.pickup,
            label: AppLocale.pickup.tr,
            name: feeDisplayValue(data?.startAddress),
          ),
          const SizedBox(height: 10),
          TaAddressRow(
            type: TaAddressType.destination,
            label: AppLocale.destination.tr,
            name: feeDisplayValue(data?.endAddress),
          ),
        ],
      ),
    );
  }
}
