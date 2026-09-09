import 'dart:math' as math;

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
