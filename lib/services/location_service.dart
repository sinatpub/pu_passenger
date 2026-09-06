import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// The single owner of the app's live GPS subscription (F-05, docs/12).
///
/// Previously `GoogleMapLogic.updatePassengerMoveFromCurrentLocation()` opened
/// its own `Geolocator.getPositionStream` (docs/08 H-3) — reachable only
/// through the history-detail screen, where the values it wrote were never
/// read by anything, a pure battery-draining no-op. [start] is idempotent,
/// so every screen can call it safely; only the first call actually opens a
/// stream.
///
/// Unlike the driver app's `LocationService`, this does not itself POST to
/// the server on every tick — the passenger app currently has no continuous
/// location-reporting requirement (only a one-shot report at booking-request
/// time, done by the caller). Wiring live reporting to a trip's lifecycle is
/// P-08/P-09 territory, not attempted here.
class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  final StreamController<Position> _controller =
      StreamController<Position>.broadcast();
  StreamSubscription<Position>? _subscription;

  /// Live position updates. Does not itself start the subscription — call
  /// [start] once (repeat calls are no-ops).
  Stream<Position> get positionStream => _controller.stream;

  /// Opens the single live GPS subscription if one isn't already running.
  void start() {
    if (_subscription != null) return;
    _subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(_controller.add);
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }
}
