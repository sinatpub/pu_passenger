import 'package:com.tara.passenger/core/network/api_client.dart';
import 'package:com.tara.passenger/core/network/api_exception.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/data/datasources/announcement_api.dart';
import 'package:com.tara.passenger/data/datasources/cancel_booking_api.dart';
import 'package:com.tara.passenger/data/datasources/driver_around_api.dart';
import 'package:com.tara.passenger/data/datasources/history_booking_info_source.dart';
import 'package:com.tara.passenger/data/datasources/request_booking_api.dart';
import 'package:com.tara.passenger/data/datasources/update_passenger_location_api.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:com.tara.passenger/presentation/screens/login/data/datasource/auth_datasource.dart';
import 'package:com.tara.passenger/mock/mock_backend.dart';
import 'package:com.tara.passenger/mock/mock_fixtures.dart';
import 'package:com.tara.passenger/mock/mock_geo.dart';
import 'package:com.tara.passenger/mock/mock_http_interceptor.dart';
import 'package:com.tara.passenger/mock/mock_models.dart';
import 'package:com.tara.passenger/mock/mock_mode.dart';
import 'package:com.tara.passenger/mock/mock_timings.dart';
import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The whole passenger flow, through the app's **real** datasources,
/// repositories and models — the only substitution is the mock interceptor on
/// the Dio client, exactly as in a `USE_MOCK_DATA` build.
void main() {
  late DateTime now;
  late MockSettings settings;
  late MockBackend backend;
  late Dio dio;
  late ApiClient api;

  T value<T>(Result<T> result) => result.when(
        ok: (v) => v,
        err: (e) => fail('expected success, got ${e.type}: ${e.message}'),
      );

  ApiException error<T>(Result<T> result) => result.when(
        ok: (v) => fail('expected an error, got $v'),
        err: (e) => e,
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues(
        {'session_token': MockData.token});
    now = DateTime(2026, 9, 17, 10, 0, 0);
    settings = const MockSettings(dispatch: MockDispatch.manual);
    backend = MockBackend(
      clock: () => now,
      settings: () => settings,
      scale: (d) => d,
      persist: false,
    );
    dio = Dio(BaseOptions(baseUrl: 'https://api.tara-taxi.com'))
      ..interceptors.add(MockHttpInterceptor(
        backend: backend,
        isActive: () => true,
        latency: (_) => Duration.zero,
      ));
    api = ApiClient(dio: dio);
  });

  tearDown(() => backend.dispose());

  test('complete flow: login → register → book → ride → pay → history',
      () async {
    // ---- Login -------------------------------------------------------------
    final auth = AuthDatasource(apiClient: api);
    final phone = value(await auth.loginPhone('098765432'));
    expect(phone.status, isTrue);
    expect(phone.data.seconde, 60);

    final login = value(await auth.verifyOtp(phone: '098765432', otpCode: '1234'));
    expect(login.data?.token, MockData.token);
    expect(login.data?.user?.name, 'Sreymom Chan');

    final registered =
        value(await auth.register(fullName: 'Sreymom Chan',
            phoneNumber: '098765432', profileImage: null, platform: 'android'));
    expect(registered.data?.token, MockData.token);

    // ---- Explore before booking: vehicle types, drivers around -------------
    final vehicles = VehicalTypeEntities.fromJson(
        (await backend.handle(
                const MockRequest(method: 'GET', path: '/taxi/get-type-vehicle')))
            .data as Map<String, dynamic>);
    expect(vehicles.data.map((v) => v.name), contains('Classic Car'));
    expect(vehicles.data.firstWhere((v) => v.id == 2).price,
        MockData.pricePerKm);

    final drivers = value(await GetDriverAroundDataSource(apiClient: api)
        .getAllDriverAroundApi(typeVehicle: 2));
    expect(drivers.data, hasLength(2));
    expect(drivers.data!.first.id, MockData.driverId);
    expect(drivers.data!.first.lastLocation, isNotNull);
    expect(drivers.data!.first.vehicle?.plateNumber, '2AB-1234');

    // ---- No active booking before anything is requested --------------------
    final idle = RequestBookingModel.fromJson(
        (await backend.handle(const MockRequest(
                method: 'GET',
                path: '/taxi-passenger/get-request-booking-info')))
            .data as Map<String, dynamic>);
    expect(idle.data, isNull,
        reason: 'home stays put when there is no booking to redirect to');

    // ---- Book a ride -------------------------------------------------------
    final booking = value(await RequestBookingApi(apiClient: api)
        .requestBookingApi(
      startLatitude: MockPlaces.passengerStart.latitude,
      startLongitude: MockPlaces.passengerStart.longitude,
      destinationLatitude: MockPlaces.destination.latitude,
      destinationLongitude: MockPlaces.destination.longitude,
      typeVehicleId: MockData.vehicleTypeId,
    ));
    expect(booking.status, isTrue);
    final data = booking.data!;
    expect(data.status, BookingStatus.request);
    expect(data.id, greaterThanOrEqualTo(MockData.firstBookingId));
    expect(data.driver?.id, MockData.driverId);
    expect(data.typeVehicle?.name, 'Classic Car');
    expect(data.startAddress, contains('Central Market'));
    expect(data.endAddress, contains('Airport'));
    expect(data.fare, isNull, reason: 'no fare until the trip is paid');
    expect(data.payment, isNull);
    expect(data.timeoutParam, MockTimings.requestTimeoutSeconds);
    expect(
        double.parse(data.startLatitude.toString()),
        closeTo(MockPlaces.passengerStart.latitude, 1e-6));

    // The passenger's GPS follows wherever the API said the pickup is.
    final pushed = value(await UpdatePassengerLocationApi(apiClient: api)
        .updatePassengerLocationApi(lat: '11.6', lng: '104.9'));
    expect(pushed.status, isTrue);
    expect(backend.passengerPosition.latitude, closeTo(11.6, 1e-9));

    // ---- The simulated driver accepts and drives to the pickup -------------
    final events = <MockSocketEvent>[];
    final sub = backend.socketEvents.listen(events.add);
    backend.acceptBookingNow();
    // Broadcast `StreamController`: the push is delivered on the next turn.
    await pumpEventQueue();
    expect(events.single.name, 'rideAccepted');

    final startFix = backend.driverFix().point;
    now = now.add(MockTimings.driveToPickup ~/ 2);
    final midFix = backend.driverFix().point;
    expect(
      distanceMeters(midFix, MockPlaces.passengerStart.latLng),
      lessThan(distanceMeters(startFix, MockPlaces.passengerStart.latLng)),
      reason: 'the simulated car is en route, closing in on the pickup',
    );
    now = now.add(MockTimings.driveToPickup);
    expect(distanceMeters(backend.driverFix().point,
            MockPlaces.passengerStart.latLng),
        lessThan(1));

    // ---- Killing the app en route resumes through get-request-booking-info -
    final resumed = RequestBookingModel.fromJson(
        (await backend.handle(const MockRequest(
                method: 'GET',
                path: '/taxi-passenger/get-request-booking-info')))
            .data as Map<String, dynamic>);
    expect(resumed.data!.status, BookingStatus.accepted);
    expect(
        double.parse(resumed.data!.startLatitude.toString()),
        closeTo(MockPlaces.passengerStart.latitude,
            1e-6), reason: 'resume keeps the pickup the booking was made from');
    await sub.cancel();
  });

  test('auto dispatch plays the whole trip and archives a paid booking',
      () {
    settings = const MockSettings();
    final raw = <MockSocketEvent>[];
    late int createdId;

    fakeAsync((async) {
      final fast = MockBackend(
        clock: () => now,
        settings: () => settings,
        scale: (_) => Duration.zero,
        persist: false,
      );
      addTearDown(fast.dispose);
      final sub = fast.socketEvents.listen(raw.add);

      MockResponse? reply;
      fast
          .handle(const MockRequest(
            method: 'POST',
            path: '/taxi-passenger/request-booking',
            body: {
              'start_latitude': '11.569600',
              'start_longitude': '104.921000',
              'end_latitude': '11.546600',
              'end_longitude': '104.844100',
              'type_vehicle_id': 2,
            },
          ))
          .then((r) => reply = r);
      async.flushMicrotasks();
      final booking =
          RequestBookingModel.fromJson(reply!.data as Map<String, dynamic>);
      createdId = booking.data!.id!;

      // The zero-scale chain cascades accept → arrive → start → drop → pay.
      // (`flushTimers()` would also fire the future finalize timer and archive
      // the ride before the fee screen could fetch it — `elapse` only fires
      // timers that are already due.)
      async.elapse(Duration.zero);
      expect(raw.map((e) => e.name), [
        'rideAccepted',
        'driverArrival',
        'driverStartDrive',
        'driverDropDrive',
        'driverAcceptPayment',
      ]);

      // The drop-off's payload is the receipt's own shape.
      final drop = RequestBookingModel.fromJson(
          raw.firstWhere((e) => e.name == 'driverDropDrive').data);
      final pending = drop.data!;
      expect(pending.status, BookingStatus.pendingPayment);
      expect(pending.payment, isNotNull);
      expect(double.parse(pending.payment!.amount!),
          greaterThan(MockData.minimumFare));
      expect(pending.payment!.distance, endsWith(' km'));
      expect(pending.payment!.paymentMethod, 'Cash');

      // The booking stays resolvable for the fee screen, then finalizes.
      const drift = MockRequest(
          method: 'GET', path: '/taxi-passenger/get-request-booking-info');
      late Map resolved;
      fast.handle(drift).then((r) => resolved = r.data as Map);
      async.flushMicrotasks();
      expect((resolved['data'] as Map)['status'], BookingStatus.pendingPayment);

      async.elapse(MockTimings.paymentFinalizeDelay);
      late Map afterFinalize;
      fast.handle(drift).then((r) => afterFinalize = r.data as Map);
      async.flushMicrotasks();
      expect(afterFinalize['data'], isNull);

      late List history;
      fast
          .handle(const MockRequest(
            method: 'GET',
            path: '/taxi-passenger/history-booking-info',
            query: {'page': '1', 'status': '4'},
          ))
          .then((r) => history = (r.data as Map)['data'] as List);
      async.flushMicrotasks();
      expect(history.map((h) => (h as Map)['id']), contains(createdId));
      expect(history.every((h) => (h as Map)['payment'] != null), isTrue,
          reason: 'the history card reads payment! on every row');

      expect(fast.summary, 'no booking');
      sub.cancel();
    });
  });

  group('scenarios', () {
    test('BOOKING_FAILED returns 2xx with no booking', () async {
      settings = settings.copyWith(scenario: MockScenario.bookingFailed);
      final result = await RequestBookingApi(apiClient: api)
          .requestBookingApi(
        startLatitude: MockPlaces.passengerStart.latitude,
        startLongitude: MockPlaces.passengerStart.longitude,
      );
      final failed = value(result);
      expect(failed.status, isFalse);
      expect(failed.data, isNull);
    });

    test('NO_DRIVER never dispatches and cancel-request confirms', () async {
      settings = settings.copyWith(scenario: MockScenario.noDriverAvailable);
      final events = <MockSocketEvent>[];
      final sub = backend.socketEvents.listen(events.add);
      final booking = value(await RequestBookingApi(apiClient: api)
          .requestBookingApi(
        startLatitude: MockPlaces.passengerStart.latitude,
        startLongitude: MockPlaces.passengerStart.longitude,
        destinationLatitude: MockPlaces.destination.latitude,
        destinationLongitude: MockPlaces.destination.longitude,
      ));
      expect(booking.data!.status, BookingStatus.request);
      // Still parked where the request found the car.
      expect(backend.driverFix().point, MockPlaces.watPhnom.latLng);

      expect(value(await CancelBookingApi(apiClient: api).cancelBookingApi()),
          isTrue);
      // The waiting overlay goes away: nothing left to redirect to.
      final now = RequestBookingModel.fromJson(
          (await backend.handle(const MockRequest(
                  method: 'GET',
                  path: '/taxi-passenger/get-request-booking-info')))
              .data as Map<String, dynamic>);
      expect(now.data, isNull);
      expect(events, isEmpty, reason: 'no driver ever accepted');
      await sub.cancel();
    });

    test('DRIVER_CANCELLED accepts then pushes onDriverCancelDrive', () {
      settings = settings.copyWith(
          scenario: MockScenario.driverCancelled,
          dispatch: MockDispatch.auto);
      final raw = <MockSocketEvent>[];
      fakeAsync((async) {
        final fast = MockBackend(
          clock: () => now,
          settings: () => settings,
          scale: (_) => Duration.zero,
          persist: false,
        );
        addTearDown(fast.dispose);
        final sub = fast.socketEvents.listen(raw.add);
        fast.handle(const MockRequest(
            method: 'POST',
            path: '/taxi-passenger/request-booking',
            body: {'start_latitude': '11.569600',
              'start_longitude': '104.921000'}));
        async.flushMicrotasks();
        async.elapse(Duration.zero);
        expect(raw.map((e) => e.name), [
          'rideAccepted',
          'onDriverCancelDrive',
        ]);
        expect(fast.ride, isNull);
        expect(
            RequestBookingModel.fromJson(raw.last.data).data!.status,
            BookingStatus.cancel,
            reason: 'the passenger listener keys its dialog on the payload');
        async.flushMicrotasks();
        expect((fast.summary), 'no booking');
        sub.cancel();
      });
    });

    test('NETWORK_ERROR is classified as a connection failure', () async {
      settings = settings.copyWith(scenario: MockScenario.networkError);
      final e = error(await RequestBookingApi(apiClient: api)
          .requestBookingApi(
              startLatitude: 0, startLongitude: 0));
      expect(e.type, ApiErrorType.connection);
    });

    test('SESSION_EXPIRED 401s authenticated calls only', () async {
      settings = settings.copyWith(scenario: MockScenario.sessionExpired);
      final reply = await backend.handle(const MockRequest(
          method: 'POST',
          path: '/taxi-passenger/get-driver-location-around',
          body: {'type_vehicle': '2'},
          authenticated: true));
      expect(reply.statusCode, 401);
      final login = await backend.handle(
          const MockRequest(method: 'POST', path: '/taxi-passenger/login-phone'));
      expect(login.statusCode, 200);
    });

    test('OTP 9999 is rejected', () async {
      final auth = AuthDatasource(apiClient: api);
      final result =
          value(await auth.verifyOtp(phone: '098765432', otpCode: '9999'));
      expect(result.status, isFalse);
      expect(result.data, isNull);
    });

    test('a ride without a destination has no end point until the trip',
        () async {
      final booking = value(await RequestBookingApi(apiClient: api)
          .requestBookingApi(
        startLatitude: MockPlaces.passengerStart.latitude,
        startLongitude: MockPlaces.passengerStart.longitude,
      ));
      expect(booking.data!.endLatitude, isNull);
      expect(booking.data!.endAddress, isNull);
    });
  });

  test('announcements and their details parse through the real repo',
      () async {
    final news = AnnouncementRepo(apiClient: api);
    final all = await news.getAllAnnouncement(pageNo: 1);
    expect(all, isNotNull);
    expect(all!.data, hasLength(3));
    final rows = all.data!;
    final detail =
        await news.getAnnouncementById(rows.first.id as int);
    expect(detail?.title, 'Pchum Ben holiday bonus');
    expect(detail?.createdAt, isNotNull);
  });

  test('history pagination and filtering come back through the real API',
      () async {
    final history =
        HistroyBookingApi(apiClient: api);
    final completed = await history.getAllHistoryPaging(
        filterStatus: BookingStatus.completed, pageNo: 1);
    expect(completed, isNotNull);
    final completedRows = completed!.data!;
    expect(completedRows, isNotEmpty);
    expect(completedRows.every((d) => d.status == BookingStatus.completed),
        isTrue);
    expect(completedRows.every((d) => d.payment != null), isTrue,
        reason: 'the history card reads payment! on every completed row');

    final cancelled = await history.getAllHistoryPaging(
        filterStatus: BookingStatus.cancel, pageNo: 1);
    expect(cancelled!.data!, isNotEmpty);
  });

  test('state survives an app restart, dropping an unanswered request',
      () async {
    SharedPreferences.setMockInitialValues({});
    final first = MockBackend(
        clock: () => now, settings: () => settings, scale: (d) => d);
    addTearDown(first.dispose);

    await first.handle(const MockRequest(
        method: 'POST',
        path: '/taxi-passenger/request-booking',
        body: {'start_latitude': '11.569600',
          'start_longitude': '104.921000'}));
    first.acceptBookingNow();
    await pumpEventQueue();
    final id = first.ride!.id;

    final restarted = MockBackend(
        clock: () => now, settings: () => settings, scale: (d) => d);
    addTearDown(restarted.dispose);
    await restarted.restore();
    expect(restarted.ride?.id, id);
    expect(restarted.ride?.status, BookingStatus.accepted);

    // A request nobody answered does not come back.
    first.resetTrip();
    await first.handle(const MockRequest(
        method: 'POST',
        path: '/taxi-passenger/request-booking',
        body: {'start_latitude': '11.569600',
          'start_longitude': '104.921000'}));
    await pumpEventQueue();
    final again = MockBackend(
        clock: () => now, settings: () => settings, scale: (d) => d);
    addTearDown(again.dispose);
    await again.restore();
    expect(again.ride, isNull);
  });

  test('FormData bodies reach the backend as flat fields', () {
    expect(
        MockHttpInterceptor.bodyToMap(
            FormData.fromMap({'phone': '098765432', 'gender': 1})),
        {'phone': '098765432', 'gender': '1'});
    expect(MockHttpInterceptor.bodyToMap(<String, Object>{
      'start_latitude': 11.5696
    }), {
      'start_latitude': 11.5696
    });
    expect(MockHttpInterceptor.bodyToMap(null), isEmpty);
  });

  test('the mock route follows Russian Federation Blvd to the airport', () {
    final route =
        mockRoute(MockPlaces.passengerStart.latLng, MockPlaces.destination.latLng);
    final km = pathLengthMeters(route) / 1000;
    expect(km, inInclusiveRange(8, 12));
    expect(pointAlong(route, 0).point, MockPlaces.passengerStart.latLng);
    expect(pointAlong(route, 1).point, MockPlaces.destination.latLng);
    expect(MockPlaces.nameNear(const LatLng(11.5697, 104.9211)),
        MockPlaces.passengerStart.name);
  });
}