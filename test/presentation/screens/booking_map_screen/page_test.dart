// ignore_for_file: must_call_super — the harness skips the real onInit and
// onReady (booking fetch, marker assets, poll timer); the page only renders
// the state it is given.

import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/data/datasources/check_request_book_source.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/booking_map_screen.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/widgets/booking_sheet.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformViewCreatedCallback;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// Stands in for the native map: a plain box that never reports itself
/// created, so `onMapCreated` — GPS, loader — does not run.
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

class _FakeCheckBookingApi extends CheckBookingApi {
  @override
  Future<RequestBookingModel> checkBookingApi() async => RequestBookingModel();
}

class _LogicHarness extends BookingMapLogic {
  _LogicHarness() : super(checkBookingApi: _FakeCheckBookingApi());

  int recentred = 0;

  @override
  Future<void> onInit() async {}

  @override
  Future<void> onReady() async {}

  @override
  void navigateMapPerspective() => recentred++;
}

void main() {
  late _LogicHarness logic;
  late _FakeMapsPlatform maps;

  setUp(() {
    Get.testMode = true;
    maps = _FakeMapsPlatform();
    GoogleMapsFlutterPlatform.instance = maps;
    logic = Get.put<BookingMapLogic>(_LogicHarness()) as _LogicHarness;
    logic.state.bookingRequestData = RequestBookingModel(
      data: Data(
        status: BookingStatus.accepted,
        startAddress: 'Street 271, Daun Penh',
        driver: Driver(name: 'Dara Sok', phone: '012345678'),
      ),
    );
  });

  tearDown(Get.reset);

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(400, 800),
          padding: EdgeInsets.only(top: 30),
        ),
        child: BookingMapScreen(),
      ),
    ));
    await tester.pump();
  }

  testWidgets('the map sits above the sheet, with nothing of it underneath',
      (tester) async {
    await pumpPage(tester);

    final map = tester.getRect(find.byKey(const Key('map')));
    final sheet = tester.getRect(find.byType(BookingSheet));
    final screen = tester.getSize(find.byType(Scaffold));

    expect(map.top, 0);
    expect(map.bottom, sheet.top);
    expect(sheet.bottom, screen.height);
  });

  testWidgets('the status is the sheet headline, not a pill over the map',
      (tester) async {
    await pumpPage(tester);

    expect(find.byType(TaStatusPill), findsNothing);
    expect(find.text(AppLocale.driverOnTheWay), findsOneWidget);
  });

  testWidgets('what the camera frames stays clear of the status bar',
      (tester) async {
    await pumpPage(tester);

    expect(maps.configuration!.padding, const EdgeInsets.only(top: 30));
  });

  testWidgets('the recenter button reframes the ride', (tester) async {
    await pumpPage(tester);

    final button = tester.getRect(find.byIcon(Icons.my_location));
    final sheet = tester.getRect(find.byType(BookingSheet));
    expect(button.bottom, lessThan(sheet.top));
    expect(button.center.dx, greaterThan(400 - 60));

    await tester.tap(find.byIcon(Icons.my_location));
    expect(logic.recentred, 1);
  });

  testWidgets('system back does not leave an active ride', (tester) async {
    await pumpPage(tester);

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.byType(BookingMapScreen), findsOneWidget);
  });
}
