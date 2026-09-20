import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/state.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/widgets/booking_loading_overlay.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/widgets/map_appbar.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/widgets/map_bottom_sheet.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';

import '../../../translations/app_locale.dart';

class MapScreen extends StatelessWidget {
  MapScreen({super.key});

  final logic = Get.find<MapLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<MapLogic>(
          id: MapUpdate.mapID,
          builder: (logic) {
            final hasDestination = logic.state.destinationLatLng != null;
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GoogleMap(
                            gestureRecognizers: <Factory<
                                OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer()),
                            },
                            mapType: MapType.normal,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            compassEnabled: true,
                            zoomControlsEnabled: false,
                            polylines: logic.state.polylines,
                            markers: logic.state.mapMarkers,
                            initialCameraPosition: const CameraPosition(
                              target: LatLng(11.5564, 104.9282),
                              zoom: 12,
                            ),
                            onMapCreated: logic.onMapCreated,
                            onCameraIdle: () {
                              if (logic.state.destinationLatLng == null) {
                                logic.onCameraIdle();
                              }
                            },
                          ),
                          const MapAppbar(),
                          _currentLocation(),
                          if (!hasDestination) _currentPinMarkerLocation(),
                        ],
                      ),
                    ),
                    const MapBottomSheet(),
                  ],
                ),
                const BookingLoadingOverlay(),
              ],
            );
          }),
    );
  }

  Widget _currentPinMarkerLocation() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(bottom: 35.d),
        child: SvgPicture.asset(
          ImageAssets.currentMarker,
          width: 60.d,
          height: 60.d,
        ),
      ),
    );
  }

  Widget _currentLocation() {
    return Positioned(
      bottom: 20.d,
      right: 16.d,
      child: TaIconButton(
        icon: const Icon(Icons.my_location),
        semanticLabel: AppLocale.currentLocation.tr,
        color: TaColors.primary,
        onTap: () => logic.moveToCurrentLocation(),
      ),
    );
  }
}
