import 'package:com.tara.passenger/presentation/screens/map_screen/map_presentation.dart';
import 'package:com.tara.passenger/data/models/driver_around_model.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// P-06 (docs/12). Marker sets and camera bounds were computed inline in
/// MapLogic against mutable MapState, so they could only be exercised by
/// running the screen. These pin the behaviour as pure functions.
void main() {
  const phnomPenh = LatLng(11.5564, 104.9282);
  const toulKork = LatLng(11.5750, 104.8900);

  group('buildTripMarkers', () {
    test('no location yet means no markers', () {
      expect(buildTripMarkers(), isEmpty);
    });

    test('a pickup alone produces one marker', () {
      final markers = buildTripMarkers(currentLatLng: phnomPenh);

      expect(markers, hasLength(1));
      expect(markers.first.markerId, const MarkerId('current_location'));
      expect(markers.first.position, phnomPenh);
    });

    test('both ends produce two distinctly identified markers', () {
      final markers = buildTripMarkers(
        currentLatLng: phnomPenh,
        destinationLatLng: toulKork,
      );

      expect(markers, hasLength(2));
      expect(
        markers.map((m) => m.markerId).toSet(),
        {const MarkerId('current_location'), const MarkerId('destination_location')},
      );
    });

    test('a missing icon falls back to a default rather than dropping the '
        'marker', () {
      final markers = buildTripMarkers(
        currentLatLng: phnomPenh,
        destinationLatLng: toulKork,
      );

      // Icons load asynchronously; markers must render before they arrive.
      expect(markers, hasLength(2));
    });

    test('the destination address rides along as the info-window snippet', () {
      final markers = buildTripMarkers(
        destinationLatLng: toulKork,
        destinationAddress: '12 St 271',
      );

      expect(markers.first.infoWindow.snippet, '12 St 271');
    });
  });

  group('tripCameraBounds', () {
    test('no bounds until both ends are known', () {
      expect(tripCameraBounds(), isNull);
      expect(tripCameraBounds(currentLatLng: phnomPenh), isNull);
      expect(tripCameraBounds(destinationLatLng: toulKork), isNull);
    });

    test('southwest and northeast are taken per axis, so a trip heading '
        'south-west still produces valid bounds', () {
      // Destination is north and west of pickup: a naive
      // southwest=pickup/northeast=destination would be invalid.
      final bounds = tripCameraBounds(
        currentLatLng: phnomPenh,
        destinationLatLng: toulKork,
      )!;

      expect(bounds.southwest.latitude, lessThanOrEqualTo(bounds.northeast.latitude));
      expect(bounds.southwest.longitude, lessThanOrEqualTo(bounds.northeast.longitude));
      expect(bounds.southwest.latitude, phnomPenh.latitude);
      expect(bounds.southwest.longitude, toulKork.longitude);
    });

    test('bounds are the same whichever end is passed as pickup', () {
      final a = tripCameraBounds(
          currentLatLng: phnomPenh, destinationLatLng: toulKork)!;
      final b = tripCameraBounds(
          currentLatLng: toulKork, destinationLatLng: phnomPenh)!;

      expect(a.southwest, b.southwest);
      expect(a.northeast, b.northeast);
    });
  });

  Driver driverAt(int id, String lat, String lng) => Driver(
        id: id,
        lastLocation: LastLocation(latitude: lat, longitude: lng),
      );

  group('buildDriverMarkers', () {
    test('no driver data yields no markers', () {
      expect(buildDriverMarkers(drivers: null), isEmpty);
      expect(buildDriverMarkers(drivers: []), isEmpty);
    });

    test('each driver with a real position gets one marker, keyed by id', () {
      final markers = buildDriverMarkers(drivers: [
        driverAt(7, '11.55', '104.91'),
        driverAt(9, '11.57', '104.90'),
      ]);

      expect(markers, hasLength(2));
      expect(markers.map((m) => m.markerId).toSet(),
          {const MarkerId('driver_7'), const MarkerId('driver_9')});
    });

    test('a driver at null island is skipped, not drawn off the coast of '
        'Africa', () {
      final markers = buildDriverMarkers(drivers: [
        driverAt(1, '0.0', '0.0'),
        driverAt(2, '11.55', '104.91'),
      ]);

      expect(markers, hasLength(1));
      expect(markers.first.markerId, const MarkerId('driver_2'));
    });

    test('an unparseable position is skipped rather than crashing', () {
      final markers = buildDriverMarkers(drivers: [
        driverAt(1, 'not-a-number', ''),
        driverAt(2, '11.55', '104.91'),
      ]);

      expect(markers, hasLength(1));
      expect(markers.first.markerId, const MarkerId('driver_2'));
    });
  });

  group('MapState marker layers (the bug this split fixes)', () {
    test('the rendered set is both layers composed', () {
      final state = MapState();
      state.tripMarkers = buildTripMarkers(currentLatLng: phnomPenh);
      state.driverMarkers =
          buildDriverMarkers(drivers: [driverAt(7, '11.55', '104.91')]);

      expect(state.mapMarkers, hasLength(2));
    });

    test('replacing the trip layer does NOT erase the drivers', () {
      final state = MapState();
      state.driverMarkers =
          buildDriverMarkers(drivers: [driverAt(7, '11.55', '104.91')]);

      // This is what refreshMarkers() does, and it runs when the passenger
      // picks a destination. It used to replace the single shared set, so
      // every nearby car vanished off the map at exactly that moment.
      state.tripMarkers = buildTripMarkers(
        currentLatLng: phnomPenh,
        destinationLatLng: toulKork,
      );

      expect(state.driverMarkers, hasLength(1),
          reason: 'the driver layer is untouched by a trip-layer write');
      expect(state.mapMarkers, hasLength(3));
      expect(
        state.mapMarkers.map((m) => m.markerId.value),
        contains('driver_7'),
      );
    });

    test('clearing the trip layer on reset leaves the drivers alone', () {
      final state = MapState();
      state.driverMarkers =
          buildDriverMarkers(drivers: [driverAt(7, '11.55', '104.91')]);
      state.tripMarkers = buildTripMarkers(currentLatLng: phnomPenh);

      state.tripMarkers = {}; // the `reset == true` path

      expect(state.mapMarkers, hasLength(1));
      expect(state.mapMarkers.first.markerId, const MarkerId('driver_7'));
    });
  });
}
