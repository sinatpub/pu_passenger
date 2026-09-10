import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/services/socket_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Characterization tests for the *payloads* the passenger puts on the wire,
/// and for the reconnection policy F-03 fixed (`.agent/TODO.md` Recommended #2).
///
/// Payload keys matter as much as event names: the server relays these through
/// **verbatim** (confirmed live 2026-09-07, `.agent/PROGRESS.md`), so a renamed
/// key silently breaks the driver with nothing failing to compile on either
/// side.
///
/// Per `.agent/skills/testing.md` these use a hand-written recording subclass,
/// not a mocking framework. `emitEvent` is the choke point every emit below
/// flows through, so overriding it captures the real call without a socket.
class _RecordingPassengerSocketService extends PassengerSocketService {
  _RecordingPassengerSocketService() : super.forTesting();

  final List<({SocketEvent event, dynamic data})> emitted = [];

  @override
  void emitEvent(SocketEvent event, dynamic data) {
    emitted.add((event: event, data: data));
  }

  ({SocketEvent event, dynamic data}) get only {
    expect(emitted, hasLength(1), reason: 'expected exactly one emit');
    return emitted.single;
  }
}

/// A booking shaped the way `request-booking` returns one. Every field on the
/// model is nullable, so each test overrides only what it is actually about.
RequestBookingModel _booking({
  int? id = 10,
  dynamic bookingCode = 20,
  dynamic typeVehicleId = 3,
  int? vehicleTypeNestedId = 3,
  int? vehiclePrice = 4500,
  int? passengerId = 30,
  int? driverId = 7,
  int? timeoutParam = 60,
}) {
  return RequestBookingModel(
    status: true,
    data: Data(
      id: id,
      bookingCode: bookingCode,
      typeVehicleId: typeVehicleId,
      typeVehicle:
          TypeVehicle(id: vehicleTypeNestedId, name: 'Taxi', price: vehiclePrice),
      timeoutParam: timeoutParam,
      passenger: Passenger(
        id: passengerId,
        name: 'Dara',
        phone: '900000001',
        profileImage: 'https://example.invalid/p.png',
      ),
      driver: Driver(id: driverId, name: 'Sok'),
    ),
  );
}

void main() {
  late _RecordingPassengerSocketService socket;

  setUp(() => socket = _RecordingPassengerSocketService());

  group('reconnection policy (F-03)', () {
    test('websocket-only transport, matching the server probe', () {
      expect(buildSocketOptions()['transports'], ['websocket']);
    });

    test('backs off 2s -> 30s instead of the old flat 60s wait', () {
      expect(buildSocketOptions()['reconnectionDelay'], 2000);
      expect(buildSocketOptions()['reconnectionDelayMax'], 30000);
    });

    test('no attempts cap — the absence of the key is the fix', () {
      // The regression F-03 fixed was `setReconnectionAttempts(4)`, which made
      // the client stop retrying for good after ~4 minutes offline. The client
      // only retries forever while this key is absent, so asserting absence is
      // the only way to catch someone "helpfully" adding a cap back.
      expect(buildSocketOptions().containsKey('reconnectionAttempts'), isFalse);
      expect(buildSocketOptions()['reconnection'], isNot(false));
    });
  });

  group('register', () {
    test('emits the raw passenger id, not a wrapping object', () {
      socket.register('4242');
      expect(socket.only.event, SocketEvent.registerPassenger);
      expect(socket.only.data, '4242');
    });
  });

  group('rideRequestSocket', () {
    test('sends the full request shape drivers are matched on', () {
      socket.rideRequestSocket(
        data: _booking(),
        startLatitude: 11.5564,
        startLongitude: 104.9282,
        startDestinationLat: 11.5,
        startDestinationLong: 104.9,
      );

      expect(socket.only.event, SocketEvent.rideRequest);
      expect(socket.only.data, {
        'booking_code': '20',
        'booking_id': '10',
        'passengerId': '30',
        'location': {'latitude': 11.5564, 'longitude': 104.9282},
        'vehiclePrice': 4500,
        'vehicleType': 3,
        'timeout': 60,
        'passenger': {
          'name': 'Dara',
          'phone': '900000001',
          'profile': 'https://example.invalid/p.png',
        },
        'destination': {'latitude': 11.5, 'longitude': 104.9},
      });
    });

    test('a null vehicle price degrades to 0 rather than a null on the wire',
        () {
      socket.rideRequestSocket(data: _booking(vehiclePrice: null));
      expect((socket.only.data as Map)['vehiclePrice'], 0);
    });

    test('a null typeVehicleId falls back to the nested typeVehicle.id', () {
      // Was a `FormatException` that killed the request inside
      // `MapScreenLogic.requestBooking()`'s `ok` branch and left the booking
      // spinner stuck. The nested `typeVehicle` carries the same vehicle type
      // in the very same response, so it is the fallback with an actual claim
      // to being correct rather than merely non-throwing.
      socket.rideRequestSocket(data: _booking(typeVehicleId: null));
      expect((socket.only.data as Map)['vehicleType'], 3);
    });

    test('a numeric-string typeVehicleId still parses, as int.parse did', () {
      // `typeVehicleId` is `dynamic` on the model and the API has been seen to
      // send it either way; the old `int.parse` accepted both, so the fix must
      // not narrow that.
      socket.rideRequestSocket(data: _booking(typeVehicleId: '7'));
      expect((socket.only.data as Map)['vehicleType'], 7);
    });

    test('an unparseable typeVehicleId degrades to 0 instead of throwing', () {
      socket.rideRequestSocket(
        data: _booking(typeVehicleId: 'not-a-number', vehicleTypeNestedId: null),
      );
      expect((socket.only.data as Map)['vehicleType'], 0);
      // The request still goes out — losing the whole booking over one
      // unreadable field is the behaviour this replaced.
      expect(socket.only.event, SocketEvent.rideRequest);
    });

    test('an omitted destination sends nulls, not absent keys', () {
      socket.rideRequestSocket(data: _booking());
      final destination =
          (socket.only.data as Map)['destination'] as Map<String, dynamic>;
      expect(destination.containsKey('latitude'), isTrue);
      expect(destination['latitude'], isNull);
      expect(destination['longitude'], isNull);
    });
  });

  group('rideRequestSpecificDriverSocket', () {
    test('is rideRequest plus driver_id, on its own event', () {
      socket.rideRequestSpecificDriverSocket(
        driverID: 7,
        data: _booking(),
        startLatitude: 11.5564,
        startLongitude: 104.9282,
      );

      expect(socket.only.event, SocketEvent.rideRequestSpecificDriver);

      final payload = socket.only.data as Map<String, dynamic>;
      expect(payload['driver_id'], 7);
      // driver_id is the only difference from the broadcast request — if these
      // two payloads ever diverge further, the targeted-request flow starts
      // matching on different data than the broadcast one.
      socket.emitted.clear();
      socket.rideRequestSocket(
        data: _booking(),
        startLatitude: 11.5564,
        startLongitude: 104.9282,
      );
      final broadcast = socket.only.data as Map<String, dynamic>;
      expect(
        {...payload}..remove('driver_id'),
        broadcast,
      );
    });

    test('driver_id stays an int here while other ids are stringified', () {
      socket.rideRequestSpecificDriverSocket(driverID: 7, data: _booking());
      final payload = socket.only.data as Map<String, dynamic>;
      expect(payload['driver_id'], isA<int>());
      expect(payload['booking_id'], isA<String>());
    });
  });

  group('handleCancelRide', () {
    test('cancels against the driver id, on the passengerCancelDrive event', () {
      socket.handleCancelRide(data: _booking());

      expect(socket.only.event, SocketEvent.rideCancel);
      expect(socket.only.event.eventName, 'passengerCancelDrive');
      expect(socket.only.data, {'driver_id': 7});
    });

    test('with no booking at all it still emits, with a null driver_id', () {
      // Documents that there is no guard here: cancelling before a driver has
      // been assigned puts `{"driver_id": null}` on the wire rather than
      // skipping the emit. This is one of the two relays that could not be
      // confirmed against the live server (`.agent/TODO.md` Discovered Tasks),
      // so the shape is pinned as-is pending that verification.
      socket.handleCancelRide();
      expect(socket.only.data, {'driver_id': null});
    });
  });
}
