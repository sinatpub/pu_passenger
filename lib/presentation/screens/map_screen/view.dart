import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) => Column(
              children: [
                Expanded(child: _mapLayer()),
                MapBottomSheet(maxHeight: constraints.maxHeight),
              ],
            ),
          ),
          const BookingLoadingOverlay(),
        ],
      ),
    );
  }

  /// The map and what floats over it: the fixed pickup pin, the app bar and
  /// the my-location button.
  Widget _mapLayer() {
    return GetBuilder<MapLogic>(
      id: MapUpdate.mapID,
      builder: (logic) {
        final hasDestination = logic.state.destinationLatLng != null;
        return Stack(
          children: [
            GoogleMap(
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
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
            // The visible-region centre is the pickup `onCameraIdle` commits;
            // the pin's tip marks it.
            if (!hasDestination)
              IgnorePointer(
                child: Center(child: TaCenterPin(size: 60.d)),
              ),
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.d, 12.d, 16.d, 0),
                  child: const MapAppbar(),
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
                onTap: () => logic.moveToCurrentLocation(),
              ),
            ),
          ],
        );
      },
    );
  }
}
