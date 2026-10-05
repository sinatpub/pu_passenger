import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_radius.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/args.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/logic.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/search_state.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/state.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/widgets/pin_confirm_sheet.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/widgets/search_view.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 8 (Search / MapDrag) — pick a point on the map, or search for one.
///
/// The page opens on the map: back button and search bar floating over it,
/// the fixed centre pin with its address, and [PinConfirmSheet] underneath.
/// Tapping the search bar opens [MapDragSearchView] over the map; back, or
/// "Set location on the map", returns to it.
///
/// The P-05 state machine is untouched: the pin is still committed on camera
/// move, the reverse-geocode is still debounced, and both Confirm and a
/// search result still pop `/map` with the `LatLng` the `result is! LatLng`
/// guard on the booking sheet awaits.
class MapDragPage extends StatelessWidget {
  MapDragPage({super.key});

  /// P-05: resolved from MapDragBinding, which the DRAGMAP route now wires.
  /// `Get.put` here ran on every construction of this widget, replacing the
  /// registered controller each time.
  final MapDragLogic logic = Get.find<MapDragLogic>();
  final MapLogic _mapLogic = Get.find<MapLogic>();

  MapDragArgs get _args => MapDragArgs.fromRoute(Get.arguments);

  MapDragPurpose get _purpose => _args.purpose;

  @override
  Widget build(BuildContext context) {
    // `search` is the id every `isShowMap` switch sends.
    return GetBuilder<MapDragLogic>(
      id: MapDragUpdate.search,
      builder: (logic) {
        final searching = !logic.state.isShowMap;
        return PopScope(
          // Back out of the search view lands on the map, not off the page.
          canPop: !searching,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) logic.closeSearch();
          },
          child: Scaffold(
            backgroundColor: TaColors.background,
            body: Stack(
              children: [
                // The map stays mounted under the search view, so the pin
                // and camera are where they were on the way back.
                Column(
                  children: [
                    Expanded(child: _mapLayer()),
                    PinConfirmSheet(purpose: _purpose),
                  ],
                ),
                if (searching)
                  const Positioned.fill(child: MapDragSearchView()),
              ],
            ),
          ),
        );
      },
    );
  }

  /// The map and what floats over it: the fixed centre pin, the header and
  /// the my-location button.
  Widget _mapLayer() {
    return Stack(
      children: [
        GoogleMap(
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          mapType: MapType.normal,
          myLocationEnabled: true,
          // The page draws its own controls; Google's sat under the sheet
          // and on top of each other.
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          initialCameraPosition: CameraPosition(
            target: _args.start ??
                _mapLogic.state.currentLatLng ??
                const LatLng(11.5564, 104.9282),
            zoom: 15,
          ),
          onMapCreated: logic.onMapCreated,
          onCameraMove: (position) =>
              logic.onCameraMove(latlng: position.target),
          onCameraIdle: logic.onCameraIdle,
        ),
        IgnorePointer(
          child: RepaintBoundary(
            child: Center(child: _centerPin()),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.d, 12.d, 16.d, 0),
              child: _header(),
            ),
          ),
        ),
        Positioned(
          bottom: 16.d,
          right: 16.d,
          child: TaIconButton(
            icon: const Icon(Icons.my_location),
            semanticLabel: AppLocale.currentLocation.tr,
            color: TaColors.primary,
            onTap: () async {
              if (await logic.moveToCurrentLocation()) return;
              Get.snackbar(
                  AppLocale.error.tr, AppLocale.cantFindLocation.tr);
            },
          ),
        ),
      ],
    );
  }

  /// Back button and the search bar, floating over the map.
  Widget _header() {
    final query = logic.searchController.text;
    return Row(
      children: [
        TaIconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          semanticLabel: AppLocale.back.tr,
          onTap: Get.back,
        ),
        SizedBox(width: 10.d),
        Expanded(
          child: Semantics(
            button: true,
            child: TaPressable(
              onTap: logic.openSearch,
              child: Container(
                height: 46,
                padding: EdgeInsets.symmetric(horizontal: 16.d),
                decoration: BoxDecoration(
                  color: TaColors.surface,
                  borderRadius: BorderRadius.circular(TaRadius.radiusFull),
                  boxShadow: TaShadows.shadowMd,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        size: 20, color: TaColors.primary),
                    SizedBox(width: 10.d),
                    Expanded(
                      child: Text(
                        query.isEmpty ? AppLocale.searchForPlace.tr : query,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TaTextStyles.bodyLarge.copyWith(
                          color: query.isEmpty
                              ? TaColors.textSecondary
                              : TaColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The fixed centre pin, with the address callout floating above it.
  Widget _centerPin() {
    return GetBuilder<MapDragLogic>(
      id: MapDragUpdate.cameraMove,
      builder: (logic) => TaCenterPin(
        size: 60.d,
        lifted: logic.state.isCameraMove,
        calloutGap: 12.d,
        callout: _callout(),
      ),
    );
  }

  /// The callout above the fixed centre pin: the place's name — the sheet
  /// carries the rest of the address — `Pinned location` when only
  /// coordinates matched, or a skeleton bar while the reverse-geocode is in
  /// flight.
  Widget _callout() {
    return GetBuilder<MapDragLogic>(
      id: MapDragUpdate.pickupLabel,
      builder: (logic) {
        final text = logic.pickupLabelText;
        return Container(
          constraints: BoxConstraints(maxWidth: Get.width * 0.7),
          padding: EdgeInsets.symmetric(horizontal: 16.d, vertical: 8.d),
          decoration: BoxDecoration(
            color: TaColors.surface,
            borderRadius: BorderRadius.circular(TaRadius.radiusMd),
            boxShadow: TaShadows.shadowSm,
          ),
          child: text == null
              ? TaSkeleton(width: 120.d, height: 14.d, radius: 4)
              : Text(
                  splitPlaceDescription(text).primary ?? text,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TaTextStyles.labelLarge
                      .copyWith(color: TaColors.textPrimary),
                ),
        );
      },
    );
  }
}
