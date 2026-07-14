import 'dart:async';
import 'package:com.tara.passenger/app/google_map_logic.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:com.tara.passenger/service/location_imp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import '../../../data/models/location_model.dart';
import '../../../service/location_search.dart';
import 'state.dart';

class MapDragLogic extends GetxController {
  final MapDragState state = MapDragState();
  Timer? _debounceTimer;
  Duration debounceDuration = const Duration(milliseconds: 300);
  final LocationRepo _locationRepo = LocationRepo();
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getArgument();
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        state.isTypingTextField = false;
        update([MapDragUpdate.search]);
      } else {
        state.isTypingTextField = true;
        update([MapDragUpdate.search]);
      }
    });
  }

  void getArgument() {}

  void onMapCreated(GoogleMapController controller) async {
    EasyLoading.show();
    state.mapController = controller;
    // 1. Get real location immediately
    var pos = await _locationRepo.getCurrentLocation();
    if (pos != null) {
      LatLng userLatLng = LatLng(pos.latitude, pos.longitude);

      state.mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLatLng, zoom: 15),
        ),
      );
    }
    EasyLoading.dismiss();
  }

  void moveCameraToLatLng() async {
    await 2.delay();
    // navigateTo(location: state.latlng!);
  }

  void onCameraMove({required LatLng latlng}) {
    _debounceTimer?.cancel();
    state.isCameraMove = true;
    update([MapDragUpdate.cameraMove]);
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      state.isCameraMove = false;

      state.latlng = latlng;
      update([MapDragUpdate.cameraMove]);
    });
  }

  // search address
  Future<void> fetchPlaceSuggestions(String query) async {
    try {
      EasyLoading.show();
      if (query.isEmpty) {
        return;
      }
      state.debounceTimer?.cancel();
      state.debounceTimer = Timer(debounceDuration, () async {
        var locationData = await _locationRepo.searchPlaces(query);
        state.suggestLocationData = locationData;
        update([MapDragUpdate.fetchLocation]);
      });
    } catch (e) {
      Logger().e("Exception e: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> selectPlace(Prediction? prediction) async {
    try {
      EasyLoading.show();
      var data = await _locationRepo.getPlaceDetails(prediction!.placeId!);
      state.isTypingTextField = false;
      update([MapDragUpdate.search]);
      state.latlng = LatLng(data[0], data[1]);
      Get.back(result: state.latlng);
    } catch (e) {
      Logger().e("Select place exception: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }
}
