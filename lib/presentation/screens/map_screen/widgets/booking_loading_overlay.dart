import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/presentation/screens/map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/map_presentation.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/state.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// C3 — the booking overlay (05 §Loading States, D14): an opaque sheet that
/// covers the map while "Contacting nearby drivers…" with the chosen vehicle
/// and how far the nearest driver is, plus a cancel button.
///
/// Extracted from `MapScreen` so it can be pumped directly in widget tests
/// without the GoogleMap platform view.
class BookingLoadingOverlay extends StatelessWidget {
  const BookingLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapLogic>(
        id: MapUpdate.bookingID,
        builder: (logic) {
          if (logic.state.isBookingLoading == false) {
            return const SizedBox.shrink();
          }

          // D14 / 05 §Loading States — "Contacting nearby drivers…" plus the
          // chosen vehicle and how far the nearest driver is.
          final vehicle = logic.state.vehicleTypeSelection;
          final nearest = nearestDriverDistanceKm(
            from: logic.state.currentLatLng,
            drivers: logic.state.driverAroundData?.data,
          );
          final subtitle = nearest == null
              ? (vehicle?.name ?? '')
              : '${vehicle?.name ?? ''} · ${nearest.toStringAsFixed(1)} '
                  '${AppLocale.kmAway.tr}';

          return Positioned.fill(
            child: TaLoadingOverlay(
              title: AppLocale.contactingDrivers.tr,
              subtitle: subtitle,
              onCancel: logic.cancelBooking,
            ),
          );
        });
  }
}