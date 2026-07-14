import 'package:geolocator/geolocator.dart';

Future<double> trackDistance(
    Position? lastPosition, Position currentPosition) async {
  if (lastPosition != null) {
    double distance = Geolocator.distanceBetween(
      lastPosition.latitude,
      lastPosition.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    return distance;
  }

  return 0.0;
}
