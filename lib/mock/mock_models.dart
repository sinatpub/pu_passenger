import 'package:com.tara.passenger/mock/mock_fixtures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A request as the mock backend sees it — transport-neutral, so the backend
/// is testable without Dio.
class MockRequest {
  const MockRequest({
    required this.method,
    required this.path,
    this.query = const {},
    this.body = const {},
    this.authenticated = false,
  });

  final String method;
  final String path;
  final Map<String, dynamic> query;
  final Map<String, dynamic> body;

  /// Whether the request carried an `Authorization` header.
  final bool authenticated;
}

class MockResponse {
  const MockResponse(this.statusCode, this.data);
  final int statusCode;
  final Object? data;
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// Thrown for `NETWORK_ERROR`; the interceptor turns it into the same
/// `DioException` a dropped connection produces.
class MockConnectionFailure implements Exception {
  const MockConnectionFailure();
}

/// A server → passenger socket push (`rideAccepted`, `driverArrival`, …).
class MockSocketEvent {
  const MockSocketEvent(this.name, this.data);
  final String name;
  final Map<String, dynamic> data;
}

/// One mock booking from the passenger's side. `status` uses the real server
/// codes from `core/utils/status_util.dart`.
class MockRide {
  MockRide({
    required this.id,
    required this.status,
    required this.driverStart,
    required this.createdAt,
    required this.paymentMethod,
    this.pickup,
    this.destination,
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.endPoint,
    this.distanceKm,
    this.fare,
  });

  final int id;
  int status;

  /// Where the simulated driver was parked when the request was made.
  final LatLng driverStart;

  /// Where the passenger is being picked up. Defaults to the mock start.
  final LatLng? pickup;

  /// Null for a no-destination ride.
  final LatLng? destination;
  final DateTime createdAt;
  final String paymentMethod;
  DateTime? acceptedAt;
  DateTime? arrivedAt;
  DateTime? startedAt;
  DateTime? completedAt;
  LatLng? endPoint;
  double? distanceKm;
  int? fare;

  LatLng get pickUpPoint => pickup ?? MockPlaces.passengerStart.latLng;

  /// Where the simulated car drives once the trip starts. A ride with no
  /// destination still goes somewhere.
  LatLng get driveTarget => destination ?? MockPlaces.destination.latLng;

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'driverStart': _latLngToJson(driverStart),
        'pickup': pickup == null ? null : _latLngToJson(pickup!),
        'destination': destination == null ? null : _latLngToJson(destination!),
        'createdAt': createdAt.toIso8601String(),
        'paymentMethod': paymentMethod,
        'acceptedAt': acceptedAt?.toIso8601String(),
        'arrivedAt': arrivedAt?.toIso8601String(),
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'endPoint': endPoint == null ? null : _latLngToJson(endPoint!),
        'distanceKm': distanceKm,
        'fare': fare,
      };

  factory MockRide.fromJson(Map<String, dynamic> json) => MockRide(
        id: json['id'] as int,
        status: json['status'] as int,
        driverStart: _latLngFromJson(json['driverStart'])!,
        pickup: _latLngFromJson(json['pickup']),
        destination: _latLngFromJson(json['destination']),
        createdAt: DateTime.parse(json['createdAt'] as String),
        paymentMethod: json['paymentMethod'] as String,
        acceptedAt: _dateOrNull(json['acceptedAt']),
        arrivedAt: _dateOrNull(json['arrivedAt']),
        startedAt: _dateOrNull(json['startedAt']),
        completedAt: _dateOrNull(json['completedAt']),
        endPoint: _latLngFromJson(json['endPoint']),
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
        fare: json['fare'] as int?,
      );
}

Map<String, double> _latLngToJson(LatLng p) =>
    {'lat': p.latitude, 'lng': p.longitude};

LatLng? _latLngFromJson(Object? json) {
  if (json is! Map) return null;
  return LatLng(
      (json['lat'] as num).toDouble(), (json['lng'] as num).toDouble());
}

DateTime? _dateOrNull(Object? v) => v is String ? DateTime.parse(v) : null;
