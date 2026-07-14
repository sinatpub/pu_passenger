import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/logic.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../app/logic.dart';
import '../../../core/utils/app_ext.dart';
import '../../../translations/app_locale.dart';
import '../../widgets/fbtn_widget.dart';
import '../../widgets/t_image_widget.dart';
import '../../widgets/x_network_image.dart';

class BookingMapScreen extends StatelessWidget {
  BookingMapScreen({super.key});

  final BookingMapLogic bookingLogic = Get.find<BookingMapLogic>();
  final BookingMapState state = BookingMapState();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              GetBuilder<BookingMapLogic>(builder: (logic) {
                return Expanded(
                  child: GoogleMap(
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    mapType: MapType.normal,
                    myLocationEnabled: false,
                    indoorViewEnabled: true,
                    myLocationButtonEnabled: true,
                    compassEnabled: false,
                    zoomControlsEnabled: true,
                    zoomGesturesEnabled: true,
                    mapToolbarEnabled: true,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(11.5564, 104.9282),
                      zoom: 12,
                    ),
                    markers: logic.state.markers,
                    polylines: logic.state.polyline,
                    onMapCreated: logic.onMapCreated,
                  ),
                );
              })
            ],
          ),
        ),
        bottomNavigationBar: _driverInfo(),
      ),
    );
  }

  _driverInfo() {
    return GetBuilder<BookingMapLogic>(builder: (logic) {
      var data = logic.state.bookingRequestData?.data;

      return Container(
        // Allow the container to grow with content but stay within safe limits
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.d)),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10.d, spreadRadius: 1),
          ],
        ),
        child: SafeArea(
          // Ensures content isn't cut off by home indicators
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.d, 12.d, 16.d, 8.d),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Vital for BottomNavigationBar
              children: [
                // 1. Event Status Header
                GetBuilder<AppLogic>(
                  id: AppUpdate.titleEventID,
                  builder: (appLogic) {
                    return Text(
                      appLogic.titleEvent ?? AppLocale.unKnown.tr,
                      style: ThemeConstands.font14SemiBold
                          .copyWith(color: AppColors.main),
                    );
                  },
                ),
                SizedBox(height: 12.d),

                // 2. Driver Info Row
                Row(
                  children: [
                    // Overlapping Images Container
                    SizedBox(
                      width: 100.d, // Responsive width
                      height: 60.d,
                      child: Stack(
                        children: [
                          // Vehicle Image
                          Positioned(
                            left: 0,
                            child: _circleImageWrapper(
                              child: TImageWidget(
                                vehicleId: data?.typeVehicleId,
                                width: 45.d,
                              ),
                            ),
                          ),
                          // Driver Photo
                          Positioned(
                            right: 10.d,
                            child: _circleImageWrapper(
                              child: XNetworkImage(
                                src:
                                    "${data?.driver?.vehicle?.vehicleImage?[0]}",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.d),

                    // Text Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data?.driver?.name ?? AppLocale.unKnown.tr,
                            style: ThemeConstands.font16SemiBold,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            data?.typeVehicle?.name ?? "---",
                            style: ThemeConstands.font14SemiBold
                                .copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    // Call Button
                    _actionButton(
                      icon: Icons.phone,
                      color: AppColors.main,
                      onTap: () =>
                          logic.makePhoneCall(data?.driver?.phone ?? ""),
                    ),
                  ],
                ),

                SizedBox(height: 16.d),

                // 3. Conditional Cancel Button
                if (data?.status != 3)
                  SizedBox(
                    width: Get.width / 2,
                    child: FBTNWidget(
                      onPressed: () {}, // logic.cancelWaitingBooking()
                      color: AppColors.lighter,
                      textColor: AppColors.light4,
                      label: AppLocale.cancelBooking.tr,
                      width: double
                          .infinity, // Full width is easier to tap on mobile
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

// Helper for clean, circular images
  Widget _circleImageWrapper({required Widget child}) {
    return Container(
      height: 55.d,
      width: 55.d,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

// Helper for Action Buttons (Phone/Msg)
  Widget _actionButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.d),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24.d),
      ),
    );
  }
}
