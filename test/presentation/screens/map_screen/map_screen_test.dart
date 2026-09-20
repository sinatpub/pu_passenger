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
import 'package:com.tara.passenger/presentation/screens/map_screen/widgets/map_bottom_sheet.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/widgets/search_where_to_go.dart';
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
    testWidgets('no destination → search card, pickup, disabled button, hint',
        (tester) async {
      mapLogic.state.currentAddress = 'No. 128, St. 271';
      await tester.pumpWidget(sheetHost());
      await tester.pump();

      expect(find.byType(SearchWhereToGo), findsOneWidget);
      expect(find.text(AppLocale.currentLocation.tr), findsOneWidget);
      expect(find.text('No. 128, St. 271'), findsOneWidget);
      expect(find.text(AppLocale.bookingNow.tr), findsOneWidget);
      expect(find.text(AppLocale.selectDestinationToContinue.tr),
          findsOneWidget);
      expect(find.byType(TaNoteField), findsNothing);
      expect(find.byType(TaStatRow), findsNothing);
    });

    testWidgets('destination set → dest row, stat row, note, vehicle row',
        (tester) async {
      mapLogic.state.currentAddress = 'No. 128, St. 271';
      mapLogic.state.destinationAddress = 'Koh Pich';
      mapLogic.state.destinationLatLng = const LatLng(11.5564, 104.9282);
      mapLogic.state.distance = '2.5 km';
      mapLogic.state.totalFare = 4500;
      mapLogic.state.vehicleTypeSelection = _vehicle;
      await tester.pumpWidget(sheetHost());
      await tester.pump();

      expect(find.byType(SearchWhereToGo), findsNothing);
      expect(find.text(AppLocale.destination.tr), findsOneWidget);
      expect(find.text('Koh Pich'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget); // clear destination
      expect(find.text('2.5 km'), findsOneWidget);
      expect(find.textContaining('4,500'), findsWidgets); // fare formatted
      expect(find.byType(TaNoteField), findsOneWidget);
      expect(find.byType(TaVehicleRow), findsOneWidget);
      expect(find.text('Rickshaw'), findsOneWidget);
      expect(find.text(AppLocale.selectDestinationToContinue.tr), findsNothing);
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