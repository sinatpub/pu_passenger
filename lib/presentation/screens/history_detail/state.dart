import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HistoryDetailState {
  Datum? data;
  bool isLoading = false;
  Set<Marker> markers = {};
  Set<Polyline> polyline = {};
  BitmapDescriptor? driverBitMarker;
}
