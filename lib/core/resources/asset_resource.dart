// ignore_for_file: constant_identifier_names
const String IMAGE_SVG_PATH = "assets/image/svg";
const String MARKER_PATH = "assets/marker";

class ImageAssets {
  /// The PU Taxi mark: the launcher icon, reused wherever the app shows its
  /// own logo.
  static const String brandMark =
      'assets/launcher/launcher_passenger_1024.png';

  /// Service art, one per vehicle type — see `vehicle_art.dart`.
  static const String vehicleTukTuk = '$IMAGE_SVG_PATH/vehicle_tuk_tuk.svg';
  static const String vehicleMoto = '$IMAGE_SVG_PATH/vehicle_moto.svg';
  static const String vehicleClassic = '$IMAGE_SVG_PATH/vehicle_classic.svg';
  static const String vehicleMiniVan = '$IMAGE_SVG_PATH/vehicle_mini_van.svg';
  static const String vehicleSuv = '$IMAGE_SVG_PATH/vehicle_suv.svg';
  static const String vehicleVip = '$IMAGE_SVG_PATH/vehicle_vip.svg';

  static const String currentMarker = "$MARKER_PATH/current_marker.svg";
  static const passengerIconMarker = "$MARKER_PATH/passenger_icon_marker.png";

  /// Driver markers, one per vehicle type — see `vehicle_art.dart`. The same
  /// family as pu_driver's (its DD-60): top-down, nose up, 120x200 PNGs
  /// exported from their sources in `docs/markers/`.
  static const String motorMarker = "$MARKER_PATH/vehicle_motor.png";
  static const String tukTukMarker = "$MARKER_PATH/vehicle_tuk_tuk.png";
  static const String classicCarMarker = "$MARKER_PATH/vehicle_classic_car.png";
  static const String miniVanMarker = "$MARKER_PATH/vehicle_mini_van.png";
  static const String suvMarker = "$MARKER_PATH/vehicle_suv.png";
  static const String alphardVipMarker = "$MARKER_PATH/vehicle_alphard_vip.png";
}
