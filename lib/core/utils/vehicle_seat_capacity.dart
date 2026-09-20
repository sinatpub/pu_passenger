/// P-06 (docs/12) — `map_screen/logic.dart`'s `getVehicleSet()` mapped
/// vehicle-type ID to seat count via a nested ternary of hardcoded magic
/// numbers (docs/01 Problem 7). Pulled out to a lookup table so the mapping
/// is readable and testable; behavior is unchanged, including the implicit
/// default (any id not 1-4 gets 5 seats). IDs match the vehicle-type
/// scheme used by `driverMarkerImage()` in the same feature.
const Map<int, int> _seatCapacityByVehicleId = {
  1: 3, // rickshaw
  2: 4, // classic car
  3: 7, // mini van
  4: 4, // suv
};

int seatCapacityForVehicleId(int? vehicleId) {
  return _seatCapacityByVehicleId[vehicleId] ?? 5; // 5 = default (alphard/vip and unknown)
}

/// C2 (docs/roadmap) — Display ETA per vehicle class (minutes) used by the
/// home vehicle list. The backend provides no ETA per vehicle type, so this
/// follows the same deterministic-lookup pattern as [seatCapacityForVehicleId]:
/// a practical placeholder until the API exposes a real ETA.
const Map<int, int> _etaByVehicleId = {
  1: 2,  // rickshaw
  2: 3,  // classic car
  3: 4,  // mini van
  4: 4,  // suv
};

int etaMinutesForVehicleId(int? vehicleId) {
  return _etaByVehicleId[vehicleId] ?? 5; // default (alphard/vip)
}

String formatEtaMinutes(int? vehicleId) {
  return '~${etaMinutesForVehicleId(vehicleId)} min';
}
