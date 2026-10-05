import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

/// The two ends of a trip as map markers (D34).
///
/// They are the symbols of the booking sheet's route card — a dark circle for
/// the pickup, a brand square for the drop-off — so the map and the card read
/// as one legend. Drawn here rather than loaded from an image, so they are
/// sharp on every screen density.
enum TripMarker { pickup, dropOff }

/// Edge of a trip marker's box in logical pixels, shadow included.
const double tripMarkerSize = 36;

/// Where a trip marker's point is in its box. A drawn marker sits on its
/// point; the map's default pin, which stands in while [icon] is still null,
/// stands on its tip.
Offset tripMarkerAnchor(BitmapDescriptor? icon) =>
    icon == null ? const Offset(0.5, 1.0) : const Offset(0.5, 0.5);

/// Draws [marker] centred in a [tripMarkerSize] box at the canvas origin.
void paintTripMarker(Canvas canvas, TripMarker marker) {
  const center = Offset(tripMarkerSize / 2, tripMarkerSize / 2);
  final shadow = Paint()
    ..color = const Color(0x47000000)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
  final white = Paint()..color = const Color(0xFFFFFFFF);

  switch (marker) {
    case TripMarker.pickup:
      canvas.drawCircle(center.translate(0, 1.5), 13, shadow);
      canvas.drawCircle(center, 13, white);
      canvas.drawCircle(center, 10, Paint()..color = TaColors.dark);
      canvas.drawCircle(center, 3.5, white);
    case TripMarker.dropOff:
      RRect square(double side, double radius, [Offset shift = Offset.zero]) =>
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: center + shift, width: side, height: side),
            Radius.circular(radius),
          );
      canvas.drawRRect(square(26, 8, const Offset(0, 1.5)), shadow);
      canvas.drawRRect(square(26, 8), white);
      canvas.drawRRect(square(20, 5.5), Paint()..color = TaColors.primary);
      canvas.drawRRect(square(7, 1.5), white);
  }
}

/// [marker] as PNG bytes, [pixelRatio] device pixels to the logical pixel.
Future<Uint8List> tripMarkerPng(
  TripMarker marker, {
  required double pixelRatio,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(pixelRatio);
  paintTripMarker(canvas, marker);
  final picture = recorder.endRecording();
  final side = (tripMarkerSize * pixelRatio).ceil();
  final image = await picture.toImage(side, side);
  picture.dispose();
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

/// [marker] as a map icon, drawn at this device's screen density.
Future<BitmapDescriptor> tripMarkerIcon(TripMarker marker) async {
  final views = ui.PlatformDispatcher.instance.views;
  final pixelRatio = views.isEmpty ? 1.0 : views.first.devicePixelRatio;
  return BitmapDescriptor.bytes(
    await tripMarkerPng(marker, pixelRatio: pixelRatio),
    width: tripMarkerSize,
    height: tripMarkerSize,
  );
}
