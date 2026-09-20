import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/calculate_fee_screen.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/widgets/fee_card.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

Data _data({
  String? amount = '12000',
  String? method = 'Cash',
  String? driverName = 'Sok Dara',
  String? vehicleName = 'Tuk-Tuk',
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
    driver: Driver(name: driverName),
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

    testWidgets('renders the four KV rows', (tester) async {
      await _pump(tester, FeeCard(data: _data()));

      expect(find.text('6.1 km'), findsOneWidget);
      expect(find.text('18 min'), findsOneWidget);
      expect(find.text(AppLocale.vehicle), findsOneWidget);
      expect(find.text(AppLocale.dateTime), findsOneWidget);
    });

    testWidgets('pickup and destination read their own fields', (tester) async {
      // The screen this replaced printed `endAddress` in both rows, so the
      // pickup line showed the destination.
      await _pump(tester, FeeCard(data: _data()));

      final rows = tester
          .widgetList<TaAddressRow>(find.byType(TaAddressRow))
          .toList();
      expect(rows, hasLength(2));
      expect(rows[0].type, TaAddressType.pickup);
      expect(rows[0].name, 'No. 128, St. 271');
      expect(rows[1].type, TaAddressType.destination);
      expect(rows[1].name, 'Aeon Mall Phnom Penh');
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

  group('FeeContent total box — money fails loudly', () {
    testWidgets('renders the fare and the payment method in the label',
        (tester) async {
      await _pump(tester, FeeContent(data: _data()));

      final box = tester.widget<TaTotalBox>(find.byType(TaTotalBox));
      expect(box.amount, '12,000 ${AppLocale.khmerCurrency}');
      expect(box.label, '${AppLocale.totalPrice} · Cash');
    });

    testWidgets('falls back to a plain total when no method is named',
        (tester) async {
      await _pump(tester, FeeContent(data: _data(method: null)));

      final box = tester.widget<TaTotalBox>(find.byType(TaTotalBox));
      expect(box.label, AppLocale.totalPrice);
    });

    testWidgets('an unparseable fare says so instead of showing a number',
        (tester) async {
      await _pump(tester, FeeContent(data: _data(amount: 'abc')));

      expect(find.byType(TaTotalBox), findsNothing);
      expect(find.text(AppLocale.fareUnavailable), findsOneWidget);
    });

    testWidgets('a missing fare says so instead of showing zero',
        (tester) async {
      await _pump(tester, FeeContent(data: _data(amount: null)));

      expect(find.byType(TaTotalBox), findsNothing);
      expect(find.text(AppLocale.fareUnavailable), findsOneWidget);
    });
  });

  group('FeeContent payment wait (D14 — no demo controls)', () {
    testWidgets('shows the waiting badge', (tester) async {
      await _pump(tester, FeeContent(data: _data()));

      final badge = tester.widget<TaBadge>(find.byType(TaBadge));
      expect(badge.variant, TaBadgeVariant.warning);
      expect(find.text(AppLocale.waitPaymentDriver), findsOneWidget);
    });

    testWidgets('offers no "simulate payment" control', (tester) async {
      // D14: production waits for the real `driverAcceptPayment` socket event.
      await _pump(tester, FeeContent(data: _data()));

      expect(find.byType(TaButton), findsNothing);
    });
  });

  group('FeeLoadingView', () {
    testWidgets('renders the shimmer placeholder', (tester) async {
      await _pump(tester, const FeeLoadingView());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TaSkeleton), findsWidgets);
      expect(find.byType(TaTotalBox), findsNothing);
    });
  });
}
