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
  // LatLng selectedPlaceLatLng = LatLng(0, 0);

  /// P-04: the query the current status describes.
  ///
  /// Held here rather than read back off the text controller: the controller
  /// is the view's, and deriving status from it lets the two disagree
  /// whenever a search is triggered by anything other than typing.
  String searchQuery = '';

  /// P-04: a network search is in flight. Drives the "previous results stay
  /// visible but dimmed" behaviour the spec asks for.
  bool isSearching = false;

  /// P-04: the last search failed. Kept separate from an empty result set —
  /// "nothing matched" and "we could not look" are different messages.
  bool hasSearchError = false;

  bool isTypingTextField = false;
  bool isShowMap = false;

  Prediction? selectedPrediction;

  GoogleMapController? mapController;
}

enum MapDragUpdate {
  search,
  fetchLocation,
  cameraMove,
}
