import 'dart:async';
import 'package:com.tara.passenger/data/models/driver_around_model.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState {
  int? vehicleTypeId;
  GoogleMapController? mapController;

  SingleVehical? vehicleTypeSelection;

  Set<Marker> mapMarkers = {};
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
