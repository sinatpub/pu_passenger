import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/search_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:com.tara.passenger/data/models/location_model.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/logic.dart';
import 'package:com.tara.passenger/service/location_imp.dart';

/// P-04 (docs/12) — `fetchPlaceSuggestions`'s loading/error handling used to
/// wrap only the synchronous work of scheduling the debounce timer, not the
/// actual search call inside it. Hand-written fake, no mocktail
/// (`.agent/skills/testing.md`).
///
/// `EasyLoading.show()` asserts on a live `OverlayEntry`
/// (`EasyLoading.init()` wired into a widget tree) — true of the original
/// code too, not something this fix introduced — so these run as
/// `testWidgets` against a minimal host instead of plain `test()`.
class _FakeLocationRepo extends LocationRepo {
  LocationModel Function(String query)? onSearch;
  final List<String> queries = [];

  @override
  Future<LocationModel> searchPlaces(String query) async {
    queries.add(query);
    final handler = onSearch;
    if (handler == null) return LocationModel(predictions: []);
    return handler(query);
  }
}

LocationModel _resultFor(String description) => LocationModel(
      predictions: [Prediction(description: description, placeId: description)],
    );

Future<void> _pumpEasyLoadingHost(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    builder: EasyLoading.init(),
    home: const SizedBox.shrink(),
  ));
}

void main() {
  group('fetchPlaceSuggestions', () {
    testWidgets('empty query does not schedule a search', (tester) async {
      await _pumpEasyLoadingHost(tester);
      final fake = _FakeLocationRepo();
      final logic = MapDragLogic(locationRepo: fake)
        ..debounceDuration = const Duration(milliseconds: 10);

      await logic.fetchPlaceSuggestions('');
      await tester.pump(const Duration(milliseconds: 30));

      expect(fake.queries, isEmpty);
    });

    testWidgets('debounced search updates suggestLocationData on success', (tester) async {
      await _pumpEasyLoadingHost(tester);
      final fake = _FakeLocationRepo()..onSearch = (q) => _resultFor('Result for $q');
      final logic = MapDragLogic(locationRepo: fake)
        ..debounceDuration = const Duration(milliseconds: 10);

      await logic.fetchPlaceSuggestions('phnom penh');
      await tester.pump(const Duration(milliseconds: 30));

      expect(fake.queries, ['phnom penh']);
      expect(logic.state.suggestLocationData.predictions?.single.description,
          'Result for phnom penh');
    });

    testWidgets('rapid typing cancels the earlier debounce; only the latest query searches',
        (tester) async {
      await _pumpEasyLoadingHost(tester);
      final fake = _FakeLocationRepo()..onSearch = (q) => _resultFor('Result for $q');
      final logic = MapDragLogic(locationRepo: fake)
        ..debounceDuration = const Duration(milliseconds: 30);

      // Two keystrokes in quick succession, well inside the debounce window.
      // Both clear kMinQueryLengthForNetwork — this test is about the
      // debounce, and shorter queries now short-circuit before reaching it
      // (P-04, spec Screen 2).
      await logic.fetchPlaceSuggestions('pho');
      await tester.pump(const Duration(milliseconds: 5));
      await logic.fetchPlaceSuggestions('phno');
      await tester.pump(const Duration(milliseconds: 60));

      expect(fake.queries, ['phno'],
          reason: "the first keystroke's timer should have been cancelled");
      expect(logic.state.suggestLocationData.predictions?.single.description,
          'Result for phno');
    });

    testWidgets('a query below the threshold never reaches the network',
        (tester) async {
      await _pumpEasyLoadingHost(tester);
      final fake = _FakeLocationRepo()..onSearch = (q) => _resultFor('x');
      final logic = MapDragLogic(locationRepo: fake)
        ..debounceDuration = const Duration(milliseconds: 10);

      await logic.fetchPlaceSuggestions('a');
      await logic.fetchPlaceSuggestions('ae');
      await tester.pump(const Duration(milliseconds: 40));

      // Places autocomplete is billed per request; this used to fire on the
      // first keystroke.
      expect(fake.queries, isEmpty);
      expect(logic.searchStatus, DestinationSearchStatus.belowThreshold);
    });

    testWidgets('a failed search is caught, not an uncaught exception', (tester) async {
      await _pumpEasyLoadingHost(tester);
      final fake = _FakeLocationRepo()..onSearch = (q) => throw Exception('network error');
      final logic = MapDragLogic(locationRepo: fake)
        ..debounceDuration = const Duration(milliseconds: 10);

      await logic.fetchPlaceSuggestions('will fail');
      // Reaching this line without the test runner recording an uncaught
      // async error (it would fail the test) is the assertion. Confirm
      // state simply wasn't touched by the failed call.
      await tester.pump(const Duration(milliseconds: 30));
      expect(logic.state.suggestLocationData.predictions, isNull);
    });
  });

  /// P-05 (docs/12) — the pin the user confirms. `state.latlng` used to be
  /// seeded with `LatLng(0, 0)` and only assigned from a 300 ms debounce, so
  /// confirming without moving the map, or within 300 ms of the last drag,
  /// handed back a point the user never chose.
  group('pin', () {
    test('there is no pin until the map reports a position', () {
      final logic = MapDragLogic(locationRepo: _FakeLocationRepo());

      expect(logic.state.latlng, isNull,
          reason: 'a LatLng(0, 0) seed is a real coordinate off West Africa');
      expect(logic.hasPin, isFalse);
    });

    test('a camera move commits the point immediately', () {
      final logic = MapDragLogic(locationRepo: _FakeLocationRepo());

      logic.onCameraMove(latlng: const LatLng(11.5564, 104.9282));

      expect(logic.hasPin, isTrue);
      expect(logic.state.latlng, const LatLng(11.5564, 104.9282));
    });

    test('the last point of a drag is the one that is kept', () {
      final logic = MapDragLogic(locationRepo: _FakeLocationRepo());

      logic.onCameraMove(latlng: const LatLng(11.0, 104.0));
      logic.onCameraMove(latlng: const LatLng(11.1, 104.1));
      logic.onCameraMove(latlng: const LatLng(11.2, 104.2));

      expect(logic.state.latlng, const LatLng(11.2, 104.2));
    });

    test('the marker lifts while the map moves and drops when it settles', () {
      final logic = MapDragLogic(locationRepo: _FakeLocationRepo());
      expect(logic.state.isCameraMove, isFalse);

      logic.onCameraMove(latlng: const LatLng(11.0, 104.0));
      expect(logic.state.isCameraMove, isTrue);

      logic.onCameraIdle();
      expect(logic.state.isCameraMove, isFalse,
          reason: 'onCameraIdle replaced the timer that only approximated it');
    });

    test('an idle callback without a preceding move is a no-op', () {
      final logic = MapDragLogic(locationRepo: _FakeLocationRepo());

      logic.onCameraIdle();

      expect(logic.state.isCameraMove, isFalse);
    });
  });

  group('disposal', () {
    testWidgets('a search in flight cannot fire after the page is closed',
        (tester) async {
      await _pumpEasyLoadingHost(tester);
      final fake = _FakeLocationRepo()
        ..onSearch = (q) => _resultFor('Result for $q');
      final logic = MapDragLogic(locationRepo: fake)
        ..debounceDuration = const Duration(milliseconds: 30);

      await logic.fetchPlaceSuggestions('phnom');
      logic.onClose();
      await tester.pump(const Duration(milliseconds: 60));

      expect(fake.queries, isEmpty,
          reason: 'the debounce outlived the controller and called update() on it');
    });
  });
}
