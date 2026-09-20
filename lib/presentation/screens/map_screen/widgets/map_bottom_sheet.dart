import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/core/utils/vehicle_cell_data.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/state.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/widgets/detail_service_dialog.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/widgets/search_where_to_go.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// The map's bottom sheet (Screen 7 §Map): search card / pickup row, then —
/// once a destination is set — destination row, distance/fare stat row, the
/// "Add a note" field, the compact vehicle row + tariff, and Book Now.
///
/// Extracted from `MapScreen` (C3) so the sheet can be pumped directly in
/// widget tests without the GoogleMap platform view. It stays a card riding
/// above the map rather than a modal sheet, so the map remains interactive
/// while the trip is composed (roadmap C3 "drag to change pickup" kept).
class MapBottomSheet extends StatelessWidget {
  const MapBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapLogic>(
        id: MapUpdate.mapID,
        builder: (logic) {
          final hasDestination = logic.state.destinationAddress != null;
          final vehicle = logic.state.vehicleTypeSelection;

          return Container(
            decoration: BoxDecoration(
              color: TaColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              boxShadow: TaShadows.shadowLg,
            ),
            padding: EdgeInsets.fromLTRB(20.d, 12.d, 20.d, 24.d),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: TaGrabHandle()),
                    SizedBox(height: 12.d),

                    /// Where to go
                    if (!hasDestination) ...[
                      SearchWhereToGo(
                        onTap: () async {
                          // P-05 (docs/12) — backing out of the drag map pops
                          // with no result, and `updateDestinationLocation`
                          // takes a non-nullable `LatLng`, so the implicit
                          // downcast of that `null` threw
                          // "type 'Null' is not a subtype of type 'LatLng'".
                          // Cancelling the picker is a normal exit, not a
                          // destination change.
                          final result = await Get.toNamed(AppRoutes.DRAGMAP);
                          if (result is! LatLng) return;
                          logic.updateDestinationLocation(latLng: result);
                        },
                      ),
                      SizedBox(height: 12.d),
                    ],

                    /// Pickup address row
                    TaAddressRow(
                      type: TaAddressType.pickup,
                      label: AppLocale.currentLocation.tr,
                      name: logic.state.currentAddress ?? '',
                    ),

                    if (hasDestination) ...[
                      const Divider(thickness: 1, height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TaAddressRow(
                              type: TaAddressType.destination,
                              label: AppLocale.destination.tr,
                              name: logic.state.destinationAddress ?? '',
                            ),
                          ),
                          TaIconButton(
                            icon: const Icon(Icons.close),
                            semanticLabel: AppLocale.clearDestination.tr,
                            size: 36,
                            onTap: () => logic.updateDestinationLocation(
                                latLng: const LatLng(0.0, 0.0), reset: true),
                          ),
                        ],
                      ),
                      TaStatRow(
                        items: [
                          StatItem(
                            value: logic.state.distance,
                            label: AppLocale.distance.tr,
                          ),
                          StatItem(
                            value:
                                '${logic.state.totalFare.toMoneyFormat()} '
                                '${AppLocale.khmerCurrency.tr}',
                            label: AppLocale.fare.tr,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TaNoteField(
                        controller: logic.noteController,
                        hint: AppLocale.addNoteForDriver.tr,
                        onChanged: (value) => logic.state.note = value,
                      ),
                    ],

                    const Divider(thickness: 1, height: 24),

                    if (vehicle != null)
                      TaVehicleRow(
                        compact: true,
                        vehicle: vehicleCellData(vehicle),
                        onTariffTap: () =>
                            openTariffSheet(Get.context!, vehicle: vehicle),
                      )
                    else ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          AppLocale.noVehicleAvailable.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: TaColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    const SizedBox(height: 6),

                    /// Book Now (disabled until a destination is set)
                    TaButton(
                      label: AppLocale.bookingNow.tr,
                      width: double.infinity,
                      isEnabled: hasDestination,
                      onTap: () async {
                        // P-08: the loading flag is owned by MapLogic. The view
                        // no longer pre-toggles it — doing so let a double-tap
                        // clear the overlay and fire a second booking.
                        await logic.requestBooking();
                      },
                    ),

                    if (!hasDestination)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Center(
                          child: Text(
                            AppLocale.selectDestinationToContinue.tr,
                            style: const TextStyle(
                              fontSize: 12,
                              color: TaColors.textSecondary,
                            ),
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
}