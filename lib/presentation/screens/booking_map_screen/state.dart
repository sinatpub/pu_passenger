import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingMapState {
  GoogleMapController? mapController;

  Set<Marker> markers = {};
  Set<Polyline> polyline = {};

  RequestBookingModel? bookingRequestData;

  /// Audit S-7: the ride could not be loaded and there is nothing to show
  /// from before. The sheet says so and offers Retry; the poll keeps asking
  /// in the background either way.
  bool loadFailed = false;

  /// How long and how far the driver's drive to the pickup is, from the
  /// route that draws the line. Null outside the accepted stage, and when
  /// the directions service did not say.
  Duration? pickupEta;
  double? pickupDistanceMeters;

  /// The pickup's address, looked up from its coordinates because the
  /// booking came without one. Null while the booking has its own, and until
  /// the lookup answers.
  String? pickupAddress;

  BitmapDescriptor? driverIcon;
  BitmapDescriptor? passengerIcon;
  BitmapDescriptor? destinationIcon;
}
