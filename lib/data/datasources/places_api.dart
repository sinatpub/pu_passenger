import 'dart:convert';

import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/data/models/location_model.dart';
import 'package:http/http.dart' as http;

/// P-04 (docs/12) — Google Places, extracted out of `LocationRepo`.
///
/// `LocationRepo` had grown to cover device permissions, GPS acquisition,
/// distance/direction lookups and Places search behind one interface. Places
/// is a distinct remote API with its own key and its own failure modes, and
/// `docs/12` calls for it to be its own repository.
///
/// The URLs are built with `Uri.https` rather than string interpolation.
/// That is not a style change — it fixes a real defect. The old code did:
///
/// ```dart
/// Uri.parse(".../autocomplete/json?input=$query&components=country:KH&key=$apiKey")
/// ```
///
/// with `query` taken straight from the passenger's keyboard and never
/// encoded. A destination containing `&`, `#`, `?` or `=` — "Blue gate &
/// pharmacy", say — silently truncated the search term or injected extra
/// parameters into the request. `Uri.https` percent-encodes every value.
class PlacesRepository {
  PlacesRepository({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ?? AppConstant.placeApiKey;

  final http.Client _client;
  final String _apiKey;

  static const _host = 'maps.googleapis.com';

  /// Autocomplete predictions for a free-text query, restricted to Cambodia.
  /// Exposed separately from the request so the encoding is testable without
  /// touching the network.
  Uri autocompleteUri(String query) => Uri.https(
        _host,
        '/maps/api/place/autocomplete/json',
        {
          'input': query,
          'components': 'country:KH',
          'key': _apiKey,
        },
      );

  Uri placeDetailsUri(String placeId) => Uri.https(
        _host,
        '/maps/api/place/details/json',
        {
          'place_id': placeId,
          'key': _apiKey,
        },
      );

  Future<LocationModel> searchPlaces(String query) async {
    if (query.isEmpty) return LocationModel(predictions: []);

    final response = await _client.get(autocompleteUri(query));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch places: ${response.body}');
    }

    final data = json.decode(response.body);
    if (data == null || !data.containsKey('predictions')) {
      return LocationModel(predictions: []);
    }
    return LocationModel.fromJson(data);
  }

  /// Returns `[lat, lng]` for a prediction.
  Future<List<double>> getPlaceDetails(String placeId) async {
    final response = await _client.get(placeDetailsUri(placeId));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch place details: ${response.body}');
    }

    final data = json.decode(response.body);
    final location = data['result']['geometry']['location'];
    return [location['lat'], location['lng']];
  }
}
