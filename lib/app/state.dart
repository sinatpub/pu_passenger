import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapState {
  Rx<double> latitude = 0.0.obs;
  Rx<double> longtitude = 0.0.obs;

  Rx<String?> addressOfPassenger = Rx<String?>(null);
  Rx<String?> addressOfDriver = Rx<String?>(null);

  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;

  BitmapDescriptor? passengerMarker;

  BitmapDescriptor? driverMarker;

  BitmapDescriptor? destinationBitmap;
  BitmapDescriptor? currentBitmap;

  BitmapDescriptor? classicBitMap;
  BitmapDescriptor? alphardVipBitMap;
  BitmapDescriptor? miniVanBitMap;
  BitmapDescriptor? suvBitMap;
}
