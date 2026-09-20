import 'dart:async';
import 'dart:convert';

import 'package:com.tara.passenger/core/utils/fare_estimate.dart';
import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/mock/mock_fixtures.dart';
import 'package:com.tara.passenger/mock/mock_geo.dart';
import 'package:com.tara.passenger/mock/mock_models.dart';
import 'package:com.tara.passenger/mock/mock_mode.dart';
import 'package:com.tara.passenger/mock/mock_timings.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The fake server, from the passenger's side. Owns the booking and its
/// lifecycle, the simulated driver (accept → arrive → start → drop → collect),
/// history and announcements. Its state survives an app restart
/// (SharedPreferences), which is what lets "kill the app mid-trip" be tested
/// through the app's real resume path (`HomeLogic.checkingBookingStatus` →
/// `get-request-booking-info` → `bookingRedirectRoute`).
///
/// Drive order, mirrored from pu_driver's mock_backend.dart:
/// * `request-booking` creates the booking and the simulated driver accepts
///   on its own after [MockTimings.driverAcceptsAfterRequest] — unless the
///   scenario says otherwise or dispatch is `Manual` (the dev panel then has
///   to call [acceptBookingNow]).
/// * Accepted → the simulated car drives to the pickup (`driverArrival`),
///   the trip starts (`driverStartDrive`), the trip ends
///   (`driverDropDrive`), and the driver collects payment
///   (`driverAcceptPayment`) — which is what walks the passenger through the
///   real Fee → Rating → Receipt → Home chain.
/// * `driverCancelled`: accepted, then `onDriverCancelDrive` a few seconds
///   later.
///
/// The wire names on the socket are exactly `SocketEventName`'s spellings
/// (see `services/socket_service.dart`); both are pinned by
/// `test/taxi_single_ton/socket_event_contract_test.dart`.
class MockBackend {
  MockBackend({
    DateTime Function()? clock,
    MockSettings Function()? settings,
    Duration Function(Duration)? scale,
    this.persist = true,
  })  : _now = clock ?? DateTime.now,
        _settings = settings ?? (() => MockMode.settings),
        _scale = scale ?? MockMode.scaled {
    _seedHistory();
  }

  static final MockBackend instance = MockBackend();

  static const _stateKey = 'qa_mock.backend_state';

  final DateTime Function() _now;
  final MockSettings Function() _settings;
  final Duration Function(Duration) _scale;
  final bool persist;

  final StreamController<MockSocketEvent> _socket =
      StreamController<MockSocketEvent>.broadcast();

  /// Server → passenger socket pushes (`rideAccepted`, `driverArrival`, …).
  /// `PassengerSocketService.connectToSocket` listens here in mock mode
  /// instead of on a real Socket.IO connection.
  Stream<MockSocketEvent> get socketEvents => _socket.stream;

  /// Bumped on every state change, for the dev panel's live summary.
  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  MockRide? ride;
  LatLng parkedAt = MockPlaces.watPhnom.latLng;
  LatLng passengerPosition = MockPlaces.passengerStart.latLng;
  int _nextBookingId = MockData.firstBookingId;
  final List<Map<String, dynamic>> _history = [];

  Timer? _acceptTimer;
  Timer? _expiryTimer;
  Timer? _arrivalTimer;
  Timer? _startTimer;
  Timer? _dropTimer;
  Timer? _paymentTimer;
  Timer? _finalizeTimer;
  Timer? _cancelTimer;

  MockSettings get settings => _settings();

  // ---------------------------------------------------------------------
  // Request handling
  // ---------------------------------------------------------------------

  /// Handle one HTTP-shaped request. Throws [MockConnectionFailure] for the
  /// `NETWORK_ERROR` scenario; returns a 401 for authenticated calls under
  /// `SESSION_EXPIRED`.
  Future<MockResponse> handle(MockRequest request) async {
    final scenario = settings.scenario;
    if (scenario == MockScenario.networkError) {
      throw const MockConnectionFailure();
    }
    if (scenario == MockScenario.sessionExpired && request.authenticated) {
      return const MockResponse(
          401, {'status': false, 'message': 'Unauthenticated.'});
    }

    final path = request.path;
    final announcementDetail =
        RegExp(r'/taxi-passenger/announcement/(\d+)$').firstMatch(path);

    if (path.endsWith('/taxi-passenger/login-phone')) return _loginPhone();
    if (path.endsWith('/taxi-passenger/verify-phone-otp')) {
      return _verifyOtp(request);
    }
    if (path.endsWith('/taxi-passenger/register')) {
      return _ok(MockData.registerPayload());
    }
    if (path.endsWith('/taxi/login')) return _debugLogin();
    if (path.endsWith('/taxi-passenger/push-device-token')) {
      return _ok({'status': true, 'message': 'Device token saved'});
    }
    if (path.endsWith('/taxi-passenger/update-passenger-location')) {
      _updatePassengerLocation(request.body);
      return _ok({'status': true, 'message': 'Location updated'});
    }
    if (path.endsWith('/taxi-passenger/request-booking')) {
      return _requestBooking(request);
    }
    if (path.endsWith('/taxi-passenger/get-request-booking-info')) {
      return _currentBooking();
    }
    if (path.endsWith('/taxi-passenger/cancel-request-booking-info')) {
      return _cancelBooking();
    }
    if (path.endsWith('/taxi-passenger/get-driver-location-around')) {
      return _driversAround(request);
    }
    if (path.endsWith('/taxi-passenger/history-booking-info')) {
      return _historyPage(request);
    }
    if (path.endsWith('/taxi-passenger/announcements')) {
      return _announcements(request);
    }
    if (announcementDetail != null) {
      return _announcement(int.parse(announcementDetail.group(1)!));
    }
    if (path.endsWith('/taxi-passenger/get-profile')) {
      return _ok({'status': true, 'message': 'Success', 'data': MockData.user()});
    }
    if (path.endsWith('/taxi/get-type-vehicle')) {
      return _ok({
        'status': true,
        'message': 'Success',
        'data': MockData.vehicleTypes(),
      });
    }
    if (path.contains('/taxi/get-current-app-version')) {
      return _ok(MockData.version());
    }

    debugPrint('[MockBackend] no handler for ${request.method} $path');
    return MockResponse(404, {
      'status': false,
      'message': 'Mock backend has no handler for ${request.method} $path',
    });
  }

  MockResponse _ok(Object data) => MockResponse(200, data);

  // ---- Auth -------------------------------------------------------------

  MockResponse _loginPhone() => _ok({
        'status': true,
        'message': 'OTP code has been sent to your phone',
        'data': {'seconde': 60},
      });

  /// Any code signs in, except `9999`, which is rejected — so the OTP error
  /// state is testable too.
  MockResponse _verifyOtp(MockRequest request) {
    if (request.body['otp_code']?.toString() == '9999') {
      return _ok({'status': false, 'message': 'OTP not correct', 'data': null});
    }
    return _ok(MockData.authPayload());
  }

  /// `POST /taxi/login` — how `DebugAuthBypass` seeds a session (screen the
  /// passenger app does not otherwise use). Same `UserResponseModel` shape as
  /// `verify-phone-otp`, which is what `AppLogic.initSocket()` and the legacy
  /// token bridge read.
  MockResponse _debugLogin() => _ok(MockData.authPayload());

  // ---- Booking lifecycle --------------------------------------------------

  /// `request-booking` — creates the booking and starts the sim. Under
  /// `BOOKING_FAILED` it returns a 2xx with no booking, which `MapLogic`
  /// treats as the "can't confirm" failure and shows its retry toast.
  MockResponse _requestBooking(MockRequest request) {
    if (settings.scenario == MockScenario.bookingFailed) {
      return _ok({
        'status': false,
        'message': 'CAN_NOT_CONFIRM_BOOKING',
        'data': null,
      });
    }

    final body = request.body;
    final pickup = _latLngFromRequest(body, 'start_latitude', 'start_longitude') ??
        MockPlaces.passengerStart.latLng;
    final destination =
        _latLngFromRequest(body, 'end_latitude', 'end_longitude');

    passengerPosition = pickup;

    final next = MockRide(
      id: _nextBookingId++,
      status: BookingStatus.request,
      driverStart: driverFix().point,
      pickup: pickup,
      destination: destination,
      createdAt: _now(),
      paymentMethod: settings.paymentMethod.label,
    );
    ride = next;

    _acceptTimer?.cancel();
    _expiryTimer?.cancel();
    if (settings.dispatch == MockDispatch.auto &&
        settings.scenario != MockScenario.noDriverAvailable) {
      _acceptTimer =
          Timer(_scale(MockTimings.driverAcceptsAfterRequest), _acceptDriver);
    }
    // Like the server's countdown on the map overlay: an unanswered request
    // goes away shortly after the passenger's `timeout_param` is up.
    _expiryTimer = Timer(MockTimings.unansweredRequestLifetime, () {
      if (ride?.id == next.id && ride?.status == BookingStatus.request) {
        _clearRide();
        _changed();
      }
    });
    _changed();
    return _ok({
      'status': true,
      'message': 'Booking created',
      'data': _bookingJson(next, driverPosition: next.driverStart),
    });
  }

  /// A booking the passenger can reach — request, accepted, arrived, on-going
  /// or pending payment. Returns `data: null` (which the app ignores) when
  /// there is no active booking.
  MockResponse _currentBooking() {
    final current = ride;
    if (current == null) {
      return _ok({'status': true, 'message': 'No active booking', 'data': null});
    }
    return _ok(
        {'status': true, 'message': 'Success', 'data': _bookingJson(current)});
  }

  /// `cancel-request-booking-info` — the passenger cancels while waiting for
  /// a driver, or en route. Always confirms; the archived ride lands in
  /// history as cancelled.
  MockResponse _cancelBooking() {
    final current = ride;
    if (current != null &&
        current.status != BookingStatus.pendingPayment &&
        current.status != BookingStatus.completed) {
      _archive(current..status = BookingStatus.cancel);
      _clearRide();
      _changed();
    }
    return _ok({'status': true, 'message': 'Booking cancelled'});
  }

  // ---- Drivers around, history, announcements -----------------------------

  MockResponse _driversAround(MockRequest request) {
    final wanted =
        int.tryParse('${request.body['type_vehicle']}') ?? MockData.vehicleTypeId;
    final aroundPickup = MockData.driver(
        id: MockData.driverId, position: parkedAt, typeVehicleId: wanted);
    final aroundAirport = MockData.driver(
        id: MockData.driverId + 1,
        position: MockPlaces.airport.latLng,
        typeVehicleId: wanted);
    return _ok({'status': true, 'message': 'Success', 'data': [aroundPickup, aroundAirport]});
  }

  MockResponse _historyPage(MockRequest request) {
    final page = int.tryParse('${request.query['page'] ?? 1}') ?? 1;
    final rawStatus = request.query['status'];
    final status = rawStatus == null ? null : int.tryParse('$rawStatus');
    final matching = [
      for (final item in _history)
        if (status == null || item['status'] == status) item,
    ];
    return _ok({
      'status': true,
      'message': 'Success',
      // One page: the list controller stops at the first empty page.
      'data': page == 1 ? matching : <dynamic>[],
      'current_page': page,
      'per_page': 10,
      'total': matching.length,
    });
  }

  MockResponse _announcements(MockRequest request) {
    final page = int.tryParse('${request.query['page'] ?? 1}') ?? 1;
    final items = MockData.announcements();
    return _ok({
      'status': true,
      'data': page == 1 ? items : <dynamic>[],
      'current_page': page,
      'last_page': 1,
      'per_page': 10,
      'total': items.length,
    });
  }

  MockResponse _announcement(int id) {
    for (final item in MockData.announcements()) {
      if (item['id'] == id) return _ok({'status': true, 'data': item});
    }
    return const MockResponse(
        404, {'status': false, 'message': 'Announcement not found'});
  }

  // ---------------------------------------------------------------------
  // Simulation
  // ---------------------------------------------------------------------

  /// Where the simulated car is right now, derived from the ride's phase and
  /// how long it has been in it — so it is correct after a restart too.
  ({LatLng point, double heading, double speedMps}) driverFix() {
    final current = ride;
    ({LatLng point, double heading, double speedMps}) along(
        List<LatLng> route, double progress, Duration phase) {
      final p = pointAlong(route, progress);
      final moving = progress < 1;
      final speed = moving
          ? pathLengthMeters(route) / (_scale(phase).inMilliseconds / 1000)
          : 0.0;
      return (point: p.point, heading: p.heading, speedMps: speed);
    }

    if (current == null) return (point: parkedAt, heading: 0, speedMps: 0);
    switch (current.status) {
      case BookingStatus.request:
        return (point: current.driverStart, heading: 0, speedMps: 0);
      case BookingStatus.accepted:
        return along(
          mockRoute(current.driverStart, current.pickUpPoint),
          _progress(current.acceptedAt, MockTimings.driveToPickup),
          MockTimings.driveToPickup,
        );
      case BookingStatus.arrival:
        return (point: current.pickUpPoint, heading: 0, speedMps: 0);
      case BookingStatus.onGoing:
        return along(
          mockRoute(current.pickUpPoint, current.driveTarget),
          _progress(current.startedAt, MockTimings.tripInProgress),
          MockTimings.tripInProgress,
        );
      case BookingStatus.pendingPayment:
        return (
          point: current.endPoint ?? current.driveTarget,
          heading: 0,
          speedMps: 0
        );
      default:
        return (point: current.driverStart, heading: 0, speedMps: 0);
    }
  }

  double _progress(DateTime? since, Duration phase) {
    if (since == null) return 0;
    final total = _scale(phase).inMilliseconds;
    if (total <= 0) return 1;
    return (_now().difference(since).inMilliseconds / total).clamp(0.0, 1.0);
  }

  /// The simulated driver accepts the booking (auto-dispatch timer, or the
  /// dev panel's manual button). Pushes `rideAccepted` — the event whose
  /// listener takes the passenger off the map overlay and onto the booking
  /// screen — then chains the rest of the trip.
  void _acceptDriver() {
    final current = ride;
    if (current == null || current.status != BookingStatus.request) return;
    current
      ..status = BookingStatus.accepted
      ..acceptedAt = _now();
    _expiryTimer?.cancel();

    _push('rideAccepted', _bookingJson(current));

    if (settings.scenario == MockScenario.driverCancelled) {
      _cancelTimer =
          Timer(_scale(MockTimings.driverCancelsAfterAccept), _cancelDriver);
    } else {
      _arrivalTimer =
          Timer(_scale(MockTimings.driveToPickup), _arriveDriver);
    }
    _changed();
  }

  /// Dev panel / tests: the simulated driver accepts right now.
  void acceptBookingNow() => _acceptDriver();

  /// Pushes a booking-status event in the same envelope shape as the REST
  /// responses (`status`/`message`/`data`). The in-app listeners only
  /// null-check the payload (`driverAcceptPayment`, `onDriverCancelDrive`) or
  /// ignore it (`_handleBookingUpdate`), but the flow tests parse
  /// `driverDropDrive` / `onDriverCancelDrive` as a `RequestBookingModel`, so
  /// the top-level `status` must stay a boolean.
  void _push(String name, Map<String, dynamic> booking) {
    _socket.add(MockSocketEvent(
        name, {'status': true, 'message': 'Success', 'data': booking}));
  }

  void _arriveDriver() {
    final current = ride;
    if (current == null || current.status != BookingStatus.accepted) return;
    current
      ..status = BookingStatus.arrival
      ..arrivedAt = _now();
    _push('driverArrival', _bookingJson(current));
    _startTimer = Timer(_scale(MockTimings.waitAtPickup), _startTrip);
    _changed();
  }

  void _startTrip() {
    final current = ride;
    if (current == null || current.status != BookingStatus.arrival) return;
    current
      ..status = BookingStatus.onGoing
      ..startedAt = _now();
    _push('driverStartDrive', _bookingJson(current));
    _dropTimer = Timer(_scale(MockTimings.tripInProgress), _dropOff);
    _changed();
  }

  void _dropOff() {
    final current = ride;
    if (current == null || current.status != BookingStatus.onGoing) return;
    final route = mockRoute(current.pickUpPoint, current.driveTarget);
    final km = pathLengthMeters(route) / 1000;
    current
      ..status = BookingStatus.pendingPayment
      ..completedAt = _now()
      ..endPoint = current.driveTarget
      ..distanceKm = km < 0.4 ? 0.4 : km
      ..fare = _roundToHundred(estimateFare(
        distanceKm: km < 0.4 ? 0.4 : km,
        pricePerKm: MockData.pricePerKm,
        minimumFare: MockData.minimumFare,
      ));
    _push('driverDropDrive', _bookingJson(current));
    _paymentTimer = Timer(_scale(MockTimings.paymentDelay), _collectPayment);
    _changed();
  }

  void _collectPayment() {
    final current = ride;
    if (current == null || current.status != BookingStatus.pendingPayment) {
      return;
    }
    // Non-null payload: the listener only runs the Fee → Rating → Receipt →
    // Home chain when `data != null`.
    _push('driverAcceptPayment', _bookingJson(current));
    // The booking stays resolvable for a moment so the app's one fetch of
    // `get-request-booking-info` after the event (~2s on the fee screen) is
    // not starved at 10x. Unscaled on purpose.
    _finalizeTimer = Timer(MockTimings.paymentFinalizeDelay, _finalizeTrip);
    _changed();
  }

  void _finalizeTrip() {
    final current = ride;
    if (current == null) return;
    _archive(current..status = BookingStatus.completed);
    parkedAt = current.endPoint ?? current.driveTarget;
    _clearRide();
    _changed();
  }

  /// `DRIVER_CANCELLED`: the simulated driver cancels after having accepted.
  /// Also reachable from the dev panel ("Driver cancels").
  void _cancelDriver() {
    final current = ride;
    if (current == null ||
        current.status == BookingStatus.pendingPayment ||
        current.status == BookingStatus.completed) {
      debugPrint('[MockBackend] nothing the driver can cancel');
      return;
    }
    _push('onDriverCancelDrive',
        _bookingJson(current, markStatus: BookingStatus.cancel));
    _archive(current..status = BookingStatus.cancel);
    _clearRide();
    _changed();
  }

  /// Dev panel / tests: the simulated driver cancels right now.
  void driverCancelNow() => _cancelDriver();

  /// Drops the current booking, keeping history and the dev panel tidy.
  void resetTrip() {
    _clearRide();
    parkedAt = MockPlaces.watPhnom.latLng;
    _changed();
  }

  /// Back to first-launch state: no ride, seeded history.
  void resetAll() {
    _clearRide();
    parkedAt = MockPlaces.watPhnom.latLng;
    passengerPosition = MockPlaces.passengerStart.latLng;
    _nextBookingId = MockData.firstBookingId;
    _seedHistory();
    _changed();
  }

  void onSettingsChanged() => _changed();

  void _clearRide() {
    _acceptTimer?.cancel();
    _expiryTimer?.cancel();
    _arrivalTimer?.cancel();
    _startTimer?.cancel();
    _dropTimer?.cancel();
    _paymentTimer?.cancel();
    _finalizeTimer?.cancel();
    _cancelTimer?.cancel();
    ride = null;
  }

  /// A one-line state description for the dev panel.
  String get summary {
    final current = ride;
    final rideText = current == null
        ? 'no booking'
        : 'booking #${current.id} · ${_statusName(current.status)}';
    return rideText;
  }

  // ---------------------------------------------------------------------
  // JSON
  // ---------------------------------------------------------------------

  static String _statusName(int status) => switch (status) {
        BookingStatus.request => 'Request',
        BookingStatus.accepted => 'Accepted',
        BookingStatus.arrival => 'Arrival',
        BookingStatus.onGoing => 'On-going',
        BookingStatus.pendingPayment => 'Pending Payment',
        BookingStatus.completed => 'Completed',
        BookingStatus.cancel => 'Cancelled',
        _ => 'Unknown',
      };

  static int _roundToHundred(double riel) => (riel / 100).round() * 100;

  /// One shape for every booking payload (`RequestBookingModel`'s data, the
  /// socket pushes, history) — the models read the same keys.
  Map<String, dynamic> _bookingJson(MockRide r,
      {LatLng? driverPosition, int? markStatus}) {
    final pickup = r.pickUpPoint;
    final end = r.endPoint ?? r.destination;
    final status = markStatus ?? r.status;
    final fix = driverPosition == null ? driverFix() : null;
    final driverPoint = driverPosition ?? fix!.point;
    final heading = driverPosition == null ? fix!.heading : 0.0;

    String? placeName(LatLng p) =>
        MockPlaces.nameNear(p) ?? 'Near Central Market, Daun Penh, Phnom Penh';

    return {
      'id': r.id,
      'booking_code': '${r.id}',
      'type_vehicle_id': MockData.vehicleTypeId,
      'type_vehicle': _typeVehicleJson(),
      'start_latitude': pickup.latitude.toStringAsFixed(6),
      'start_longitude': pickup.longitude.toStringAsFixed(6),
      'end_latitude': end?.latitude.toStringAsFixed(6),
      'end_longitude': end?.longitude.toStringAsFixed(6),
      'start_time':
          r.startedAt == null ? null : MockData.timestamp(r.startedAt!),
      'end_time':
          r.completedAt == null ? null : MockData.timestamp(r.completedAt!),
      'start_address': placeName(pickup),
      'end_address': end == null ? null : placeName(end),
      'fare': r.fare,
      'status': status,
      'status_name': _statusName(status),
      'passenger': _passengerJson(position: pickup),
      'driver': MockData.driver(
        position: driverPoint,
        heading: heading,
      ),
      // Cancelled rides carry a zero payment: the history card reads
      // `payment!` for every row, cancelled ones included.
      'payment':
          r.fare == null && status != BookingStatus.cancel ? null : _paymentJson(r),
      'timeout_count_down': 0,
      'timeout_param': MockTimings.requestTimeoutSeconds,
      'created_at': MockData.timestamp(r.createdAt),
      'updated_at': MockData.timestamp(r.completedAt ?? r.startedAt ?? r.createdAt),
    };
  }

  Map<String, dynamic> _typeVehicleJson() => {
        'id': MockData.vehicleTypeId,
        'name': 'Classic Car',
        'price': MockData.pricePerKm,
        'image': null,
        'created_at': '2025-01-01T00:00:00.000000Z',
        'updated_at': '2025-01-01T00:00:00.000000Z',
      };

  Map<String, dynamic> _passengerJson({required LatLng position}) => {
        ...MockData.user(),
        'last_location': MockData.location(position),
      };

  Map<String, dynamic> _paymentJson(MockRide r) {
    final km = r.distanceKm ?? 0;
    final seconds = (km / MockTimings.assumedCitySpeedKmh * 3600).round();
    final paid = r.status == BookingStatus.completed ||
        r.status == BookingStatus.pendingPayment;
    final cancelled = r.status == BookingStatus.cancel;
    return {
      'id': r.id - MockData.firstBookingId + 1,
      'invoice_id': 70000 + r.id - MockData.firstBookingId,
      'ride_id': r.id,
      'distance': '${km.toStringAsFixed(2)} km',
      'duration': seconds >= 3600
          ? '${seconds ~/ 3600} hours ${(seconds % 3600) ~/ 60} mins'
          : '${seconds ~/ 60} mins ${seconds % 60} seconds',
      'amount': '${r.fare ?? 0}',
      'payment_method': r.paymentMethod,
      'status': paid ? 1 : (cancelled ? 2 : 0),
      'status_name': paid ? 'Paid' : (cancelled ? 'Cancelled' : 'Pending'),
      'created_at': MockData.timestamp(r.startedAt ?? r.createdAt),
      'updated_at': MockData.timestamp(r.completedAt ?? r.createdAt),
    };
  }

  void _archive(MockRide r) {
    _history.insert(
        0, _bookingJson(r, driverPosition: r.endPoint ?? r.driverStart));
  }

  void _seedHistory() {
    _history.clear();
    final now = _now();
    var seedId = MockData.firstBookingId - 5;
    MockRide past({
      required int daysAgo,
      required int status,
      required double km,
      required String method,
      required LatLng destination,
    }) {
      final started = now.subtract(Duration(days: daysAgo, hours: 2));
      final r = MockRide(
        id: seedId++,
        status: status,
        driverStart: MockPlaces.watPhnom.latLng,
        pickup: MockPlaces.passengerStart.latLng,
        destination: destination,
        createdAt: started.subtract(const Duration(minutes: 6)),
        paymentMethod: method,
        startedAt: status == BookingStatus.cancel ? null : started,
        completedAt: status == BookingStatus.cancel
            ? null
            : started.add(Duration(
                minutes: (km / MockTimings.assumedCitySpeedKmh * 60).round())),
        endPoint: destination,
      );
      if (status == BookingStatus.completed) {
        r
          ..distanceKm = km
          ..fare = _roundToHundred(estimateFare(
              distanceKm: km,
              pricePerKm: MockData.pricePerKm,
              minimumFare: MockData.minimumFare));
      }
      return r;
    }

    for (final r in [
      past(
          daysAgo: 0,
          status: BookingStatus.completed,
          km: 3.4,
          method: 'Cash',
          destination: MockPlaces.russianMarket.latLng),
      past(
          daysAgo: 1,
          status: BookingStatus.completed,
          km: 10.6,
          method: 'Wallet',
          destination: MockPlaces.airport.latLng),
      past(
          daysAgo: 1,
          status: BookingStatus.cancel,
          km: 0,
          method: 'Cash',
          destination: MockPlaces.aeonMall.latLng),
      past(
          daysAgo: 3,
          status: BookingStatus.completed,
          km: 0.8,
          method: 'Card',
          destination: MockPlaces.royalPalace.latLng),
      past(
          daysAgo: 6,
          status: BookingStatus.completed,
          km: 2.9,
          method: 'Cash',
          destination: MockPlaces.independenceMonument.latLng),
    ]) {
      _history.add(_bookingJson(r, driverPosition: r.endPoint));
    }
  }

  // ---------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------

  void _changed() {
    revision.value++;
    if (persist) unawaited(_save());
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _stateKey,
        jsonEncode({
          'ride': ride?.toJson(),
          'parkedAt': _latLngToJson(parkedAt),
          'passengerPosition': _latLngToJson(passengerPosition),
          'nextBookingId': _nextBookingId,
          'history': _history,
        }));
  }

  /// Restores the state saved before the app was killed. A booking nobody
  /// accepted is dropped — it would have expired server-side. A mid-flight
  /// booking resumes wherever the timestamps say it is.
  Future<void> restore() async {
    if (!persist) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_stateKey);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final savedRide = json['ride'];
      ride = savedRide is Map<String, dynamic>
          ? MockRide.fromJson(savedRide)
          : null;
      _parkedAtFrom(json['parkedAt']);
      _passengerPositionFrom(json['passengerPosition']);
      _nextBookingId = json['nextBookingId'] as int? ?? _nextBookingId;
      _history
        ..clear()
        ..addAll((json['history'] as List).cast<Map<String, dynamic>>());
    } catch (e) {
      debugPrint('[MockBackend] discarding unreadable saved state: $e');
      resetAll();
      return;
    }
    final current = ride;
    if (current == null) return;
    if (current.status == BookingStatus.request) {
      // The request side of the sim died with the app.
      ride = null;
      _changed();
      return;
    }
    // Resume the driver's chain from wherever the timestamps put it.
    switch (current.status) {
      case BookingStatus.accepted:
        _arrivalTimer =
            Timer(_scale(MockTimings.driveToPickup), _arriveDriver);
      case BookingStatus.arrival:
        _startTimer = Timer(_scale(MockTimings.waitAtPickup), _startTrip);
      case BookingStatus.onGoing:
        _dropTimer = Timer(_scale(MockTimings.tripInProgress), _dropOff);
      case BookingStatus.pendingPayment:
        _paymentTimer = Timer(_scale(MockTimings.paymentDelay), _collectPayment);
      default:
        break;
    }
    revision.value++;
  }

  @visibleForTesting
  void dispose() {
    _acceptTimer?.cancel();
    _expiryTimer?.cancel();
    _arrivalTimer?.cancel();
    _startTimer?.cancel();
    _dropTimer?.cancel();
    _paymentTimer?.cancel();
    _finalizeTimer?.cancel();
    _cancelTimer?.cancel();
    _socket.close();
  }

  // ---- Shared helpers -----------------------------------------------------

  /// The passenger's own GPS pushing in (the real app does this while it is
  /// on the map, mock or not). Kept instead of ignored so the persisted
  /// `passengerPosition` — what `MockLocationSource` simulates — always
  /// matches where the passenger last was.
  void _updatePassengerLocation(Map<String, dynamic> body) {
    final p = _latLngFromRequest(body, 'latitude', 'longitude');
    if (p != null) passengerPosition = p;
  }

  void _parkedAtFrom(Object? json) {
    final p = _latLngFromJson(json);
    if (p != null) parkedAt = p;
  }

  void _passengerPositionFrom(Object? json) {
    final p = _latLngFromJson(json);
    if (p != null) passengerPosition = p;
  }
}

LatLng? _latLngFromRequest(
    Map<String, dynamic> body, String latKey, String lngKey) {
  final lat = double.tryParse(body[latKey]?.toString() ?? '');
  final lng = double.tryParse(body[lngKey]?.toString() ?? '');
  if (lat == null || lng == null || (lat == 0 && lng == 0)) return null;
  return LatLng(lat, lng);
}

Map<String, double> _latLngToJson(LatLng p) =>
    {'lat': p.latitude, 'lng': p.longitude};

LatLng? _latLngFromJson(Object? json) {
  if (json is! Map) return null;
  return LatLng(
      (json['lat'] as num).toDouble(), (json['lng'] as num).toDouble());
}