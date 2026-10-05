import 'package:com.tara.passenger/presentation/shared/map_drag/args.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/logic.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/state.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/widgets/pin_confirm_sheet.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/widgets/search_view.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/services/location_imp.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// The two halves of the pick-a-point page that can render without the
/// GoogleMap platform view: the confirm sheet under the map, and the search
/// view that opens over it.
void main() {
  late MapDragLogic logic;

  setUp(() {
    Get.testMode = true;
    logic = Get.put<MapDragLogic>(MapDragLogic(locationRepo: LocationRepo()));
  });

  tearDown(Get.reset);

  Widget host(Widget child) => GetMaterialApp(
        home: Scaffold(
          body: Align(alignment: Alignment.bottomCenter, child: child),
        ),
      );

  TaButton confirm(WidgetTester tester) =>
      tester.widget<TaButton>(find.byType(TaButton));

  void refresh() =>
      logic.update([MapDragUpdate.pickupLabel, MapDragUpdate.confirm]);

  group('PinConfirmSheet', () {
    const sheet = PinConfirmSheet(purpose: MapDragPurpose.destination);

    testWidgets('no pin yet → skeleton address, Confirm disabled',
        (tester) async {
      await tester.pumpWidget(host(sheet));
      await tester.pump();

      expect(find.text(AppLocale.setDestination.tr), findsOneWidget);
      expect(find.byType(TaSkeleton), findsNWidgets(2));
      expect(confirm(tester).label, AppLocale.confirmDropOff.tr);
      expect(confirm(tester).isEnabled, isFalse);
    });

    testWidgets('destination: Confirm is live as soon as there is a pin',
        (tester) async {
      logic.state.latlng = const LatLng(11.5564, 104.9282);
      logic.state.isResolving = true;
      await tester.pumpWidget(host(sheet));
      await tester.pump();

      expect(find.byType(TaSkeleton), findsNWidgets(2));
      expect(confirm(tester).isEnabled, isTrue);
    });

    testWidgets('resolved → the name over the rest of the address',
        (tester) async {
      logic.state.latlng = const LatLng(11.5564, 104.9282);
      logic.state.resolvedAddress = 'Street 271, Daun Penh, Phnom Penh';
      await tester.pumpWidget(host(sheet));
      await tester.pump();

      expect(find.text('Street 271'), findsOneWidget);
      expect(find.text('Daun Penh, Phnom Penh'), findsOneWidget);
      expect(find.byType(TaSkeleton), findsNothing);
    });

    testWidgets('no address matched → "Pinned location", still confirmable',
        (tester) async {
      logic.state.latlng = const LatLng(11.5564, 104.9282);
      await tester.pumpWidget(host(sheet));
      await tester.pump();

      expect(find.text(AppLocale.pinnedLocation.tr), findsOneWidget);
      expect(confirm(tester).isEnabled, isTrue);
    });

    // The map sits in the space above the sheet; a sheet that grew when the
    // address arrived would resize the map on every drag.
    testWidgets('keeps its height as the address resolves', (tester) async {
      logic.state.latlng = const LatLng(11.5564, 104.9282);
      logic.state.isResolving = true;
      await tester.pumpWidget(host(sheet));
      await tester.pump();
      final resolving = tester.getSize(find.byType(PinConfirmSheet)).height;

      logic.state.isResolving = false;
      logic.state.resolvedAddress = 'Street 271, Daun Penh, Phnom Penh';
      refresh();
      await tester.pump();

      expect(tester.getSize(find.byType(PinConfirmSheet)).height, resolving);
    });

    testWidgets('pickup: note field, and Confirm waits for the address',
        (tester) async {
      logic.state.latlng = const LatLng(11.5564, 104.9282);
      logic.state.isResolving = true;
      await tester.pumpWidget(
          host(const PinConfirmSheet(purpose: MapDragPurpose.pickup)));
      await tester.pump();

      expect(find.text(AppLocale.setPickup.tr), findsOneWidget);
      expect(find.byType(TaNoteField), findsOneWidget);
      expect(confirm(tester).label, AppLocale.confirmPickup.tr);
      expect(confirm(tester).isEnabled, isFalse);

      logic.state.isResolving = false;
      logic.state.resolvedAddress = 'Street 271, Daun Penh, Phnom Penh';
      refresh();
      await tester.pump();

      expect(confirm(tester).isEnabled, isTrue);
    });
  });

  group('MapDragSearchView', () {
    Widget searchHost() => const GetMaterialApp(
          home: Scaffold(body: MapDragSearchView()),
        );

    testWidgets('opens with the field focused and "Set on map" offered',
        (tester) async {
      logic.openSearch();
      await tester.pumpWidget(searchHost());
      await tester.pump();

      expect(tester.testTextInput.isVisible, isTrue);
      expect(find.text(AppLocale.setLocationMap.tr), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('the clear button appears with text and empties the field',
        (tester) async {
      logic.openSearch();
      await tester.pumpWidget(searchHost());
      await tester.pump();

      // Two letters: under the threshold, so nothing reaches the network.
      await tester.enterText(find.byType(TextField), 'ph');
      await tester.pump();
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(logic.searchController.text, isEmpty);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('back returns to the map', (tester) async {
      logic.openSearch();
      await tester.pumpWidget(searchHost());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();

      expect(logic.state.isShowMap, isTrue);
    });

    testWidgets('"Set location on the map" returns to the map',
        (tester) async {
      logic.openSearch();
      await tester.pumpWidget(searchHost());
      await tester.pump();

      await tester.tap(find.text(AppLocale.setLocationMap.tr));
      await tester.pump();

      expect(logic.state.isShowMap, isTrue);
    });
  });
}
