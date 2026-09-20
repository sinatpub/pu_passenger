import 'package:com.tara.passenger/data/models/location_model.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/logic.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/widgets/search_panel.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Harness that keeps the panel's state-table render testable without the
/// GoogleMap platform view or the Places network calls. `selectPlace` /
/// `fetchPlaceSuggestions` are the only logic touchpoints the panel drives —
/// pin-commit semantics live elsewhere and stay covered by `logic_test.dart`.
class _HarnessLogic extends MapDragLogic {
  Prediction? selected;
  int retryCalls = 0;

  @override
  Future<void> selectPlace(Prediction? prediction) async {
    selected = prediction;
  }

  @override
  Future<void> fetchPlaceSuggestions(String query) async {
    retryCalls++;
  }
}

Widget _host(SearchPanel panel) => GetMaterialApp(
      home: Scaffold(
        body: SizedBox(height: 500, child: panel),
      ),
    );

void main() {
  late _HarnessLogic logic;

  setUp(() {
    Get.testMode = true;
    logic = _HarnessLogic();
  });

  tearDown(() {
    Get.reset();
  });

  group('SearchPanel results (C4)', () {
    testWidgets('renders one TaSearchResult per prediction, name + keyword',
        (tester) async {
      logic.state.searchQuery = 'phnom';
      logic.state.suggestLocationData = LocationModel(
        predictions: [
          Prediction(
            description: 'AEON Mall Sen Sok, Phnom Penh, Cambodia',
            placeId: 'place-aeon',
          ),
          Prediction(
            description: 'Wat Phnom, Daun Penh, Phnom Penh',
            placeId: 'place-wat',
          ),
        ],
      );

      await tester.pumpWidget(_host(SearchPanel(logic: logic)));
      await tester.pump();

      expect(find.byType(TaSearchResult), findsNWidgets(2));
      expect(find.text('AEON Mall Sen Sok'), findsOneWidget);
      expect(find.text('Phnom Penh, Cambodia'), findsOneWidget);
      // Placeline responses carry no distance — the badge is omitted, not faked.
      expect(find.textContaining('km'), findsNothing);
    });

    testWidgets('tap result → selectPlace with the prediction + field text',
        (tester) async {
      logic.state.searchQuery = 'phnom';
      logic.state.suggestLocationData = LocationModel(
        predictions: [
          Prediction(
            description: 'AEON Mall Sen Sok, Phnom Penh, Cambodia',
            placeId: 'place-aeon',
          ),
        ],
      );

      await tester.pumpWidget(_host(SearchPanel(logic: logic)));
      await tester.pump();

      await tester.tap(find.text('AEON Mall Sen Sok'));
      await tester.pump();

      expect(logic.selected?.placeId, 'place-aeon');
      expect(logic.searchController.text, 'AEON Mall Sen Sok, Phnom Penh, Cambodia');
    });

    testWidgets('"Set on map" row switches the page to the full map',
        (tester) async {
      logic.state.searchQuery = 'phnom';
      logic.state.suggestLocationData = LocationModel(
        predictions: [
          Prediction(description: 'Wat Phnom', placeId: 'place-wat'),
        ],
      );

      await tester.pumpWidget(_host(SearchPanel(logic: logic)));
      await tester.pump();

      expect(logic.state.isShowMap, isFalse);
      await tester.tap(find.text(AppLocale.setLocationMap.tr));
      await tester.pump();
      expect(logic.state.isShowMap, isTrue);
    });
  });

  group('SearchPanel states (C4)', () {
    testWidgets('idle → hint text', (tester) async {
      await tester.pumpWidget(_host(SearchPanel(logic: logic)));
      await tester.pump();
      expect(find.text(AppLocale.searchForPlace.tr), findsOneWidget);
    });

    testWidgets('searching with prior results → dimmed list keeps them visible',
        (tester) async {
      logic.state.searchQuery = 'phnom';
      logic.state.isSearching = true;
      logic.state.suggestLocationData = LocationModel(
        predictions: [
          Prediction(description: 'Wat Phnom', placeId: 'place-wat'),
        ],
      );

      await tester.pumpWidget(_host(SearchPanel(logic: logic)));
      await tester.pump();

      expect(find.byType(TaSearchResult), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byType(TaSearchResult),
          matching: find.byType(Opacity),
        ),
        findsOneWidget,
      );
    });

    testWidgets('searching with no prior results → skeleton, no rows',
        (tester) async {
      logic.state.searchQuery = 'phnom';
      logic.state.isSearching = true;
      logic.state.suggestLocationData = LocationModel(predictions: []);

      await tester.pumpWidget(_host(SearchPanel(logic: logic)));
      await tester.pump();

      expect(find.byType(TaSearchResult), findsNothing);
      expect(find.byType(ListView), findsOneWidget); // skeleton rows
    });

    testWidgets('empty → "No places match" + Check the spelling + Set on map',
        (tester) async {
      logic.state.searchQuery = 'xyz';
      logic.state.suggestLocationData = LocationModel(predictions: []);

      await tester.pumpWidget(_host(SearchPanel(logic: logic)));
      await tester.pump();

      expect(find.textContaining(AppLocale.noPlacesMatch.tr), findsOneWidget);
      expect(find.text(AppLocale.checkSpelling.tr), findsOneWidget);
      expect(find.text(AppLocale.setLocationMap.tr), findsOneWidget);
    });

    testWidgets('error → retry re-runs the same query', (tester) async {
      logic.state.searchQuery = 'will fail';
      logic.state.hasSearchError = true;
      logic.searchController.text = 'will fail';

      await tester.pumpWidget(_host(SearchPanel(logic: logic)));
      await tester.pump();

      expect(find.text(AppLocale.couldntSearch.tr), findsOneWidget);
      await tester.tap(find.text(AppLocale.retry.tr));
      await tester.pump();
      expect(logic.retryCalls, 1);
    });
  });
}