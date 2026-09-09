import 'dart:async';

import 'package:com.tara.passenger/core/network/api_exception.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/data/datasources/request_booking_api.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/data/datasources/update_passenger_location_api.dart';
import 'package:com.tara.passenger/data/models/passenger_location_model.dart'
    show UpdateLocationModel;
import 'package:com.tara.passenger/presentation/screens/map_screen/logic.dart';
import 'package:com.tara.passenger/services/socket_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// P-08 (docs/12) — the booking-request lifecycle.
///
/// Every test here pins a state the old toggle-from-the-view implementation
/// could reach and could not leave: the overlay up with no booking behind it
/// and no way back, because the cancel button was commented out. Hand-written
/// fakes, no mocktail (`.agent/skills/testing.md`).
class _FakeRequestBookingApi extends RequestBookingApi {
  _FakeRequestBookingApi();

  final List<Completer<Result<RequestBookingModel>>> completers = [];
  int callCount = 0;

  @override
  Future<Result<RequestBookingModel>> requestBookingApi({
    required double startLatitude,
    required double startLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    String? address,
    int? typeVehicleId,
  }) {
    callCount++;
    final c = Completer<Result<RequestBookingModel>>();
    completers.add(c);
    return c.future;
  }
}

/// Records ride-request emits without opening a socket.
class _FakeSocket extends PassengerSocketService {
  _FakeSocket() : super.forTesting();

  int rideRequests = 0;

  @override
  void rideRequestSocket({
    required RequestBookingModel data,
    double? startLatitude,
    double? startLongitude,
    double? startDestinationLat,
    double? startDestinationLong,
  }) {
    rideRequests++;
  }
}

class _FakeUpdateLocationApi extends UpdatePassengerLocationApi {
  int calls = 0;

  @override
  Future<Result<UpdateLocationModel>> updatePassengerLocationApi({
    required String lat,
    required String lng,
  }) async {
    calls++;
    return Result.ok(UpdateLocationModel());
  }
}

/// A booking the server accepted. `data` non-null is the success signal
/// `requestBooking()` keys off.
RequestBookingModel _booking() => RequestBookingModel(data: Data(id: 1));

/// A 2xx carrying no booking — the silent dead end before P-08.
RequestBookingModel _emptyBooking() => RequestBookingModel(data: null);

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });
  tearDown(() => Get.reset());

  /// Builds a MapLogic with only the collaborators `requestBooking()` reaches,
  /// so nothing touches the network, the socket, or GetX bindings.
  late _FakeSocket socket;
  late _FakeUpdateLocationApi updateLocation;
  late List<String> shownErrors;

  MapLogic buildLogic(_FakeRequestBookingApi api) {
    socket = _FakeSocket();
    updateLocation = _FakeUpdateLocationApi();
    shownErrors = <String>[];
    // Only the collaborators `requestBooking()` actually reaches are supplied.
    // The rest stay unresolved — which is the point of the lazy fields.
    return MapLogic(
      requestBookingApi: api,
      socket: socket,
      updatePassengerLocationApi: updateLocation,
      errorPresenter: (message) async => shownErrors.add(message),
    );
  }

  group('setBookingLoading', () {
    test('is a set, not a toggle — repeat calls are idempotent', () {
      final logic = buildLogic(_FakeRequestBookingApi());

      logic.setBookingLoading(true);
      expect(logic.state.isBookingLoading, isTrue);

      // The old toggle would have flipped this back to false.
      logic.setBookingLoading(true);
      expect(logic.state.isBookingLoading, isTrue);

      logic.setBookingLoading(false);
      expect(logic.state.isBookingLoading, isFalse);
    });
  });

  group('requestBooking preconditions', () {
    test('a null current location does not strand the overlay', () async {
      final api = _FakeRequestBookingApi();
      final logic = buildLogic(api);
      logic.state.currentLatLng = null;

      await logic.requestBooking();

      // Previously: the view had already switched the overlay on and the
      // early return left it there permanently.
      expect(logic.state.isBookingLoading, isFalse);
      expect(api.callCount, 0, reason: 'no request without a location');
    });
  });

  group('requestBooking re-entrancy', () {
    test('a second tap while one is in flight is a no-op', () async {
      final api = _FakeRequestBookingApi();
      final logic = buildLogic(api);
      logic.state.currentLatLng = const LatLng(11.55, 104.91);

      final first = logic.requestBooking();
      expect(logic.state.isBookingLoading, isTrue);

      // The double-tap. Previously this flipped the flag to false and issued
      // a second booking against the same passenger.
      await logic.requestBooking();

      expect(api.callCount, 1, reason: 'exactly one booking may be in flight');
      expect(logic.state.isBookingLoading, isTrue,
          reason: 'the overlay must not clear while a request is in flight');

      api.completers[0].complete(Result.ok(_booking()));
      await first;
    });
  });

  group('requestBooking outcomes', () {
    test('an ok result with a null booking is a failure, not silence',
        () async {
      final api = _FakeRequestBookingApi();
      final logic = buildLogic(api);
      logic.state.currentLatLng = const LatLng(11.55, 104.91);

      final call = logic.requestBooking();
      api.completers[0].complete(Result.ok(_emptyBooking()));
      await call;

      // Previously: no emit, no error, no state change — overlay up forever.
      expect(logic.state.isBookingLoading, isFalse);
    });

    test('an error clears the overlay exactly once', () async {
      final api = _FakeRequestBookingApi();
      final logic = buildLogic(api);
      logic.state.currentLatLng = const LatLng(11.55, 104.91);

      final call = logic.requestBooking();
      api.completers[0].complete(
        Result.err(const ApiException(
            type: ApiErrorType.connection, message: 'network down')),
      );
      await call;

      // Previously the error branch toggled, so after a double-tap it turned
      // the overlay back ON.
      expect(logic.state.isBookingLoading, isFalse);
    });

    test('a successful booking emits rideRequest exactly once and keeps the '
        'overlay up while waiting for a driver', () async {
      final api = _FakeRequestBookingApi();
      final logic = buildLogic(api);
      logic.state.currentLatLng = const LatLng(11.55, 104.91);

      final call = logic.requestBooking();
      api.completers[0].complete(Result.ok(_booking()));
      await call;

      expect(socket.rideRequests, 1);
      expect(updateLocation.calls, 1);
      expect(shownErrors, isEmpty);
      // Deliberate: the passenger is now waiting for a driver to accept.
      expect(logic.state.isBookingLoading, isTrue);
    });

    test('cancelBooking is the way out of the waiting state', () async {
      final api = _FakeRequestBookingApi();
      final logic = buildLogic(api);
      logic.state.currentLatLng = const LatLng(11.55, 104.91);

      final call = logic.requestBooking();
      api.completers[0].complete(Result.ok(_booking()));
      await call;
      expect(logic.state.isBookingLoading, isTrue);

      logic.setBookingLoading(false);
      expect(logic.state.isBookingLoading, isFalse);
    });

    test('a failed booking surfaces a message to the passenger', () async {
      final api = _FakeRequestBookingApi();
      final logic = buildLogic(api);
      logic.state.currentLatLng = const LatLng(11.55, 104.91);

      final call = logic.requestBooking();
      api.completers[0].complete(
        Result.err(const ApiException(
            type: ApiErrorType.connection, message: 'network down')),
      );
      await call;

      expect(shownErrors, hasLength(1),
          reason: 'the passenger must be told, not left guessing');
      expect(socket.rideRequests, 0);
    });

    test('a failed booking can be retried', () async {
      final api = _FakeRequestBookingApi();
      final logic = buildLogic(api);
      logic.state.currentLatLng = const LatLng(11.55, 104.91);

      final first = logic.requestBooking();
      api.completers[0].complete(
        Result.err(const ApiException(
            type: ApiErrorType.connection, message: 'network down')),
      );
      await first;

      // The re-entrancy guard must not latch after a failure.
      final second = logic.requestBooking();
      expect(api.callCount, 2, reason: 'retry after failure must be allowed');
      api.completers[1].complete(Result.ok(_booking()));
      await second;
    });
  });
}
