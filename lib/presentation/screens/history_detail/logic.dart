import 'package:com.tara.passenger/app/google_map_logic.dart';
import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/utils/history_cell_data.dart';
import 'package:com.tara.passenger/core/utils/pretty_logger.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/map_presentation.dart';
import 'package:com.tara.passenger/presentation/shared/ride_dialogs.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/utils/trip_marker.dart';
import 'state.dart';

class HistoryDetailLogic extends GetxController {
  /// [data] is the trip to show. Left out, it is read from the route's
  /// arguments, which is how the history list opens this page.
  HistoryDetailLogic({Datum? data}) : _injectedData = data;

  final Datum? _injectedData;

  final HistoryDetailState state = HistoryDetailState();

  @override
  void onInit() {
    super.onInit();
    final argument = Get.arguments;
    state.data = _injectedData ?? (argument is Datum ? argument : null);
  }

  /// Where the trip started, or null when the record has no usable point.
  LatLng? get pickup =>
      historyLatLng(state.data?.startLatitude, state.data?.startLongitude);

  /// Where it ended. Null for a trip booked without a destination, or
  /// cancelled before one was set.
  LatLng? get dropOff =>
      historyLatLng(state.data?.endLatitude, state.data?.endLongitude);

  /// The map is ready: put the two pins on it, draw the route between them
  /// and frame both. A trip with no drop-off shows its pickup alone — never
  /// a line to (0, 0).
  Future<void> onMapCreated(GoogleMapController controller) async {
    state.mapController = controller;
    await _loadPins();
    _placePins();
    update();
    await _drawRoute();
    update();
    _frameTrip();
  }

  Future<void> _loadPins() async {
    try {
      state.pickupIcon = await tripMarkerIcon(TripMarker.pickup);
      state.dropOffIcon = await tripMarkerIcon(TripMarker.dropOff);
    } catch (e) {
      // The map's default pins still mark the two ends.
      tlog('history detail pins failed to load: $e');
    }
  }

  void _placePins() {
    final start = pickup;
    final end = dropOff;
    state.markers = {
      if (start != null)
        Marker(
          markerId: const MarkerId('pickup'),
          position: start,
          consumeTapEvents: true,
          icon: state.pickupIcon ?? BitmapDescriptor.defaultMarker,
          anchor: tripMarkerAnchor(state.pickupIcon),
        ),
      if (end != null)
        Marker(
          markerId: const MarkerId('drop_off'),
          position: end,
          consumeTapEvents: true,
          icon: state.dropOffIcon ?? BitmapDescriptor.defaultMarker,
          anchor: tripMarkerAnchor(state.dropOffIcon),
        ),
    };
  }

  Future<void> _drawRoute() async {
    final start = pickup;
    final end = dropOff;
    if (start == null || end == null) return;
    if (!Get.isRegistered<GoogleMapLogic>()) {
      Get.put<GoogleMapLogic>(GoogleMapLogic());
    }
    final route = await Get.find<GoogleMapLogic>().drawPolylineWithReturnValue(
      startLatLng: start,
      endLatLng: end,
      polylineColor: TaColors.primary,
    );
    if (route != null) state.polyline = route;
  }

  void _frameTrip() {
    final controller = state.mapController;
    if (controller == null) return;
    final bounds =
        tripCameraBounds(currentLatLng: pickup, destinationLatLng: dropOff);
    if (bounds == null) return;
    controller.moveCamera(CameraUpdate.newLatLngBounds(bounds, 36));
  }

  /// Opens the booking map set up for this trip again: the same vehicle type
  /// and the same drop-off. The passenger confirms the pickup and taps Book.
  void bookAgain() {
    Get.toNamed(
      AppRoutes.MAP,
      arguments: rebookArguments(
        vehicleTypeId: state.data?.driver?.vehicle?.typeVehicleId,
        destination: dropOff,
      ),
    );
  }
}
