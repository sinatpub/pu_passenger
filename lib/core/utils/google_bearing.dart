  import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

double calculateBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * pi / 180; // Convert to radians
    double lat2 = end.latitude * pi / 180; // Convert to radians
    double deltaLon = (end.longitude - start.longitude) * pi / 180; // Radians

    double y = sin(deltaLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon);

    double bearing = atan2(y, x) * 180 / pi; // Convert to degrees
    return (bearing + 360) % 360; // Normalize to 0-360
  }