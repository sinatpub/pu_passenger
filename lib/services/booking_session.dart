import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Where a booking attempt has got to.
enum BookingRequestStatus {
  /// Nothing in progress.
  idle,

  /// A `request-booking` call is in flight.
  inFlight,

  /// The server accepted it; waiting for a driver to accept.
  awaitingDriver,

  /// The attempt failed and can be retried from the recorded draft.
  failed,
}

/// P-08 (docs/12) — the booking attempt, held outside the route that started
/// it.
///
/// `MapLogic` is `lazyPut` in `MapBinding`, so it is route-scoped: it and its
/// `MapState` are disposed when the map route is popped or replaced. Every
/// fact about an in-flight booking — where the passenger is being picked up,
/// where they are going, which vehicle they chose, and whether the request
/// succeeded — lived in that state and died with it.
///
/// `docs/12` states the requirement as "preserve state across failure —
/// current route-scoped state cannot". Concretely, what was lost:
///
///  * a request that failed left nothing to retry from, so the passenger
///    re-entered pickup and destination by hand;
///  * navigating away mid-request (or the OS disposing the route) dropped the
///    attempt silently, with no record that one was ever made;
///  * on returning to the map the passenger saw a blank slate even though the
///    server may well have created the booking.
///
/// This service is registered `permanent: true` alongside `AppLogic`, so it
/// outlives any route. It holds the *intent*, not the map — markers,
/// polylines and camera state stay with `MapLogic`, and splitting those out
/// is P-06's job, not this one.
class BookingSession extends GetxService {
  LatLng? pickup;
  String? pickupAddress;
  LatLng? destination;
  String? destinationAddress;
  int? vehicleTypeId;

  BookingRequestStatus status = BookingRequestStatus.idle;

  /// Why the last attempt failed, for surfacing on a retry screen. Cleared
  /// whenever a new attempt starts.
  String? lastFailureMessage;

  /// True when there is an attempt worth showing the passenger again — either
  /// one still running, or a failed one they can retry without re-entering
  /// anything.
  bool get hasRecoverableAttempt =>
      status == BookingRequestStatus.inFlight ||
      status == BookingRequestStatus.failed;

  /// True while the booking overlay should be up. Derived rather than stored,
  /// so a rebuilt `MapLogic` cannot disagree with the session about whether a
  /// booking is running.
  bool get isBusy =>
      status == BookingRequestStatus.inFlight ||
      status == BookingRequestStatus.awaitingDriver;

  /// Records an attempt as it is being sent. Everything needed to re-send it
  /// is captured here *before* the call goes out, so a failure — or a
  /// disposed route — still leaves something to retry from.
  void beginRequest({
    required LatLng pickup,
    String? pickupAddress,
    LatLng? destination,
    String? destinationAddress,
    int? vehicleTypeId,
  }) {
    this.pickup = pickup;
    this.pickupAddress = pickupAddress;
    this.destination = destination;
    this.destinationAddress = destinationAddress;
    this.vehicleTypeId = vehicleTypeId;
    status = BookingRequestStatus.inFlight;
    lastFailureMessage = null;
  }

  void markAwaitingDriver() => status = BookingRequestStatus.awaitingDriver;

  void markFailed(String message) {
    status = BookingRequestStatus.failed;
    lastFailureMessage = message;
  }

  /// The attempt is over — cancelled, completed, or abandoned. Clears the
  /// draft so a later session does not resurrect a stale destination.
  void reset() {
    pickup = null;
    pickupAddress = null;
    destination = null;
    destinationAddress = null;
    vehicleTypeId = null;
    status = BookingRequestStatus.idle;
    lastFailureMessage = null;
  }
}
