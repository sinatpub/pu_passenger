import 'dart:async';
import 'package:com.tara.passenger/service/location_imp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import '../../../data/models/location_model.dart';
import 'search_state.dart';
import 'state.dart';

class MapDragLogic extends GetxController {
  MapDragLogic({LocationRepo? locationRepo})
      : _locationRepo = locationRepo ?? LocationRepo();

  final MapDragState state = MapDragState();
  Duration debounceDuration = const Duration(milliseconds: 300);
  final LocationRepo _locationRepo;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
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

  void onMapCreated(GoogleMapController controller) async {
    EasyLoading.show();
    state.mapController = controller;
    // 1. Get real location immediately
    var pos = await _locationRepo.getCurrentLocation();
    if (pos != null) {
      LatLng userLatLng = LatLng(pos.latitude, pos.longitude);

      state.latlng = userLatLng;
      state.mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLatLng, zoom: 15),
        ),
      );
      update([MapDragUpdate.cameraMove]);
    }
    EasyLoading.dismiss();
  }

  /// P-05 (docs/12) — the pin the user confirms is the point under the centre
  /// of the viewport, so it is committed on every camera move rather than from
  /// a 300 ms debounce. The old debounce meant confirming within 300 ms of the
  /// last drag handed back the *previous* point, and `state.latlng`'s
  /// `LatLng(0, 0)` seed meant confirming without ever moving the map handed
  /// back the null island off West Africa. `hasPin` now gates the button, and
  /// `onMapCreated` seeds the pin from the user's own position.
  void onCameraMove({required LatLng latlng}) {
    state.latlng = latlng;
    if (state.isCameraMove) return;
    state.isCameraMove = true;
    update([MapDragUpdate.cameraMove]);
  }

  /// The map has stopped moving — drop the marker back onto the map. Driven by
  /// `GoogleMap.onCameraIdle` instead of a timer that only approximated it.
  void onCameraIdle() {
    if (!state.isCameraMove) return;
    state.isCameraMove = false;
    update([MapDragUpdate.cameraMove]);
  }

  /// Whether there is a real point to confirm. False until the map reports a
  /// position — with location permission denied and no interaction, it stays
  /// false and the confirm button stays disabled.
  bool get hasPin => state.latlng != null;

  /// What the results area should be showing, per spec Screen 2's state table.
  DestinationSearchStatus get searchStatus => destinationSearchStatus(
        query: state.searchQuery,
        isSearching: state.isSearching,
        hasError: state.hasSearchError,
        resultCount: state.suggestLocationData.predictions?.length ?? 0,
      );

  // search address
  //
  // P-04 (docs/12) — the loading/error handling below used to wrap only the
  // synchronous work of *scheduling* the debounce timer, not the actual
  // `searchPlaces` call inside it: `EasyLoading.show()` was immediately
  // followed by `dismiss()` in a `finally` that ran before the debounced
  // callback ever fired, and a failed search inside that callback was an
  // uncaught exception (pu_passenger has no Crashlytics wired yet either,
  // so it would have had zero visibility). Moved show/catch/dismiss inside
  // the timer callback so they actually cover the async work; debounce
  // mechanics (cancel-and-reschedule per keystroke) are unchanged.
  Future<void> fetchPlaceSuggestions(String query) async {
    state.debounceTimer?.cancel();
    state.searchQuery = query;

    // P-04 / spec Screen 2: do not reach the network below the threshold.
    // This used to fire on a single character — results too generic to
    // disambiguate, and Places autocomplete is billed per request, so every
    // passenger paid for two useless calls before the first useful one.
    if (!shouldQueryNetwork(query)) {
      state.isSearching = false;
      state.hasSearchError = false;
      update([MapDragUpdate.fetchLocation]);
      return;
    }

    state.isSearching = true;
    state.hasSearchError = false;
    update([MapDragUpdate.fetchLocation]);

    EasyLoading.show();
    state.debounceTimer = Timer(debounceDuration, () async {
      try {
        var locationData = await _locationRepo.searchPlaces(query);
        state.suggestLocationData = locationData;
        state.hasSearchError = false;
      } catch (e) {
        // Spec: keep the typed query so the passenger can retry it.
        state.hasSearchError = true;
        Logger().e("Exception e: $e");
      } finally {
        state.isSearching = false;
        update([MapDragUpdate.fetchLocation]);
        EasyLoading.dismiss();
      }
    });
  }

  /// P-05 (docs/12) — nothing here was ever disposed. A search debounce that
  /// outlived the page called `update()` on a dead controller, and because
  /// `fetchPlaceSuggestions` only dismisses its loader from inside the timer
  /// callback, cancelling that timer without dismissing left the global
  /// `EasyLoading` overlay up over whatever screen came next.
  @override
  void onClose() {
    state.debounceTimer?.cancel();
    EasyLoading.dismiss();
    searchController.dispose();
    super.onClose();
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
