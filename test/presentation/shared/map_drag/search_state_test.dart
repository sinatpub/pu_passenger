import 'package:com.tara.passenger/presentation/shared/map_drag/search_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// P-04 (docs/12) — spec Screen 2's state table, checked against tests rather
/// than against a running app.
void main() {
  group('shouldQueryNetwork', () {
    test('one and two characters stay off the wire', () {
      // Previously every keystroke searched. Places autocomplete is billed
      // per request, so this was money as well as noise.
      expect(shouldQueryNetwork('a'), isFalse);
      expect(shouldQueryNetwork('ae'), isFalse);
    });

    test('three characters is the threshold', () {
      expect(shouldQueryNetwork('aeo'), isTrue);
    });

    test('whitespace does not count toward the threshold', () {
      expect(shouldQueryNetwork('  a  '), isFalse);
      expect(shouldQueryNetwork(' aeon '), isTrue);
    });

    test('an empty query never reaches the network', () {
      expect(shouldQueryNetwork(''), isFalse);
      expect(shouldQueryNetwork('   '), isFalse);
    });
  });

  group('destinationSearchStatus', () {
    DestinationSearchStatus status(String q,
            {bool searching = false, bool error = false, int results = 0}) =>
        destinationSearchStatus(
          query: q,
          isSearching: searching,
          hasError: error,
          resultCount: results,
        );

    test('no query shows recents, not an empty search', () {
      expect(status(''), DestinationSearchStatus.idle);
      expect(status('   '), DestinationSearchStatus.idle);
    });

    test('a short query filters locally rather than searching', () {
      expect(status('ae'), DestinationSearchStatus.belowThreshold);
    });

    test('a search in flight reads as searching', () {
      expect(status('aeon', searching: true), DestinationSearchStatus.searching);
    });

    test('a retry already in flight reads as searching, not as the error it '
        'is replacing', () {
      expect(status('aeon', searching: true, error: true),
          DestinationSearchStatus.searching);
    });

    test('a failed search is distinct from an empty one', () {
      // "nothing matched" and "we could not look" are different messages.
      expect(status('aeon', error: true), DestinationSearchStatus.error);
      expect(status('aeon', results: 0), DestinationSearchStatus.empty);
    });

    test('results are reported when there are any', () {
      expect(status('aeon', results: 3), DestinationSearchStatus.results);
    });
  });

  group('keepsPreviousResults', () {
    test('a search in flight keeps the old list on screen', () {
      // The spec dims previous results rather than clearing them - clearing
      // flashes an empty list on every keystroke.
      expect(keepsPreviousResults(DestinationSearchStatus.searching), isTrue);
    });

    test('the list is dropped once the query no longer supports it', () {
      expect(keepsPreviousResults(DestinationSearchStatus.idle), isFalse);
      expect(keepsPreviousResults(DestinationSearchStatus.empty), isFalse);
      expect(keepsPreviousResults(DestinationSearchStatus.error), isFalse);
      expect(
          keepsPreviousResults(DestinationSearchStatus.belowThreshold), isFalse);
    });
  });
}
