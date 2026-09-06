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
