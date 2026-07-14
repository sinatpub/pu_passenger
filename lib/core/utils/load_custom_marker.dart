import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

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
