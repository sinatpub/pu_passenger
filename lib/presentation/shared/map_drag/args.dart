import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:get/get.dart';

/// Which end of the trip the shared pick-a-point page is being used for.
///
/// `map_drag/` is shared, but its confirm button was hardcoded to
/// `AppLocale.confirmDropOff`. That is accurate today only because the
/// destination flow is the page's single live caller (`map_screen/view.dart`).
/// It becomes wrong the moment the pickup flow reuses the page — which is
/// exactly what `ux_ui_design/taxi-booking-ux-spec.md` Screen 3 specifies
/// ("Confirm pickup").
///
/// `.agent/TODO.md` logged this as needing "a route argument that does not
/// exist yet". This is that argument. It defaults to [destination], so the
/// existing caller behaves exactly as before and the page is ready for the
/// second one without another edit to its view.
enum MapDragPurpose {
  /// Choosing where the trip starts — Screen 3.
  pickup,

  /// Choosing where the trip ends — the only flow live today.
  destination;

  /// The confirm button's label for this purpose.
  String get confirmLabel => switch (this) {
        MapDragPurpose.pickup => AppLocale.confirmPickup.tr,
        MapDragPurpose.destination => AppLocale.confirmDropOff.tr,
      };
}

/// Arguments for the `DRAGMAP` route.
class MapDragArgs {
  const MapDragArgs({this.purpose = MapDragPurpose.destination});

  final MapDragPurpose purpose;

  /// Reads the arguments off the route, falling back to the destination
  /// flow. The fallback is what keeps the existing `Get.toNamed(DRAGMAP)`
  /// call — which passes nothing — working unchanged.
  static MapDragArgs fromRoute(Object? arguments) =>
      arguments is MapDragArgs ? arguments : const MapDragArgs();
}
