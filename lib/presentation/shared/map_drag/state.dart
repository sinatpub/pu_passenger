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
