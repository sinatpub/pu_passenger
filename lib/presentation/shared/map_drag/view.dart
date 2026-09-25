import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_radius.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
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
        child: Column(
          children: [
            _appBar(),
            _searchField(),
            Expanded(child: _mapLayer(context)),
          ],
        ),
      ),
    );
  }

  /// D18: minimal appbar — icon-button back + screen title.
  Widget _appBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.d, 12.d, 16.d, 0),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TaTextStyles.headlineMedium
                  .copyWith(color: TaColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return GetBuilder<MapDragLogic>(
      id: MapDragUpdate.search,
      builder: (logic) {
        if (logic.state.isShowMap) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.fromLTRB(16.d, 12.d, 16.d, 8.d),
          child: TaTextField(
            prefix: const Icon(Icons.search,
                size: 20, color: TaColors.textMuted),
            textInputAction: TextInputAction.done,
            controller: logic.searchController,
            onChanged: (value) => logic.fetchPlaceSuggestions(value),
            hint: AppLocale.searchForPlace.tr,
            autofocus: true,
          ),
        );
      },
    );
  }

  /// The map and everything that genuinely floats over it: the fixed centre
  /// pin, and the bottom slot that holds either the search results (search
  /// mode) or the confirm CTA (map mode).
  Widget _mapLayer(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Spec caps the results at half the screen; with the keyboard up the
        // map area can be shorter than that, and the panel must not outgrow it.
        final panelMaxHeight = math.min(
          MediaQuery.sizeOf(context).height * 0.5,
          constraints.maxHeight,
        );
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
            IgnorePointer(
              child: RepaintBoundary(
                child: Center(child: _centerPin()),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              // `search` is the id every `isShowMap` switch sends. The slot
              // used to hang off an id-less builder that the switch never
              // notified, so the results panel outlived search mode.
              child: GetBuilder<MapDragLogic>(
                id: MapDragUpdate.search,
                builder: (logic) {
                  if (logic.state.isShowMap) return _confirmSection();
                  // Screen 8's results panel: the whole
                  // `DestinationSearchStatus` table. It rebuilds on
                  // `fetchLocation`, the id `fetchPlaceSuggestions` updates.
                  return GetBuilder<MapDragLogic>(
                    id: MapDragUpdate.fetchLocation,
                    builder: (logic) => SearchPanel(
                      logic: logic,
                      maxHeight: panelMaxHeight,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// The fixed centre pin, with the pickup callout floating above it.
  ///
  /// The pin is shifted up so its *tip* — not the centre of its box — sits on
  /// the map centre, which is the camera target committed as the pin.
  Widget _centerPin() {
    final pinSize = 60.d;
    // `current_marker.svg` is 39×52 with its tip at y≈46; `contain` in a
    // square box fills the height, so the tip sits at 46/52 of [pinSize].
    final tipBelowCentre = pinSize * (46 / 52 - 0.5);
    return Transform.translate(
      offset: Offset(0, -tipBelowCentre),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (_purpose == MapDragPurpose.pickup)
            Positioned(
              bottom: pinSize + 12.d,
              child: _pickupCallout(),
            ),
          GetBuilder<MapDragLogic>(
            id: MapDragUpdate.cameraMove,
            builder: (logic) {
              return AnimatedSlide(
                offset:
                    state.isCameraMove ? const Offset(0, -0.4) : Offset.zero,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: SvgPicture.asset(
                  ImageAssets.currentMarker,
                  width: pinSize,
                  height: pinSize,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Screen 3's callout above the fixed centre pin. Shows the resolved
  /// address, `Pinned location` when only coordinates matched, or a skeleton
  /// bar while the reverse-geocode is in flight.
  Widget _pickupCallout() {
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
              ? TaSkeleton(width: 140.d, height: 14.d, radius: 4)
              : Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TaTextStyles.labelLarge
                      .copyWith(color: TaColors.textPrimary),
                ),
        );
      },
    );
  }

  /// The confirm affordance, shown in map mode only. For the destination
  /// flow this is unchanged from P-05 (gated purely on `hasPin`). For the
  /// pickup flow it follows Screen 3's state machine in `pickup_label.dart`:
  /// disabled while resolving, and it carries the note-for-driver field above
  /// it.
  Widget _confirmSection() {
    final isPickup = _purpose == MapDragPurpose.pickup;
    return Padding(
      padding: EdgeInsets.all(16.d),
      child: GetBuilder<MapDragLogic>(
        id: MapDragUpdate.confirm,
        builder: (logic) {
          final canConfirm = isPickup
              ? canConfirmPickup(logic.pickupConfirm)
              : logic.hasPin;
          final button = TaButton(
            label: _purpose.confirmLabel,
            width: double.infinity,
            isEnabled: canConfirm,
            onTap: () => Get.back(result: logic.state.latlng),
          );
          if (!isPickup) {
            // Destination keeps its compact centred CTA; the cap lets it
            // shrink on narrow screens instead of relying on fixed margins.
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 220.d),
              child: button,
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _driverNoteField(logic),
              SizedBox(height: 8.d),
              button,
            ],
          );
        },
      ),
    );
  }

  /// Screen 3's "Add a note for driver" — optional, capped to the spec's 60
  /// characters by `normaliseDriverNote` on the way into state (the display
  /// cap is cosmetic; the payload is what is validated).
  Widget _driverNoteField(MapDragLogic logic) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TaRadius.radiusMd),
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
