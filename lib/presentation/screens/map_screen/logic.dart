import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'dart:async';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:com.tara.passenger/core/utils/fare_estimate.dart';
import 'package:com.tara.passenger/core/utils/load_custom_marker.dart';
import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/core/utils/trip_marker.dart';
import 'package:com.tara.passenger/core/utils/vehicle_kind.dart';
import 'package:com.tara.passenger/core/utils/vehicle_seat_capacity.dart';
import 'package:com.tara.passenger/mock/mock_fixtures.dart';
import 'package:com.tara.passenger/mock/mock_mode.dart';
import 'package:com.tara.passenger/data/datasources/cancel_booking_api.dart';
import 'package:com.tara.passenger/data/datasources/check_request_book_source.dart';
import 'package:com.tara.passenger/data/datasources/driver_around_api.dart';
import 'package:com.tara.passenger/data/datasources/request_booking_api.dart';
import 'package:com.tara.passenger/data/datasources/update_passenger_location_api.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:com.tara.passenger/presentation/screens/invite/invite_feature.dart';
import 'package:com.tara.passenger/presentation/screens/invite/invite_presentation.dart';
import 'package:com.tara.passenger/presentation/screens/invite/logic.dart';
import 'package:com.tara.passenger/presentation/screens/home/booking_redirect.dart';
import 'package:com.tara.passenger/presentation/screens/home/logic.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/map_presentation.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/state.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/widgets/driver_info_sheet.dart';
import 'package:com.tara.passenger/presentation/shared/ride_dialogs.dart';
import 'package:com.tara.passenger/services/location_imp.dart';
import 'package:com.tara.passenger/services/booking_session.dart';
import 'package:com.tara.passenger/services/socket_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';


/// How the booking flow surfaces a failure to the passenger. Injectable so
/// the controller does not reach into `EasyLoading` directly — the Definition
/// of Done (`.agent/RULES.md`) rules out ad hoc `EasyLoading` calls inside a
/// controller, and a direct call also makes every failure path untestable
/// without a MaterialApp.
///
/// Completes with whether the passenger asked to try again.
typedef BookingErrorPresenter = Future<bool> Function(BookingFailure failure);

/// The "Couldn't book your ride" dialog. With no screen to show it on there
/// is nobody to ask, so nothing is retried.
Future<bool> _defaultBookingErrorPresenter(BookingFailure failure) async {
  final context = Get.context;
  if (context == null) return false;
  return showBookingFailedDialog(context, failure);
}

/// How often the wait for a driver asks the server what became of the
/// booking. See [MapLogic.checkAwaitedBooking].
const Duration kAwaitDriverPollInterval = Duration(seconds: 5);

/// Added to the request's `timeout_param` before the wait gives up on its own
/// (audit S-3): the time for a driver's accept, tapped at the last second, to
/// reach the server and come back in a check.
const Duration kDriverAnswerGrace = Duration(seconds: 15);

/// Whether the server's answer says nobody is going to take the request
/// (audit S-3): it no longer has a booking for the passenger, or has it as
/// cancelled. `get-request-booking-info` returns the active booking only, so a
/// request that expired, or was dropped, comes back with no booking.
bool requestWentUnanswered(RequestBookingModel booking) {
  final data = booking.data;
  return data == null || data.status == BookingStatus.cancel;
}

/// Leaves the map for the screen a booking has moved on to. Injectable
/// because `Get.offNamed` needs a live navigator.
typedef BookingRouteOpener = void Function(String route);

void _defaultBookingRouteOpener(String route) {
  if (Get.currentRoute != route) Get.offNamed(route);
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
    CheckBookingApi? checkBookingApi,
    Duration awaitDriverPollInterval = kAwaitDriverPollInterval,
    BookingRouteOpener? openBookingRoute,
    DateTime Function()? clock,
  })  : _presentError = errorPresenter ?? _defaultBookingErrorPresenter,
        _now = clock ?? DateTime.now,
        _injectedBookingSession = bookingSession,
        _checkBookingApi = checkBookingApi,
        _awaitDriverPollInterval = awaitDriverPollInterval,
        _openBookingRoute = openBookingRoute ?? _defaultBookingRouteOpener,
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

  final CheckBookingApi? _checkBookingApi;
  late final CheckBookingApi checkBookingApi =
      _checkBookingApi ?? CheckBookingApi();
  final Duration _awaitDriverPollInterval;
  final BookingRouteOpener _openBookingRoute;

  /// Reads the time for the wait's deadline. Injectable for tests.
  final DateTime Function() _now;

  Timer? _awaitDriverTimer;
  bool _checkingAwaitedBooking = false;

  final BookingSession? _injectedBookingSession;

  /// P-08: the booking attempt lives here, not in `state`, so it survives
  /// this controller being disposed with its route.
  late final BookingSession session =
      _injectedBookingSession ?? Get.find<BookingSession>();

  final MapState state = MapState();

  /// C3: the "Add a note for driver" field's controller. Presentational only —
  /// the value hangs off `state.note` for the session and is never sent, so
  /// the `requestBooking` payload and `rideRequest` emit stay unchanged
  /// (roadmap C3 "Done When").
  final TextEditingController noteController = TextEditingController();

  @override
  void onClose() {
    _stopWatchingForDriver();
    noteController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    var arg = Get.arguments;
    if (arg is Map) {
      final vehicleId = arg['vehicleId'];
      if (vehicleId is int) state.vehicleTypeId = vehicleId;
      // "Book again" after a driver cancelled carries the lost trip's
      // drop-off; it is applied once the pickup is known.
      final destination = arg['destination'];
      if (destination is LatLng) state.pendingDestination = destination;
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
    state.sourceIcon = await tripMarkerIcon(TripMarker.pickup);
    state.destinationIcon = await tripMarkerIcon(TripMarker.dropOff);
    state.driverIcon = await driverMarkerIcon(
        vehicleKindFromName(state.vehicleTypeSelection?.name));
    update([MapUpdate.mapID]);
  }

  void refreshMarkers() {
    // P-06: marker construction is a pure function of the trip being
    // composed — see map_presentation.dart.
    state.tripMarkers = buildTripMarkers(
      currentLatLng: state.currentLatLng,
      destinationLatLng: state.destinationLatLng,
      sourceIcon: state.sourceIcon,
      destinationIcon: state.destinationIcon,
      destinationAddress: state.destinationAddress,
    );
    update([MapUpdate.mapID]);
  }

  /// The vehicle the map opened for — or, when it was opened without one
  /// ("Book again"), the first type on offer. Without a default the sheet
  /// had no vehicle, no chips to pick one from, and a Book button that could
  /// never be pressed.
  void getVehicleTypeSelection() {
    final vehicles = homeLogic.state.vehicleAllType?.data ?? const [];
    final vehicle =
        vehicles.firstWhereOrNull((e) => e.id == state.vehicleTypeId) ??
            vehicles.firstOrNull;
    if (vehicle != null) {
      state.vehicleTypeId = vehicle.id;
      state.vehicleTypeSelection = vehicle;
      update([MapUpdate.mapID, MapUpdate.vehicleID]);
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

  /// Fills in the drop-off the map was opened with, once. It needs the
  /// pickup first: the distance and the fare are measured from it.
  void applyPendingDestination() {
    final destination = state.pendingDestination;
    if (destination == null || state.currentLatLng == null) return;
    state.pendingDestination = null;
    updateDestinationLocation(latLng: destination);
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
    // Whichever way the pickup became known — GPS, or the pin on the map
    // when there is no GPS — a drop-off waiting for it can now be set.
    applyPendingDestination();
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
      state.currentAddress = null;
      state.addressFailed = true;
      update([MapUpdate.mapID]);
      return;
    }

    String? address;
    try {
      address = await _locationRepo.findAddress(latlng: latLng);
    } catch (e) {
      xPrettyLog(message: "getCurrentAddress failed: $e");
    }
    // The pin moved on while this was in flight: the answer describes a
    // point it has left, and that move started its own lookup.
    if (state.currentLatLng != latLng) return;
    // No address is said to be none, rather than leaving a stale one — or
    // the "Address not found." sentence — to be sent with the booking.
    state.currentAddress = address;
    state.addressFailed = address == null;
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
        state.distanceKm = 0.0;
        state.totalFare = 0.0;
        state.polylines = {};
        // Only the trip layer resets — the nearby drivers are still there.
        state.tripMarkers = {};
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
    // Both ends are needed. The guard used to check only the destination and
    // then force-unwrap `currentLatLng!` two lines later.
    if (state.destinationLatLng == null || state.currentLatLng == null) return;

    var vehicle = state.vehicleTypeSelection;
    double distanceInKm = await _locationRepo.getDistance(
      start:
          LatLng(state.currentLatLng!.latitude, state.currentLatLng!.longitude),
      destination: state.destinationLatLng!,
    );

    state.distance = formatDistance(distanceInKm);
    state.distanceKm = distanceInKm;

    // Calculate price
    state.totalFare = estimateFare(
      distanceKm: distanceInKm,
      pricePerKm: vehicle?.price ?? 1,
      minimumFare: vehicle?.miniMunFare ?? 1,
    );
  }

  /// Every vehicle type the passenger can pick from, in the server's order.
  List<SingleVehical> get vehicles =>
      homeLogic.state.vehicleAllType?.data ?? const [];

  /// [vehicle]'s fare for the current route, or null while there is no
  /// destination — the booking is then metered and only the minimum is known.
  double? fareFor(SingleVehical vehicle) {
    if (state.destinationLatLng == null || state.distanceKm <= 0) return null;
    return estimateFare(
      distanceKm: state.distanceKm,
      pricePerKm: vehicle.price,
      minimumFare: vehicle.miniMunFare ?? 1,
    );
  }

  /// Switches the vehicle type being booked: re-prices the route and reloads
  /// the nearby drivers and their marker for that type.
  Future<void> selectVehicle(SingleVehical vehicle) async {
    if (state.vehicleTypeSelection?.id == vehicle.id) return;
    state.vehicleTypeId = vehicle.id;
    state.vehicleTypeSelection = vehicle;
    final fare = fareFor(vehicle);
    if (fare != null) state.totalFare = fare;
    update([MapUpdate.mapID, MapUpdate.vehicleID]);
    await _loadMarkerIcons();
    await getAvailableDriver();
  }

  /// Draw Polyline
  // Inside MapLogic class
  Future<void> drawPolyline() async {
    if (state.currentLatLng == null || state.destinationLatLng == null) return;

    // QA mock build: a synthetic route instead of the Directions API.
    final List<PointLatLng> result;
    if (MockMode.isActive) {
      result = [
        for (final p in mockRoute(
            state.currentLatLng!, state.destinationLatLng!))
          PointLatLng(p.latitude, p.longitude),
      ];
    } else {
      final response = await PolylinePoints().getRouteBetweenCoordinates(
        googleApiKey: AppConstant.googleKeyApi,
        request: PolylineRequest(
          origin: PointLatLng(
              state.currentLatLng!.latitude, state.currentLatLng!.longitude),
          destination: PointLatLng(state.destinationLatLng!.latitude,
              state.destinationLatLng!.longitude),
          mode: TravelMode.driving,
        ),
      );
      if (response.points.isEmpty) return;
      result = response.points;
    }

    state.polylines =
        buildRoutePolyline(points: result, color: TaColors.primary);

    // Zoom to fit the whole trip once the polyline has been laid down.
    Future.delayed(const Duration(milliseconds: 300), _fitBounds);

    update([MapUpdate.mapID]);
  }

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
          displayDriverMarker();
        },
        err: (error) async => Logger().e("Exception ${error.message}"),
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  void displayDriverMarker() {
    if (state.currentLatLng == null) return;
    state.driverMarkers = buildDriverMarkers(
      drivers: state.driverAroundData?.data,
      driverIcon: state.driverIcon,
      onTap: (driver) => showDriverInfoSheet(Get.context!, driver: driver),
    );
    update([MapUpdate.mapID]);
  }

  // Tap on Marker

  String getVehicleSet() {
    var data = state.vehicleTypeSelection;
    return seatsLabel(vehicleKindFromName(data?.name));
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

  /// The attempt failed: drop the overlay, tell the passenger, and send it
  /// again if they ask. The draft is still in the session and the map's
  /// state is untouched, so "Try again" is the same request.
  Future<void> _failBooking(
    String logMessage, {
    BookingFailure failure = BookingFailure.requestFailed,
  }) async {
    _stopWatchingForDriver();
    setBookingLoading(false);
    session.markFailed(logMessage);
    xPrettyLog(message: "requestBooking failed: $logMessage");
    final retry = await _presentError(failure);
    if (retry) await requestBooking();
  }

  /// P-08: restores the overlay from the session when this controller is
  /// rebuilt. Without this, returning to the map after the route was disposed
  /// showed an idle screen while a booking was still running.
  void restoreFromSession() {
    setBookingLoading(session.isBusy);
    if (session.status == BookingRequestStatus.awaitingDriver) {
      _watchForDriver();
    }
  }

  /// The wait for a driver, asked of the server as well as heard from the
  /// socket.
  ///
  /// The overlay used to come down only on the `rideAccepted` socket push.
  /// That push is not the server's own: it is relayed when the *driver app*
  /// emits `acceptRide` after its accept call returns. A driver app that
  /// accepted the ride and then failed to emit (seen 2026-10-06: it could not
  /// read the accept response) left the passenger searching for a driver who
  /// was already on the way, with only Cancel to press.
  ///
  /// The booking's status is the server's own record, so it is asked every
  /// [kAwaitDriverPollInterval] while the overlay is up. The socket push still
  /// wins when it arrives; this only bounds how long its absence can last.
  void _watchForDriver() {
    _awaitDriverTimer?.cancel();
    _awaitDriverTimer = Timer.periodic(
      _awaitDriverPollInterval,
      (_) => checkAwaitedBooking(),
    );
  }

  void _stopWatchingForDriver() {
    _awaitDriverTimer?.cancel();
    _awaitDriverTimer = null;
  }

  /// One look at the booking being waited on. Opens the ride screen (or the
  /// fare page) when the server says it has moved past "requested", by the
  /// same rule Home applies on launch ([bookingRedirectRoute]).
  @visibleForTesting
  Future<void> checkAwaitedBooking() async {
    if (_checkingAwaitedBooking) return;
    if (session.status != BookingRequestStatus.awaitingDriver) {
      _stopWatchingForDriver();
      return;
    }
    _checkingAwaitedBooking = true;
    try {
      final booking = await checkBookingApi.checkBookingApi();
      // Cancelled, or the socket got there first, while this was in flight.
      if (session.status != BookingRequestStatus.awaitingDriver) return;
      // Audit S-3: the overlay used to stay up for good once the server had
      // let the request go — only an accept, or the passenger's own Cancel,
      // ever took it down.
      if (requestWentUnanswered(booking)) {
        xPrettyLog(
          message: "The awaited booking is gone (status: "
              "${booking.data?.status}): no driver took it",
        );
        unawaited(_noDriverFound(cancelOnServer: false));
        return;
      }
      final route = bookingRedirectRoute(booking.data?.status);
      if (route == null) {
        // Still requested after every driver's countdown is up: nobody can
        // take it now. Withdrawn from the server, so a late accept cannot
        // send a driver to a passenger who has been told there is none.
        if (session.answerOverdue(_now())) {
          unawaited(_noDriverFound(cancelOnServer: true));
        }
        return;
      }
      xPrettyLog(
        message: "Booking moved on while waiting (status: "
            "${booking.data?.status}), opening $route",
      );
      _stopWatchingForDriver();
      session.markAccepted();
      setBookingLoading(false);
      _openBookingRoute(route);
    } catch (e) {
      // A check that failed is not a booking that failed: ask again on the
      // next tick.
      xPrettyLog(message: "Could not check the awaited booking: $e");
    } finally {
      _checkingAwaitedBooking = false;
    }
  }

  /// Audit S-3: nobody took the request. The overlay comes down, the attempt
  /// is marked failed so a new one can start, and the passenger is told, with
  /// "Try again" sending the same request again ([_failBooking]).
  Future<void> _noDriverFound({required bool cancelOnServer}) async {
    _stopWatchingForDriver();
    setBookingLoading(false);
    session.markFailed("no driver accepted");
    if (cancelOnServer) await cancelBookingApi();
    await _failBooking(
      "no driver accepted",
      failure: BookingFailure.noDriver,
    );
  }

  // ── Ride credit (D40) ────────────────────────────────────────────────────

  void setUseRideCredit(bool use) {
    state.useRideCredit = use;
    update([MapUpdate.mapID]);
  }

  /// Null is "all of it".
  void setRideCreditAmount(double? amount) {
    state.rideCreditAmount = amount;
    update([MapUpdate.mapID]);
  }

  /// What goes out with the booking. Zero while the feature is off.
  double _rideCreditToAsk() {
    if (!inviteFeatureEnabled || !Get.isRegistered<InviteLogic>()) return 0;
    return rideCreditToAsk(
      use: state.useRideCredit,
      chosen: state.rideCreditAmount,
      balance: Get.find<InviteLogic>().usableCredit,
    );
  }

  Future<void> requestBooking() async {
    // Re-entrancy guard. A second tap while a request is in flight is a
    // no-op, not a second booking. Asks the session, not local state, so a
    // rebuilt controller cannot start a second booking over a live one.
    if (session.isBusy || state.isBookingLoading) return;

    if (state.currentLatLng == null) {
      await _failBooking(
        "no current location",
        failure: BookingFailure.noLocation,
      );
      return;
    }

    setBookingLoading(true);

    // The address is looked up after the pin settles, so a quick tap on
    // Book can get here first. A booking sent without it has no pickup
    // address on the ride screen, the fare page, the receipt or the history,
    // so it is looked up now. Still none after that: the booking goes
    // without, and the ride screen finds one from the coordinates.
    if ((state.currentAddress ?? '').trim().isEmpty) {
      await getCurrentAddress();
    }

    double currentLat = state.currentLatLng?.latitude ?? 0.0;
    double currentLng = state.currentLatLng?.longitude ?? 0.0;
    String? currentAddress = (state.currentAddress ?? '').trim().isEmpty
        ? null
        : state.currentAddress;

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
      rideCredit: _rideCreditToAsk(),
    );

    await result.when(
      ok: (data) async {
        // A 2xx carrying no booking is a failure, not a success. Treating it
        // as one is what left the overlay up with nothing behind it.
        if (data.data == null) {
          await _failBooking("server returned ok with a null booking");
          return;
        }
        // Every driver's request screen counts down from the same
        // `timeout_param` (it goes out in the `rideRequest` emit below).
        final answerWithin = data.data?.timeoutParam;
        session.markAwaitingDriver(
          answerBy: answerWithin == null || answerWithin <= 0
              ? null
              : _now().add(Duration(seconds: answerWithin) + kDriverAnswerGrace),
        );
        _watchForDriver();
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
    _stopWatchingForDriver();
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
