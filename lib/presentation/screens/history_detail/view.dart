import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_radius.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/history_cell_data.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/history_detail/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 14 — History Detail.
///
/// Same arguments and same formatters as the list (roadmap S1 Done When): the
/// `Datum` arrives through `Get.arguments` exactly as before, and every string
/// comes from `history_cell_data.dart`, so a card and its detail screen cannot
/// disagree. `HistoryDetailLogic` — the marker/polyline work — is untouched.
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

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      TaIconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    semanticLabel: AppLocale.back.tr,
                        onTap: Get.back,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          historyInvoice(data?.payment?.invoiceId),
                          style:
                              TaTextStyles.titleLarge.copyWith(fontSize: 17),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const HistoryDetailMap(),
                  const SizedBox(height: 12),
                  HistoryDetailCard(data: data),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The 200px route preview. Camera, markers and polyline stay
/// `HistoryDetailLogic`'s — this only frames and clips them.
class HistoryDetailMap extends StatelessWidget {
  const HistoryDetailMap({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HistoryDetailLogic>(builder: (logic) {
      final startLat =
          double.tryParse('${logic.state.data?.startLatitude}') ?? 0.0;
      final startLng =
          double.tryParse('${logic.state.data?.startLongitude}') ?? 0.0;

      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TaRadius.radiusLg),
          boxShadow: TaShadows.shadowMd,
        ),
        clipBehavior: Clip.antiAlias,
        child: GoogleMap(
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(startLat, startLng),
            zoom: 16,
          ),
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: true,
          indoorViewEnabled: false,
          mapType: MapType.normal,
          markers: logic.state.markers.toSet(),
          polylines: logic.state.polyline.toSet(),
          onMapCreated: (controller) => logic.drawPolyline(),
        ),
      );
    });
  }
}

/// Driver row, status badge and the trip's key/value rows.
class HistoryDetailCard extends StatelessWidget {
  const HistoryDetailCard({super.key, required this.data});

  final Datum? data;

  @override
  Widget build(BuildContext context) {
    final item = historyCellData(data);
    final method = data?.payment?.paymentMethod?.toString().trim();

    return TaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TaAvatar(
                variant: TaAvatarVariant.history,
                initials: item.initials,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.invoice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: TaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.driver} · ${item.date}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: TaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: TaColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TaBadge(
              label: historyStatusLabel(data?.status),
              variant: isCompletedHistory(data?.status)
                  ? TaBadgeVariant.success
                  : TaBadgeVariant.error,
            ),
          ),
          const SizedBox(height: 6),
          TaKVRow(label: AppLocale.distance.tr, value: item.distance),
          TaKVRow(label: AppLocale.duration.tr, value: item.duration),
          if (method != null && method.isNotEmpty && method != 'null')
            TaKVRow(label: method, value: AppLocale.paid.tr),
          const SizedBox(height: 10),
          const Divider(height: 1, color: TaColors.border),
          const SizedBox(height: 12),
          TaAddressRow(
            type: TaAddressType.pickup,
            label: AppLocale.pickup.tr,
            name: item.from,
          ),

          /// A cancelled trip often has no destination; the row is dropped
          /// rather than printing "Unknown" as if one had been chosen
          /// (roadmap S1 Risk).
          if (item.to != null) ...[
            const SizedBox(height: 10),
            TaAddressRow(
              type: TaAddressType.destination,
              label: AppLocale.destination.tr,
              name: item.to!,
            ),
          ],
        ],
      ),
    );
  }
}
