import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../data/models/location_model.dart';

class MapDragState {
  String title = "";
  LatLng? latlng = LatLng(0.0, 0.0);
  bool isCameraMove = false;
  Timer? debounceTimer;
  LocationModel suggestLocationData = LocationModel();
  // LatLng selectedPlaceLatLng = LatLng(0, 0);

  bool isTypingTextField = false;
  bool isShowMap = false;

  String? selectedLocationId;
  Prediction? selectedPrediction;

  GoogleMapController? mapController;
}

enum MapDragUpdate {
  search,
  fetchLocation,
  cameraMove,
}
