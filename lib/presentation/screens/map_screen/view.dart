import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/widgets/search_where_to_go.dart';
import 'package:com.tara.passenger/presentation/widgets/fbtn_widget.dart';
import 'package:com.tara.passenger/presentation/widgets/t_image_widget.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'state.dart';
import 'widgets/detail_service_dialog.dart';
import 'widgets/map_appbar.dart';

class MapScreen extends StatelessWidget {
  MapScreen({super.key});

  final logic = Get.find<MapLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<MapLogic>(
          id: MapUpdate.mapID,
          builder: (logic) {
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
                          ...[
                            if (logic.state.destinationLatLng == null)
                              _currentPinMarkerLocation(),
                          ],
                        ],
                      ),
                    ),
                    _buildBottomSheet(),
                  ],
                ),
                requestBookingLoading(context),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              ImageAssets.currentMarker,
              width: 60..d,
              height: 60..d,
            )
          ],
        ),
      ),
    );
  }

  _buildBottomSheet() {
    return GetBuilder<MapLogic>(
        id: MapUpdate.mapID,
        builder: (logic) {
          double height =
              logic.state.destinationAddress != null ? 350.d : 330.d;

          return Container(
            height: height,
            color: Colors.white,
            padding: EdgeInsetsGeometry.all(12.d),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Where to go
                ...[
                  if (logic.state.destinationAddress == null)
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
                    )
                ],

                SizedBox(
                  height: 8.d,
                ),

                /// Current Location Address
                _currentAddress(),
                SizedBox(
                  height: 8.d,
                ),
                ...[
                  if (logic.state.destinationAddress != null)
                    Column(
                      children: [
                        const Divider(
                          thickness: .1,
                        ),
                        _whereToGoAddress(),
                        const Divider(
                          thickness: .1,
                        ),
                        // Distance X Fare
                        Row(
                          children: [
                            Text(
                              "${AppLocale.distance.tr} : ",
                              style: ThemeConstands.font14Regular,
                            ),
                            Text(
                              logic.state.distance,
                              style: ThemeConstands.font10SemiBold,
                            ),
                            Text(
                              " , ${AppLocale.fare.tr} : ",
                              style: ThemeConstands.font14Regular,
                            ),
                            Text(
                              "${logic.state.totalFare.toMoneyFormat()} ${AppLocale.khmerCurrency.tr}",
                              style: ThemeConstands.font10SemiBold,
                            ),
                          ],
                        ),
                        const Divider(
                          thickness: .1,
                        ),
                      ],
                    )
                ],

                // Vehicle Type
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.vehicleType.tr,
                      style: ThemeConstands.font12SemiBold,
                    ),
                    SizedBox(
                      height: 60.d,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            spacing: 8.d,
                            children: [
                              TImageWidget(
                                vehicleId: logic.state.vehicleTypeSelection?.id,
                                width: 68.d,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      logic.state.vehicleTypeSelection?.name ??
                                          "",
                                      style: ThemeConstands.font14SemiBold),
                                  Text(
                                    logic.getVehicleSet(),
                                    style: ThemeConstands.font14Regular
                                        .copyWith(color: Colors.grey),
                                  ),
                                ],
                              )
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                isDismissible: true,
                                context: Get.context!,
                                builder: (context) {
                                  return DetailServiceDialog(
                                      data: logic.state.vehicleTypeSelection);
                                },
                              );
                            },
                            child: Container(
                              height: 28..d,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: AppColors.main,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                AppLocale.tarrif.tr,
                                style: ThemeConstands.font14Regular
                                    .copyWith(color: AppColors.light4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                FBTNWidget(
                    onPressed: () async {
                      // P-08: the loading flag is owned by MapLogic. The view
                      // no longer pre-toggles it — doing so let a double-tap
                      // clear the overlay and fire a second booking.
                      await logic.requestBooking();
                    },
                    color: AppColors.main,
                    textColor: AppColors.light4,
                    label: AppLocale.bookingNow.tr,
                    width: Get.width / 2),
              ],
            ),
          );
        });
  }

  _currentAddress() {
    return Row(
      spacing: 8.d,
      children: [
        Image.asset(
          ImageAssets.passengerMarker,
          scale: 1.5,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocale.currentLocation.tr,
                style: ThemeConstands.font12Regular,
              ),
              Text(
                logic.state.currentAddress ?? "",
                style: ThemeConstands.font10SemiBold,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
      ],
    );
  }

  _whereToGoAddress() {
    return Row(
      spacing: 8.d,
      children: [
        Image.asset(
          ImageAssets.destinationMarker,
          scale: 1.5,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocale.whereToGo.tr,
                style: ThemeConstands.font12Regular,
              ),
              Text(
                logic.state.destinationAddress ?? "",
                style: ThemeConstands.font10SemiBold,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            logic.updateDestinationLocation(
                latLng: const LatLng(0.0, 0.0), reset: true);
          },
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(
              Icons.delete,
              size: 22,
              color: AppColors.main,
            ),
          ),
        ),
      ],
    );
  }

  _currentLocation() {
    return Positioned(
      bottom: 20.d,
      right: 20.d,
      child: InkWell(
        onTap: () {
          logic.moveToCurrentLocation();
        },
        child: Container(
          width: 38.d,
          height: 38.d,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.main,
          ),
          child: const Icon(
            Icons.my_location,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget requestBookingLoading(BuildContext context) {
    return GetBuilder<MapLogic>(
        id: MapUpdate.bookingID,
        builder: (logic) {
          if (logic.state.isBookingLoading == false) {
            return const SizedBox.shrink();
          }

          return Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white.withValues(alpha: .6),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 4.5,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          height: 80,
                          width: 80,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.main),
                            strokeWidth: 1,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        Container(
                          width: 75.d,
                          height: 75.d,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.car_crash,
                            // Icon inside the loading indicator
                            color: AppColors.main, // Icon color
                            size: 40, // Icon size
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  // P-08: restored. While this was commented out, every
                  // stuck-overlay path was unrecoverable without killing the
                  // app. cancelBooking() drops the overlay before calling the
                  // API so a failing cancel cannot strand the passenger.
                  SizedBox(
                    width: Get.width / 2,
                    child: FBTNWidget(
                      label: AppLocale.cancel.tr,
                      onPressed: () async => logic.cancelBooking(),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
