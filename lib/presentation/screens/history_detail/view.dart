import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_radius.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/fee_presentation.dart';
import 'package:com.tara.passenger/core/utils/history_cell_data.dart';
import 'package:com.tara.passenger/core/utils/initials.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/history/vehicle_type_name.dart';
import 'package:com.tara.passenger/presentation/screens/history_detail/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 14 — Trip details.
///
/// One finished or cancelled trip, top to bottom: where it went, what it
/// cost, who drove what, the route in words, the record. The `Datum` arrives
/// through `Get.arguments` exactly as before, and every string comes from
/// `history_cell_data.dart`, so a card in the list and this page cannot
/// disagree.
class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaColors.background,
      body: SafeArea(
        child: GetBuilder<HistoryDetailLogic>(
          builder: (logic) {
            final data = logic.state.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      TaIconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        semanticLabel: AppLocale.back.tr,
                        onTap: Get.back,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocale.tripDetails.tr,
                          style:
                              TaTextStyles.titleLarge.copyWith(fontSize: 17),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const HistoryDetailMap(),
                        const SizedBox(height: 16),
                        HistoryDetailCard(
                          data: data,
                          vehicleName: currentVehicleTypeName(
                              data?.driver?.vehicle?.typeVehicleId),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: TaButton(
                    label: AppLocale.bookAgain.tr,
                    onTap: logic.bookAgain,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The route preview: a still picture of the trip, not a map to explore. It
/// takes no touches, so a finger that lands on it scrolls the page — the
/// pannable map it replaced swallowed the scroll. Camera, pins and line are
/// `HistoryDetailLogic`'s; this only frames and clips them.
class HistoryDetailMap extends StatelessWidget {
  const HistoryDetailMap({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HistoryDetailLogic>(builder: (logic) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TaRadius.radiusLg),
          border: Border.all(color: TaColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: IgnorePointer(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              // Phnom Penh until the trip's own points frame the camera.
              target: logic.pickup ?? const LatLng(11.5564, 104.9282),
              zoom: 15,
            ),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            scrollGesturesEnabled: false,
            zoomGesturesEnabled: false,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            indoorViewEnabled: false,
            mapType: MapType.normal,
            markers: logic.state.markers,
            polylines: logic.state.polyline,
            onMapCreated: logic.onMapCreated,
          ),
        ),
      );
    });
  }
}

/// Everything under the map: the fare or the cancellation, the driver and
/// car, the route in words, and the record.
class HistoryDetailCard extends StatelessWidget {
  const HistoryDetailCard({super.key, required this.data, this.vehicleName});

  final Datum? data;

  /// The trip's vehicle type under the name the app uses for it today. The
  /// record's own name is used when this is null.
  final String? vehicleName;

  @override
  Widget build(BuildContext context) {
    final completed = isCompletedHistory(data?.status);
    final hasDriver = data?.driver != null;
    final invoice = data?.payment?.invoiceId;
    final distance =
        completed ? historyDistanceShort(data?.payment?.distance) : null;
    final duration =
        completed ? historyDurationShort(data?.payment?.duration) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _outcome(completed),
        const SizedBox(height: 16),
        if (hasDriver) ...[
          TaDriverCard(
            bordered: true,
            name: data?.driver?.name ?? AppLocale.unKnown.tr,
            initials: initialsFromName(data?.driver?.name),
            vehicleInfo: historyVehicleInfo(data, vehicleName: vehicleName),

            /// The plate is what a passenger needs to describe the car after
            /// the trip — a lost item, a complaint.
            plateNumber: feeOptionalValue(data?.driver?.vehicle?.plateNumber),
          ),
          const SizedBox(height: 10),
        ],
        TaTripCard(
          pickupLabel: AppLocale.pickup.tr,
          pickup: feeDisplayValue(data?.startAddress),
          dropOffLabel: AppLocale.destination.tr,
          dropOff: historyDestination(data?.endAddress),

          /// A completed trip with no drop-off was booked by meter. A
          /// cancelled one simply never had one, and the row is dropped
          /// (roadmap S1 Risk).
          noDropOffText: completed ? AppLocale.noDropOffMeter.tr : null,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: TaColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TaColors.border),
          ),
          child: Column(
            children: [
              TaKVRow(
                label: AppLocale.dateTime.tr,
                value: historyDate(data?.createdAt),
              ),
              if (distance != null)
                TaKVRow(label: AppLocale.distance.tr, value: distance),
              if (duration != null)
                TaKVRow(label: AppLocale.duration.tr, value: duration),
              if (invoice != null)
                TaKVRow(
                  label: AppLocale.invoice.tr,
                  value: historyInvoice(invoice),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// What the trip came to: the fare, marked paid — or, for a cancelled trip,
  /// that it was cancelled and cost nothing.
  Widget _outcome(bool completed) {
    final amount = feeAmount(data?.payment?.amount);
    final charged = historyWasCharged(data?.payment?.amount);

    if (!completed) {
      return Column(
        children: [
          /// A cancelled trip the record did charge for shows that charge:
          /// the page does not say "no fare" over an amount.
          if (charged && amount != null) ...[
            _amount(amount),
            const SizedBox(height: 8),
          ],
          TaBadge(
            label: AppLocale.cancelled.tr,
            variant: TaBadgeVariant.error,
          ),
          if (!charged) ...[
            const SizedBox(height: 8),
            Text(
              AppLocale.noFareCharged.tr,
              textAlign: TextAlign.center,
              style: TaTextStyles.bodyMedium
                  .copyWith(color: TaColors.textSecondary),
            ),
          ],
        ],
      );
    }

    /// Money fails loudly: a completed trip whose fare the backend did not
    /// send, or sent unparseably, says so — and is not called "Paid".
    if (amount == null) {
      return Text(
        AppLocale.fareUnavailable.tr,
        textAlign: TextAlign.center,
        style: TaTextStyles.bodyMedium.copyWith(color: TaColors.error),
      );
    }
    return Column(
      children: [
        _amount(amount),
        const SizedBox(height: 8),
        TaBadge(
          label: historyPaidLabel(data?.payment?.paymentMethod),
          icon: const Icon(Icons.check_circle),
        ),
      ],
    );
  }

  Widget _amount(String amount) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        amount,
        maxLines: 1,
        style: TaTextStyles.displayLarge.copyWith(
          fontSize: 36,
          color: TaColors.textPrimary,
        ),
      ),
    );
  }
}
