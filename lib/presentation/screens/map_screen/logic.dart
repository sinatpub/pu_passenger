import 'dart:async';
import 'dart:typed_data';
import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:com.tara.passenger/core/utils/fare_estimate.dart';
import 'package:com.tara.passenger/core/utils/load_custom_marker.dart';
import 'package:com.tara.passenger/core/utils/vehicle_seat_capacity.dart';
import 'package:com.tara.passenger/data/datasources/cancel_booking_api.dart';
import 'package:com.tara.passenger/data/datasources/driver_around_api.dart';
import 'package:com.tara.passenger/data/datasources/request_booking_api.dart';
import 'package:com.tara.passenger/data/datasources/update_passenger_location_api.dart';
import 'package:com.tara.passenger/data/models/driver_around_model.dart';
import 'package:com.tara.passenger/presentation/screens/home/logic.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/map_presentation.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/state.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/widgets/driver_info_sheet.dart';
import 'package:com.tara.passenger/service/location_imp.dart';
import 'package:com.tara.passenger/services/booking_session.dart';
import 'package:com.tara.passenger/services/socket_service.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

import '../../../core/resources/asset_resource.dart';

/// How the booking flow surfaces a failure to the passenger. Injectable so
/// the controller does not reach into `EasyLoading` directly — the Definition
/// of Done (`.agent/RULES.md`) rules out ad hoc `EasyLoading` calls inside a
/// controller, and a direct call also makes every failure path untestable
/// without a MaterialApp.
typedef BookingErrorPresenter = Future<void> Function(String userMessage);

Future<void> _defaultBookingErrorPresenter(String userMessage) async {
  EasyLoading.showError(userMessage);
  await 1.delay();
  EasyLoading.dismiss();
}

class MapLogic extends GetxController {
  /// P-08 (docs/12) — constructor injection with `Get.find` defaults, the
  /// pattern already used by `BookingMapLogic`. Previously every dependency
  /// was resolved in a field initializer, which made `requestBooking()`
  /// untestable (`.agent/TODO.md` Discovered Tasks) and violated the
  /// Definition of Done's "dependencies injected, not self-instantiated".
  MapLogic({
    HomeLogic? homeLogic,
    RequestBookingApi? requestBookingApi,
    CancelBookingApi? cancelBookingRepo,
    GetDriverAroundDataSource? driverRepo,
    LocationRepo? locationRepo,
    PassengerSocketService? socket,
    UpdatePassengerLocationApi? updatePassengerLocationApi,
    BookingErrorPresenter? errorPresenter,
    BookingSession? bookingSession,
  })  : _presentError = errorPresenter ?? _defaultBookingErrorPresenter,
        _injectedBookingSession = bookingSession,
        _homeLogic = homeLogic,
        _requestBookingApi = requestBookingApi,
        _cancelBookingRepo = cancelBookingRepo,
        _driverRepo = driverRepo,
        _injectedLocationRepo = locationRepo,
        _socket = socket,
        _updatePassengerLocationApi = updatePassengerLocationApi;

  final HomeLogic? _homeLogic;
  final RequestBookingApi? _requestBookingApi;
  final CancelBookingApi? _cancelBookingRepo;
  final GetDriverAroundDataSource? _driverRepo;
  final LocationRepo? _injectedLocationRepo;
  final PassengerSocketService? _socket;
  final UpdatePassengerLocationApi? _updatePassengerLocationApi;

  /// Resolved lazily rather than in a field initializer. A field initializer
  /// runs `Get.find` at construction time, so building a `MapLogic` demanded
  /// that every collaborator already be registered — even the ones the code
  /// path under test never touches. That is what made this controller
  /// untestable (`.agent/TODO.md` Discovered Tasks). Behaviour in production
  /// is unchanged: the binding registers everything before the first access.
  late final HomeLogic homeLogic = _homeLogic ?? Get.find<HomeLogic>();
  late final RequestBookingApi requestBookingApi =
      _requestBookingApi ?? RequestBookingApi();
  late final CancelBookingApi cancelBookingRepo =
      _cancelBookingRepo ?? CancelBookingApi();
  late final GetDriverAroundDataSource driverRepo =
      _driverRepo ?? Get.find<GetDriverAroundDataSource>();
  late final LocationRepo _locationRepo =
      _injectedLocationRepo ?? Get.find<LocationRepo>();
  late final PassengerSocketService socket =
      _socket ?? Get.find<PassengerSocketService>();
  late final UpdatePassengerLocationApi updatePassengerLocationApi =
      _updatePassengerLocationApi ?? Get.find<UpdatePassengerLocationApi>();

  final BookingErrorPresenter _presentError;

  final BookingSession? _injectedBookingSession;

  /// P-08: the booking attempt lives here, not in `state`, so it survives
  /// this controller being disposed with its route.
  late final BookingSession session =
      _injectedBookingSession ?? Get.find<BookingSession>();

  final MapState state = MapState();

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
    // P-06: marker construction is a pure function of the trip being
    // composed — see map_presentation.dart.
    state.mapMarkers = buildTripMarkers(
      currentLatLng: state.currentLatLng,
      destinationLatLng: state.destinationLatLng,
      sourceIcon: state.sourceIcon,
      destinationIcon: state.destinationIcon,
      destinationAddress: state.destinationAddress,
    );
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

  /// Reverse-geocodes the current pin into a human-readable address.
  ///
  /// Two defects fixed here (`docs/01` Problem 15 / `docs/08` L-10):
  ///
  /// 1. The `latLng == null` branch set the error string but did **not**
  ///    return, so it fell straight through to `latLng!`, threw, and the
  ///    empty catch swallowed it — which also meant `update()` never ran and
  ///    the error message it had just set was never rendered. The null path
  ///    was entirely broken, in a way nothing could surface.
  /// 2. `catch (e) {}` discarded every failure — a dropped network call, a
  ///    geocoder quota error — leaving the previous address on screen with no
  ///    indication it was stale.
  Future<void> getCurrentAddress({LatLng? latlng}) async {
    final latLng = state.currentLatLng;
    if (latLng == null) {
      state.currentAddress = AppLocale.error.tr;
      update([MapUpdate.mapID]);
      return;
    }

    try {
      state.currentAddress =
          await _locationRepo.getAddressLocation(latlng: latLng);
    } catch (e) {
      // Surface the failure rather than leaving a stale address on screen.
      state.currentAddress = AppLocale.error.tr;
      xPrettyLog(message: "getCurrentAddress failed: $e");
    }
    update([MapUpdate.mapID]);
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
    if (state.mapController == null) return;

    // P-06: bounds are a pure function of the two endpoints. A null result
    // means one end is missing and the camera should be left alone.
    final bounds = tripCameraBounds(
      currentLatLng: state.currentLatLng,
      destinationLatLng: state.destinationLatLng,
    );
    if (bounds == null) return;

    state.mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80.d), // 80 is padding in pixels
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
          onTap: () => showDriverInfoSheet(Get.context!, driver: driver),
        ),
      );
    }

    // 5. Trigger partial update for the Map layer only
    update([MapUpdate.mapID]);
  }
  // Tap on Marker

  String getVehicleSet() {
    var data = state.vehicleTypeSelection;
    return "${seatCapacityForVehicleId(data?.id)} ${AppLocale.seatCapacity.tr}";
  }

  /// P-08 (docs/12) — the booking-request lifecycle.
  ///
  /// This was previously a public toggle driven from the view, which the
  /// button pressed *before* calling [requestBooking]. That produced four
  /// distinct stuck-overlay states, all of them unrecoverable because the
  /// overlay's cancel button was commented out:
  ///
  ///  * a double-tap flipped the flag back to `false` and fired a *second*
  ///    booking while the first was still in flight;
  ///  * the `currentLatLng == null` early return left the overlay up forever;
  ///  * an `ok` result carrying a null `data` did nothing at all — no emit,
  ///    no error, no state change;
  ///  * on error the toggle assumed the flag was `true`, so after a double-tap
  ///    it switched the overlay back *on*.
  ///
  /// The flag is now owned here and set explicitly, never toggled. Ownership
  /// of the "am I busy" question sits with the code that starts and finishes
  /// the work, not with the widget that starts it.
  void setBookingLoading(bool value) {
    if (state.isBookingLoading == value) return;
    state.isBookingLoading = value;
    update([MapUpdate.bookingID]);
  }

  /// Terminal failure: drop the overlay and surface the reason.
  Future<void> _failBooking(String logMessage) async {
    setBookingLoading(false);
    session.markFailed(logMessage);
    xPrettyLog(message: "requestBooking failed: $logMessage");
    await _presentError(AppLocale.pleaseTryAgain.tr);
  }

  /// P-08: restores the overlay from the session when this controller is
  /// rebuilt. Without this, returning to the map after the route was disposed
  /// showed an idle screen while a booking was still running.
  void restoreFromSession() {
    setBookingLoading(session.isBusy);
  }

  Future<void> requestBooking() async {
    // Re-entrancy guard. A second tap while a request is in flight is a
    // no-op, not a second booking. Asks the session, not local state, so a
    // rebuilt controller cannot start a second booking over a live one.
    if (session.isBusy || state.isBookingLoading) return;

    if (state.currentLatLng == null) {
      await _failBooking("no current location");
      return;
    }

    setBookingLoading(true);

    double currentLat = state.currentLatLng?.latitude ?? 0.0;
    double currentLng = state.currentLatLng?.longitude ?? 0.0;
    String? currentAddress = state.currentAddress;

    // Destination
    double? destinationLat = state.destinationLatLng?.latitude;
    double? destinationLng = state.destinationLatLng?.longitude;

    // Vehicle Type
    int vehicleId = state.vehicleTypeSelection?.id ?? 0;

    // Recorded before the call goes out, so a failure — or this route being
    // disposed mid-flight — still leaves something to retry from.
    session.beginRequest(
      pickup: state.currentLatLng!,
      pickupAddress: currentAddress,
      destination: state.destinationLatLng,
      destinationAddress: state.destinationAddress,
      vehicleTypeId: vehicleId,
    );

    final result = await requestBookingApi.requestBookingApi(
      startLatitude: currentLat,
      startLongitude: currentLng,
      address: currentAddress,
      destinationLatitude: destinationLat,
      destinationLongitude: destinationLng,
      typeVehicleId: vehicleId,
    );

    await result.when(
      ok: (data) async {
        // A 2xx carrying no booking is a failure, not a success. Treating it
        // as one is what left the overlay up with nothing behind it.
        if (data.data == null) {
          await _failBooking("server returned ok with a null booking");
          return;
        }
        session.markAwaitingDriver();
        socket.rideRequestSocket(
          data: data,
          startLatitude: currentLat,
          startLongitude: currentLng,
          startDestinationLat: destinationLat,
          startDestinationLong: destinationLng,
        );
        updatePassengerLocationApi.updatePassengerLocationApi(
            lat: currentLat.toString(), lng: currentLng.toString());
        // The overlay deliberately stays up on success: the passenger is now
        // waiting for a driver to accept. `BookingMapLogic` owns the screen
        // from here, and cancelBooking() is the way out.
      },
      err: (error) => _failBooking(error.message),
    );
  }

  /// The overlay's escape hatch. Clears the overlay first so a failing
  /// cancel call cannot strand the passenger behind it.
  Future<void> cancelBooking() async {
    setBookingLoading(false);
    session.reset();
    await cancelBookingApi();
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
