import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/core/utils/vehicle_seat_capacity.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:com.tara.passenger/presentation/widgets/ta_vehicle_row.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:get/get.dart';

/// Masks a [SingleVehical] model into the presentational [VehicleData] the
/// shared rows render (roadmap C2/C3 — "name, seats, price/km and ETA from
/// existing model fields only").
///
/// Formatting lives here so the Home list and the Map sheet cannot drift:
/// price per km / "from" use today's formatter + KHR currency (PDD-01, D15
/// superseded), and the ETA is the deterministic `formatEtaMinutes` estimate
/// because the backend exposes no per-vehicle ETA.
VehicleData vehicleCellData(SingleVehical vehicle) {
  final pricePerKm = '${vehicle.price.toMoneyFormat()} '
      '${AppLocale.khmerCurrency.tr}/km';
  final priceFrom = vehicle.miniMunFare == null
      ? 'from —'
      : 'from ${vehicle.miniMunFare!.toMoneyFormat()} '
          '${AppLocale.khmerCurrency.tr}';
  return VehicleData(
    name: vehicle.name,
    seats: '${seatCapacityForVehicleId(vehicle.id)} '
        '${AppLocale.seatCapacity.tr}',
    pricePerKm: pricePerKm,
    priceFrom: priceFrom,
    eta: formatEtaMinutes(vehicle.id),
  );
}