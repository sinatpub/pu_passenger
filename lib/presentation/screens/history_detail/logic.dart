import 'dart:typed_data';
import 'package:com.tara.passenger/app/google_map_logic.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/resources/asset_resource.dart';
import '../../../core/utils/load_custom_marker.dart';
import 'state.dart';

class HistoryDetailLogic extends GetxController {
  final HistoryDetailState state = HistoryDetailState();

  @override
  void onInit() async {
    super.onInit();
    checkRegisteredMapLogic();
    state.data = Get.arguments;
    await loadMarker();

    update();
  }

  checkRegisteredMapLogic() {
    if (!Get.isRegistered<GoogleMapLogic>()) {
      Get.put<GoogleMapLogic>(GoogleMapLogic());
    }
  }

  Future<void> loadMarker() async {
    final Uint8List markerDriverImage = await loadImageFromAssets(
        driverMarkerImage(vehicleTypeId: state.data?.driver?.vehicle?.id ?? 0));
    state.driverBitMarker =
        BitmapDescriptor.bytes(markerDriverImage, width: 24.d);
  }

  drawPolyline() async {
    var data = state.data;
    final startLatLng = LatLng(double.parse(data?.startLatitude ?? "0.0"),
        double.parse(data?.startLongitude ?? "0.0"));
    final endLatLng = LatLng(double.parse(data?.endLatitude ?? "0.0"),
        double.parse(data?.endLongitude ?? "0.0"));
    final mapLogic = Get.find<GoogleMapLogic>();
    state.polyline = (await mapLogic.drawPolylineWithReturnValue(
        startLatLng: startLatLng, endLatLng: endLatLng))!;
    await displayMarker(start: startLatLng, end: endLatLng);
    update();
  }

  Future<void> displayMarker(
      {required LatLng start, required LatLng end}) async {
    final mapLogic = Get.find<GoogleMapLogic>();
    state.markers.add(
      Marker(
        markerId: const MarkerId("123"),
        position: start,
        consumeTapEvents: true,
        icon: state.driverBitMarker ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: AppLocale.driver.tr),
      ),
    );

    state.markers.add(
      Marker(
        markerId: const MarkerId("1234"),
        consumeTapEvents: true,
        position: end,
        icon: mapLogic.parentState.passengerMarker ??
            BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: AppLocale.passenger.tr),
      ),
    );
    update();
  }

  String driverMarkerImage({int? vehicleTypeId}) {
    var vehicleType = state.data?.driver?.vehicle;
    switch (vehicleType?.id ?? vehicleTypeId) {
      case 1:
        return ImageAssets.rickshawMarker;
      case 2:
        return ImageAssets.classicCarMarker;
      case 3:
        return ImageAssets.minVanCarMarker;
      case 4:
        return ImageAssets.suvCarMarker;
      case 5:
        return ImageAssets.alphardVipCarMarker;
      default:
        return ImageAssets.rickshawMarker;
    }
  }
}
