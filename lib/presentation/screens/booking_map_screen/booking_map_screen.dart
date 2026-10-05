import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/widgets/booking_sheet.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 9 — Booking (Active Ride).
///
/// The map takes the room above the booking sheet, as it does on the booking
/// and set-destination screens, so whatever the camera frames is in view:
/// nothing is hidden under the sheet. The stage is the sheet's headline; the
/// status pill that used to float over the map said the same thing twice.
///
/// The prototype's "Skip ▸" button and its 17s auto-advance are deliberately
/// absent: `D14` lists both as demo-only — production advances on real socket
/// events, which `BookingMapLogic` already drives.
class BookingMapScreen extends StatelessWidget {
  const BookingMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Unchanged: the active ride cannot be backed out of, only cancelled.
      canPop: false,
      child: Scaffold(
        backgroundColor: TaColors.background,
        body: GetBuilder<BookingMapLogic>(builder: (logic) {
          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: _map(context, logic)),
                    Positioned(
                      right: 16.d,
                      bottom: 16.d,
                      // Puts the driver and the pickup (or the trip) back in
                      // view after the passenger has panned away.
                      child: TaIconButton(
                        icon: const Icon(Icons.my_location),
                        semanticLabel: AppLocale.recenterMap.tr,
                        color: TaColors.primary,
                        onTap: logic.navigateMapPerspective,
                      ),
                    ),
                  ],
                ),
              ),
              BookingSheet(logic: logic),
            ],
          );
        }),
      ),
    );
  }

  /// Camera, markers and polyline are `BookingMapLogic`'s — this only renders
  /// them.
  Widget _map(BuildContext context, BookingMapLogic logic) {
    return GoogleMap(
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      },
      mapType: MapType.normal,
      myLocationEnabled: false,
      indoorViewEnabled: true,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: true,
      mapToolbarEnabled: false,
      // The map runs up under the status bar; padding keeps what the camera
      // frames — the driver's marker, most of all — clear of it.
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      initialCameraPosition: const CameraPosition(
        target: LatLng(11.5564, 104.9282),
        zoom: 12,
      ),
      markers: logic.state.markers,
      polylines: logic.state.polyline,
      onMapCreated: logic.onMapCreated,
    );
  }
}
