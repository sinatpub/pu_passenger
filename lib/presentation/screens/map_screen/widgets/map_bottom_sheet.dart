import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_radius.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/core/utils/vehicle_cell_data.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/state.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/widgets/detail_service_dialog.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// The map's bottom sheet (Screen 7 §Map): one route card (pickup and an
/// optional drop-off), the vehicle chips, the driver note, and Book.
///
/// **A destination is optional.** Without one the booking is metered: the
/// chips show each vehicle's minimum fare and the button is live. With one,
/// the chips show the estimate for the route and the button carries the fare.
///
/// Extracted from `MapScreen` (C3) so the sheet can be pumped directly in
/// widget tests without the GoogleMap platform view. It stays a card riding
/// above the map rather than a modal sheet, so the map remains interactive
/// while the trip is composed (roadmap C3 "drag to change pickup" kept).
class MapBottomSheet extends StatelessWidget {
  const MapBottomSheet({super.key, this.maxHeight});

  /// The most the whole sheet may take: the screen's body height, which
  /// shrinks while the keyboard is up. `Scaffold` strips the keyboard inset
  /// from its body's `MediaQuery`, so the screen measures it and passes it in.
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapLogic>(
        id: MapUpdate.mapID,
        builder: (logic) {
          final hasDestination = logic.state.destinationAddress != null;
          final vehicle = logic.state.vehicleTypeSelection;

          // `paddingOf` drops to zero while the keyboard is up, so the home
          // indicator inset only applies when it is actually exposed.
          // No grab handle: the sheet does not drag, so it does not offer to.
          final padding = EdgeInsets.fromLTRB(
            20.d,
            20.d,
            20.d,
            24.d + MediaQuery.paddingOf(context).bottom,
          );
          // Spec cap is 55% of the screen. With the keyboard up (the note
          // field) the body shrinks, so the sheet also must fit what is left.
          final maxContentHeight = math.max(
            0.0,
            math.min(
              MediaQuery.sizeOf(context).height * 0.55,
              (maxHeight ?? double.infinity) - padding.vertical,
            ),
          );

          return Container(
            decoration: BoxDecoration(
              color: TaColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(TaRadius.radiusXxl),
              ),
              boxShadow: TaShadows.shadowLg,
            ),
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxContentHeight),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RouteCard(logic: logic),
                    if (hasDestination) ...[
                      SizedBox(height: 8.d),
                      TaNoteField(
                        controller: logic.noteController,
                        hint: AppLocale.addNoteForDriver.tr,
                        onChanged: (value) => logic.state.note = value,
                      ),
                    ],
                    SizedBox(height: 12.d),
                    if (vehicle != null) ...[
                      _VehicleChips(logic: logic),
                      SizedBox(height: 8.d),
                      _VehicleCaption(
                        logic: logic,
                        vehicle: vehicle,
                        onTariffTap: () =>
                            openTariffSheet(context, vehicle: vehicle),
                      ),
                    ] else
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.d),
                          child: Text(
                            AppLocale.noVehicleAvailable.tr,
                            style: TaTextStyles.bodySmall
                                .copyWith(color: TaColors.textSecondary),
                          ),
                        ),
                      ),
                    SizedBox(height: 12.d),

                    /// Book — live without a destination; only a missing
                    /// vehicle type disables it.
                    TaButton(
                      label: _bookLabel(logic, vehicle),
                      width: double.infinity,
                      isEnabled: vehicle != null,
                      onTap: () async {
                        // P-08: the loading flag is owned by MapLogic. The view
                        // no longer pre-toggles it — doing so let a double-tap
                        // clear the overlay and fire a second booking.
                        await logic.requestBooking();
                      },
                    ),

                    if (!hasDestination)
                      Padding(
                        padding: EdgeInsets.only(top: 8.d),
                        child: Center(
                          child: Text(
                            AppLocale.fareByMeterHint.tr,
                            textAlign: TextAlign.center,
                            style: TaTextStyles.bodySmall
                                .copyWith(color: TaColors.textSecondary),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  /// "Book Tuk Tuk", plus the estimate once there is a route to price.
  static String _bookLabel(MapLogic logic, SingleVehical? vehicle) {
    if (vehicle == null) return AppLocale.bookingNow.tr;
    final label =
        AppLocale.bookVehicle.trParams({'name': vehicle.name});
    final fare = logic.fareFor(vehicle);
    if (fare == null) return label;
    return '$label · ${fare.toMoneyFormat()} ${AppLocale.khmerCurrency.tr}';
  }
}

/// Pickup and drop-off in one bordered card. The drop-off row is a button
/// that opens the picker until a destination exists, then shows it with a
/// clear control.
class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.logic});

  final MapLogic logic;

  @override
  Widget build(BuildContext context) {
    final state = logic.state;
    final hasDestination = state.destinationAddress != null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.d, vertical: 6.d),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TaRadius.radiusLg),
        border: Border.all(color: TaColors.border),
      ),
      child: Column(
        children: [
          _pickupRow(),
          Divider(color: TaColors.border, height: 1, indent: 24.d),
          if (hasDestination)
            _destinationRow()
          else
            _addDropOffRow(),
        ],
      ),
    );
  }

  Widget _pickupRow() {
    final failed = logic.state.addressFailed;
    final row = Padding(
      padding: EdgeInsets.symmetric(vertical: 10.d),
      child: Row(
        children: [
          const _RouteMarker(color: TaColors.dark, round: true),
          SizedBox(width: 12.d),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocale.currentLocation.tr, style: _labelStyle),
                SizedBox(height: 1.d),
                Text(
                  failed
                      ? AppLocale.cantFindAddress.tr
                      : (logic.state.currentAddress ?? ''),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _nameStyle.copyWith(
                    color: failed ? TaColors.textSecondary : null,
                    fontWeight: failed ? FontWeight.w500 : null,
                  ),
                ),
              ],
            ),
          ),
          if (failed)
            const Icon(Icons.refresh, size: 18, color: TaColors.primary),
        ],
      ),
    );
    if (!failed) return row;
    return TaPressable(onTap: logic.getCurrentAddress, child: row);
  }

  Widget _destinationRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.d),
      child: Row(
        children: [
          const _RouteMarker(color: TaColors.primary, round: false),
          SizedBox(width: 12.d),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocale.destination.tr, style: _labelStyle),
                SizedBox(height: 1.d),
                Text(
                  logic.state.destinationAddress ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _nameStyle,
                ),
              ],
            ),
          ),
          TaIconButton(
            icon: const Icon(Icons.close),
            semanticLabel: AppLocale.clearDestination.tr,
            size: 32,
            onTap: () => logic.updateDestinationLocation(
                latLng: const LatLng(0.0, 0.0), reset: true),
          ),
        ],
      ),
    );
  }

  Widget _addDropOffRow() {
    return TaPressable(
      onTap: () async {
        // P-05 (docs/12) — backing out of the drag map pops with no result,
        // and `updateDestinationLocation` takes a non-nullable `LatLng`, so
        // the implicit downcast of that `null` threw "type 'Null' is not a
        // subtype of type 'LatLng'". Cancelling the picker is a normal exit,
        // not a destination change.
        final result = await Get.toNamed(AppRoutes.DRAGMAP);
        if (result is! LatLng) return;
        logic.updateDestinationLocation(latLng: result);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.d),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18, color: TaColors.primary),
            SizedBox(width: 10.d),
            Expanded(
              child: Text(
                AppLocale.addDropOff.tr,
                style: _nameStyle.copyWith(color: TaColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _labelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: TaColors.textMuted,
  );

  static const _nameStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: TaColors.textPrimary,
  );
}

class _RouteMarker extends StatelessWidget {
  const _RouteMarker({required this.color, required this.round});

  final Color color;
  final bool round;

  @override
  Widget build(BuildContext context) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: round ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: round ? null : BorderRadius.circular(3),
        ),
      );
}

/// One chip per vehicle type with its fare: the route estimate once there is
/// a destination, the minimum fare before.
class _VehicleChips extends StatelessWidget {
  const _VehicleChips({required this.logic});

  final MapLogic logic;

  @override
  Widget build(BuildContext context) {
    final vehicles = logic.vehicles;
    final selectedId = logic.state.vehicleTypeSelection?.id;
    if (vehicles.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 62.d,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: vehicles.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.d),
        itemBuilder: (context, i) {
          final v = vehicles[i];
          final selected = v.id == selectedId;
          final fare = logic.fareFor(v);
          final currency = AppLocale.khmerCurrency.tr;
          final fareText = fare != null
              ? '${fare.toMoneyFormat()} $currency'
              : v.miniMunFare == null
                  ? '—'
                  : 'from ${v.miniMunFare!.toMoneyFormat()} $currency';
          return TaPressable(
            onTap: () => logic.selectVehicle(v),
            child: Container(
              constraints: BoxConstraints(minWidth: 96.d),
              padding: EdgeInsets.symmetric(horizontal: 12.d, vertical: 8.d),
              decoration: BoxDecoration(
                color: selected ? TaColors.primaryBg : TaColors.surface,
                borderRadius: BorderRadius.circular(TaRadius.radiusMd),
                border: Border.all(
                  color: selected ? TaColors.primary : TaColors.border,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: TaColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.d),
                  Text(
                    fareText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? TaColors.primaryDark
                          : TaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// "6.2 km · 4 Seats · ~3 min" for the chosen vehicle, with the Tariff link.
class _VehicleCaption extends StatelessWidget {
  const _VehicleCaption({
    required this.logic,
    required this.vehicle,
    required this.onTariffTap,
  });

  final MapLogic logic;
  final SingleVehical vehicle;
  final VoidCallback onTariffTap;

  @override
  Widget build(BuildContext context) {
    final data = vehicleCellData(vehicle);
    final distance = logic.state.distance;
    return Row(
      children: [
        Expanded(
          child: Text(
            [if (distance.isNotEmpty) distance, data.seats, data.eta]
                .join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TaTextStyles.bodySmall
                .copyWith(color: TaColors.textSecondary),
          ),
        ),
        TaPressable(
          onTap: onTariffTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.d, vertical: 7.d),
            decoration: BoxDecoration(
              color: TaColors.primaryBg,
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'Tariff',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: TaColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
