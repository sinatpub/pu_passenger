import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingMapState {
  GoogleMapController? mapController;

  Set<Marker> markers = {};
  Set<Polyline> polyline = {};

  RequestBookingModel? bookingRequestData;

  /// How long and how far the driver's drive to the pickup is, from the
  /// route that draws the line. Null outside the accepted stage, and when
  /// the directions service did not say.
  Duration? pickupEta;
  double? pickupDistanceMeters;

  BitmapDescriptor? driverIcon;
  BitmapDescriptor? passengerIcon;
  BitmapDescriptor? destinationIcon;
}
