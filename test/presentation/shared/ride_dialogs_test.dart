import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:com.tara.passenger/presentation/shared/ride_dialogs.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/services/booking_session.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

const _rideMarker = Key('ride-stub');
const _homeMarker = Key('home-stub');
const _mapMarker = Key('map-stub');

/// What the booking map was opened with.
Object? _mapArguments;

/// A ride in progress, with stubs for the two places the dialogs lead to.
Future<void> _pumpRide(WidgetTester tester) async {
  _mapArguments = null;
  await tester.pumpWidget(
    GetMaterialApp(
      initialRoute: AppRoutes.BOOKING,
      getPages: [
        GetPage(
          name: AppRoutes.BOOKING,
          page: () => const Scaffold(body: SizedBox(key: _rideMarker)),
        ),
        GetPage(
          name: AppRoutes.BOTTOMNAV,
          page: () => const Scaffold(body: SizedBox(key: _homeMarker)),
        ),
        GetPage(
          name: AppRoutes.MAP,
          page: () {
            _mapArguments = Get.arguments;
            return const Scaffold(body: SizedBox(key: _mapMarker));
          },
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() => Get.reset());

  group('rebookArguments', () {
    test('carries the vehicle and the drop-off of the trip that was lost', () {
      expect(
        rebookArguments(
            vehicleTypeId: 3, destination: const LatLng(11.54, 104.85)),
        {'vehicleId': 3, 'destination': const LatLng(11.54, 104.85)},
      );
    });

    test('leaves out what the trip did not have', () {
      expect(rebookArguments(vehicleTypeId: 3), {'vehicleId': 3});
      expect(rebookArguments(), isEmpty);
    });
  });

  group('Driver cancelled', () {
    BookingSession lostTrip({LatLng? destination}) => BookingSession()
      ..beginRequest(
        pickup: const LatLng(11.55, 104.91),
        destination: destination,
        vehicleTypeId: 3,
      )
      ..markAwaitingDriver()
      ..markAccepted();

    testWidgets('leaves the ride for Home and says so in a dialog',
        (tester) async {
      await _pumpRide(tester);

      presentDriverCancelled(session: lostTrip());
      await tester.pumpAndSettle();

      expect(find.byKey(_rideMarker), findsNothing);
      expect(find.byKey(_homeMarker), findsOneWidget);
      expect(find.byType(TaDialogCard), findsOneWidget);
      expect(find.text(AppLocale.driverCancelledTitle), findsOneWidget);
      expect(find.text(AppLocale.driverCancelledBody), findsOneWidget);
      expect(find.byType(TaDialogIcon), findsOneWidget);
    });

    // The popup this replaced vanished after 8 seconds and at any tap.
    testWidgets('stays until the passenger answers', (tester) async {
      await _pumpRide(tester);
      presentDriverCancelled(session: lostTrip());
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 30));
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.text(AppLocale.driverCancelledTitle), findsOneWidget);
    });

    testWidgets('Close leaves the passenger on Home', (tester) async {
      await _pumpRide(tester);
      presentDriverCancelled(session: lostTrip());
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppLocale.close));
      await tester.pumpAndSettle();

      expect(find.byType(TaDialogCard), findsNothing);
      expect(find.byKey(_homeMarker), findsOneWidget);
      expect(_mapArguments, isNull);
    });

    testWidgets('Book again opens the booking map with the same vehicle and '
        'drop-off', (tester) async {
      await _pumpRide(tester);
      presentDriverCancelled(
        session: lostTrip(destination: const LatLng(11.54, 104.85)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppLocale.bookAgain));
      await tester.pumpAndSettle();

      expect(find.byType(TaDialogCard), findsNothing);
      expect(find.byKey(_mapMarker), findsOneWidget);
      expect(_mapArguments,
          {'vehicleId': 3, 'destination': const LatLng(11.54, 104.85)});
    });

    testWidgets('a trip booked without a drop-off rebooks without one',
        (tester) async {
      await _pumpRide(tester);
      presentDriverCancelled(session: lostTrip());
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppLocale.bookAgain));
      await tester.pumpAndSettle();

      expect(_mapArguments, {'vehicleId': 3});
    });

    testWidgets('with no draft left — the app was restarted mid-ride — Book '
        'again still opens the booking map', (tester) async {
      await _pumpRide(tester);
      presentDriverCancelled(session: BookingSession());
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppLocale.bookAgain));
      await tester.pumpAndSettle();

      expect(find.byKey(_mapMarker), findsOneWidget);
      expect(_mapArguments, isEmpty);
    });

    testWidgets('finds the session the app registered', (tester) async {
      Get.put<BookingSession>(
        lostTrip(destination: const LatLng(11.54, 104.85)),
        permanent: true,
      );
      await _pumpRide(tester);

      presentDriverCancelled();
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppLocale.bookAgain));
      await tester.pumpAndSettle();

      expect(_mapArguments,
          {'vehicleId': 3, 'destination': const LatLng(11.54, 104.85)});
    });
  });

  group('Booking failed', () {
    /// Opens the dialog and returns a reader for what it was answered with:
    /// null until a button is tapped.
    Future<bool? Function()> open(
        WidgetTester tester, BookingFailure failure) async {
      bool? answer;
      await tester.pumpWidget(
        GetMaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async =>
                    answer = await showBookingFailedDialog(context, failure),
                child: const Text('fail'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('fail'));
      await tester.pumpAndSettle();
      return () => answer;
    }

    testWidgets('a failed request: check the connection', (tester) async {
      await open(tester, BookingFailure.requestFailed);

      expect(find.text(AppLocale.bookingFailedTitle), findsOneWidget);
      expect(find.text(AppLocale.bookingFailedBody), findsOneWidget);
      expect(find.text(AppLocale.bookingFailedNoLocation), findsNothing);
    });

    testWidgets('no location: says it is the location', (tester) async {
      await open(tester, BookingFailure.noLocation);

      expect(find.text(AppLocale.bookingFailedNoLocation), findsOneWidget);
      expect(find.text(AppLocale.bookingFailedBody), findsNothing);
    });

    testWidgets('"Try again" is a button, and answers yes', (tester) async {
      final answer = await open(tester, BookingFailure.requestFailed);

      await tester
          .tap(find.widgetWithText(TaButton, AppLocale.pleaseTryAgain));
      await tester.pumpAndSettle();

      expect(find.byType(TaDialogCard), findsNothing);
      expect(answer(), isTrue);
    });

    testWidgets('Close answers no', (tester) async {
      final answer = await open(tester, BookingFailure.requestFailed);

      await tester.tap(find.widgetWithText(TaButton, AppLocale.close));
      await tester.pumpAndSettle();

      expect(find.byType(TaDialogCard), findsNothing);
      expect(answer(), isFalse);
    });

    // The popup this replaced showed for one second.
    testWidgets('stays until answered', (tester) async {
      final answer = await open(tester, BookingFailure.requestFailed);

      await tester.pump(const Duration(seconds: 30));

      expect(find.text(AppLocale.bookingFailedTitle), findsOneWidget);
      expect(answer(), isNull);
    });
  });
}
