import 'dart:io';

import 'package:com.tara.passenger/core/resources/asset_resource.dart';
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

    test('a moto is not drawn as a tuk tuk, nor a tuk tuk as a car', () {
      expect(driverMarkerAsset(VehicleKind.moto), ImageAssets.motoMarker);
      expect(
          driverMarkerAsset(VehicleKind.tukTuk), ImageAssets.rickshawMarker);
      expect(driverMarkerAsset(VehicleKind.car), ImageAssets.classicCarMarker);
    });

    test('a type the app does not recognise is drawn as a car', () {
      expect(driverMarkerAsset(null), ImageAssets.classicCarMarker);
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
