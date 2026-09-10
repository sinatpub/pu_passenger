import 'package:com.tara.passenger/presentation/shared/map_drag/args.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// `.agent/TODO.md` Discovered Tasks: the shared pick-a-point page's confirm
/// button was hardcoded to "Confirm Drop Off", accurate only because the
/// destination flow is its single live caller. These pin the argument that
/// lets the pickup flow (spec Screen 3) reuse the page without the label
/// going wrong — and pin the default that keeps today's caller unchanged.
void main() {
  group('MapDragArgs.fromRoute', () {
    test('no arguments falls back to the destination flow — this is what '
        'keeps the existing Get.toNamed(DRAGMAP) call working', () {
      expect(MapDragArgs.fromRoute(null).purpose, MapDragPurpose.destination);
    });

    test('arguments of an unexpected type fall back rather than throwing', () {
      // Get.arguments is dynamic; another screen passing a Map must not
      // crash the page.
      expect(MapDragArgs.fromRoute({'vehicleId': 3}).purpose,
          MapDragPurpose.destination);
      expect(MapDragArgs.fromRoute('nonsense').purpose,
          MapDragPurpose.destination);
    });

    test('an explicit purpose is carried through', () {
      expect(
        MapDragArgs.fromRoute(const MapDragArgs(purpose: MapDragPurpose.pickup))
            .purpose,
        MapDragPurpose.pickup,
      );
    });
  });

  group('MapDragPurpose.confirmLabel', () {
    test('the two purposes use different labels', () {
      expect(MapDragPurpose.pickup.confirmLabel,
          isNot(MapDragPurpose.destination.confirmLabel));
    });

    test('destination keeps the existing drop-off wording', () {
      expect(MapDragPurpose.destination.confirmLabel,
          AppLocale.confirmDropOff.tr);
    });

    test('pickup uses the wording spec Screen 3 asks for', () {
      expect(MapDragPurpose.pickup.confirmLabel, AppLocale.confirmPickup.tr);
    });
  });
}
