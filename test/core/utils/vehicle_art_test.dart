import 'dart:io';

import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/utils/vehicle_art.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const arts = {
    1: ImageAssets.vehicleTukTuk,
    2: ImageAssets.vehicleClassic,
    3: ImageAssets.vehicleMiniVan,
    4: ImageAssets.vehicleSuv,
    5: ImageAssets.vehicleVip,
  };

  group('vehicleArtAsset', () {
    test('each of the five vehicle types has its own drawing', () {
      for (final entry in arts.entries) {
        expect(vehicleArtAsset(entry.key), entry.value);
      }
      expect(arts.values.toSet(), hasLength(5));
    });

    test('a type the app has no drawing of gets none, not a wrong one', () {
      expect(vehicleArtAsset(null), isNull);
      expect(vehicleArtAsset(0), isNull);
      expect(vehicleArtAsset(99), isNull);
    });

    test('every drawing is a file the app bundles', () {
      for (final asset in arts.values) {
        expect(File(asset).existsSync(), isTrue, reason: asset);
        // `assets/image/svg/` is listed in pubspec.yaml as a folder.
        expect(asset, startsWith('assets/image/svg/'));
      }
    });
  });

  // flutter_svg supports a subset of SVG; a drawing that uses anything
  // outside it fails only when it is first shown.
  for (final entry in arts.entries) {
    testWidgets('type ${entry.key} renders through flutter_svg',
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
