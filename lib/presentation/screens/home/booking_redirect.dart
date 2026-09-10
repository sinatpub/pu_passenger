import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';

/// P-03 (docs/12) — where an already-active booking should send the passenger
/// when the app opens on Home.
///
/// Extracted from `HomeLogic.checkingBookingStatus()`, which previously did
/// three jobs in one method: fetch the booking, decide what it means, and
/// navigate. The decision is the only part with rules in it, and it was the
/// only part that could not be tested — `Get.offNamed` needs a live GetX
/// navigator. It is a pure function now.
///
/// Returns `null` when the passenger should stay on Home. `null` is the
/// deliberate answer for four cases, not an oversight:
///
///  * no booking at all;
///  * `request` — the passenger is still waiting for a driver to accept, and
///    that wait is owned by the map screen, not by Home;
///  * `cancel` — a cancelled booking is over; there is nothing to return to;
///  * any status the server introduces that this client does not know yet.
///    Staying put is the safe default: the old `default:` branch logged and
///    fell through to exactly the same behaviour.
String? bookingRedirectRoute(int? status) {
  switch (status) {
    case BookingStatus.accepted:
    case BookingStatus.arrival:
    case BookingStatus.onGoing:
      return AppRoutes.BOOKING;
    case BookingStatus.completed:
    case BookingStatus.pendingPayment:
      return AppRoutes.CALCULATEFEE;
    default:
      return null;
  }
}
