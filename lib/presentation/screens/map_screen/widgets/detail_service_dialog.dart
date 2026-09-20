import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/core/utils/vehicle_seat_capacity.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:com.tara.passenger/presentation/widgets/ta_minimax_sheet.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Opens the nested tariff sheet (`D7` / Screen 7 §Tariff) above the map's
/// bottom sheet. Replaces the old `DetailServiceDialog` modal with the shared
/// `TaMinMaxSheet` presentation — min fee, price/km and seats as KV rows.
///
/// Formatting stays with today's formatter + KHR currency (PDD-01, `D15`
/// superseded), matching the vehicle rows.
Future<void> openTariffSheet(
  BuildContext context, {
  required SingleVehical? vehicle,
}) {
  if (vehicle == null) return Future.value();
  final pricePerKm = '${vehicle.price.toMoneyFormat()} '
      '${AppLocale.khmerCurrency.tr}/${AppLocale.km.tr}';
  final minFee = vehicle.miniMunFare == null
      ? '—'
      : '${vehicle.miniMunFare!.toMoneyFormat()} '
          '${AppLocale.khmerCurrency.tr}';
  return TaMinMaxSheet.open(
    context,
    vehicleName: vehicle.name,
    minFee: minFee,
    pricePerKm: pricePerKm,
    seats:
        '${seatCapacityForVehicleId(vehicle.id)} ${AppLocale.seatCapacity.tr}',
  );
}