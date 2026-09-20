import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/utils/history_cell_data.dart';
import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';
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
}) =>
    Datum(
      status: status,
      createdAt: '2026-09-11T09:41:00',
      startAddress: 'No. 128, St. 271',
      endAddress: endAddress,
      driver: Driver(name: 'Sok Dara'),
      payment: Payment(
        invoiceId: 2041,
        amount: amount,
        distance: '6.1 km',
        duration: '18',
        paymentMethod: method,
      ),
    );

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
    testWidgets('renders the compact card with formatted trip data',
        (tester) async {
      await _pump(tester, HistoryRow(data: _trip()));

      final card = tester.widget<TaHistoryCard>(find.byType(TaHistoryCard));
      expect(card.item.invoice, 'INV-2041');
      expect(card.item.driver, 'Sok Dara');
      expect(card.item.amount, '12,000 ${AppLocale.khmerCurrency}');
      expect(card.isCompleted, isTrue);
      expect(card.statusLabel, AppLocale.completed);
    });

    testWidgets('a cancelled trip gets the error badge and its own label',
        (tester) async {
      await _pump(
        tester,
        HistoryRow(data: _trip(status: BookingStatus.cancel)),
      );

      final card = tester.widget<TaHistoryCard>(find.byType(TaHistoryCard));
      expect(card.isCompleted, isFalse);
      expect(card.statusLabel, AppLocale.cancelled);
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

    testWidgets('drops the row entirely when there is no destination',
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
      // The pickup still renders.
      expect(find.text('No. 128, St. 271'), findsOneWidget);
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
    testWidgets('uses the same formatters as the list', (tester) async {
      final trip = _trip();
      await _pump(tester, HistoryDetailCard(data: trip));

      final item = historyCellData(trip);
      expect(find.text(item.invoice), findsOneWidget);
      expect(find.text(item.amount), findsOneWidget);
      expect(find.text('${item.driver} · ${item.date}'), findsOneWidget);
    });

    testWidgets('shows the completed badge and the paid row', (tester) async {
      await _pump(tester, HistoryDetailCard(data: _trip()));

      final badge = tester.widget<TaBadge>(find.byType(TaBadge));
      expect(badge.variant, TaBadgeVariant.success);
      expect(find.text(AppLocale.paid), findsOneWidget);
    });

    testWidgets('a cancelled trip gets the error badge and no destination row',
        (tester) async {
      await _pump(
        tester,
        HistoryDetailCard(
          data: _trip(status: BookingStatus.cancel, endAddress: null),
        ),
      );

      final badge = tester.widget<TaBadge>(find.byType(TaBadge));
      expect(badge.variant, TaBadgeVariant.error);

      final rows =
          tester.widgetList<TaAddressRow>(find.byType(TaAddressRow)).toList();
      expect(rows, hasLength(1));
      expect(rows.single.type, TaAddressType.pickup);
    });

    testWidgets('no payment method drops the paid row', (tester) async {
      await _pump(tester, HistoryDetailCard(data: _trip(method: null)));
      expect(find.text(AppLocale.paid), findsNothing);
    });

    testWidgets('an empty payload renders without throwing', (tester) async {
      await _pump(tester, const HistoryDetailCard(data: null));
      expect(tester.takeException(), isNull);
    });
  });
}
