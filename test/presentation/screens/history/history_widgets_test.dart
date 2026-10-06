import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:com.tara.passenger/presentation/screens/home/logic.dart';
import 'package:com.tara.passenger/presentation/screens/history/widgets/history_tab.dart';
import 'package:com.tara.passenger/presentation/screens/history_detail/view.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

const _detailMarker = Key('history-detail-stub');

Datum _trip({
  int? status = BookingStatus.completed,
  String? endAddress = 'Aeon Mall',
  String? amount = '12000',
  String? method = 'Cash',
  int? vehicleTypeId = 2,
  String? duration = '18 mins 20 seconds',
}) =>
    Datum(
      status: status,
      createdAt: '2026-09-11T09:41:00',
      startAddress: 'No. 128, St. 271',
      endAddress: endAddress,
      driver: Driver(
        name: 'Sok Dara',
        vehicle: Vehicle(typeVehicleId: vehicleTypeId),
      ),
      payment: Payment(
        invoiceId: 2041,
        amount: amount,
        distance: '6.14 km',
        duration: duration,
        paymentMethod: method,
      ),
    );

/// Registers a Home that knows vehicle type 2 as [name]. A past trip records
/// only the type id; its name, and with it the drawing, come from Home.
void _homeNamesTheType(String name) {
  final home = _HomeLogicHarness()
    ..state.vehicleAllType = VehicalTypeEntities(
      data: [
        SingleVehical(
          id: 2,
          name: name,
          price: 0.5,
          orderKey: null,
          miniMunFare: 1,
          image: '',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ],
      message: '',
      status: true,
    );
  Get.put<HomeLogic>(home);
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    GetMaterialApp(
      initialRoute: '/under-test',
      getPages: [
        GetPage(
          name: '/under-test',
          page: () => Scaffold(body: SingleChildScrollView(child: child)),
        ),
        GetPage(
          name: AppRoutes.HISTORYDETAIL,
          page: () => const Scaffold(body: SizedBox(key: _detailMarker)),
        ),
      ],
    ),
  );
  await tester.pump();
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() => Get.reset());

  group('HistoryRow (03 §Screen 13)', () {
    testWidgets('a completed trip: when, what it cost, who drove, how far',
        (tester) async {
      _homeNamesTheType('Classic Car');
      await _pump(tester, HistoryRow(data: _trip()));

      expect(find.textContaining('11 Sep'), findsOneWidget);
      expect(find.text('\$12,000.00'), findsOneWidget);
      expect(find.text('Classic Car · Sok Dara'), findsOneWidget);
      expect(find.text('No. 128, St. 271'), findsOneWidget);
      expect(find.text('Aeon Mall'), findsOneWidget);
      expect(find.text('6.1 km · 18 min'), findsOneWidget);
    });

    testWidgets('the vehicle is drawn, and the invoice and status are not '
        'on the card', (tester) async {
      _homeNamesTheType('Classic Car');
      await _pump(tester, HistoryRow(data: _trip()));

      expect(find.byType(SvgPicture), findsOneWidget);
      // The invoice is on the detail page; the tab already says Completed.
      expect(find.textContaining('INV-'), findsNothing);
      expect(find.byType(TaBadge), findsNothing);
      expect(find.text(AppLocale.completed), findsNothing);
    });

    testWidgets('a cancelled trip shows no fare and no distance',
        (tester) async {
      _homeNamesTheType('Classic Car');
      await _pump(
        tester,
        HistoryRow(data: _trip(status: BookingStatus.cancel)),
      );

      expect(find.textContaining('\$'), findsNothing);
      expect(find.textContaining('km'), findsNothing);
      expect(find.text(AppLocale.cancelled), findsNothing);
      // What was booked is still there.
      expect(find.text('Classic Car · Sok Dara'), findsOneWidget);
      expect(find.text('Aeon Mall'), findsOneWidget);
    });

    testWidgets('a completed trip with no fare says it is missing, not zero',
        (tester) async {
      await _pump(tester, HistoryRow(data: _trip(amount: null)));

      final card = tester.widget<TaHistoryCard>(find.byType(TaHistoryCard));
      expect(card.item.fare, '—');
    });

    testWidgets('a booking with no vehicle yet gets the neutral car',
        (tester) async {
      await _pump(
        tester,
        HistoryRow(
          data: _trip(status: BookingStatus.cancel, vehicleTypeId: null),
        ),
      );

      expect(find.byType(SvgPicture), findsNothing);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
      expect(find.text('Sok Dara'), findsOneWidget);
    });

    testWidgets('the vehicle is named as Home names it today', (tester) async {
      _homeNamesTheType('Sedan');

      await _pump(tester, HistoryRow(data: _trip()));

      expect(find.text('Sedan · Sok Dara'), findsOneWidget);
    });

    testWidgets('a type Home does not list is not named or drawn by its id',
        (tester) async {
      // Type id 2 was a car on one backend and is a tuk tuk on another, so
      // the id alone says nothing.
      await _pump(tester, HistoryRow(data: _trip()));

      expect(find.text('Sok Dara'), findsOneWidget);
      expect(find.byType(SvgPicture), findsNothing);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    testWidgets('tapping anywhere on the card opens the detail screen',
        (tester) async {
      // The whole card is the tap target (S1 Risk); `TaHistoryCard.onTap` was
      // declared but never wired, so this silently did nothing.
      await _pump(tester, HistoryRow(data: _trip()));

      await tester.tap(find.byType(TaHistoryCard));
      await tester.pumpAndSettle();

      expect(find.byKey(_detailMarker), findsOneWidget);
    });

    testWidgets('the detail screen receives the same Datum argument',
        (tester) async {
      final trip = _trip();
      await _pump(tester, HistoryRow(data: trip));

      await tester.tap(find.byType(TaHistoryCard));
      await tester.pumpAndSettle();

      expect(
        Get.arguments,
        same(trip),
        reason: 'roadmap S1: the detail screen opens with identical arguments',
      );
    });
  });

  group('TaHistoryCard destination row', () {
    testWidgets('renders the destination when the trip had one',
        (tester) async {
      await _pump(tester, HistoryRow(data: _trip()));
      expect(find.text('Aeon Mall'), findsOneWidget);
    });

    testWidgets('a cancelled trip with no destination drops the row',
        (tester) async {
      await _pump(
        tester,
        HistoryRow(
          data: _trip(status: BookingStatus.cancel, endAddress: null),
        ),
      );

      final card = tester.widget<TaHistoryCard>(find.byType(TaHistoryCard));
      expect(card.item.to, isNull);
      expect(find.text(AppLocale.unKnown), findsNothing);
      expect(find.text(AppLocale.noDropOffMeter), findsNothing);
      // The pickup still renders.
      expect(find.text('No. 128, St. 271'), findsOneWidget);
    });

    testWidgets('a completed trip with no destination was a metered trip',
        (tester) async {
      await _pump(tester, HistoryRow(data: _trip(endAddress: null)));

      expect(find.text(AppLocale.noDropOffMeter), findsOneWidget);
    });

    testWidgets('long addresses fit a narrow phone on one line each',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _pump(
        tester,
        HistoryRow(
          data: Datum(
            status: BookingStatus.completed,
            createdAt: '2026-09-11T09:41:00',
            startAddress:
                'Independence Monument, Chamkar Mon, Phnom Penh, Cambodia',
            endAddress:
                'Phnom Penh International Airport, Pou Senchey, Phnom Penh',
            driver: Driver(
              name: 'A Driver With A Rather Long Name',
              vehicle: Vehicle(typeVehicleId: 5),
            ),
            payment: Payment(amount: '1234500', distance: '10.25 km'),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('History empty and error states (S1 Done When)', () {
    testWidgets('the completed tab has its own empty copy', (tester) async {
      await _pump(tester, const HistoryEmptyState(isCompleted: true));
      expect(find.text(AppLocale.noCompletedTrips), findsOneWidget);
    });

    testWidgets('the cancelled tab has its own empty copy', (tester) async {
      await _pump(tester, const HistoryEmptyState(isCompleted: false));
      expect(find.text(AppLocale.noCancelledTrips), findsOneWidget);
    });

    testWidgets('the error state explains and offers retry', (tester) async {
      var retried = 0;
      await _pump(tester, HistoryErrorState(onRetry: () => retried++));

      expect(find.text(AppLocale.couldNotLoadHistory), findsOneWidget);
      await tester.tap(find.widgetWithText(TaButton, AppLocale.retry));
      await tester.pump();
      expect(retried, 1);
    });
  });

  group('HistoryDetailCard (03 §Screen 14)', () {
    Datum detailed({
      int? status = BookingStatus.completed,
      String? amount = '19900',
      String? method = 'Wallet',
      String? endAddress = 'Phnom Penh International Airport',
      bool withDriver = true,
    }) =>
        Datum(
          status: status,
          createdAt: '2026-10-05T14:59:00',
          startAddress: 'Independence Monument',
          endAddress: endAddress,
          driver: withDriver
              ? Driver(
                  name: 'Dara Sok',
                  vehicle: Vehicle(
                    typeVehicleId: 2,
                    manufacturer: 'Toyota',
                    model: 'Prius',
                    color: 'White',
                    plateNumber: '2AB-1234',
                  ),
                )
              : null,
          payment: Payment(
            invoiceId: 70000,
            amount: amount,
            distance: '10.25 km',
            duration: '27 mins 57 seconds',
            paymentMethod: method,
          ),
        );

    testWidgets('a completed trip leads with the fare, marked paid',
        (tester) async {
      await _pump(tester, HistoryDetailCard(data: detailed()));

      final fare = find.text('\$19,900.00');
      expect(fare, findsOneWidget);
      final badge = tester.widget<TaBadge>(find.byType(TaBadge));
      expect(badge.variant, TaBadgeVariant.success);
      expect(badge.label, '${AppLocale.paid} · Wallet');
      expect(
        tester.getRect(fare).bottom,
        lessThan(tester.getRect(find.byType(TaDriverCard)).top),
      );
    });

    testWidgets('the driver card names the car and carries its plate',
        (tester) async {
      await _pump(tester, HistoryDetailCard(data: detailed()));

      final card = tester.widget<TaDriverCard>(find.byType(TaDriverCard));
      expect(card.name, 'Dara Sok');
      expect(card.vehicleInfo, 'Toyota Prius · White');
      expect(card.plateNumber, '2AB-1234');
    });

    testWidgets('route and record: rounded distance and time, labelled invoice',
        (tester) async {
      await _pump(tester, HistoryDetailCard(data: detailed()));

      final trip = tester.widget<TaTripCard>(find.byType(TaTripCard));
      expect(trip.pickup, 'Independence Monument');
      expect(trip.dropOff, 'Phnom Penh International Airport');

      expect(find.text('5 Oct 2026, 2:59 PM'), findsOneWidget);
      expect(find.text('10.3 km'), findsOneWidget);
      expect(find.text('28 min'), findsOneWidget);
      expect(find.text(AppLocale.invoice), findsOneWidget);
      expect(find.text('INV-70000'), findsOneWidget);
    });

    testWidgets('no payment method: plain "Paid", nothing invented',
        (tester) async {
      await _pump(tester, HistoryDetailCard(data: detailed(method: null)));

      expect(tester.widget<TaBadge>(find.byType(TaBadge)).label,
          AppLocale.paid);
    });

    testWidgets('a completed trip with no fare says so and is not called paid',
        (tester) async {
      await _pump(tester, HistoryDetailCard(data: detailed(amount: null)));

      expect(find.text(AppLocale.fareUnavailable), findsOneWidget);
      expect(find.byType(TaBadge), findsNothing);
    });

    // The page this replaced showed "<method> · Paid" for any trip that had a
    // payment method, cancelled ones included.
    testWidgets('a cancelled trip is never called paid', (tester) async {
      await _pump(
        tester,
        HistoryDetailCard(
          data: detailed(status: BookingStatus.cancel, amount: '0'),
        ),
      );

      final badge = tester.widget<TaBadge>(find.byType(TaBadge));
      expect(badge.variant, TaBadgeVariant.error);
      expect(badge.label, AppLocale.cancelled);
      expect(find.textContaining(AppLocale.paid), findsNothing);
      expect(find.text(AppLocale.noFareCharged), findsOneWidget);
      expect(find.textContaining('\$'), findsNothing);
      // No distance or duration for a trip that did not happen.
      expect(find.text(AppLocale.distance), findsNothing);
      expect(find.text(AppLocale.duration), findsNothing);
    });

    testWidgets('a cancelled trip the record did charge for shows the charge',
        (tester) async {
      await _pump(
        tester,
        HistoryDetailCard(
          data: detailed(status: BookingStatus.cancel, amount: '2000'),
        ),
      );

      expect(find.text('\$2,000.00'), findsOneWidget);
      expect(find.text(AppLocale.noFareCharged), findsNothing,
          reason: 'the page does not say "no fare" over an amount');
      expect(find.text(AppLocale.cancelled), findsOneWidget);
    });

    testWidgets('a trip cancelled before a driver took it has no driver card '
        'and no drop-off row', (tester) async {
      await _pump(
        tester,
        HistoryDetailCard(
          data: detailed(
            status: BookingStatus.cancel,
            amount: null,
            endAddress: null,
            withDriver: false,
          ),
        ),
      );

      expect(find.byType(TaDriverCard), findsNothing);
      expect(tester.widget<TaTripCard>(find.byType(TaTripCard)).dropOff,
          isNull);
      expect(find.text(AppLocale.noDropOffMeter), findsNothing);
      expect(find.text(AppLocale.unKnown), findsNothing);
    });

    testWidgets('a completed trip with no drop-off was a metered trip',
        (tester) async {
      await _pump(tester, HistoryDetailCard(data: detailed(endAddress: null)));

      expect(find.text(AppLocale.noDropOffMeter), findsOneWidget);
    });

    testWidgets('the vehicle type is named as the caller names it when the '
        'record has no model', (tester) async {
      await _pump(
        tester,
        HistoryDetailCard(
          data: Datum(
            status: BookingStatus.completed,
            driver: Driver(
              name: 'Dara Sok',
              vehicle: Vehicle(typeVehicleId: 2, color: 'White'),
            ),
            payment: Payment(amount: '5000'),
          ),
          vehicleName: 'Sedan',
        ),
      );

      expect(tester.widget<TaDriverCard>(find.byType(TaDriverCard)).vehicleInfo,
          'Sedan · White');
    });

    testWidgets('an empty payload renders without throwing', (tester) async {
      await _pump(tester, const HistoryDetailCard(data: null));
      expect(tester.takeException(), isNull);
    });
  });
}

// ignore: must_call_super
class _HomeLogicHarness extends HomeLogic {
  @override
  // ignore: must_call_super
  Future<void> onInit() async {}

  @override
  // ignore: must_call_super
  Future<void> onReady() async {}
}
