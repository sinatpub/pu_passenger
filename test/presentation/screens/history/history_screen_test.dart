// ignore_for_file: must_call_super — the harness answers the paging
// controller from a fixed list instead of the history API.

import 'package:com.tara.passenger/core/api_service/client/dio_http_client.dart';
import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/history/logic.dart';
import 'package:com.tara.passenger/presentation/screens/history/view.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

Datum _trip(int id, {int status = BookingStatus.completed}) => Datum(
      id: id,
      status: status,
      createdAt: '2026-10-05T14:59:00',
      startAddress: 'Central Market $id',
      endAddress: 'Airport',
      driver: Driver(name: 'Sok Dara', vehicle: Vehicle(typeVehicleId: 2)),
      payment: Payment(
        amount: '9600',
        distance: '3.40 km',
        duration: '9 mins 16 seconds',
      ),
    );

class _HistoryLogicHarness extends HistoryLogic {
  final List<int> requestedFilters = [];

  @override
  Future<void> getAllHistoryBookingPaging({
    required int pageNo,
    bool isRefresh = false,
    String? search,
    int? pptTypeId,
  }) async {
    requestedFilters.add(state.filterStatus.value);
    final completed = state.filterStatus.value == 4;
    state.propertyPagingController.value.appendLastPage([
      for (var i = 1; i <= 6; i++)
        _trip(i,
            status: completed ? BookingStatus.completed : BookingStatus.cancel),
    ]);
  }
}

void main() {
  late _HistoryLogicHarness logic;

  // The controller builds its datasource in a field initializer, and that
  // needs the HTTP client to exist — once. Nothing is ever sent: the harness
  // answers every page request itself.
  setUpAll(BaseHttpClient.init);

  setUp(() {
    Get.testMode = true;
    Get.reset();
    // `HistoryScreen` does `Get.put(HistoryLogic())`, which keeps a controller
    // that is already registered.
    logic = Get.put<HistoryLogic>(_HistoryLogicHarness()) as _HistoryLogicHarness;
  });

  tearDown(Get.reset);

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 889);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(GetMaterialApp(home: HistoryScreen()));
    await tester.pumpAndSettle();
  }

  testWidgets('the title is the tab\'s own name', (tester) async {
    await pumpScreen(tester);

    expect(find.text(AppLocale.myBooking), findsOneWidget);
    expect(find.text(AppLocale.ridingHistory), findsNothing);
  });

  testWidgets('Completed and Cancelled share the width of the switch',
      (tester) async {
    await pumpScreen(tester);

    final segment = tester.getRect(find.byType(TaSegment));
    final completed = tester.getCenter(find.text(AppLocale.completed)).dx;
    final cancelled = tester.getCenter(find.text(AppLocale.cancelled)).dx;

    expect(segment.width, 400 - 40);
    expect(completed, lessThan(segment.center.dx));
    expect(cancelled, greaterThan(segment.center.dx));
    expect(segment.center.dx - completed, closeTo(cancelled - segment.center.dx, 4));
  });

  // The old cards were about 226 high with their gap: three to a screen.
  testWidgets('at least four trips fit on a phone screen', (tester) async {
    await pumpScreen(tester);

    final visible = tester
        .widgetList<TaHistoryCard>(find.byType(TaHistoryCard))
        .length;
    final first = tester.getRect(find.byType(TaHistoryCard).first);

    // The card and the gap under it.
    expect(first.height, lessThan(160));
    expect(visible, greaterThanOrEqualTo(4));
  });

  testWidgets('switching to Cancelled reloads the list without fares',
      (tester) async {
    await pumpScreen(tester);
    expect(find.textContaining(AppLocale.khmerCurrency), findsWidgets);

    await tester.tap(find.text(AppLocale.cancelled));
    await tester.pumpAndSettle();

    expect(logic.requestedFilters.last, 5);
    expect(find.textContaining(AppLocale.khmerCurrency), findsNothing);
    expect(find.byType(TaHistoryCard), findsWidgets);
  });
}
