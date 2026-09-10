import 'dart:async';
import 'dart:typed_data';
import 'package:com.tara.passenger/app/state.dart';
import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/core/utils/load_custom_marker.dart';
import 'package:com.tara.passenger/core/utils/pretty_logger.dart';
import 'package:com.tara.passenger/presentation/widgets/error_dialog_widget.dart';
import 'package:com.tara.passenger/service/location_imp.dart';
import 'package:com.tara.passenger/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../translations/app_locale.dart';

class GoogleMapLogic extends GetxController {
  final GoogleMapState parentState = GoogleMapState();
  final LocationRepo _locationRepo = LocationRepo();
  final PolylinePoints polylinePoints = PolylinePoints();

  final Rx<CameraPosition> cameraPosition = const CameraPosition(
          target: LatLng(0.0, 0.0), zoom: AppConstant.initZoomLevel)
      .obs;
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();

  StreamSubscription<Position>? _positionStream;

  @override
  void onInit() {
    super.onInit();
    requestPermissionLocation();
    loadCustomMarkerIcon();
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    LocationService.instance.stop();
    super.onClose();
  }

  // * 1. Check & Request Permission
  void requestPermissionLocation() async {
    try {
      bool permissionGranted = await _locationRepo.checkPermission();
      if (!permissionGranted) {
        await _locationRepo.requestLocationPermission();
      }
      getCurrentLocation();
    } catch (e) {
      Logger().e("Error requesting permission: $e");
    }
  }

  // * 2. Get and Store Passenger Location
  void getCurrentLocation() async {
    try {
      var location = await _locationRepo.getCurrentLocation();
      if (location != null) {
        parentState.latitude.value = location.latitude;
        parentState.longtitude.value = location.longitude;
        navigateToCurrentLocation();
        // update current location of passenger move
        updatePassengerMoveFromCurrentLocation();
      }
    } catch (e) {
      Logger().e("Error getting current location: $e");
    }
  }

  void navigateToCurrentLocation({double? zoom}) async {
    if (!mapController.isCompleted) {
      return;
    }

    final controller = await mapController.future;

    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target:
              LatLng(parentState.latitude.value, parentState.longtitude.value),
          zoom: zoom ?? AppConstant.initZoomLevel),
    ));
  }

  Future<void> navigateTo({required LatLng location, double? zoom}) async {
    if (!mapController.isCompleted) {
      return;
    }
    final controller = await mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: location, zoom: zoom ?? AppConstant.initZoomLevel),
      ),
    );
  }

  // * 4. Add Marker
  void addMarker(
      {required LatLng position,
      required String id,
      BitmapDescriptor? icon,
      double? rotation,
      String? title}) {
    parentState.markers.add(
      Marker(
        markerId: MarkerId(id),
        position: position,
        rotation: rotation ?? 0.0,
        icon: icon ?? BitmapDescriptor.defaultMarker,
        anchor: const Offset(0.5, 0.5),
        zIndex: 1,
        infoWindow: title != null
            ? InfoWindow(
                title: title,
              )
            : InfoWindow.noText,
      ),
    );
  }

  // * 5. Remove Marker
  void removeMarker(String id) {
    parentState.markers.removeWhere((m) => m.markerId.value == id);
  }

  // * 6. Draw Polyline
  Future<void> drawPolyline(
      {required LatLng startLatLng,
      required LatLng endLatLng,
      Color? polylineColor}) async {
    try {
      if (endLatLng.latitude != 0.0 && endLatLng.longitude != 0.0) {
        final result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: AppConstant.googleKeyApi,
          request: PolylineRequest(
            origin: PointLatLng(startLatLng.latitude, startLatLng.longitude),
            destination: PointLatLng(endLatLng.latitude, endLatLng.longitude),
            mode: TravelMode.driving,
          ),
        );

        if (result.status == 'OK' && result.points.isNotEmpty) {
          parentState.polylines.clear();
          parentState.polylines.add(Polyline(
            polylineId: const PolylineId("driverRoute"),
            color: polylineColor ?? AppColors.main,
            points: result.points
                .map(
                  (point) => LatLng(point.latitude, point.longitude),
                )
                .toList(),
            width: 5,
          ));
          update();
          Logger().i("Polylines: ${parentState.polylines.value.length}");
        }
      }
    } catch (e) {
      Logger().e("Error drawing polyline: $e");
    }
  }

  // * 7. Remove Polyline
  void removePolyline(String id) {
    parentState.polylines.removeWhere((p) => p.polylineId.value == id);
  }

  // * 8. Update Driver Location (from socket)
  void updateDriverLocation(LatLng position) {
    removeMarker('driver');
    addMarker(position: position, id: 'driver');
  }

  // * 9. OnCreatedMap
  Future<void> onMapCreated(
      {required GoogleMapController? controller, bool? isWhereToGo}) async {
    if (controller == null) return;

    if (!mapController.isCompleted) {
      mapController.complete(controller);
      Logger().i("✅ Google Map is ready.");

      final position = await _locationRepo.getCurrentLocation();
      if (position != null) {
        final latLng = LatLng(position.latitude, position.longitude);
        if (isWhereToGo != true) {
          parentState.latitude.value = latLng.latitude;
          parentState.longtitude.value = latLng.longitude;
        }
        getAddressOfLocation(latlng: LatLng(latLng.latitude, latLng.longitude));
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: AppConstant.initZoomLevel),
          ),
        );
        Logger().i("📍 Moved to current location: $latLng");
      }
    } else {
      Logger().w("⚠️ Map controller already completed.");
    }
  }

  Future<void> updatePassengerMoveFromCurrentLocation() async {
    LocationService.instance.start();
    _positionStream =
        LocationService.instance.positionStream.listen((Position position) {
      parentState.latitude.value = position.latitude;
      parentState.longtitude.value = position.longitude;
      Logger().i(
          "📍 Updated user location: ${position.latitude}, ${position.longitude}");
    });
  }

  // * 10. Get address
  Future<void> getAddressOfLocation({required LatLng latlng}) async {
    try {
      String addressLocation =
          await _locationRepo.getAddressLocation(latlng: latlng);

      if (addressLocation == AppLocale.addressNotFound.tr) {
        showErrorCustomDialog(Get.context!, AppLocale.addressNotFound.tr,
            AppLocale.desAddressNotFound.tr, () {
          Get.back();
          // Get.back();
        }, isDismiss: false);
      }

      parentState.addressOfPassenger.value = addressLocation;
    } catch (e) {
      Logger().e("Error Get address of location: $e");
    }
  }

  // * 11. Load Marker
  Future<void> loadCustomMarkerIcon() async {
    final Uint8List markerDriverImage =
        await loadImageFromAssets('assets/marker/car_marker.png');
    final Uint8List markerPassengerImage =
        await loadImageFromAssets(ImageAssets.passengerIconMarker);

    final Uint8List destineMarker =
        await loadImageFromAssets('assets/marker/destination_icon.png');

    parentState.passengerMarker =
        BitmapDescriptor.bytes(markerPassengerImage, width: 84, height: 84);
    parentState.driverMarker =
        BitmapDescriptor.bytes(markerDriverImage, width: 84, height: 84);

    parentState.destinationBitmap = BitmapDescriptor.bytes(destineMarker,
        width: 48, height: 48, bitmapScaling: MapBitmapScaling.none);
  }

  // * 12 draw polyline with return value
  /// * 6. Draw Polyline (Returns a Set<Polyline>)
  Future<Set<Polyline>?> drawPolylineWithReturnValue({
    required LatLng startLatLng,
    required LatLng endLatLng,
    Color? polylineColor,
  }) async {
    tlog("Drawing Polyline from $startLatLng to $endLatLng");

    try {
      final result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: AppConstant.googleKeyApi,
        request: PolylineRequest(
          origin: PointLatLng(startLatLng.latitude, startLatLng.longitude),
          destination: PointLatLng(endLatLng.latitude, endLatLng.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.status == 'OK' && result.points.isNotEmpty) {
        final polylineId =
            PolylineId("route-${DateTime.now().millisecondsSinceEpoch}");

        final points = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        final polyline = Polyline(
          polylineId: polylineId,
          color: polylineColor ?? Colors.blue,
          points: points,
          width: 5,
        );

        final Set<Polyline> polylineSet = {polyline};
        return polylineSet;
      }

      return null;
    } catch (e) {
      Logger().e("Error drawing polyline: $e");
      return null;
    }
  }
}
