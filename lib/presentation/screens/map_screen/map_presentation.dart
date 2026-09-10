import 'dart:math' as math;
import 'dart:ui' show Color, Offset;

import 'package:com.tara.passenger/data/models/driver_around_model.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// P-06 (docs/12, docs/08 Problem 15 / docs/09 L-10) — the presentation half
/// of `MapLogic`, extracted as pure functions.
///
/// `MapLogic` is the passenger app's god controller: at its peak it mixed
/// booking requests, GPS acquisition, geocoding, route drawing, nearby-driver
/// polling and map rendering in one class. The booking half moved out under
/// P-08 (`BookingSession`). This is the rendering half.
///
/// Everything here is a pure function of its inputs — no GetX, no controller,
/// no `BuildContext`, no map controller. That is the point: marker sets and
/// camera bounds were previously computed inline against mutable `MapState`
/// and could only be exercised by running the screen. `docs/07` §S-4/S-5
/// proposes eventually sharing map utilities across both apps; that is
/// blocked on Q-7, and keeping these free of app-specific types is what will
/// make the move cheap when Q-7 is answered.

/// The pickup and destination markers for the trip being composed.
///
/// Preserves the original behaviour exactly, including that a null icon falls
/// back to a default hue rather than dropping the marker, and that the
/// destination marker carries the address as its info-window snippet.
Set<Marker> buildTripMarkers({
  LatLng? currentLatLng,
  LatLng? destinationLatLng,
  BitmapDescriptor? sourceIcon,
  BitmapDescriptor? destinationIcon,
  String? destinationAddress,
}) {
  final markers = <Marker>{};

  if (currentLatLng != null) {
    markers.add(
      Marker(
        markerId: const MarkerId("current_location"),
        position: currentLatLng,
        icon: sourceIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "My Location"),
      ),
    );
  }

  if (destinationLatLng != null) {
    markers.add(
      Marker(
        markerId: const MarkerId("destination_location"),
        position: destinationLatLng,
        icon: destinationIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: "Destination", snippet: destinationAddress),
      ),
    );
  }

  return markers;
}

/// The camera bounds that contain both ends of the trip.
///
/// Returns null when either end is missing, which is the caller's signal to
/// leave the camera alone — the original inline version guarded on exactly
/// that and returned early.
///
/// Note this deliberately keeps the original's ordering behaviour: the
/// southwest corner takes the minimum of each axis independently, so the
/// bounds are correct regardless of which end is further north or east. A
/// naive `southwest: pickup, northeast: destination` would throw whenever the
/// passenger travelled south or west.
LatLngBounds? tripCameraBounds({
  LatLng? currentLatLng,
  LatLng? destinationLatLng,
}) {
  if (currentLatLng == null || destinationLatLng == null) return null;

  final minLat =
      math.min(currentLatLng.latitude, destinationLatLng.latitude);
  final maxLat =
      math.max(currentLatLng.latitude, destinationLatLng.latitude);
  final minLng =
      math.min(currentLatLng.longitude, destinationLatLng.longitude);
  final maxLng =
      math.max(currentLatLng.longitude, destinationLatLng.longitude);

  return LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );
}

/// Markers for the drivers currently available nearby.
///
/// Kept as its own layer rather than written into the same set as the trip
/// markers. They used to share one mutable `state.mapMarkers`, with two
/// writers racing over it: `refreshMarkers()` *replaced* the set wholesale,
/// and it runs when the passenger picks a destination — so every nearby-driver
/// marker disappeared off the map at that moment, and nothing put them back
/// until the next `getAvailableDriver()`. Selecting a destination and watching
/// the cars vanish is the bug that shape produces. Composing two layers means
/// neither writer can erase the other.
///
/// Drivers whose last known position is unparseable, or the null-island
/// `(0, 0)` the backend uses for "no fix", are skipped — the original code did
/// this and it is load-bearing: a driver rendered off the coast of Africa is
/// worse than one not rendered at all.
Set<Marker> buildDriverMarkers({
  required List<Driver>? drivers,
  BitmapDescriptor? driverIcon,
  void Function(Driver driver)? onTap,
}) {
  if (drivers == null) return {};

  final markers = <Marker>{};
  for (final driver in drivers) {
    final lat = double.tryParse(driver.lastLocation?.latitude ?? '') ?? 0.0;
    final lng = double.tryParse(driver.lastLocation?.longitude ?? '') ?? 0.0;
    if (lat == 0.0 && lng == 0.0) continue;

    markers.add(
      Marker(
        markerId: MarkerId("driver_${driver.id}"),
        position: LatLng(lat, lng),
        icon: driverIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        anchor: const Offset(0.5, 0.5),
        flat: true,
        onTap: onTap == null ? null : () => onTap(driver),
      ),
    );
  }
  return markers;
}

/// The driving route as a single map polyline.
Set<Polyline> buildRoutePolyline({
  required List<PointLatLng> points,
  required Color color,
}) {
  if (points.isEmpty) return {};

  return {
    Polyline(
      polylineId: const PolylineId("route"),
      color: color,
      points: [
        for (final p in points) LatLng(p.latitude, p.longitude),
      ],
      width: 5,
      jointType: JointType.round,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    ),
  };
}

/// Renders a distance in kilometres as `"<km> km <m> m"`.
///
/// The original did this inline as:
///
/// ```dart
/// int km = distanceInKm.floor();
/// int meters = ((distanceInKm - km) * 1000).round();
/// ```
///
/// which reads correctly and is wrong at the boundary: the metres component
/// is rounded independently of the kilometres it was derived from, so
/// `2.9996` floors to `2 km` and then rounds the remainder to `1000 m` —
/// the passenger is shown **"2 km 1000 m"**. Rounding to whole metres first
/// and deriving both components from that result keeps them consistent.
String formatDistance(double distanceInKm) {
  final totalMetres = (distanceInKm * 1000).round();
  final km = totalMetres ~/ 1000;
  final metres = totalMetres % 1000;
  return "$km km $metres m";
}
