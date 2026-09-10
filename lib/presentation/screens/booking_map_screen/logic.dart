import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:com.tara.passenger/data/datasources/check_request_book_source.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/state.dart';
import 'package:com.tara.passenger/service/location_imp.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/logic.dart';
import '../../../core/resources/asset_resource.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/app_ext.dart';
import '../../../core/utils/load_custom_marker.dart';
import '../../../core/utils/pretty_logger.dart';
import '../../../core/utils/status_util.dart';
import '../map_screen/logic.dart';
import 'package:com.tara.passenger/services/socket_service.dart';
import 'poll_policy.dart';

class BookingMapLogic extends GetxController {
  /// Collaborators arrive by constructor and resolve lazily. A `Get.find`
  /// in a field initializer runs at construction, so building this
  /// controller demanded every collaborator already be registered — the
  /// gap logged in `.agent/TODO.md` Discovered Tasks against
  /// `docs/10` §3.2. Production behaviour is unchanged: bindings register
  /// everything before first access.
  BookingMapLogic({
    CheckBookingApi? checkBookingApi,
    bool Function()? isSocketConnected,
    LocationRepo? locationRepo,
    AppLogic? appLogic,
  })  : checkBookingApi = checkBookingApi ?? CheckBookingApi(),
        _isSocketConnected = isSocketConnected,
        _injectedLocationRepo = locationRepo,
        _injectedAppLogic = appLogic;

  final LocationRepo? _injectedLocationRepo;
  final AppLogic? _injectedAppLogic;

  late final LocationRepo _locationRepo =
      _injectedLocationRepo ?? Get.find<LocationRepo>();
  late final AppLogic appLogic = _injectedAppLogic ?? Get.find<AppLogic>();

  /// P-09: reads F-03's connection-state signal. Injectable so the poll
  /// policy is testable without a live socket.
  final bool Function()? _isSocketConnected;

  bool get socketConnected =>
      (_isSocketConnected ?? () => PassengerSocketService().isConnected)();

  /// Timer ticks since the poll started, counting from 1. Incremented on
  /// every fire whether or not it polled.
  int _pollTick = 0;
  final CheckBookingApi checkBookingApi;
  final BookingMapState state = BookingMapState();
  Timer? _refreshTimer;

  // P-09 (docs/12, docs/09 §7/docs/08 M-2) — this screen is refreshed by two
  // independent channels: the 10s poll below and socket events
  // (`PassengerSocketService._handleBookingUpdate`), both calling
  // `getBookingInfo`. Nothing stopped a slower, now-stale fetch from
  // completing (and overwriting `state.bookingRequestData`) after a faster,
  // more current one already had — "socket says onGoing" could be
  // regressed by "the poll I kicked off 2s earlier still thinks accepted".
  // This counter makes a response only apply if no newer request has
  // started since — standard out-of-order-response guard, independent of
  // which channel triggered which fetch.
  //
  // The other half — "socket primary, bounded poll fallback" — is now done
  // too (2026-09-09), once F-03 exposed `BaseSocketService.isConnected`.
  // While the socket is healthy the poll drops to one tick in six; it never
  // stops entirely, because a transport-level connection can be up while the
  // server has gone quiet. See `poll_policy.dart` for why bounded rather
  // than off.
  int _requestSeq = 0;

  @override
  Future<void> onInit() async {
    await getBookingInfo();
    await _loadMarkerIcons();
    await refreshMarkers();
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    _startTimer();
  }

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    _pollTick = 0;
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      onPollTick();
    });
  }

  /// One timer fire. Separated from the `Timer.periodic` callback so the
  /// policy can be driven directly in a test without waiting on wall time.
  void onPollTick() {
    _pollTick++;
    if (!shouldPollOnTick(
      socketConnected: socketConnected,
      tick: _pollTick,
    )) {
      return;
    }
    getBookingInfo(isSilent: true);
  }

  void _stopTimer() {
    if (_refreshTimer != null) {
      _refreshTimer!.cancel();
      _refreshTimer = null;
    }
  }

  Future<void> _loadMarkerIcons() async {
    // Passenger
    final Uint8List sourceBytes =
        await getBytesFromAsset(ImageAssets.passengerIconMarker, 65);
    state.passengerIcon = BitmapDescriptor.bytes(sourceBytes);

    // Destination
    final Uint8List destBytes =
        await getBytesFromAsset(ImageAssets.destinationMarker, 45);
    state.destinationIcon = BitmapDescriptor.bytes(destBytes);

    // Driver
    final Uint8List driverBytes = await getBytesFromAsset(
        driverMarkerImage(
            id: state.bookingRequestData?.data?.typeVehicleId ?? 0),
        25);
    state.driverIcon = BitmapDescriptor.bytes(driverBytes);
    update();
  }

  Future<void> refreshMarkers() async {
    Set<Marker> newMarkers = {};
    var data = state.bookingRequestData?.data;

    if (data == null) return;

    // 1. Add Passenger Marker (Remove if trip has started)
    if (data.status != BookingStatus.onGoing) {
      double pLat = double.tryParse(data.startLatitude ?? "") ?? 0.0;
      double pLng = double.tryParse(data.startLongitude ?? "") ?? 0.0;
      if (pLat != 0) {
        newMarkers.add(Marker(
          markerId: const MarkerId("current_location"),
          position: LatLng(pLat, pLng),
          icon: state.passengerIcon ?? BitmapDescriptor.defaultMarker,
        ));
      }
    }

    // 2. Add Driver Marker
    var driverLoc = data.driver?.lastLocation;
    if (driverLoc != null) {
      double dLat = double.tryParse(driverLoc.latitude ?? "") ?? 0.0;
      double dLng = double.tryParse(driverLoc.longitude ?? "") ?? 0.0;
      newMarkers.add(Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(dLat, dLng),
        rotation: (driverLoc.heading ?? 0).toDouble(),
        flat: true,
        anchor: const Offset(0.5, 0.5),
        icon: state.driverIcon ?? BitmapDescriptor.defaultMarker,
      ));
    }

    // 3. Add Destination Marker (Only if On-Going)
    if (data.status == BookingStatus.onGoing) {
      double destLat = double.tryParse(data.endLatitude ?? "") ?? 0.0;
      double destLng = double.tryParse(data.endLongitude ?? "") ?? 0.0;
      if (destLat != 0) {
        newMarkers.add(Marker(
          markerId: const MarkerId("destination"),
          position: LatLng(destLat, destLng),
          icon: state.destinationIcon ?? BitmapDescriptor.defaultMarker,
        ));
      }
    }

    state.markers = newMarkers;
    update();
  }

  Future<void> drawPolyline() async {
    var data = state.bookingRequestData?.data;
    if (data == null) return;

    // Rule: If driver arrived, clear path to keep the map clean
    if (data.status == BookingStatus.arrival) {
      state.polyline = {};
      update();
      return;
    }

    LatLng start;
    LatLng end;

    if (data.status == BookingStatus.accepted) {
      // Path: Driver -> Passenger Pickup
      double dLat =
          double.tryParse(data.driver?.lastLocation?.latitude ?? "") ?? 0.0;
      double dLng =
          double.tryParse(data.driver?.lastLocation?.longitude ?? "") ?? 0.0;
      double pLat = double.tryParse(data.startLatitude ?? "") ?? 0.0;
      double pLng = double.tryParse(data.startLongitude ?? "") ?? 0.0;
      start = LatLng(dLat, dLng);
      end = LatLng(pLat, pLng);
    } else if (data.status == BookingStatus.onGoing) {
      // Path: Pickup Point -> Final Destination
      double pLat = double.tryParse(data.startLatitude ?? "") ?? 0.0;
      double pLng = double.tryParse(data.startLongitude ?? "") ?? 0.0;
      double destLat = double.tryParse(data.endLatitude ?? "") ?? 0.0;
      double destLng = double.tryParse(data.endLongitude ?? "") ?? 0.0;
      start = LatLng(pLat, pLng);
      end = LatLng(destLat, destLng);
    } else {
      state.polyline = {};
      update();
      return;
    }

    // Guard: Don't call API if coordinates are invalid
    if (start.latitude == 0 || end.latitude == 0) return;

    // Fetch road points from your LocationRepo
    List<LatLng> points = await _locationRepo.getDirectionPoint(start, end);

    if (points.isNotEmpty) {
      state.polyline = {
        Polyline(
          polylineId: const PolylineId("trip_route"),
          points: points,
          color: AppColors.main,
          width: 5,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      };
      update();
    }
  }

  void navigateMapPerspective() {
    var data = state.bookingRequestData?.data;
    if (data == null || state.mapController == null) return;

    // 1. Official Pickup Point (The location stored in the booking)
    double pLat = double.tryParse(data.startLatitude ?? "") ?? 0.0;
    double pLng = double.tryParse(data.startLongitude ?? "") ?? 0.0;
    LatLng officialPickup = LatLng(pLat, pLng);

    // 2. Official Destination Point
    double dLat = double.tryParse(data.endLatitude ?? "") ?? 0.0;
    double dLng = double.tryParse(data.endLongitude ?? "") ?? 0.0;
    LatLng officialDestination = LatLng(dLat, dLng);

    // 3. Driver's Current Location
    var driverLoc = data.driver?.lastLocation;
    double drLat = double.tryParse(driverLoc?.latitude ?? "") ?? 0.0;
    double drLng = double.tryParse(driverLoc?.longitude ?? "") ?? 0.0;
    LatLng driverLatLng = LatLng(drLat, drLng);

    switch (data.status) {
      case BookingStatus.accepted:
        // Show Driver approaching the Selected Pickup Point
        _fitTwoPoints(driverLatLng, officialPickup);
        break;

      case BookingStatus.arrival:
        // Zoom in strictly on the Pickup Point
        _fitTwoPoints(driverLatLng, officialPickup);
        // state.mapController!.animateCamera(
        //   CameraUpdate.newLatLngZoom(driverLatLng, 18.0),
        // );
        break;

      case BookingStatus.onGoing:
        // Show Driver moving toward the Official Destination
        _fitTwoPoints(driverLatLng, officialDestination);
        state.mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(driverLatLng, 18.0),
        );
        break;

      default:
        // For payment/completed, just center on destination
        state.mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(officialDestination, 15.0),
        );
        break;
    }
  }

// Helper to frame two points on the screen
  void _fitTwoPoints(LatLng a, LatLng b) {
    // Guard against invalid coordinates
    if (a.latitude == 0 || b.latitude == 0) return;

    LatLngBounds bounds;

    if (a.latitude <= b.latitude && a.longitude <= b.longitude) {
      bounds = LatLngBounds(southwest: a, northeast: b);
    } else if (a.latitude <= b.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(a.latitude, b.longitude),
        northeast: LatLng(b.latitude, a.longitude),
      );
    } else if (a.longitude <= b.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(b.latitude, a.longitude),
        northeast: LatLng(a.latitude, b.longitude),
      );
    } else {
      bounds = LatLngBounds(southwest: b, northeast: a);
    }

    state.mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 70.d),
    );
  }

  Future<void> getBookingInfo({bool isSilent = false}) async {
    final requestId = ++_requestSeq;
    try {
      // 1. Only show loading on manual entry or hard refresh
      if (!isSilent) EasyLoading.show();

      var response = await checkBookingApi.checkBookingApi();

      // A newer call (poll or socket-triggered) has started since this one
      // did — its response will supersede ours. Applying this one now would
      // regress state with stale data. See the field comment on _requestSeq.
      if (requestId != _requestSeq) return;

      if (response.data != null) {
        // Update the local state
        state.bookingRequestData = response;
        _bookingInfo(); // Updates UI Text/Titles

        // 2. Always refresh markers (This makes the car move every 30s)
        await refreshMarkers();
        await drawPolyline(); // Re-calculates road path
        navigateMapPerspective();
      }
    } catch (e) {
      tlog("Booking Update Error: $e");
    } finally {
      if (!isSilent) EasyLoading.dismiss();
    }
  }

  _bookingInfo() {
    var data = state.bookingRequestData?.data;
    if (data != null) {
      switch (data.status) {
        case BookingStatus.arrival:
          appLogic.titleEvent = AppLocale.driverArrivedLocation.tr;
          appLogic.update([AppUpdate.titleEventID]);
          break;

        case BookingStatus.accepted:
          appLogic.titleEvent = AppLocale.waitingDriverArrived.tr;
          appLogic.update([AppUpdate.titleEventID]);
          break;
        case BookingStatus.onGoing:
          appLogic.titleEvent = AppLocale.startRide.tr;
          appLogic.update([AppUpdate.titleEventID]);
        case BookingStatus.completed:
        case BookingStatus.pendingPayment:
          appLogic.titleEvent = AppLocale.pendingPayment.tr;
          appLogic.update([AppUpdate.titleEventID]);
        default:
          tlog("Default Route from Checking Status API");
      }
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    EasyLoading.show();
    state.mapController = controller;
    // 1. Get real location immediately
    var pos = await _locationRepo.getCurrentLocation();
    if (pos != null) {
      LatLng userLatLng = LatLng(pos.latitude, pos.longitude);
      // updateCurrentLatLng(latLng: userLatLng);
      state.mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLatLng, zoom: 15),
        ),
      );
    }
    EasyLoading.dismiss();
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    try {
      final uri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        xLog(message: 'Could not launch $phoneNumber');
      }
    } catch (e) {
      xLog(message: 'Error in makePhoneCall: $e');
    }
  }
}
