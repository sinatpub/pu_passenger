import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/data/datasources/check_request_book_source.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/logic.dart';
import 'package:com.tara.passenger/services/booking_session.dart';
import 'package:com.tara.passenger/services/location_imp.dart';

/// P-09 (docs/12, docs/09 §7, docs/08 M-2) — `getBookingInfo` is triggered
/// by two independent channels (a 10s poll and socket events), both racing
/// to write the same `state.bookingRequestData`. A slower, earlier-started
/// call must not overwrite state a faster, later-started call already
/// wrote. Hand-written fake, no mocktail (`.agent/skills/testing.md`).
class _FakeCheckBookingApi extends CheckBookingApi {
  final List<Completer<RequestBookingModel>> _completers = [];

  @override
  Future<RequestBookingModel> checkBookingApi() {
    final completer = Completer<RequestBookingModel>();
    _completers.add(completer);
    return completer.future;
  }

  int get callCount => _completers.length;

  void completeCall(int index, RequestBookingModel response) {
    _completers[index].complete(response);
  }
}

/// A directions service that answers with a fixed route, at once or when the
/// test completes [pending].
class _FakeLocationRepo extends LocationRepo {
  final List<(LatLng, LatLng)> requests = [];
  Completer<RouteInfo>? pending;

  static const route = RouteInfo(
    points: [LatLng(11.57, 104.92), LatLng(11.56, 104.93)],
    distanceMeters: 1240,
    duration: Duration(seconds: 250),
  );

  @override
  Future<RouteInfo> getRoute(LatLng start, LatLng end) {
    requests.add((start, end));
    return pending?.future ?? Future.value(route);
  }
}

/// A booking with a pickup, a driver somewhere else and, optionally, a
/// drop-off — enough for `drawPolyline()` to ask for a route.
RequestBookingModel _tripModel(int status, {bool withDropOff = true}) =>
    RequestBookingModel(
      data: Data(
        status: status,
        startLatitude: '11.5600',
        startLongitude: '104.9300',
        endLatitude: withDropOff ? '11.5500' : null,
        endLongitude: withDropOff ? '104.8500' : null,
        driver: Driver(
          lastLocation: LastLocation(latitude: '11.5700', longitude: '104.9200'),
        ),
      ),
    );

/// `startLatitude`/`startLongitude` and `driver` are left null so
/// `drawPolyline()` hits its `start.latitude == 0` guard and returns before
/// any real network call — keeps this a pure logic test.
RequestBookingModel _modelWithStatus(int status) =>
    RequestBookingModel(data: Data(status: status));

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    // The Get.put<LocationRepo>/Get.put<AppLogic> calls that used to live
    // here were a workaround: BookingMapLogic resolved both with Get.find in
    // field initializers, so merely *constructing* it required them to be
    // registered. They now resolve lazily and can be injected, so the
    // workaround is gone — see the "constructor injection" group below.
  });

  tearDown(() => Get.reset());

  group('getBookingInfo out-of-order response guard', () {
    test('a single call updates state normally', () async {
      final fake = _FakeCheckBookingApi();
      final logic = BookingMapLogic(checkBookingApi: fake);

      final call = logic.getBookingInfo(isSilent: true);
      fake.completeCall(0, _modelWithStatus(BookingStatus.accepted));
      await call;

      expect(logic.state.bookingRequestData?.data?.status, BookingStatus.accepted);
    });

    test('a slower call started first does not overwrite a faster call started later', () async {
      final fake = _FakeCheckBookingApi();
      final logic = BookingMapLogic(checkBookingApi: fake);

      // Call 0 starts first (simulates the 10s poll firing).
      final firstCall = logic.getBookingInfo(isSilent: true);
      // Call 1 starts second, before call 0 has resolved (simulates a
      // socket event triggering a refresh while the poll is in flight).
      final secondCall = logic.getBookingInfo(isSilent: true);
      expect(fake.callCount, 2);

      // The newer call's response arrives first — this is the common case
      // (sockets are faster than a fixed 10s poll) and should apply.
      fake.completeCall(1, _modelWithStatus(BookingStatus.onGoing));
      await secondCall;
      expect(logic.state.bookingRequestData?.data?.status, BookingStatus.onGoing);

      // The older call's stale response arrives after — must be discarded,
      // not overwrite the newer state.
      fake.completeCall(0, _modelWithStatus(BookingStatus.accepted));
      await firstCall;
      expect(
        logic.state.bookingRequestData?.data?.status,
        BookingStatus.onGoing,
        reason: 'the stale "accepted" response must not regress the newer "onGoing" state',
      );
    });

    test('three interleaved calls: only the latest-started response wins', () async {
      final fake = _FakeCheckBookingApi();
      final logic = BookingMapLogic(checkBookingApi: fake);

      final call0 = logic.getBookingInfo(isSilent: true);
      final call1 = logic.getBookingInfo(isSilent: true);
      final call2 = logic.getBookingInfo(isSilent: true);

      // Resolve out of start order: 1, then 0, then 2 (the actually-latest
      // one). Only call2's response should be reflected at the end.
      fake.completeCall(1, _modelWithStatus(BookingStatus.accepted));
      await call1;
      fake.completeCall(0, _modelWithStatus(BookingStatus.request));
      await call0;
      fake.completeCall(2, _modelWithStatus(BookingStatus.arrival));
      await call2;

      expect(logic.state.bookingRequestData?.data?.status, BookingStatus.arrival);
    });
  });

  /// The arrival time on the sheet comes from the route that draws the line:
  /// one directions request gives both.
  group('driver arrival time', () {
    BookingMapLogic logicWith(_FakeLocationRepo repo, RequestBookingModel model) {
      final logic = BookingMapLogic(
        checkBookingApi: _FakeCheckBookingApi(),
        locationRepo: repo,
      );
      logic.state.bookingRequestData = model;
      return logic;
    }

    test('accepted: the driver → pickup route gives the time and distance',
        () async {
      final repo = _FakeLocationRepo();
      final logic = logicWith(repo, _tripModel(BookingStatus.accepted));

      await logic.drawPolyline();

      expect(repo.requests.single,
          (const LatLng(11.57, 104.92), const LatLng(11.56, 104.93)));
      expect(logic.state.pickupEta, const Duration(seconds: 250));
      expect(logic.state.pickupDistanceMeters, 1240);
      expect(logic.state.polyline, hasLength(1));
    });

    test('arrived: the line and the arrival time are both cleared', () async {
      final repo = _FakeLocationRepo();
      final logic = logicWith(repo, _tripModel(BookingStatus.accepted));
      await logic.drawPolyline();

      logic.state.bookingRequestData = _tripModel(BookingStatus.arrival);
      await logic.drawPolyline();

      expect(logic.state.pickupEta, isNull);
      expect(logic.state.pickupDistanceMeters, isNull);
      expect(logic.state.polyline, isEmpty);
    });

    test('on trip: the trip route is drawn, but it is not an arrival time',
        () async {
      final repo = _FakeLocationRepo();
      final logic = logicWith(repo, _tripModel(BookingStatus.onGoing));

      await logic.drawPolyline();

      expect(repo.requests, hasLength(1));
      expect(logic.state.polyline, hasLength(1));
      expect(logic.state.pickupEta, isNull);
    });

    test('on trip without a drop-off: no route is asked for', () async {
      final repo = _FakeLocationRepo();
      final logic = logicWith(
          repo, _tripModel(BookingStatus.onGoing, withDropOff: false));

      await logic.drawPolyline();

      expect(repo.requests, isEmpty);
      expect(logic.state.pickupEta, isNull);
    });

    test('a route that lands after the stage changed is dropped', () async {
      final repo = _FakeLocationRepo()..pending = Completer<RouteInfo>();
      final logic = logicWith(repo, _tripModel(BookingStatus.accepted));

      final drawing = logic.drawPolyline();
      // The driver arrives while the directions request is still out.
      logic.state.bookingRequestData = _tripModel(BookingStatus.arrival);
      repo.pending!.complete(_FakeLocationRepo.route);
      await drawing;

      expect(logic.state.pickupEta, isNull,
          reason: 'an arrival time under "Driver has arrived"');
      expect(logic.state.polyline, isEmpty);
    });
  });

  // Reaching the ride screen — by the accept event, a poll or a restart —
  // is what ends the request phase. Until this, the session stayed
  // `awaitingDriver` and refused every later booking.
  group('the ride screen takes the booking over', () {
    test('opening it marks the request accepted, keeping the draft', () async {
      final session = BookingSession()
        ..beginRequest(
          pickup: const LatLng(11.56, 104.93),
          destination: const LatLng(11.55, 104.85),
          vehicleTypeId: 3,
        )
        ..markAwaitingDriver();
      final logic = BookingMapLogic(
        checkBookingApi: _FakeCheckBookingApi(),
        bookingSession: session,
      );

      // `onInit` calls this first; the rest of it fetches the booking and
      // loads marker images, which this test does not provide.
      logic.markRequestAccepted();

      expect(session.status, BookingRequestStatus.accepted);
      expect(session.isBusy, isFalse);
      expect(session.vehicleTypeId, 3);
    });

    test('the session the app registered is the one it marks', () {
      final session = Get.put<BookingSession>(
        BookingSession()
          ..beginRequest(pickup: const LatLng(11.56, 104.93))
          ..markAwaitingDriver(),
      );
      final logic = BookingMapLogic(checkBookingApi: _FakeCheckBookingApi());

      logic.markRequestAccepted();

      expect(session.status, BookingRequestStatus.accepted);
    });

    test('with no session registered it still opens', () {
      final logic = BookingMapLogic(checkBookingApi: _FakeCheckBookingApi());

      expect(logic.markRequestAccepted, returnsNormally);
    });
  });

  group('poll policy driven through the controller (P-09 remainder / F-03)',
      () {
    test('a healthy socket suppresses five ticks in six', () async {
      final fake = _FakeCheckBookingApi();
      final logic = BookingMapLogic(
        checkBookingApi: fake,
        isSocketConnected: () => true,
      );

      for (var i = 0; i < 5; i++) {
        logic.onPollTick();
      }
      expect(fake.callCount, 0,
          reason: 'the socket is primary while it is up');

      logic.onPollTick(); // sixth tick — the safety net
      expect(fake.callCount, 1);
    });

    test('a down socket polls on every tick', () async {
      final fake = _FakeCheckBookingApi();
      final logic = BookingMapLogic(
        checkBookingApi: fake,
        isSocketConnected: () => false,
      );

      for (var i = 0; i < 5; i++) {
        logic.onPollTick();
      }
      expect(fake.callCount, 5);
    });

    test('losing the socket mid-cycle resumes polling on the next tick',
        () async {
      final fake = _FakeCheckBookingApi();
      var connected = true;
      final logic = BookingMapLogic(
        checkBookingApi: fake,
        isSocketConnected: () => connected,
      );

      logic.onPollTick();
      logic.onPollTick();
      expect(fake.callCount, 0);

      connected = false;
      logic.onPollTick();
      expect(fake.callCount, 1,
          reason: 'the fallback must take over without waiting for tick 6');
    });
  });

  group('constructor injection (Discovered Tasks / docs/10 §3.2)', () {
    test('the controller can be constructed with nothing registered in Get',
        () {
      // Previously this threw: `Get.find<LocationRepo>()` ran in a field
      // initializer, so construction demanded a populated Get container.
      expect(
        () => BookingMapLogic(checkBookingApi: _FakeCheckBookingApi()),
        returnsNormally,
      );
    });

    test('an injected collaborator is used instead of the container', () {
      final injected = LocationRepo();
      final logic = BookingMapLogic(
        checkBookingApi: _FakeCheckBookingApi(),
        locationRepo: injected,
      );

      // Reaching the field must not consult Get at all.
      expect(() => logic.socketConnected, returnsNormally);
    });
  });
}
