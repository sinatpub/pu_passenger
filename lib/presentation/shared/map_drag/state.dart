import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../data/models/location_model.dart';

class MapDragState {
  /// Null until the map reports a position (P-05) — it used to be seeded with
  /// `LatLng(0, 0)`, which confirm handed back as a real pickup point.
  LatLng? latlng;
  bool isCameraMove = false;
  Timer? debounceTimer;
  LocationModel suggestLocationData = LocationModel();

  /// P-04: the query the current status describes.
  String searchQuery = '';

  /// P-04: a network search is in flight. Drives the "previous results stay
  /// visible but dimmed" behaviour the spec asks for.
  bool isSearching = false;

  /// P-04: the last search failed. Kept separate from an empty result set.
  bool hasSearchError = false;

  bool isTypingTextField = false;
  bool isShowMap = false;

  Prediction? selectedPrediction;

  GoogleMapController? mapController;

  // --- P-05: pickup label ---

  /// The reverse-geocoded address string. Null before first resolution.
  String? resolvedAddress;

  /// Reverse-geocode in flight. Spec: label goes to a skeleton, Confirm disabled.
  bool isResolving = false;

  /// Debounce timer for reverse-geocode calls on camera idle.
  Timer? geocodeDebounceTimer;

  /// P-05: the driver note. Wired to the text field in the map sheet.
  String? driverNote;
}

enum MapDragUpdate {
  search,
  fetchLocation,
  cameraMove,
  pickupLabel,

  /// The confirm CTA: whether it is on screen at all (map mode vs. search
  /// mode) and whether it is enabled. It has its own id because its state is
  /// the union of three others — the pin (`cameraMove`), the pickup label's
  /// resolution status (`pickupLabel`) and the mode switch (`search`) — and a
  /// `GetBuilder` can only carry one.
  confirm,
}
