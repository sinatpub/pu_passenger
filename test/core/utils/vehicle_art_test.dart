import 'dart:io';
import 'dart:typed_data';

import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/utils/load_custom_marker.dart';
import 'package:com.tara.passenger/core/utils/vehicle_art.dart';
import 'package:com.tara.passenger/core/utils/vehicle_kind.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const arts = {
    VehicleKind.moto: ImageAssets.vehicleMoto,
    VehicleKind.tukTuk: ImageAssets.vehicleTukTuk,
    VehicleKind.car: ImageAssets.vehicleClassic,
    VehicleKind.miniVan: ImageAssets.vehicleMiniVan,
    VehicleKind.suv: ImageAssets.vehicleSuv,
    VehicleKind.vip: ImageAssets.vehicleVip,
  };

  group('vehicleArtAsset', () {
    test('each kind of vehicle has its own drawing', () {
      expect(arts.keys, VehicleKind.values);
      for (final entry in arts.entries) {
        expect(vehicleArtAsset(entry.key), entry.value);
      }
      expect(arts.values.toSet(), hasLength(VehicleKind.values.length));
    });

    test('a type the app does not recognise gets none, not a wrong one', () {
      expect(vehicleArtAsset(null), isNull);
    });

    test('every drawing is a file the app bundles', () {
      for (final asset in arts.values) {
        expect(File(asset).existsSync(), isTrue, reason: asset);
        // `assets/image/svg/` is listed in pubspec.yaml as a folder.
        expect(asset, startsWith('assets/image/svg/'));
      }
    });
  });

  group('driverMarkerAsset', () {
    test('every kind has a marker file the app bundles', () {
      for (final kind in <VehicleKind?>[...VehicleKind.values, null]) {
        final asset = driverMarkerAsset(kind);
        expect(File(asset).existsSync(), isTrue, reason: asset);
        // `assets/marker/` is listed in pubspec.yaml as a folder.
        expect(asset, startsWith('assets/marker/'));
      }
    });

    test('each kind of vehicle has its own marker', () {
      const markers = {
        VehicleKind.moto: ImageAssets.motorMarker,
        VehicleKind.tukTuk: ImageAssets.tukTukMarker,
        VehicleKind.car: ImageAssets.classicCarMarker,
        VehicleKind.miniVan: ImageAssets.miniVanMarker,
        VehicleKind.suv: ImageAssets.suvMarker,
        VehicleKind.vip: ImageAssets.alphardVipMarker,
      };
      expect(markers.keys, VehicleKind.values);
      for (final entry in markers.entries) {
        expect(driverMarkerAsset(entry.key), entry.value);
      }
      expect(markers.values.toSet(), hasLength(VehicleKind.values.length));
    });

    test('a type the app does not recognise is drawn as a car', () {
      expect(driverMarkerAsset(null), ImageAssets.classicCarMarker);
    });

    // The marker is drawn in a 30x50 box; an image of any other shape is
    // stretched to fit it (the old ones were about 1:2).
    test('every marker image is 3:5, the shape of the box it is drawn in', () {
      expect(driverMarkerSize, const Size(30, 50));
      for (final kind in VehicleKind.values) {
        final path = driverMarkerAsset(kind);
        final header =
            ByteData.sublistView(File(path).readAsBytesSync(), 0, 24);
        // PNG: 8-byte signature, then the IHDR chunk's width and height.
        final width = header.getUint32(16);
        final height = header.getUint32(20);
        expect(width * 5, height * 3, reason: '$path is ${width}x$height');
      }
    });
  });

  // flutter_svg supports a subset of SVG; a drawing that uses anything
  // outside it fails only when it is first shown.
  for (final entry in arts.entries) {
    testWidgets('${entry.key.name} renders through flutter_svg',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: SizedBox(
            width: 84,
            height: 52,
            child: SvgPicture.asset(entry.value),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(SvgPicture)), const Size(84, 52));
    });
  }
}
