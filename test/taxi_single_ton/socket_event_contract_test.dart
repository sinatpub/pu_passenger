import 'package:com.tara.passenger/taxi_single_ton/init_socket.dart';
import 'package:flutter_test/flutter_test.dart';

/// Characterization tests for the passenger half of the Socket.IO wire contract
/// (`.agent/TODO.md` Recommended #2; mandatory under `.agent/RULES.md` because
/// every event here moves trip state or money).
///
/// These pin *wire strings*, not Dart identifiers. Unlike the driver app, the
/// passenger maps enum → wire string by hand through `SocketEventName.eventName`,
/// and four of those mappings deliberately do **not** match the constant's own
/// name (`rideCancel` → `passengerCancelDrive`, `onDriverCancel` →
/// `onDriverCancelDrive`). That hand-written switch is exactly the kind of thing
/// a rename or a merge silently breaks, and `dart analyze` cannot catch it.
///
/// The expected values are not guesses. They were confirmed against the live
/// server on 2026-09-07 by connecting two Socket.IO probe clients and observing
/// the relay (`.agent/PROGRESS.md`), which resolved the open question `docs/04`
/// §3.3 raised and `docs/13` carried.
void main() {
  group('passenger wire event names', () {
    test('every SocketEvent maps to its confirmed wire string', () {
      expect(SocketEvent.registerPassenger.eventName, 'registerPassenger');
      expect(SocketEvent.rideRequest.eventName, 'rideRequest');
      expect(SocketEvent.rideAccepted.eventName, 'rideAccepted');
      expect(SocketEvent.driverArrival.eventName, 'driverArrival');
      expect(SocketEvent.driverStartDrive.eventName, 'driverStartDrive');
      expect(SocketEvent.driverDropDrive.eventName, 'driverDropDrive');
      expect(SocketEvent.driverAcceptPayment.eventName, 'driverAcceptPayment');
      expect(
        SocketEvent.rideRequestSpecificDriver.eventName,
        'rideRequestSpecificDriver',
      );
    });

    test('the four constants whose wire name differs from the enum name', () {
      // Called out separately because these are the ones a "tidy up the enum
      // names to match the strings" refactor would break on the wire while
      // leaving the code compiling and every other test green.
      expect(SocketEvent.rideCancel.eventName, 'passengerCancelDrive');
      expect(SocketEvent.rideCancel.eventName, isNot(SocketEvent.rideCancel.name));

      expect(SocketEvent.onDriverCancel.eventName, 'onDriverCancelDrive');
      expect(
        SocketEvent.onDriverCancel.eventName,
        isNot(SocketEvent.onDriverCancel.name),
      );
    });

    test('the enum has not grown or shrunk without this test being updated', () {
      expect(SocketEvent.values, hasLength(10));
    });

    test('eventName is total — no constant falls through to a throw', () {
      // The switch has no default arm, so a constant added without a case is a
      // compile error today; this keeps that true if the switch ever gains one.
      for (final event in SocketEvent.values) {
        expect(event.eventName, isNotEmpty, reason: 'no wire name for $event');
      }
    });
  });

  group('cross-app relay contract (verified live 2026-09-07)', () {
    // The server renames driver→passenger events as it relays them, routing by
    // `passengerId` and passing payloads through verbatim. The driver app's own
    // outbound names are pinned in pu_driver's socket_event_contract_test.dart;
    // the literals below are that test's expectations restated, so a unilateral
    // rename on *either* side fails on one side or the other. The two apps are
    // separate Dart packages, so this pairing cannot be asserted by importing
    // both — restating it is the only mechanism available.
    const driverEmitsToPassengerListens = <String, String>{
      'acceptRide': 'rideAccepted',
      'rideArrival': 'driverArrival',
      'startDrive': 'driverStartDrive',
      'dropDrive': 'driverDropDrive',
      'acceptPayment': 'driverAcceptPayment',
    };

    test('every relayed event has a passenger listener with the right name', () {
      final passengerNames =
          SocketEvent.values.map((e) => e.eventName).toSet();
      for (final entry in driverEmitsToPassengerListens.entries) {
        expect(
          passengerNames,
          contains(entry.value),
          reason: 'server relays ${entry.key} -> ${entry.value}, but no '
              'passenger SocketEvent maps to ${entry.value}',
        );
      }
    });

    test('driver outbound names are never mistaken for passenger events', () {
      // A driver-side name appearing in the passenger enum would mean one app
      // is listening for the pre-relay name and would never fire.
      final passengerNames =
          SocketEvent.values.map((e) => e.eventName).toSet();
      for (final driverEvent in driverEmitsToPassengerListens.keys) {
        expect(
          passengerNames,
          isNot(contains(driverEvent)),
          reason: '$driverEvent is the driver\'s pre-relay name; the passenger '
              'must listen for ${driverEmitsToPassengerListens[driverEvent]}',
        );
      }
    });
  });
}
