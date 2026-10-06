import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/utils/money.dart';
import 'package:com.tara.passenger/core/utils/vehicle_kind.dart';
import 'package:com.tara.passenger/core/utils/vehicle_seat_capacity.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:com.tara.passenger/presentation/widgets/ta_minimax_sheet.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Opens the nested tariff sheet (`D7` / Screen 7 §Tariff) above the map's
/// bottom sheet. Replaces the old `DetailServiceDialog` modal with the shared
/// `TaMinMaxSheet` presentation — min fee, price/km and seats as KV rows.
///
/// Amounts are dollars through [formatMoney], matching the vehicle rows.
Future<void> openTariffSheet(
  BuildContext context, {
  required SingleVehical? vehicle,
}) {
  if (vehicle == null) return Future.value();
  final pricePerKm = '${formatMoney(vehicle.price)}/${AppLocale.km.tr}';
  final minFee =
      vehicle.miniMunFare == null ? '—' : formatMoney(vehicle.miniMunFare!);
  return TaMinMaxSheet.open(
    context,
    vehicleName: vehicle.name,
    minFee: minFee,
    pricePerKm: pricePerKm,
    seats: seatsLabel(vehicleKindFromName(vehicle.name)),
  );
}