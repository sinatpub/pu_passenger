import 'package:com.tara.passenger/core/utils/money.dart';
import 'package:com.tara.passenger/core/utils/vehicle_art.dart';
import 'package:com.tara.passenger/core/utils/vehicle_kind.dart';
import 'package:com.tara.passenger/core/utils/vehicle_seat_capacity.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:com.tara.passenger/presentation/widgets/ta_vehicle_row.dart';
import 'package:flutter_svg/svg.dart';

/// Masks a [SingleVehical] model into the presentational [VehicleData] the
/// shared rows render (roadmap C2/C3 — "name, seats, price/km and ETA from
/// existing model fields only").
///
/// Formatting lives here so the Home list and the Map sheet cannot drift:
/// price per km / "from" are dollars through [formatMoney], and the ETA is the deterministic `formatEtaMinutes` estimate
/// because the backend exposes no per-vehicle ETA. The art, seats and ETA
/// follow the kind of vehicle the type's name describes (`vehicle_kind.dart`).
VehicleData vehicleCellData(SingleVehical vehicle) {
  final pricePerKm = '${formatMoney(vehicle.price)}/km';
  final priceFrom = vehicle.miniMunFare == null
      ? 'from —'
      : 'from ${formatMoney(vehicle.miniMunFare!)}';
  final kind = vehicleKindFromName(vehicle.name);
  final art = vehicleArtAsset(kind);
  return VehicleData(
    name: vehicle.name,
    seats: seatsLabel(kind),
    pricePerKm: pricePerKm,
    priceFrom: priceFrom,
    eta: formatEtaMinutes(kind),
    art: art == null ? null : SvgPicture.asset(art),
  );
}