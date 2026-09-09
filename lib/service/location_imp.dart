import 'dart:convert';

import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

import '../core/utils/app_constant.dart';
import '../data/datasources/places_api.dart';
import '../data/models/location_model.dart';

abstract class LocationImpl {
  Future<bool> checkPermission();
  Future<Position?> getCurrentLocation();
  Future<bool> requestLocationPermission();
  Future<String> getAddressLocation({required LatLng latlng});
  Future<double> getDistance(
      {required LatLng start, required LatLng destination});
  Future<void> openAppSettings();
  Future<LocationModel?> searchPlaces(String query);
  Future<List<double>> getPlaceDetails(String placeId);

  Future<List<LatLng>> getDirectionPoint(LatLng start, LatLng end);
}

class LocationRepo implements LocationImpl {
  LocationRepo({PlacesRepository? placesRepository})
      : _injectedPlacesRepository = placesRepository;

  final PlacesRepository? _injectedPlacesRepository;
  late final PlacesRepository placesRepository =
      _injectedPlacesRepository ?? PlacesRepository();

  @override
  Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    // Only return true if we actually have permission
    return (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse);
  }

  @override
  Future<Position?> getCurrentLocation() async {
    if (await checkPermission() == false) {
      return null;
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      Position? result = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            timeLimit: const Duration(seconds: 10),
            desiredAccuracy: LocationAccuracy.medium,
          );
      return result;
    } catch (e) {
      Logger().e(e);
    }
    return null;
  }

  @override
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Handle the "Permanently Denied" case
    if (permission == LocationPermission.deniedForever) {
      // You cannot request again; you must open settings
      return false;
    }

    return (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse);
  }

  @override
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> showDialog({
    required String title,
    required String content,
    required String actionText,
    required VoidCallback onActionPressed,
  }) async {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        insetPadding: const EdgeInsets.all(50.0),
        shadowColor: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16.0),
              Text(
                content,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: onActionPressed,
                      child: Text(actionText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Future<String> getAddressLocation(
      {required LatLng latlng, bool localeKhmer = true}) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latlng.latitude, latlng.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String address = '';
        address += place.name != null ? "${place.name}, " : '';
        address += place.street != null ? "${place.street}, " : '';
        address += place.subLocality != null ? "${place.subLocality}, " : '';
        address += place.locality != null ? "${place.locality}, " : '';
        address += place.postalCode != null ? "${place.postalCode}, " : '';
        address += place.country != null ? "${place.country}" : '';
        return address.trim().replaceAll(RegExp(r',\s*$'), '');
      } else {
        return AppLocale.addressNotFound.tr;
      }
    } catch (e) {
      return AppLocale.addressNotFound.tr;
    }
  }

  @override
  getDistance({required LatLng start, required LatLng destination}) async {
    // final url =
    //     "https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=${AppConstant.googleKeyApi}";
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json"
      "?origin=${start.latitude},${start.longitude}"
      "&destination=${destination.latitude},${destination.longitude}"
      "&mode=driving"
      "&key=${AppConstant.googleKeyApi}",
    );
    final response = await get(url);
    final data = jsonDecode(response.body);

    if (data["status"] == "OK") {
      // var distance = data["routes"][0]["legs"][0]["distance"]["value"];
      // var duration = data["routes"][0]["legs"][0]["duration"]["value"];
      // Logger()
      //     .d("Driving Distance: $distance - ${convertDistanceToKM(distance)}");
      // Logger().d("Estimated Time: ${convertSecondsToHoursMinutes(duration)}");

      final route = data["routes"][0];
      final leg = route["legs"][0];

      final distanceMeters = leg["distance"]["value"] ?? 0;
      final durationSeconds = leg["duration"]["value"] ?? 0;

      final distanceKm = distanceMeters / 1000.0;

      Logger().d("Driving Distance: ${distanceKm.toStringAsFixed(2)} km");
      Logger().d(
          "Estimated Time: ${convertSecondsToHoursMinutes(durationSeconds)}");
      return distanceKm;
    } else {
      Logger().d("Error fetching distance: ${data['status']}");
      return convertDistanceToKM(0000);
    }
  }

  double convertDistanceToKM(int meters) {
    double kilometers = meters / 1000;
    return kilometers;
  }

  String convertSecondsToHoursMinutes(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    return '${hours}h ${minutes}m';
  }

  /// P-04: delegates to `PlacesRepository`. Kept on this interface so the
  /// existing callers in `MapDragLogic` are unaffected; the request building
  /// and its encoding now live in one place.
  @override
  Future<LocationModel> searchPlaces(String query) async {
    try {
      return await placesRepository.searchPlaces(query);
    } catch (e) {
      Logger().e("Error: $e");
      throw Exception("Failed to search places");
    }
  }

  /// P-04: delegates to `PlacesRepository`, as `searchPlaces` does.
  @override
  Future<List<double>> getPlaceDetails(String placeId) async {
    try {
      return await placesRepository.getPlaceDetails(placeId);
    } catch (e) {
      Logger().e("Error: $e");
      throw Exception("Failed to get place details");
    }
  }

  @override
  Future<List<LatLng>> getDirectionPoint(LatLng start, LatLng end) async {
    List<LatLng> polylinePoints = [];

    // 1. Define the Google Directions API URL
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=${AppConstant.googleKeyApi}";

    try {
      var response = await Dio().get(url);

      if (response.statusCode == 200) {
        String encodedPoints =
            response.data['routes'][0]['overview_polyline']['points'];

        // 3. Decode the encoded string into a list of LatLng
        polylinePoints = _decodePolyline(encodedPoints);
      }
    } catch (e) {
      print("Directions API Error: $e");
    }

    return polylinePoints;
  }

  // 4. The Decoding Algorithm (Standard Google Polyline Algorithm)
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }
}
