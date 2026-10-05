import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/calculate_fee_screen.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/widgets/fee_card.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/widgets/fee_waiting_banner.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

Data _data({
  String? amount = '12000',
  String? method = 'Cash',
  String? driverName = 'Sok Dara',
  String? vehicleName = 'Tuk-Tuk',
  Vehicle? vehicle,
  String? distance = '6.1 km',
  String? duration = '18 min',
  String? startAddress = 'No. 128, St. 271',
  dynamic endAddress = 'Aeon Mall Phnom Penh',
  dynamic startTime = '2026-09-11 09:41:00',
}) {
  return Data(
    startTime: startTime,
    startAddress: startAddress,
    endAddress: endAddress,
    typeVehicle: TypeVehicle(name: vehicleName),
    driver: Driver(name: driverName, vehicle: vehicle),
    payment: Payment(
      amount: amount,
      paymentMethod: method,
      distance: distance,
      duration: duration,
    ),
  );
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    GetMaterialApp(home: Scaffold(body: child)),
  );
  await tester.pump();
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() => Get.reset());

  group('FeeCard (03 §Screen 10)', () {
    testWidgets('renders the driver row without rating or plate',
        (tester) async {
      await _pump(tester, FeeCard(data: _data()));

      final card = tester.widget<TaDriverCard>(find.byType(TaDriverCard));
      expect(card.name, 'Sok Dara');
      expect(card.vehicleInfo, 'Tuk-Tuk');
      expect(card.initials, 'SD');
      expect(card.rating, isNull, reason: 'the trip is over');
      expect(card.plateNumber, isNull);
    });

    testWidgets('names the car by model and colour when the booking has them',
        (tester) async {
      await _pump(
        tester,
        FeeCard(
          data: _data(
            vehicle: Vehicle(
                manufacturer: 'Toyota', model: 'Prius', color: 'White'),
          ),
        ),
      );

      final card = tester.widget<TaDriverCard>(find.byType(TaDriverCard));
      expect(card.vehicleInfo, 'Toyota Prius · White');
    });

    testWidgets('distance, duration and date — and no second "Vehicle" line',
        (tester) async {
      await _pump(tester, FeeCard(data: _data()));

      expect(find.text('6.1 km'), findsOneWidget);
      expect(find.text('18 min'), findsOneWidget);
      expect(find.text('11 Sep 2026, 9:41 AM'), findsOneWidget);
      expect(find.text(AppLocale.vehicle), findsNothing);
      // The vehicle is named once, under the driver.
      expect(find.text('Tuk-Tuk'), findsOneWidget);
    });

    testWidgets('pickup and destination read their own fields', (tester) async {
      // The screen this replaced printed `endAddress` in both rows, so the
      // pickup line showed the destination.
      await _pump(tester, FeeCard(data: _data()));

      final trip = tester.widget<TaTripCard>(find.byType(TaTripCard));
      expect(trip.pickup, 'No. 128, St. 271');
      expect(trip.dropOff, 'Aeon Mall Phnom Penh');
    });

    testWidgets('a trip booked without a drop-off says so, not a dash',
        (tester) async {
      await _pump(tester, FeeCard(data: _data(endAddress: null)));

      expect(find.text(AppLocale.noDropOffMeter), findsOneWidget);
    });

    testWidgets('a payload with nothing filled in degrades instead of crashing',
        (tester) async {
      await _pump(
        tester,
        FeeCard(
          data: _data(
            driverName: null,
            vehicleName: null,
            distance: null,
            duration: null,
            startAddress: null,
            endAddress: null,
            startTime: null,
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('—'), findsWidgets);
    });

    testWidgets('a null booking renders the empty receipt without throwing',
        (tester) async {
      await _pump(tester, const FeeCard(data: null));
      expect(tester.takeException(), isNull);
    });
  });

  group('FeeContent fare — money fails loudly', () {
    testWidgets('the fare leads the page, with the payment method under it',
        (tester) async {
      await _pump(tester, FeeContent(data: _data()));

      final fare = find.text('12,000 ${AppLocale.khmerCurrency}');
      expect(fare, findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);

      final fareRect = tester.getRect(fare);
      expect(fareRect.bottom,
          lessThanOrEqualTo(tester.getRect(find.text('Cash')).top));
      expect(
        fareRect.bottom,
        lessThan(tester.getRect(find.byType(FeeWaitingBanner)).top),
        reason: 'what is owed comes before everything else',
      );
      expect(
        tester.getRect(find.byType(FeeWaitingBanner)).bottom,
        lessThan(tester.getRect(find.byType(FeeCard)).top),
      );
    });

    testWidgets('no method named: the fare stands alone, nothing invented',
        (tester) async {
      await _pump(tester, FeeContent(data: _data(method: null)));

      expect(find.text('12,000 ${AppLocale.khmerCurrency}'), findsOneWidget);
      expect(find.text('Cash'), findsNothing);
    });

    testWidgets('an unparseable fare says so instead of showing a number',
        (tester) async {
      await _pump(tester, FeeContent(data: _data(amount: 'abc')));

      expect(find.textContaining(AppLocale.khmerCurrency), findsNothing);
      expect(find.text(AppLocale.fareUnavailable), findsOneWidget);
    });

    testWidgets('a missing fare says so instead of showing zero',
        (tester) async {
      await _pump(tester, FeeContent(data: _data(amount: null)));

      expect(find.textContaining(AppLocale.khmerCurrency), findsNothing);
      expect(find.text(AppLocale.fareUnavailable), findsOneWidget);
    });

    testWidgets('a missing fare can be asked for again', (tester) async {
      var retries = 0;
      await _pump(
        tester,
        FeeContent(data: _data(amount: null), onRetry: () => retries++),
      );

      await tester.tap(find.text(AppLocale.retry));
      expect(retries, 1);
    });
  });

  group('FeeContent payment wait (D14 — no demo controls)', () {
    testWidgets('says the driver is confirming the payment', (tester) async {
      await _pump(tester, FeeContent(data: _data()));

      expect(find.byType(FeeWaitingBanner), findsOneWidget);
      expect(find.text(AppLocale.waitPaymentDriver), findsOneWidget);
    });

    testWidgets('the same message whatever the payment method',
        (tester) async {
      for (final method in ['Cash', 'Wallet', 'Card', null]) {
        await _pump(tester, FeeContent(data: _data(method: method)));
        expect(find.text(AppLocale.waitPaymentDriver), findsOneWidget);
      }
    });

    testWidgets('offers no "simulate payment" control', (tester) async {
      // D14: production waits for the real `driverAcceptPayment` socket event.
      await _pump(tester, FeeContent(data: _data()));

      expect(find.byType(TaButton), findsNothing);
    });
  });

  group('FeeErrorView — the trip could not be loaded', () {
    testWidgets('says so, points at the driver, and offers Retry',
        (tester) async {
      var retries = 0;
      await _pump(tester, FeeErrorView(onRetry: () => retries++));

      expect(find.text(AppLocale.couldNotLoadFare), findsOneWidget);
      expect(find.text(AppLocale.askDriverForAmount), findsOneWidget);

      await tester.tap(find.text(AppLocale.retry));
      expect(retries, 1);
    });

    testWidgets('still shows that the driver is confirming the payment',
        (tester) async {
      await _pump(tester, FeeErrorView(onRetry: () {}));

      expect(find.byType(FeeWaitingBanner), findsOneWidget);
    });
  });

  group('FeeLoadingView', () {
    testWidgets('renders the shimmer placeholder', (tester) async {
      await _pump(tester, const FeeLoadingView());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TaSkeleton), findsWidgets);
      expect(find.byType(FeeWaitingBanner), findsNothing);
    });
  });
}
