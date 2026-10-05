import 'package:com.tara.passenger/services/location_imp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// `parseDirectionsRoute` reads the Directions API's documented response:
/// `routes[0].overview_polyline.points` for the line, and each leg's
/// `distance.value` (metres) and `duration.value` (seconds).
void main() {
  // Stands in for the polyline decoder: one point per encoded character.
  List<LatLng> decode(String encoded) =>
      [for (var i = 0; i < encoded.length; i++) LatLng(i.toDouble(), 0)];

  Map<String, dynamic> body({List<Map<String, dynamic>>? legs}) => {
        'status': 'OK',
        'routes': [
          {
            'overview_polyline': {'points': 'abcd'},
            if (legs != null) 'legs': legs,
          },
        ],
      };

  Map<String, dynamic> leg(int metres, int seconds) => {
        'distance': {'text': 'x', 'value': metres},
        'duration': {'text': 'y', 'value': seconds},
      };

  test('one leg: the line, its length and its driving time', () {
    final route = parseDirectionsRoute(body(legs: [leg(1240, 250)]), decode);

    expect(route.points, hasLength(4));
    expect(route.distanceMeters, 1240);
    expect(route.duration, const Duration(seconds: 250));
  });

  test('several legs are summed', () {
    final route = parseDirectionsRoute(
        body(legs: [leg(1000, 200), leg(500, 100)]), decode);

    expect(route.distanceMeters, 1500);
    expect(route.duration, const Duration(seconds: 300));
  });

  test('no legs: the line is still drawn, the time is simply unknown', () {
    final route = parseDirectionsRoute(body(), decode);

    expect(route.points, hasLength(4));
    expect(route.distanceMeters, isNull);
    expect(route.duration, isNull);
  });

  test('a leg without a duration leaves the time unknown, not understated',
      () {
    final route = parseDirectionsRoute(
      body(legs: [
        leg(1000, 200),
        {
          'distance': {'value': 500},
        },
      ]),
      decode,
    );

    expect(route.distanceMeters, 1500);
    expect(route.duration, isNull);
  });

  test('no route found, or not a directions response at all: empty', () {
    for (final bad in [
      {'status': 'ZERO_RESULTS', 'routes': []},
      {'error_message': 'denied'},
      'not json',
      null,
    ]) {
      final route = parseDirectionsRoute(bad, decode);
      expect(route.points, isEmpty);
      expect(route.distanceMeters, isNull);
      expect(route.duration, isNull);
    }
  });
}
