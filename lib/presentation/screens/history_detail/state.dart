import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HistoryDetailState {
  Datum? data;
  bool isLoading = false;
  Set<Marker> markers = {};
  Set<Polyline> polyline = {};

  GoogleMapController? mapController;

  /// The pins for the two ends of the trip — the same images the booking map
  /// uses for a pickup and a drop-off.
  BitmapDescriptor? pickupIcon;
  BitmapDescriptor? dropOffIcon;
}
