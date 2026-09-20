import 'dart:async';
import 'package:com.tara.passenger/services/location_imp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import '../../../data/models/location_model.dart';
import '../../../translations/app_locale.dart';
import 'pickup_label.dart';
import 'search_state.dart';
import 'state.dart';

class MapDragLogic extends GetxController {
  MapDragLogic({LocationRepo? locationRepo})
      : _locationRepo = locationRepo ?? LocationRepo();

  final MapDragState state = MapDragState();
  Duration debounceDuration = const Duration(milliseconds: 300);
  final LocationRepo _locationRepo;
  final TextEditingController searchController = TextEditingController();

  /// P-05: whether this page instance is the pickup (Screen 3) flow.
  ///
  /// Defaults to false — the destination flow, the route's only live caller.
  /// The view sets it from the route arguments so the logic stays free of
  /// routing concerns (and the VM-testable imports stay VM-testable).
  bool isPickupFlow = false;

  /// P-05: the note-for-driver text. Gated to the spec's 60-char cap in the
  /// view via `LengthLimitingTextInputFormatter(kDriverNoteMaxLength)`.
  final TextEditingController noteController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        state.isTypingTextField = false;
        update([MapDragUpdate.search, MapDragUpdate.confirm]);
      } else {
        state.isTypingTextField = true;
        update([MapDragUpdate.search, MapDragUpdate.confirm]);
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
      update([MapDragUpdate.cameraMove, MapDragUpdate.confirm]);
      // Resolve the seeded pin too: `animateCamera` does not raise
      // `isCameraMove`, so `onCameraIdle` would never fill the pickup label
      // for the initial position — only for positions the user drags to.
      schedulePickupResolution();
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
    update([MapDragUpdate.cameraMove, MapDragUpdate.confirm]);
  }

  /// The map has stopped moving — drop the marker back onto the map, and start
  /// a debounced reverse-geocode for the point under the centre pin. Driven by
  /// `GoogleMap.onCameraIdle` instead of a timer that only approximated it.
  void onCameraIdle() {
    if (!state.isCameraMove) return;
    state.isCameraMove = false;
    update([MapDragUpdate.cameraMove, MapDragUpdate.confirm]);
    schedulePickupResolution();
  }

  /// Whether the geocode-to-label pipeline applies at all. It follows the
  /// route's purpose set by the view: Screen 3 (pickup) shows a resolved
  /// label; the destination flow does not, so reverse-geocoding there would be
  /// an invisible network call on every camera movement (behavior change on
  /// the live caller).
  bool get shouldResolvePickup => isPickupFlow && state.latlng != null;

  /// The spec's 400 ms debounce for Screen 3's reverse-geocode. Kept as a
  /// separate timer from the search debounce so the two never cross-cancel.
  void schedulePickupResolution() {
    state.geocodeDebounceTimer?.cancel();
    if (!shouldResolvePickup) return;
    state.geocodeDebounceTimer =
        Timer(const Duration(milliseconds: 400), resolvePickupAddress);
  }

  /// Resolves the picked point to an address, updating the pickup label and
  /// driving [pickupConfirm]. The spec's resolving state is a skeleton label
  /// and a disabled Confirm — this sets `isResolving` and lets the view read
  /// `pickupConfirm` rather than touching widgets itself.
  Future<void> resolvePickupAddress() async {
    final latlng = state.latlng;
    if (latlng == null) return;
    state.isResolving = true;
    update([MapDragUpdate.pickupLabel, MapDragUpdate.confirm]);
    try {
      final address = await _locationRepo.getAddressLocation(latlng: latlng);
      state.resolvedAddress = address;
    } catch (e) {
      Logger().e("Reverse geocode exception: $e");
      state.resolvedAddress = null;
    } finally {
      state.isResolving = false;
      update([MapDragUpdate.pickupLabel, MapDragUpdate.confirm]);
    }
  }

  /// Which tier the resolved point reached (spec Screen 3).
  PickupLabelTier get pickupTier => pickupLabelTier(
        address: state.resolvedAddress,
        venue: null,
      );

  /// The confirm button's state (spec Screen 3 state table).
  PickupConfirmState get pickupConfirm => pickupConfirmState(
        hasPin: hasPin,
        isResolving: state.isResolving,
        tier: pickupTier,
      );

  /// The label to show above the centre pin / in the sheet. `null` means the
  /// spec's skeleton state.
  String? get pickupLabelText {
    if (state.isResolving) return null;
    if (state.resolvedAddress != null &&
        state.resolvedAddress!.trim().isNotEmpty) {
      return state.resolvedAddress;
    }
    // No address resolved — the spec shows "Pinned location" here.
    return AppLocale.pinnedLocation.tr;
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
  /// P-05: captures the note under the same normalisation the rest of the app
  /// uses, so the confirmed payload carries the trimmed, capped text.
  void updateDriverNote(String? value) {
    state.driverNote = normaliseDriverNote(value);
  }

  @override
  void onClose() {
    state.debounceTimer?.cancel();
    state.geocodeDebounceTimer?.cancel();
    EasyLoading.dismiss();
    searchController.dispose();
    noteController.dispose();
    super.onClose();
  }

  Future<void> selectPlace(Prediction? prediction) async {
    try {
      EasyLoading.show();
      var data = await _locationRepo.getPlaceDetails(prediction!.placeId!);
      state.isTypingTextField = false;
      update([MapDragUpdate.search, MapDragUpdate.confirm]);
      state.latlng = LatLng(data[0], data[1]);
      Get.back(result: state.latlng);
    } catch (e) {
      Logger().e("Select place exception: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }
}
