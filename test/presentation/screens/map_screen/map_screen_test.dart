// ignore_for_file: must_call_super — this harness overrides the heavyweight
// onInit/onReady/network methods of the real MapLogic (marker assets, driver
// polling, socket) so the sheet and overlay can render states without side
// effects. The C3 widgets under test are pure GetBuilder views over MapState.

import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/data/models/driver_around_model.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:com.tara.passenger/presentation/screens/home/logic.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/widgets/booking_loading_overlay.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/widgets/map_appbar.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/widgets/map_bottom_sheet.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _vehicle = SingleVehical(
  id: 1,
  name: 'Rickshaw',
  price: 1500,
  orderKey: 1,
  miniMunFare: 4000,
  image: null,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

/// Light no-op doubles so the C3 widgets can render their GetBuilders without
/// storage, network or heavy collaborators.
class _FakeAppLogic extends AppLogic {
  @override
  void onInit() {
    // no super — the real onInit reads live storage + locale and schedules
    // frames that break the widget-test frame guard.
    languageKeyCode.value = AppConstant.englishCode;
  }
}

class _HomeLogicHarness extends HomeLogic {
  @override
  Future<void> onInit() async {}
  @override
  Future<void> onReady() async {}
  @override
  Future<void> getVehicleType() async {}
  @override
  Future<void> checkingBookingStatus() async {}
  @override
  Future<void> pushFcmToken() async {}
  @override
  Future<void> requestPermissionLocation() async {}
}

class _MapLogicHarness extends MapLogic {
  @override
  Future<void> onReady() async {}
  @override
  Future<void> getAvailableDriver() async {}
  @override
  Future<void> getVehicleTypeSelection() async {}

  /// The overlay's cancel escape hatch. The real one additionally calls the
  /// cancel API + socket; here it just drops the overlay (the "clear the
  /// overlay first" contract is what the overlay test asserts).
  @override
  Future<void> cancelBooking() async {
    setBookingLoading(false);
  }
}

void main() {
  late _MapLogicHarness mapLogic;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    mapLogic = _MapLogicHarness();
    Get.put<AppLogic>(_FakeAppLogic(), permanent: true);
    Get.put<HomeLogic>(_HomeLogicHarness(), permanent: true);
    Get.put<MapLogic>(mapLogic, permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  Widget sheetHost() => const GetMaterialApp(
          home: Scaffold(
            body: SizedBox(height: 400, child: MapBottomSheet()),
          ),
        );

  group('MapBottomSheet (C3)', () {
    testWidgets(
        'no destination → pickup, add drop-off, live Book button, meter hint',
        (tester) async {
      mapLogic.state.currentAddress = 'No. 128, St. 271';
      mapLogic.state.vehicleTypeSelection = _vehicle;
      await tester.pumpWidget(sheetHost());
      await tester.pump();

      expect(find.text(AppLocale.addDropOff.tr), findsOneWidget);
      expect(find.text(AppLocale.currentLocation.tr), findsOneWidget);
      expect(find.text('No. 128, St. 271'), findsOneWidget);
      expect(find.text('Book Rickshaw'), findsOneWidget);
      expect(find.text(AppLocale.fareByMeterHint.tr), findsOneWidget);
      expect(tester.widget<TaButton>(find.byType(TaButton)).isEnabled, isTrue);
      expect(find.byType(TaNoteField), findsNothing);
      expect(find.byType(TaStatRow), findsNothing);
    });

    testWidgets('failed pickup lookup → retry row, not the word "Error"',
        (tester) async {
      mapLogic.state.addressFailed = true;
      mapLogic.state.vehicleTypeSelection = _vehicle;
      await tester.pumpWidget(sheetHost());
      await tester.pump();

      expect(find.text(AppLocale.cantFindAddress.tr), findsOneWidget);
      expect(find.text(AppLocale.error.tr), findsNothing);
    });

    testWidgets('no vehicle type → Book is disabled', (tester) async {
      await tester.pumpWidget(sheetHost());
      await tester.pump();

      expect(tester.widget<TaButton>(find.byType(TaButton)).isEnabled, isFalse);
    });

    testWidgets('destination set → dest row, note, estimate on chip and button',
        (tester) async {
      mapLogic.state.currentAddress = 'No. 128, St. 271';
      mapLogic.state.destinationAddress = 'Koh Pich';
      mapLogic.state.destinationLatLng = const LatLng(11.5564, 104.9282);
      mapLogic.state.distance = '2.5 km';
      mapLogic.state.distanceKm = 2.5;
      mapLogic.state.totalFare = 6250;
      mapLogic.state.vehicleTypeSelection = _vehicle;
      Get.find<HomeLogic>().state.vehicleAllType = VehicalTypeEntities(
        data: [_vehicle],
        message: '',
        status: true,
      );
      await tester.pumpWidget(sheetHost());
      await tester.pump();

      expect(find.text(AppLocale.addDropOff.tr), findsNothing);
      expect(find.text(AppLocale.destination.tr), findsOneWidget);
      expect(find.text('Koh Pich'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget); // clear destination
      expect(find.byType(TaNoteField), findsOneWidget);
      // (2.5 - 1) km * 1,500 + 4,000 minimum = 6,250 on the chip and button.
      expect(find.textContaining('6,250'), findsNWidgets(2));
      expect(find.textContaining('2.5 km'), findsOneWidget); // caption
      expect(find.text(AppLocale.fareByMeterHint.tr), findsNothing);
    });

    testWidgets('tapping another chip selects that vehicle', (tester) async {
      final suv = SingleVehical(
        id: 4,
        name: 'SUV',
        price: 2500,
        orderKey: 4,
        miniMunFare: 10000,
        image: null,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      mapLogic.state.vehicleTypeSelection = _vehicle;
      Get.find<HomeLogic>().state.vehicleAllType = VehicalTypeEntities(
        data: [_vehicle, suv],
        message: '',
        status: true,
      );
      await tester.pumpWidget(sheetHost());
      await tester.pump();

      await tester.tap(find.text('SUV'));
      await tester.pump();

      expect(mapLogic.state.vehicleTypeSelection?.id, 4);
      expect(find.text('Book SUV'), findsOneWidget);
    });

    testWidgets('bottom padding clears the home indicator', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(375, 812),
            padding: EdgeInsets.only(bottom: 34),
          ),
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: MapBottomSheet(),
            ),
          ),
        ),
      ));
      await tester.pump();

      final sheet = tester.getRect(find.byType(MapBottomSheet));
      final button = tester.getRect(find.byType(TaButton));
      // 24.d of design padding sits on top of the 34 px system inset.
      expect(sheet.bottom - button.bottom, greaterThan(34));
    });

    testWidgets('fits the body left above the keyboard without overflow',
        (tester) async {
      mapLogic.state.destinationAddress = 'Koh Pich';
      mapLogic.state.destinationLatLng = const LatLng(11.5564, 104.9282);
      mapLogic.state.vehicleTypeSelection = _vehicle;

      // What MapScreen's LayoutBuilder measures on a small phone with the
      // keyboard up: a 600 px screen minus a 300 px keyboard.
      await tester.pumpWidget(const GetMaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 300,
              child: Column(
                children: [
                  Expanded(child: SizedBox()),
                  MapBottomSheet(maxHeight: 300),
                ],
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(tester.getRect(find.byType(MapBottomSheet)).height,
          lessThanOrEqualTo(300));
    });

    testWidgets('tariff tap → "Vehicle · Tariff" sheet with spec rows',
        (tester) async {
      mapLogic.state.vehicleTypeSelection = _vehicle;
      await tester.pumpWidget(sheetHost());
      await tester.pump();

      await tester.tap(find.text('Tariff'));
      await tester.pumpAndSettle();

      expect(find.textContaining('· Tariff'), findsOneWidget);
      expect(find.text('Min fee'), findsOneWidget);
      expect(find.text('Price per km'), findsOneWidget);
      expect(find.text('Seats'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
    });
  });

  group('map layer chrome', () {
    // Same arrangement as `MapScreen._mapLayer`: the app bar aligned to the
    // top, the my-location button pinned bottom-right.
    testWidgets('back button sits top-left, my-location bottom-right',
        (tester) async {
      await tester.pumpWidget(GetMaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              const Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: MapAppbar(),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: TaIconButton(
                  icon: const Icon(Icons.my_location),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ));

      final screen = tester.getSize(find.byType(Scaffold));
      final back = tester.getRect(find.byIcon(Icons.arrow_back_ios_new));
      final locate = tester.getRect(find.byIcon(Icons.my_location));

      expect(back.center.dx, lessThan(60));
      expect(back.center.dy, lessThan(60));
      expect(locate.center.dx, greaterThan(screen.width - 60));
      expect(locate.center.dy, greaterThan(screen.height - 60));
    });
  });

  group('BookingLoadingOverlay (C3)', () {
    Widget overlayHost() => const GetMaterialApp(
          home: Scaffold(
            body: Stack(children: [BookingLoadingOverlay()]),
          ),
        );

    testWidgets('hidden when not loading', (tester) async {
      await tester.pumpWidget(overlayHost());
      await tester.pump();
      expect(find.byType(TaLoadingOverlay), findsNothing);
    });

    testWidgets('"Contacting nearby drivers…" title + vehicle · nearest km',
        (tester) async {
      mapLogic.state.vehicleTypeSelection = _vehicle;
      mapLogic.state.currentLatLng = const LatLng(11.5564, 104.9282);
      mapLogic.state.driverAroundData = DriverAroundModel(
        data: [
          Driver(
            id: 1,
            firstName: 'Driver',
            lastName: 'One',
            lastLocation: LastLocation(
              latitude: '11.5600',
              longitude: '104.9300',
            ),
          ),
        ],
        status: true,
      );
      mapLogic.setBookingLoading(true);

      await tester.pumpWidget(overlayHost());
      await tester.pump();

      expect(find.byType(TaLoadingOverlay), findsOneWidget);
      expect(find.text(AppLocale.contactingDrivers.tr), findsOneWidget);
      expect(find.textContaining('Rickshaw'), findsOneWidget);
      expect(find.textContaining(AppLocale.kmAway.tr), findsOneWidget);
    });

    testWidgets('cancel button drops the overlay', (tester) async {
      mapLogic.state.vehicleTypeSelection = _vehicle;
      mapLogic.setBookingLoading(true);

      await tester.pumpWidget(overlayHost());
      await tester.pump();
      expect(find.byType(TaLoadingOverlay), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(find.byType(TaLoadingOverlay), findsNothing);
    });
  });
}