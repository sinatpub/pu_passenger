import 'package:com.tara.passenger/core/utils/vehicle_kind.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:get/get.dart';

/// Passenger seats per kind of vehicle. The backend sends no seat count for
/// a vehicle type, so the app states the usual one. A type it does not
/// recognise is taken to be a car.
int seatCapacityFor(VehicleKind? kind) => switch (kind) {
      VehicleKind.moto => 1,
      VehicleKind.tukTuk => 3,
      VehicleKind.miniVan => 7,
      VehicleKind.vip => 5,
      VehicleKind.car || VehicleKind.suv || null => 4,
    };

/// "1 Seat", "3 Seats" — a moto carries one, and "1 Seats" is not English.
String seatsLabel(VehicleKind? kind) {
  final seats = seatCapacityFor(kind);
  return '$seats ${(seats == 1 ? AppLocale.seat : AppLocale.seatCapacity).tr}';
}

/// C2 (docs/roadmap) — Display ETA per kind of vehicle (minutes) used by the
/// home vehicle list. The backend provides no ETA per vehicle type, so this
/// is a practical placeholder until the API exposes a real one: the smaller
/// the vehicle, the more of them are near.
int etaMinutesFor(VehicleKind? kind) => switch (kind) {
      VehicleKind.moto || VehicleKind.tukTuk => 2,
      VehicleKind.car => 3,
      VehicleKind.miniVan || VehicleKind.suv => 4,
      VehicleKind.vip || null => 5,
    };

String formatEtaMinutes(VehicleKind? kind) => '~${etaMinutesFor(kind)} min';
