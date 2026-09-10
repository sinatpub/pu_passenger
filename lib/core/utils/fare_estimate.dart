/// P-06 (docs/12) — `map_screen/logic.dart`'s on-screen fare-estimate
/// formula, the third of three near-identical variants across both apps
/// (docs/08 C-4) — same shape as pu_driver's own
/// `core/utils/fare_estimate.dart`. Rounds to the nearest whole unit,
/// matching the original inline `.roundToDouble()` call.
///
/// Display-only: `MapLogic.requestBooking()` never sends this value (or
/// the distance it's based on) to the backend — only lat/lng and vehicle
/// type — so there's no "fare to server" gap to fix here; the server
/// already computes the real charge independently of this estimate.
double estimateFare({
  required double distanceKm,
  required int pricePerKm,
  required int minimumFare,
}) {
  final fare = distanceKm <= 1.0
      ? minimumFare.toDouble()
      : (distanceKm - 1.0) * pricePerKm + minimumFare;
  return fare.roundToDouble();
}
