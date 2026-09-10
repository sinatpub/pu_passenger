import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/logic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/resources/asset_resource.dart';
import '../../../core/theme/colors.dart';
import '../../../translations/app_locale.dart';
import '../../widgets/fbtn_widget.dart';
import '../../widgets/x_text_field.dart';
import 'args.dart';
import 'logic.dart';
import 'state.dart';

class MapDragPage extends StatelessWidget {
  MapDragPage({super.key});

  // P-05: resolved from MapDragBinding, which the DRAGMAP route now wires.
  // `Get.put` here ran on every construction of this widget, replacing the
  // registered controller each time.
  final MapDragLogic logic = Get.find<MapDragLogic>();
  final MapDragState state = Get.find<MapDragLogic>().state;
  final MapLogic _mapLogic = Get.find<MapLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(CupertinoIcons.chevron_left),
          iconSize: 24,
        ),
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        title: Text(AppLocale.searchLocation.tr),
      ),
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                GetBuilder<MapDragLogic>(
                    id: MapDragUpdate.search,
                    builder: (logic) {
                      return logic.state.isShowMap
                          ? const SizedBox()
                          : Container(
                              constraints: BoxConstraints(
                                maxHeight: 125..d,
                                minHeight: 120..d,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 46,
                                    child: XTextField(
                                      textInputAction: TextInputAction.done,
                                      textController: logic.searchController,
                                      onChanged: (value) {
                                        logic.fetchPlaceSuggestions(
                                            value.toString());
                                      },
                                      maxLines: 1,
                                      keyboardType: TextInputType.text,
                                      hasShadow: false,
                                      borderColor: AppColors.light1,
                                      onFieldSubmitted: (value) {
                                        // logic.state.isSearching.value = false;
                                      },
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: AppColors.main,
                                      ),
                                      hintText: AppLocale.enterAddress.tr,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  !logic.state.isShowMap
                                      ? Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: InkWell(
                                              onTap: () {
                                                logic.state.isShowMap = true;
                                                logic.update(
                                                    [MapDragUpdate.search]);
                                              },
                                              child: Column(
                                                children: [
                                                  Divider(
                                                    color: Colors.grey.shade200,
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    spacing: 8..d,
                                                    children: [
                                                      SvgPicture.asset(
                                                        ImageAssets.marker_icon,
                                                        fit: BoxFit.scaleDown,
                                                      ),
                                                      Text(
                                                        AppLocale
                                                            .setLocationMap.tr,
                                                        style:
                                                            AppTextStyles.body,
                                                      )
                                                    ],
                                                  ),
                                                  Divider(
                                                    color: Colors.grey.shade200,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox()
                                ],
                              ),
                            );
                    }),
                Divider(
                  height: .1,
                  color: Colors.grey[300],
                ),
                Expanded(child: mapWidget()),
              ],
            ),
            GetBuilder<MapDragLogic>(
              id: MapDragUpdate.search,
              builder: (searchLogic) {
                return searchLogic.state.isShowMap == false
                    ? AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        top: 120..d,
                        left: 0,
                        right: 0,
                        child: Container(
                            height: Get.height,
                            color: Colors.white,
                            child: GetBuilder<MapDragLogic>(
                                id: MapDragUpdate.fetchLocation,
                                builder: (fetchLogic) {
                                  return (logic.state.suggestLocationData
                                                  .predictions?.length ??
                                              0) <=
                                          0
                                      ? Padding(
                                          padding: EdgeInsets.only(top: 40..d),
                                          child: Text(
                                            AppLocale.emptyLocation.tr,
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: logic
                                              .state
                                              .suggestLocationData
                                              .predictions
                                              ?.length,
                                          itemBuilder: (context, index) {
                                            final prediction = logic
                                                .state
                                                .suggestLocationData
                                                .predictions?[index];

                                            if (prediction == null) {
                                              return const SizedBox();
                                            }
                                            return ListTile(
                                              selectedColor: Colors.red,
                                              selectedTileColor:
                                                  Colors.red.withAlpha(10),
                                              selected: logic
                                                      .state
                                                      .selectedPrediction
                                                      ?.placeId ==
                                                  prediction.placeId,
                                              onTap: () {
                                                logic.searchController.text =
                                                    prediction.description ??
                                                        "";
                                                logic.state.selectedPrediction =
                                                    prediction;
                                                logic.selectPlace(
                                                    state.selectedPrediction);
                                                logic.update();
                                                FocusScope.of(context)
                                                    .unfocus();
                                              },
                                              title: Text(prediction
                                                      .description ??
                                                  'No description available'),
                                              trailing: const Icon(
                                                  Icons.navigate_next_outlined),
                                            );
                                          },
                                        );
                                })),
                      )
                    : const SizedBox.shrink();
              },
            ),
            _buildBackButton(),
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
                  target:
                      _mapLogic.state.currentLatLng ?? const LatLng(0.0, 0.0)),
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
                                  width: 60..d,
                                  height: 60..d,
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  /// P-05 (docs/12) — the confirm affordance is disabled until the map has
  /// reported a position, so it can no longer hand back the `LatLng(0, 0)`
  /// the state used to be seeded with. `FBTNWidget` renders a null
  /// `onPressed` with `disabledColor`, which is the spec's "Confirm disabled
  /// while resolving" state (`ux_ui_design/taxi-booking-ux-spec.md`,
  /// Screen 3).
  Widget _buildBackButton() {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 100..d),
        child: GetBuilder<MapDragLogic>(
          id: MapDragUpdate.cameraMove,
          builder: (logic) {
            return FBTNWidget(
              onPressed: logic.hasPin
                  ? () => Get.back(result: logic.state.latlng)
                  : null,
              color: AppColors.main,
              textColor: AppColors.light4,
              // Follows the route argument; defaults to the drop-off flow,
              // which is the only live caller today.
              label: MapDragArgs.fromRoute(Get.arguments).purpose.confirmLabel,
            );
          },
        ),
      ),
    );
  }
}
