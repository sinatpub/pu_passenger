import 'package:com.tara.passenger/presentation/screens/map_screen/map_presentation.dart';
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
}
