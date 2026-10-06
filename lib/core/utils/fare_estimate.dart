import 'package:com.tara.passenger/core/utils/money.dart';

/// P-06 (docs/12) — `map_screen/logic.dart`'s on-screen fare-estimate
/// formula, the third of three near-identical variants across both apps
/// (docs/08 C-4) — same shape as pu_driver's own
/// `core/utils/fare_estimate.dart`.
///
/// The first kilometre is the minimum fare; each further kilometre adds the
/// per-km rate. Rounded to the cent: the rates are dollar decimals
/// (`0.30` per km), so rounding to a whole unit, as this did when prices
/// were whole riel, would turn `$1.70` into `$2`.
///
/// Display-only: `MapLogic.requestBooking()` never sends this value (or
/// the distance it's based on) to the backend — only lat/lng and vehicle
/// type — so there's no "fare to server" gap to fix here; the server
/// already computes the real charge independently of this estimate.
double estimateFare({
  required double distanceKm,
  required num pricePerKm,
  required num minimumFare,
}) {
  final fare = distanceKm <= 1.0
      ? minimumFare.toDouble()
      : (distanceKm - 1.0) * pricePerKm + minimumFare;
  return roundToCents(fare);
}
