import 'dart:async';

import 'package:com.tara.passenger/mock/mock_backend.dart';
import 'package:com.tara.passenger/mock/mock_geo.dart';
import 'package:com.tara.passenger/mock/mock_mode.dart';
import 'package:com.tara.passenger/mock/mock_timings.dart';
import 'package:com.tara.passenger/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Simulated GPS for [LocationService]. The passenger's own position comes
/// from [MockBackend.passengerPosition] — the pickup the booking was made
/// from — so the map dot and the booking's `start_latitude/longitude` always
/// agree. Idle, the passenger is parked at the mock start.
class MockLocationSource implements PositionSource {
  MockLocationSource({MockBackend? backend}) : _backend = backend;

  static final MockLocationSource instance = MockLocationSource();

  final MockBackend? _backend;
  MockBackend get _b => _backend ?? MockBackend.instance;

  bool get _unavailable =>
      MockMode.settings.scenario == MockScenario.locationError;

  @override
  Future<bool> requestPermission() => Future.value(true);

  /// `LOCATION_ERROR`: permission is granted but no fix ever arrives — the
  /// same null the real source returns when the GPS times out.
  @override
  Future<Position?> getCurrentPosition() async =>
      _unavailable ? null : _position();

  @override
  Stream<Position> positionStream() {
    late StreamController<Position> controller;
    Timer? timer;
    LatLng? last;
    controller = StreamController<Position>(
      onListen: () {
        timer = Timer.periodic(MockTimings.gpsTick, (_) {
          if (_unavailable) return;
          final position = _position();
          final point = LatLng(position.latitude, position.longitude);
          // Like the real stream's distanceFilter: a parked passenger is
          // silent.
          if (last != null && distanceMeters(last!, point) < 1) return;
          last = point;
          controller.add(position);
        });
      },
      onCancel: () => timer?.cancel(),
    );
    return controller.stream;
  }

  Position _position() {
    final point = _b.passengerPosition;
    return Position(
      latitude: point.latitude,
      longitude: point.longitude,
      timestamp: DateTime.now(),
      accuracy: 5,
      altitude: 12,
      altitudeAccuracy: 3,
      heading: 0,
      headingAccuracy: 10,
      speed: 0,
      speedAccuracy: 1,
      isMocked: true,
    );
  }
}