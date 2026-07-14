// import 'package:com.tara.passenger/core/utils/app_constant.dart';
// import 'package:com.tara.passenger/data/models/location_model.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:logger/logger.dart';
//
// abstract class ILocationSearch {
//   Future<LocationModel?> searchPlaces(String query);
//   Future<List<double>> getPlaceDetails(String placeId);
// }
//
// class LocationSearchRepo implements ILocationSearch {
//   final String apiKey = AppConstant.placeApiKey;
//
//   @override
//   Future<LocationModel> searchPlaces(String query) async {
//     if (query.isEmpty) return LocationModel(predictions: []);
//
//     final url = Uri.parse(
//         "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&components=country:KH&key=$apiKey");
//
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data == null || !data.containsKey("predictions")) {
//           return LocationModel(
//               predictions: []); // Return an empty model instead of null
//         }
//
//         return LocationModel.fromJson(data);
//       } else {
//         throw Exception("Failed to fetch places: ${response.body}");
//       }
//     } catch (e) {
//       Logger().e("Error: $e");
//       throw Exception("Failed to search places");
//     }
//   }
//
//   @override
//   Future<List<double>> getPlaceDetails(String placeId) async {
//     final url = Uri.parse(
//         "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey");
//
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final location = data['result']['geometry']['location'];
//         return [location['lat'], location['lng']];
//       } else {
//         throw Exception("Failed to fetch place details: ${response.body}");
//       }
//     } catch (e) {
//       Logger().e("Error: $e");
//       throw Exception("Failed to get place details");
//     }
//   }
// }
