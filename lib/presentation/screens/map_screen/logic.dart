import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:com.tara.passenger/app/google_map_logic.dart';
import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:com.tara.passenger/core/utils/fare_estimate.dart';
import 'package:com.tara.passenger/core/utils/load_custom_marker.dart';
import 'package:com.tara.passenger/data/datasources/cancel_booking_api.dart';
import 'package:com.tara.passenger/data/datasources/check_request_book_source.dart';
import 'package:com.tara.passenger/data/datasources/driver_around_api.dart';
import 'package:com.tara.passenger/data/datasources/request_booking_api.dart';
import 'package:com.tara.passenger/data/datasources/update_passenger_location_api.dart';
import 'package:com.tara.passenger/data/models/driver_around_model.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:com.tara.passenger/presentation/screens/home/logic.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/state.dart';
import 'package:com.tara.passenger/presentation/widgets/error_dialog_widget.dart';
import 'package:com.tara.passenger/presentation/widgets/fbtn_widget.dart';
import 'package:com.tara.passenger/presentation/widgets/g_showmodal_bottom.dart';
import 'package:com.tara.passenger/presentation/widgets/x_network_image.dart';
import 'package:com.tara.passenger/presentation/widgets/yesno_dialog_widget.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/service/location_imp.dart';
import 'package:com.tara.passenger/taxi_single_ton/init_socket.dart';
import 'package:com.tara.passenger/taxi_single_ton/taxi_notification.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/resources/asset_resource.dart';

class MapLogic extends GetxController {
  final HomeLogic homeLogic = Get.find<HomeLogic>();
  final RequestBookingApi requestBookingApi = RequestBookingApi();
  CancelBookingApi cancelBookingRepo = CancelBookingApi();
  final MapState state = MapState();
  final GetDriverAroundDataSource driverRepo =
      Get.find<GetDriverAroundDataSource>();
  final LocationRepo _locationRepo = Get.find<LocationRepo>();

  PassengerSocketService socket = Get.find<PassengerSocketService>();
  final UpdatePassengerLocationApi updatePassengerLocationApi =
      Get.find<UpdatePassengerLocationApi>();

  @override
  void onInit() {
    var arg = Get.arguments;
    if (arg != null) {
      state.vehicleTypeId = arg?['vehicleId'];
    }
    super.onInit();
  }

  @override
  void onReady() async {
    getVehicleTypeSelection();
    await _loadMarkerIcons();
    await getAvailableDriver();
    super.onReady();
  }

  Future<void> _loadMarkerIcons() async {
    // Load and resize source icon
    final Uint8List sourceBytes =
        await getBytesFromAsset(ImageAssets.passengerMarker, 45);
    state.sourceIcon = BitmapDescriptor.bytes(sourceBytes);

    // Load and resize destination icon
    final Uint8List destBytes =
        await getBytesFromAsset(ImageAssets.destinationMarker, 45);
    state.destinationIcon = BitmapDescriptor.bytes(destBytes);
    final Uint8List driverBytes = await getBytesFromAsset(
        driverMarkerImage(id: state.vehicleTypeSelection?.id ?? 0), 25);
    state.driverIcon = BitmapDescriptor.bytes(driverBytes);
    update([MapUpdate.mapID]);
  }

  void refreshMarkers() {
    Set<Marker> newMarkers = {};

    // 1. Add Current Location Marker
    if (state.currentLatLng != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId("current_location"),
          position: state.currentLatLng!,
          icon: state.sourceIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: "My Location"),
        ),
      );
    }

    // 2. Add Destination Marker
    if (state.destinationLatLng != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId("destination_location"),
          position: state.destinationLatLng!,
          icon: state.destinationIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
              title: "Destination", snippet: state.destinationAddress),
        ),
      );
    }

    state.mapMarkers = newMarkers;
    update([MapUpdate.mapID]);
  }

  void getVehicleTypeSelection() {
    var vehicle = homeLogic.state.vehicleAllType?.data
        .firstWhereOrNull((e) => e.id == (state.vehicleTypeId ?? 0));
    if (vehicle != null) {
      state.vehicleTypeSelection = vehicle;
      update([MapUpdate.vehicleID]);
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    EasyLoading.show();
    state.mapController = controller;
    // 1. Get real location immediately
    var pos = await _locationRepo.getCurrentLocation();
    if (pos != null) {
      LatLng userLatLng = LatLng(pos.latitude, pos.longitude);
      updateCurrentLatLng(latLng: userLatLng);
      state.mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLatLng, zoom: 15),
        ),
      );
    }
    EasyLoading.dismiss();
  }

  void onCameraIdle() async {
    if (state.mapController == null) return;
    // 1. Get the center coordinates of the map
    LatLngBounds visibleRegion = await state.mapController!.getVisibleRegion();
    LatLng centerLatLng = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) /
          2,
    );

    // 2. Update the passenger's current/pickup location
    updateCurrentLatLng(latLng: centerLatLng);
  }

  /// Current Location
  void updateCurrentLatLng({required LatLng latLng}) async {
    state.currentLatLng = latLng;
    await getCurrentAddress();
  }

  Future<void> moveToCurrentLocation() async {
    var pos = await _locationRepo.getCurrentLocation();

    if (pos != null && state.mapController != null) {
      CameraUpdate update = CameraUpdate.newLatLngZoom(
        LatLng(pos.latitude, pos.longitude),
        15.d,
      );

      state.mapController!.animateCamera(update);
    } else {
      Get.snackbar("Error", "Could not find your location");
    }
  }

  Future<void> getCurrentAddress({LatLng? latlng}) async {
    try {
      var latLng = state.currentLatLng;
      if (latLng == null) {
        state.currentAddress = AppLocale.error.tr;
      }
      String address = await _locationRepo.getAddressLocation(latlng: latLng!);
      state.currentAddress = address;
      update([MapUpdate.mapID]);
    } catch (e) {}
  }

  /// Destination Location
  void updateDestinationLocation(
      {required LatLng latLng, bool? reset = false}) async {
    try {
      if (reset == true) {
        state.destinationAddress = null;
        state.destinationLatLng = null;
        state.distance = "";
        state.totalFare = 0.0;
        state.polylines = {};
        state.mapMarkers = {};
        update([MapUpdate.mapID]);
        moveToCurrentLocation();
        return;
      }
      if (state.destinationLatLng == latLng) return;
      EasyLoading.show();
      state.destinationLatLng = latLng;
      state.destinationAddress =
          await _locationRepo.getAddressLocation(latlng: latLng);
      await calculateDistance();
      await drawPolyline();
      refreshMarkers();
      update([MapUpdate.mapID]);
    } catch (e) {
      Logger().e("Exception $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> calculateDistance() async {
    if (state.destinationLatLng == null) return;

    var vehicle = state.vehicleTypeSelection;
    double distanceInKm = await _locationRepo.getDistance(
      start:
          LatLng(state.currentLatLng!.latitude, state.currentLatLng!.longitude),
      destination: state.destinationLatLng!,
    );

    int km = distanceInKm.floor();
    int meters = ((distanceInKm - km) * 1000).round();

    state.distance = "$km km $meters m";

    // Calculate price
    state.totalFare = estimateFare(
      distanceKm: distanceInKm,
      pricePerKm: vehicle?.price ?? 1,
      minimumFare: vehicle?.miniMunFare ?? 1,
    );
  }

  /// Draw Polyline
  // Inside MapLogic class
  Future<void> drawPolyline() async {
    if (state.currentLatLng == null || state.destinationLatLng == null) return;

    PolylinePoints polylinePoints = PolylinePoints();

    // 1. Fetch points from Google Directions API
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: AppConstant.googleKeyApi,
      request: PolylineRequest(
        origin: PointLatLng(
            state.currentLatLng!.latitude, state.currentLatLng!.longitude),
        destination: PointLatLng(state.destinationLatLng!.latitude,
            state.destinationLatLng!.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = [];
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      // 2. Create the Polyline object
      Polyline polyline = Polyline(
        polylineId: const PolylineId("route"),
        color: AppColors.main, // Your theme color
        points: polylineCoordinates,
        width: 5, // Thickness of the line
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      );

      // 3. Update state and UI
      state.polylines = {polyline};

      // 4. Zoom the camera to fit the entire trip
      Future.delayed(const Duration(milliseconds: 300), () => _fitBounds());

      update([MapUpdate.mapID]);
    }
  }

  // Helper to zoom the map so both markers are visible
  void _fitBounds() {
    if (state.mapController == null ||
        state.currentLatLng == null ||
        state.destinationLatLng == null) return;

    LatLngBounds bounds;

    // Find the absolute min and max for both Latitude and Longitude
    double minLat = math.min(
        state.currentLatLng!.latitude, state.destinationLatLng!.latitude);
    double maxLat = math.max(
        state.currentLatLng!.latitude, state.destinationLatLng!.latitude);
    double minLng = math.min(
        state.currentLatLng!.longitude, state.destinationLatLng!.longitude);
    double maxLng = math.max(
        state.currentLatLng!.longitude, state.destinationLatLng!.longitude);

    bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    state.mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80.d), // 80 is the padding in pixels
    );
  }

  Future<void> getAvailableDriver() async {
    EasyLoading.show();
    try {
      final result = await driverRepo.getAllDriverAroundApi(
          typeVehicle: state.vehicleTypeId ?? 0);
      await result.when(
        ok: (data) async {
          state.driverAroundData = data;
          // 2. Process markers
          await displayDriverMarker();
        },
        err: (error) async => Logger().e("Exception ${error.message}"),
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  displayDriverMarker() {
    // 1. Safety check for data and location
    final List<Driver>? allDrivers = state.driverAroundData?.data;
    if (allDrivers == null || state.currentLatLng == null) {
      return;
    }

    // 2. Clear only driver markers to avoid duplicating icons on update
    state.mapMarkers.removeWhere((m) => m.markerId.value.startsWith("driver_"));

    final double userLat = state.currentLatLng!.latitude;
    final double userLng = state.currentLatLng!.longitude;

    // 3. Filter and Add Markers
    // We use for-in for better readability and performance in large lists
    for (var driver in allDrivers) {
      // Parse coordinates safely
      double dLat = double.tryParse(driver.lastLocation?.latitude ?? '') ?? 0.0;
      double dLng =
          double.tryParse(driver.lastLocation?.longitude ?? '') ?? 0.0;

      // Skip drivers with invalid coordinates (0,0)
      if (dLat == 0.0 && dLng == 0.0) continue;

      state.mapMarkers.add(
        Marker(
          markerId: MarkerId("driver_${driver.id}"),
          position: LatLng(dLat, dLng),
          icon: state.driverIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          anchor: const Offset(0.5, 0.5),
          flat: true,
          onTap: () {
            gShowModalBottomSheet(
              initialChildSize: 0.3,
              minChildSize: .2,
              context: Get.context!,
              body: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocale.driverInfo.tr,
                        style: ThemeConstands.font14SemiBold,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 65,
                            height: 65,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            child: ClipOval(
                              child: XNetworkImage(
                                src: driver.profileImage ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(driver.name ?? AppLocale.unKnown.tr,
                                  style: ThemeConstands.font16SemiBold),
                              Text(driver.vehicle?.model ?? "",
                                  style: ThemeConstands.font14SemiBold),
                              InkWell(
                                onTap: () {
                                  if (driver.phone != null &&
                                      driver.phone!.isNotEmpty) {
                                    _makePhoneCall(driver.phone!);
                                  }
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.phone,
                                          size: 16, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Text(
                                        driver.phone ?? "",
                                        style: ThemeConstands.font14SemiBold
                                            .copyWith(
                                          color: Colors
                                              .blue, // Visual cue that it's a link
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: FBTNWidget(
                          onPressed: () {
                            Get.back();
                            // requestBooking(
                            //     isClickOnDriverMarker: true, driverID: driver.id);
                          },
                          color: AppColors.main,
                          textColor: AppColors.light4,
                          label: AppLocale.back.tr,
                          width: MediaQuery.of(context).size.width / 2,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    }

    // 5. Trigger partial update for the Map layer only
    update([MapUpdate.mapID]);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Handle error or show a Toast
      debugPrint('Could not launch $phoneNumber');
    }
  }
  // Tap on Marker

  String getVehicleSet() {
    var data = state.vehicleTypeSelection;
    return "${data?.id == 1 ? 3 : data?.id == 2 ? 4 : data?.id == 3 ? 7 : data?.id == 4 ? 4 : 5} ${AppLocale.seatCapacity.tr}";
  }

  void toggleBookLoading() {
    state.isBookingLoading = !state.isBookingLoading;
    update([MapUpdate.bookingID]);
  }

  Future<void> requestBooking() async {
    if (state.currentLatLng == null) return;

    double currentLat = state.currentLatLng?.latitude ?? 0.0;
    double currentLng = state.currentLatLng?.longitude ?? 0.0;
    String? currentAddress = state.currentAddress;

    // Destination
    double? destinationLat = state.destinationLatLng?.latitude;
    double? destinationLng = state.destinationLatLng?.longitude;

    // Vehicle Type
    int vehicleId = state.vehicleTypeSelection?.id ?? 0;

    final result = await requestBookingApi.requestBookingApi(
      startLatitude: currentLat,
      startLongitude: currentLng,
      address: currentAddress,
      destinationLatitude: destinationLat,
      destinationLongitude: destinationLng,
      typeVehicleId: vehicleId,
    );

    result.when(
      ok: (data) {
        if (data.data != null) {
          socket.rideRequestSocket(
            data: data,
            startLatitude: currentLat,
            startLongitude: currentLng,
            startDestinationLat: destinationLat,
            startDestinationLong: destinationLng,
          );
          updatePassengerLocationApi.updatePassengerLocationApi(
              lat: currentLat.toString(), lng: currentLng.toString());
        }
      },
      err: (error) async {
        toggleBookLoading();
        EasyLoading.showError(AppLocale.pleaseTryAgain.tr);
        await 1.delay();
        EasyLoading.dismiss();
        Logger().e("Exception ${error.message}");
      },
    );
  }

  Future<void> cancelBookingApi() async {
    final result = await cancelBookingRepo.cancelBookingApi();
    result.when(
      ok: (success) {
        if (success) socket.handleCancelRide();
      },
      err: (error) => xPrettyLog(message: error.message),
    );
  }
}

String driverMarkerImage({required int id}) {
  // var vehicleType = state.vehicleTypeSelection;
  switch (id) {
    case 1:
      return ImageAssets.rickshawMarker;
    case 2:
      return ImageAssets.classicCarMarker;
    case 3:
      return ImageAssets.minVanCarMarker;
    case 4:
      return ImageAssets.suvCarMarker;
    case 5:
      return ImageAssets.alphardVipCarMarker;
    default:
      return ImageAssets.rickshawMarker;
  }
}
