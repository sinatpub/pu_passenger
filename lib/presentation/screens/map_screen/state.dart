import 'package:com.tara.passenger/data/models/driver_around_model.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState {
  int? vehicleTypeId;
  GoogleMapController? mapController;

  SingleVehical? vehicleTypeSelection;

  /// P-06: markers are two independent layers, not one shared set.
  ///
  /// Trip markers (pickup, destination) and nearby-driver markers have
  /// different owners and different lifetimes. While they shared a single
  /// mutable set, whichever writer ran last erased the other — see
  /// `buildDriverMarkers` in `map_presentation.dart` for the symptom.
  Set<Marker> tripMarkers = {};
  Set<Marker> driverMarkers = {};

  /// What the map renders: both layers composed.
  Set<Marker> get mapMarkers => {...tripMarkers, ...driverMarkers};
  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;

  BitmapDescriptor? driverIcon;

  BitmapDescriptor? destinationBitmap;
  BitmapDescriptor? passengerBitMap;
  BitmapDescriptor? driverMarkerBitMap;

  /// * Service Type

  Rx<BitmapDescriptor> serviceMarker =
      Rx<BitmapDescriptor>(BitmapDescriptor.defaultMarker);

  // Load PNG image from assets and convert to BitmapDescriptor
  bool isCameraMove = false;
  Rx<bool> isSelectedCurrentLocation = false.obs;
  int? serviceTypeId;

  // * Current Address
  String? currentAddress;
  LatLng? currentLatLng;

  // Destination
  String? destinationAddress;
  LatLng? destinationLatLng;

  String distance = "";
  double totalFare = 0.0;

  Set<Polyline> polylines = {};

  // Driver Around
  DriverAroundModel? driverAroundData;

  // booking loading
  bool isBookingLoading = false;
}

enum MapUpdate {
  mapID,
  vehicleID,
  bookingID,
}
