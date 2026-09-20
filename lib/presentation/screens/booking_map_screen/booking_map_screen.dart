import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:com.tara.passenger/presentation/screens/booking_map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/widgets/booking_sheet.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';

/// Screen 9 — Booking (Active Ride).
///
/// The map fills the screen with the status pill floating over it and the
/// booking sheet docked at the bottom (`03 §Screen 9`), replacing the old
/// `bottomNavigationBar` panel that squeezed the map into a `Column`.
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
        body: GetBuilder<BookingMapLogic>(builder: (logic) {
          return Stack(
            children: [
              Positioned.fill(child: _map(context, logic)),
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 0,
                right: 0,
                child: Center(
                  child: TaStatusPill(
                    text: bookingStatusText(
                      bookingPhaseFromStatus(
                        logic.state.bookingRequestData?.data?.status,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BookingSheet(logic: logic),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Camera, markers and polyline are `BookingMapLogic`'s (roadmap C5: "camera
  /// and location updates on the booking map are untouched") — this only
  /// renders them.
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
      // The sheet covers the bottom of the map, so Google's own controls are
      // off (`03 §Screen 9` shows none) and the logo is padded clear of it.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.28,
      ),
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
