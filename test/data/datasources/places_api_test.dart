import 'package:com.tara.passenger/data/datasources/places_api.dart';
import 'package:flutter_test/flutter_test.dart';

/// P-04 (docs/12). The old implementation interpolated the passenger's raw
/// keyboard input straight into the request URL:
///
///   Uri.parse(".../autocomplete/json?input=$query&components=country:KH&key=$apiKey")
///
/// Anything the passenger typed that is meaningful in a URL therefore changed
/// the shape of the request instead of being searched for. These pin the
/// encoding.
void main() {
  final repo = PlacesRepository(apiKey: 'TEST_KEY');

  group('autocompleteUri', () {
    test('sends the query, the country restriction and the key', () {
      final uri = repo.autocompleteUri('AEON Mall');

      expect(uri.scheme, 'https');
      expect(uri.host, 'maps.googleapis.com');
      expect(uri.path, '/maps/api/place/autocomplete/json');
      expect(uri.queryParameters['input'], 'AEON Mall');
      expect(uri.queryParameters['components'], 'country:KH');
      expect(uri.queryParameters['key'], 'TEST_KEY');
    });

    test('an ampersand in the query is encoded, not treated as a separator',
        () {
      final uri = repo.autocompleteUri('Blue gate & pharmacy');

      // Previously this ended the `input` parameter early and injected a
      // bogus `pharmacy` parameter into the request.
      expect(uri.queryParameters['input'], 'Blue gate & pharmacy');
      expect(uri.queryParameters.containsKey(' pharmacy'), isFalse);
      expect(uri.queryParameters['key'], 'TEST_KEY');
    });

    test('a hash in the query does not truncate the request', () {
      final uri = repo.autocompleteUri('Flat #3 St 271');

      // `#` began a URL fragment, silently dropping the key and the country
      // restriction from the request that was actually sent.
      expect(uri.queryParameters['input'], 'Flat #3 St 271');
      expect(uri.queryParameters['key'], 'TEST_KEY');
      expect(uri.fragment, isEmpty);
    });

    test('an injected key parameter cannot override the real one', () {
      final uri = repo.autocompleteUri('somewhere&key=ATTACKER');

      expect(uri.queryParameters['input'], 'somewhere&key=ATTACKER');
      expect(uri.queryParameters['key'], 'TEST_KEY');
    });

    test('Khmer script survives encoding intact', () {
      final uri = repo.autocompleteUri('ភ្នំពេញ');
      expect(uri.queryParameters['input'], 'ភ្នំពេញ');
    });
  });

  group('placeDetailsUri', () {
    test('sends the place id and the key', () {
      final uri = repo.placeDetailsUri('ChIJ_abc123');

      expect(uri.path, '/maps/api/place/details/json');
      expect(uri.queryParameters['place_id'], 'ChIJ_abc123');
      expect(uri.queryParameters['key'], 'TEST_KEY');
    });
  });

  group('searchPlaces', () {
    test('an empty query short-circuits without a request', () async {
      final result = await repo.searchPlaces('');
      expect(result.predictions, isEmpty);
    });
  });
}
