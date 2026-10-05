import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/utils/trip_marker.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// D34 — the trip's two ends are drawn, not loaded: a dark circle for the
/// pickup and a brand square for the drop-off, the symbols of the route card.
void main() {
  /// Decodes [png] and reads the colour of the logical pixel at ([x], [y]).
  Future<({int side, Color Function(double x, double y) at})> decode(
    Uint8List png,
    double pixelRatio,
  ) async {
    final codec = await ui.instantiateImageCodec(png);
    final image = (await codec.getNextFrame()).image;
    final rgba = (await image.toByteData())!;
    final side = image.width;
    expect(image.height, side);
    Color at(double x, double y) {
      final i = (((y * pixelRatio).floor() * side) + (x * pixelRatio).floor()) * 4;
      return Color.fromARGB(rgba.getUint8(i + 3), rgba.getUint8(i),
          rgba.getUint8(i + 1), rgba.getUint8(i + 2));
    }

    return (side: side, at: at);
  }

  const mid = tripMarkerSize / 2;

  testWidgets('is drawn at the screen density it is asked for',
      (tester) async {
    await tester.runAsync(() async {
      for (final ratio in [1.0, 2.0, 3.0]) {
        final png = await tripMarkerPng(TripMarker.pickup, pixelRatio: ratio);
        expect((await decode(png, ratio)).side, tripMarkerSize * ratio);
      }
    });
  });

  testWidgets('pickup is a dark circle: white ring, white centre, clear '
      'corners', (tester) async {
    await tester.runAsync(() async {
      final image = await decode(
          await tripMarkerPng(TripMarker.pickup, pixelRatio: 2), 2);
      expect(image.at(mid, mid), const Color(0xFFFFFFFF));
      expect(image.at(mid + 7, mid), TaColors.dark);
      expect(image.at(mid + 11.5, mid), const Color(0xFFFFFFFF));
      // A circle leaves the corner of its bounding square empty.
      expect(image.at(mid + 11.5, mid - 11.5).a, lessThan(0.5));
    });
  });

  testWidgets('drop-off is a brand square: its corner is filled',
      (tester) async {
    await tester.runAsync(() async {
      final image = await decode(
          await tripMarkerPng(TripMarker.dropOff, pixelRatio: 2), 2);
      expect(image.at(mid, mid), const Color(0xFFFFFFFF));
      expect(image.at(mid + 7, mid), TaColors.primary);
      expect(image.at(mid + 11.5, mid), const Color(0xFFFFFFFF));
      expect(image.at(mid + 7, mid - 7), TaColors.primary);
    });
  });

  test('a drawn marker sits on its point; the stand-in default pin stands on '
      'its tip', () {
    expect(tripMarkerAnchor(null), const Offset(0.5, 1.0));
    expect(tripMarkerAnchor(BitmapDescriptor.defaultMarker),
        const Offset(0.5, 0.5));
  });
}
