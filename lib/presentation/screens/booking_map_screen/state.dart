import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingMapState {
  GoogleMapController? mapController;

  Set<Marker> markers = {};
  Set<Polyline> polyline = {};

  RequestBookingModel? bookingRequestData;

  BitmapDescriptor? driverIcon;
  BitmapDescriptor? passengerIcon;
  BitmapDescriptor? destinationIcon;
}
