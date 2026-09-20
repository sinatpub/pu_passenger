import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/args.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/logic.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/pickup_label.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/state.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/widgets/search_panel.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 8 (Search / MapDrag) — reskinned onto the Ta components (C4).
///
/// Render-only change: the appbar is the D18 minimal icon-button row, the
/// search field is `TaTextField`, results are `TaSearchResult` cards inside
/// the extracted [SearchPanel], the confirm CTA is `TaButton` and the pickup
/// note uses `TaNoteField`. The P-05 state machine is untouched: the pin is
/// still committed on camera move, reverse-geocode is still debounced behind
/// `MapDragPurpose.pickup`, and confirm still pops `/map` with the `LatLng`
/// the `result is! LatLng` guard in `map_screen/view.dart` awaits.
class MapDragPage extends StatelessWidget {
  MapDragPage({super.key});

  /// P-05: resolved from MapDragBinding, which the DRAGMAP route now wires.
  /// `Get.put` here ran on every construction of this widget, replacing the
  /// registered controller each time.
  final MapDragLogic logic = Get.find<MapDragLogic>();
  final MapDragState state = Get.find<MapDragLogic>().state;
  final MapLogic _mapLogic = Get.find<MapLogic>();

  MapDragPurpose get _purpose => MapDragArgs.fromRoute(Get.arguments).purpose;

  String get _title => _purpose == MapDragPurpose.pickup
      ? AppLocale.setPickup.tr
      : AppLocale.setDestination.tr;

  @override
  Widget build(BuildContext context) {
    // The pickup flow gates the reverse-geocode pipeline in the logic; the
    // destination flow's behavior stays exactly as it was.
    logic.isPickupFlow = _purpose == MapDragPurpose.pickup;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                // D18: minimal appbar — icon-button back + screen title.
                Padding(
                  padding: EdgeInsets.fromLTRB(16.d, 10.d, 16.d, 0),
                  child: Row(
                    children: [
                      TaIconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        semanticLabel: AppLocale.back.tr,
                        onTap: Get.back,
                      ),
                      SizedBox(width: 12.d),
                      Expanded(
                        child: Text(
                          _title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: TaColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GetBuilder<MapDragLogic>(
                  id: MapDragUpdate.search,
                  builder: (logic) {
                    if (logic.state.isShowMap) return const SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.fromLTRB(16.d, 12.d, 16.d, 8.d),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              size: 20, color: TaColors.textMuted),
                          SizedBox(width: 10.d),
                          Expanded(
                            child: TaTextField(
                              textInputAction: TextInputAction.done,
                              controller: logic.searchController,
                              onChanged: (value) =>
                                  logic.fetchPlaceSuggestions(value),
                              hint: AppLocale.searchForPlace.tr,
                              autofocus: true,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Expanded(child: mapWidget()),
              ],
            ),
            _confirmButton(),
          ],
        ),
      ),
    );
  }

  Widget mapWidget() {
    return GetBuilder<MapDragLogic>(
      builder: (logic) {
        return Stack(
          children: [
            GoogleMap(
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              mapType: MapType.normal,
              trafficEnabled: true,
              myLocationEnabled: true,
              indoorViewEnabled: true,
              myLocationButtonEnabled: true,
              compassEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              mapToolbarEnabled: true,
              initialCameraPosition: CameraPosition(
                target: _mapLogic.state.currentLatLng ??
                    const LatLng(11.5564, 104.9282),
              ),
              onMapCreated: (controller) => logic.onMapCreated(controller),
              onCameraMove: (CameraPosition position) async {
                logic.onCameraMove(latlng: position.target);
              },
              onCameraIdle: () => logic.onCameraIdle(),
            ),
            Positioned.fill(
              child: RepaintBoundary(
                child: IgnorePointer(
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        if (_purpose == MapDragPurpose.pickup)
                          _pickupCallout(),
                        GetBuilder<MapDragLogic>(
                          id: MapDragUpdate.cameraMove,
                          builder: (logic) {
                            return AnimatedSlide(
                              offset: state.isCameraMove
                                  ? const Offset(0, -0.4)
                                  : Offset.zero,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              child: SvgPicture.asset(
                                ImageAssets.currentMarker,
                                width: 60.d,
                                height: 60.d,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Screen 8's results panel: the whole `DestinationSearchStatus`
            // table (idle/below-threshold hint, searching skeleton or dimmed
            // prior results, results, empty, error+retry).
            // The panel rebuilds on `MapDragUpdate.fetchLocation`, the id
            // `fetchPlaceSuggestions` updates with. Without a builder for
            // that id the search results never reached the screen: typing
            // fetched predictions, and the panel stayed on its idle hint.
            if (!logic.state.isShowMap)
              Align(
                alignment: Alignment.bottomCenter,
                child: GetBuilder<MapDragLogic>(
                  id: MapDragUpdate.fetchLocation,
                  builder: (logic) => SearchPanel(logic: logic),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Screen 3's callout above the fixed centre pin. Shows the resolved
  /// address, `Pinned location` when only coordinates matched, or a skeleton
  /// bar while the reverse-geocode is in flight.
  Widget _pickupCallout() {
    return Positioned(
      bottom: 72.d,
      child: GetBuilder<MapDragLogic>(
        id: MapDragUpdate.pickupLabel,
        builder: (logic) {
          final text = logic.pickupLabelText;
          return Container(
            constraints: BoxConstraints(maxWidth: Get.width * 0.7),
            padding: EdgeInsets.symmetric(horizontal: 14.d, vertical: 8.d),
            decoration: BoxDecoration(
              color: TaColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: TaShadows.shadowSm,
            ),
            child: text == null
                ? Container(
                    width: 140.d,
                    height: 14.d,
                    decoration: BoxDecoration(
                      color: TaColors.disabledBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                : Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TaColors.textPrimary,
                    ),
                  ),
          );
        },
      ),
    );
  }

  /// The confirm affordance. For the destination flow this is unchanged from
  /// P-05 (gated purely on `hasPin`). For the pickup flow it follows Screen 3's
  /// state machine in `pickup_label.dart`: disabled while resolving, and it
  /// carries the note-for-driver field above it.
  Widget _confirmButton() {
    return Positioned(
      bottom: 10.d,
      left: 0,
      right: 0,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: _purpose == MapDragPurpose.pickup ? 14.d : 100.d,
        ),
        child: GetBuilder<MapDragLogic>(
          id: MapDragUpdate.confirm,
          builder: (logic) {
            // Search mode gives the bottom of the screen to `SearchPanel`;
            // the CTA belongs to the map-pin mode the panel's "set location
            // on the map" row switches into. It used to sit on top of the
            // results, covering the last row of the list.
            if (!logic.state.isShowMap) return const SizedBox.shrink();
            final isPickup = _purpose == MapDragPurpose.pickup;
            final canConfirm = isPickup
                ? canConfirmPickup(logic.pickupConfirm)
                : logic.hasPin;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPickup && state.isShowMap) _driverNoteField(logic),
                SizedBox(height: 8.d),
                TaButton(
                  label: _purpose.confirmLabel,
                  width: double.infinity,
                  isEnabled: canConfirm,
                  onTap: () => Get.back(result: logic.state.latlng),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Screen 3's "Add a note for driver" — optional, capped to the spec's 60
  /// characters by `normaliseDriverNote` on the way into state (the display
  /// cap is cosmetic; the payload is what is validated).
  Widget _driverNoteField(MapDragLogic logic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        color: TaColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: TaShadows.shadowSm,
      ),
      child: TaNoteField(
        controller: logic.noteController,
        onChanged: (value) => logic.updateDriverNote(value),
        hint: AppLocale.addNoteForDriver.tr,
      ),
    );
  }
}