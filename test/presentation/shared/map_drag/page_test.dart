// ignore_for_file: must_call_super — the MapLogic harness skips the real
// onReady (marker assets, driver polling); the page only reads its pickup.

import 'package:com.tara.passenger/data/models/location_model.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/logic.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/state.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/view.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/widgets/pin_confirm_sheet.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/widgets/search_view.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/services/location_imp.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformViewCreatedCallback;
import 'package:flutter_easyloading/flutter_easyloading.dart';
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

/// Place details without the Places API.
class _FakeLocationRepo extends LocationRepo {
  @override
  Future<List<double>> getPlaceDetails(String placeId) async =>
      [11.5700, 104.9000];
}

class _MapLogicHarness extends MapLogic {
  @override
  void onReady() {}
}

void main() {
  late MapDragLogic logic;
  late _FakeMapsPlatform maps;

  setUp(() {
    Get.testMode = true;
    maps = _FakeMapsPlatform();
    GoogleMapsFlutterPlatform.instance = maps;
    Get.put<MapLogic>(_MapLogicHarness());
    logic = Get.put<MapDragLogic>(
        MapDragLogic(locationRepo: _FakeLocationRepo()));
  });

  tearDown(Get.reset);

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(home: MapDragPage()));
    await tester.pump();
  }

  testWidgets('opens on the map: search bar on top, pin, Confirm below',
      (tester) async {
    await pumpPage(tester);

    expect(find.byType(MapDragSearchView), findsNothing);
    expect(find.text(AppLocale.searchForPlace.tr), findsOneWidget);
    expect(find.byType(TaCenterPin), findsOneWidget);
    expect(find.byType(PinConfirmSheet), findsOneWidget);
    expect(find.text(AppLocale.confirmDropOff.tr), findsOneWidget);
    // No keyboard until the passenger asks for the search.
    expect(tester.testTextInput.isVisible, isFalse);

    final screen = tester.getSize(find.byType(Scaffold));
    final map = tester.getRect(find.byKey(const Key('map')));
    final sheet = tester.getRect(find.byType(PinConfirmSheet));
    final back = tester.getRect(find.byIcon(Icons.arrow_back_ios_new));
    final locate = tester.getRect(find.byIcon(Icons.my_location));

    // The map runs from the top of the screen down to the sheet.
    expect(map.top, 0);
    expect(map.bottom, sheet.top);
    expect(sheet.bottom, screen.height);
    expect(back.center.dx, lessThan(60));
    expect(back.center.dy, lessThan(60));
    expect(locate.center.dx, greaterThan(screen.width - 60));
    expect(locate.bottom, lessThan(sheet.top));
  });

  testWidgets("Google's own controls and the traffic layer are off",
      (tester) async {
    await pumpPage(tester);

    final config = maps.configuration!;
    expect(config.zoomControlsEnabled, isFalse);
    expect(config.myLocationButtonEnabled, isFalse);
    expect(config.mapToolbarEnabled, isFalse);
    expect(config.trafficEnabled, isFalse);
  });

  testWidgets('the search bar opens the search view; back returns to the map',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text(AppLocale.searchForPlace.tr));
    await tester.pump();

    expect(find.byType(MapDragSearchView), findsOneWidget);
    expect(tester.testTextInput.isVisible, isTrue);
    // The map stays mounted underneath, so the pin is where it was left.
    expect(find.byKey(const Key('map')), findsOneWidget);

    // System back closes the search rather than leaving the page.
    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.byType(MapDragSearchView), findsNothing);
    expect(find.byType(MapDragPage), findsOneWidget);
    expect(logic.state.isShowMap, isTrue);
  });

  testWidgets('the search bar keeps what was typed', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text(AppLocale.searchForPlace.tr));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'ae');
    await tester.pump();
    await tester.tap(find.text(AppLocale.setLocationMap.tr));
    await tester.pump();

    expect(find.byType(MapDragSearchView), findsNothing);
    expect(find.text('ae'), findsOneWidget);
  });

  /// Pushes the page from a host route, the way the booking sheet does, and
  /// hands back whatever it pops with.
  ///
  /// Fixed pumps, not pumpAndSettle: the address skeleton shimmers for as
  /// long as there is no resolved address, so the page never settles.
  Future<Object? Function()> pushPage(WidgetTester tester) async {
    Object? result;
    await tester.pumpWidget(GetMaterialApp(
      builder: EasyLoading.init(),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async => result = await Get.to(() => MapDragPage()),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    return () => result;
  }

  testWidgets('Confirm pops the page with the pin', (tester) async {
    final result = await pushPage(tester);

    logic.onCameraMove(latlng: const LatLng(11.5564, 104.9282));
    await tester.pump();
    await tester.tap(find.text(AppLocale.confirmDropOff.tr));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(result(), const LatLng(11.5564, 104.9282));
  });

  // The search view holds system back to itself, which must not also hold a
  // chosen result on the page.
  testWidgets('a search result pops the page with that place', (tester) async {
    final result = await pushPage(tester);
    await tester.tap(find.text(AppLocale.searchForPlace.tr));
    await tester.pump();

    logic.state.searchQuery = 'aeon';
    logic.state.suggestLocationData = LocationModel(
      predictions: [
        Prediction(
          description: 'AEON Mall Sen Sok, Phnom Penh',
          placeId: 'place-aeon',
        ),
      ],
    );
    logic.update([MapDragUpdate.fetchLocation]);
    await tester.pump();

    await tester.tap(find.text('AEON Mall Sen Sok'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(result(), const LatLng(11.5700, 104.9000));
    expect(find.byType(MapDragPage), findsNothing);
  });
}
