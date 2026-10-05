import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/history_detail/logic.dart';
import 'package:com.tara.passenger/presentation/screens/history_detail/view.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformViewCreatedCallback;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// Stands in for the native map: a plain box that never reports itself
/// created, so the route and pins are not drawn.
class _FakeMapsPlatform extends GoogleMapsFlutterPlatform {
  MapConfiguration? configuration;

  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapConfiguration mapConfiguration = const MapConfiguration(),
    MapObjects mapObjects = const MapObjects(),
  }) {
    configuration = mapConfiguration;
    return const SizedBox.expand(key: Key('map'));
  }
}

Datum _trip({
  int status = BookingStatus.completed,
  String? endLatitude = '11.5466',
  String? endLongitude = '104.8441',
}) =>
    Datum(
      status: status,
      createdAt: '2026-10-05T14:59:00',
      startLatitude: '11.5564',
      startLongitude: '104.9282',
      endLatitude: endLatitude,
      endLongitude: endLongitude,
      startAddress: 'Independence Monument',
      endAddress: endLatitude == null ? null : 'Airport',
      driver: Driver(
        name: 'Dara Sok',
        vehicle: Vehicle(typeVehicleId: 3, plateNumber: '2AB-1234'),
      ),
      payment: Payment(invoiceId: 70000, amount: '19900'),
    );

const _mapMarker = Key('map-stub');
Object? _mapArguments;

void main() {
  late _FakeMapsPlatform maps;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    maps = _FakeMapsPlatform();
    GoogleMapsFlutterPlatform.instance = maps;
    _mapArguments = null;
  });

  tearDown(Get.reset);

  Future<HistoryDetailLogic> pumpPage(WidgetTester tester, Datum trip) async {
    tester.view.physicalSize = const Size(400, 889);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final logic = Get.put(HistoryDetailLogic(data: trip));
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.HISTORYDETAIL,
        getPages: [
          GetPage(
            name: AppRoutes.HISTORYDETAIL,
            page: () => const HistoryDetailPage(),
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
    return logic;
  }

  group('HistoryDetailLogic', () {
    test('reads the two ends of the trip from the record', () {
      final logic = HistoryDetailLogic(data: _trip())..onInit();

      expect(logic.pickup, const LatLng(11.5564, 104.9282));
      expect(logic.dropOff, const LatLng(11.5466, 104.8441));
    });

    test('a trip with no drop-off has none — not (0, 0)', () {
      final logic = HistoryDetailLogic(
        data: _trip(endLatitude: null, endLongitude: null),
      )..onInit();

      expect(logic.dropOff, isNull);
    });
  });

  group('Trip details page (03 §Screen 14)', () {
    testWidgets('titled "Trip details", not the invoice number',
        (tester) async {
      await pumpPage(tester, _trip());

      expect(find.text(AppLocale.tripDetails), findsOneWidget);
      // The invoice is a labelled row further down, once.
      expect(find.text('INV-70000'), findsOneWidget);
    });

    testWidgets('map, then fare, then the rest; Book again at the bottom',
        (tester) async {
      await pumpPage(tester, _trip());

      final map = tester.getRect(find.byKey(const Key('map')));
      final fare =
          tester.getRect(find.text('19,900 ${AppLocale.khmerCurrency}'));
      final driver = tester.getRect(find.byType(TaDriverCard));
      final button = tester.getRect(
          find.widgetWithText(TaButton, AppLocale.bookAgain));

      expect(map.height, 150 - 2, reason: 'the preview, inside its border');
      expect(map.bottom, lessThan(fare.top));
      expect(fare.bottom, lessThan(driver.top));
      expect(button.bottom, lessThanOrEqualTo(889));
      expect(button.top, greaterThan(driver.bottom));
    });

    // The map this replaced took every drag that started on it, so the page
    // could not be scrolled from there.
    testWidgets('the map is a still picture: it takes no touches',
        (tester) async {
      await pumpPage(tester, _trip());

      expect(
        find.ancestor(
          of: find.byKey(const Key('map')),
          matching: find.byWidgetPredicate(
              (widget) => widget is IgnorePointer && widget.ignoring),
        ),
        findsWidgets,
      );
      final config = maps.configuration!;
      expect(config.scrollGesturesEnabled, isFalse);
      expect(config.zoomGesturesEnabled, isFalse);
      expect(config.zoomControlsEnabled, isFalse);
    });

    testWidgets('Book again opens the booking map with the same vehicle and '
        'drop-off', (tester) async {
      await pumpPage(tester, _trip());

      await tester.tap(find.widgetWithText(TaButton, AppLocale.bookAgain));
      await tester.pumpAndSettle();

      expect(find.byKey(_mapMarker), findsOneWidget);
      expect(_mapArguments, {
        'vehicleId': 3,
        'destination': const LatLng(11.5466, 104.8441),
      });
    });

    testWidgets('a trip with no drop-off rebooks without one', (tester) async {
      await pumpPage(
          tester, _trip(endLatitude: null, endLongitude: null));

      await tester.tap(find.widgetWithText(TaButton, AppLocale.bookAgain));
      await tester.pumpAndSettle();

      expect(_mapArguments, {'vehicleId': 3});
    });

    testWidgets('a cancelled trip can be booked again too', (tester) async {
      await pumpPage(tester, _trip(status: BookingStatus.cancel));

      expect(find.text(AppLocale.cancelled), findsOneWidget);
      expect(find.widgetWithText(TaButton, AppLocale.bookAgain),
          findsOneWidget);
    });

    testWidgets('fits a small phone by scrolling, with Book again in reach',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      Get.put(HistoryDetailLogic(data: _trip()));
      await tester.pumpWidget(
        const GetMaterialApp(home: HistoryDetailPage()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final button = tester.getRect(
          find.widgetWithText(TaButton, AppLocale.bookAgain));
      expect(button.bottom, lessThanOrEqualTo(568));
    });
  });
}
