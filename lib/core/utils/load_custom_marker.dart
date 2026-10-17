import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:com.tara.passenger/core/utils/vehicle_art.dart';
import 'package:com.tara.passenger/core/utils/vehicle_kind.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

/// The box a driver marker is drawn in, in logical pixels. Every driver
/// marker image is this 3:5 shape, so none is stretched, and the vehicle is
/// centred in it, so `rotation: heading` with `anchor: Offset(0.5, 0.5)`
/// turns it about its middle. The same box as pu_driver's own marker.
const ui.Size driverMarkerSize = ui.Size(30, 50);

/// The map icon for a driver of [kind]. The image is 4x [driverMarkerSize]
/// and is handed over whole, so it stays sharp on every screen density.
Future<BitmapDescriptor> driverMarkerIcon(VehicleKind? kind) async =>
    BitmapDescriptor.bytes(
      await loadImageFromAssets(driverMarkerAsset(kind)),
      width: driverMarkerSize.width,
      height: driverMarkerSize.height,
    );

Future<Uint8List> loadImageFromAssets(String assetPath) async {
  try {
    final ByteData byteData = await rootBundle.load(assetPath);

    // Must create a mutable copy
    final bytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
    return Uint8List.fromList(bytes);
  } catch (e) {
    xPrettyLog(message: "LoadImage to marker fail: $e");
    rethrow;
  }
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}
