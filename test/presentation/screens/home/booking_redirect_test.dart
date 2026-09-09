import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/presentation/screens/home/booking_redirect.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:flutter_test/flutter_test.dart';

/// P-03 (docs/12). The redirect rules used to sit inside
/// `HomeLogic.checkingBookingStatus()` next to a `Get.offNamed` call, so they
/// could not be exercised without a live GetX navigator. These pin the
/// mapping verbatim as it behaved before the extraction.
void main() {
  group('bookingRedirectRoute', () {
    test('an accepted booking resumes the trip screen', () {
      expect(bookingRedirectRoute(BookingStatus.accepted), AppRoutes.BOOKING);
    });

    test('a driver-arrived booking resumes the trip screen', () {
      expect(bookingRedirectRoute(BookingStatus.arrival), AppRoutes.BOOKING);
    });

    test('an in-progress booking resumes the trip screen', () {
      expect(bookingRedirectRoute(BookingStatus.onGoing), AppRoutes.BOOKING);
    });

    test('a completed booking goes to the fare screen', () {
      expect(
          bookingRedirectRoute(BookingStatus.completed), AppRoutes.CALCULATEFEE);
    });

    test('a booking pending payment goes to the fare screen', () {
      expect(bookingRedirectRoute(BookingStatus.pendingPayment),
          AppRoutes.CALCULATEFEE);
    });

    test('no booking keeps the passenger on Home', () {
      expect(bookingRedirectRoute(null), isNull);
    });

    test('a booking still waiting for a driver keeps the passenger on Home — '
        'that wait belongs to the map screen', () {
      expect(bookingRedirectRoute(BookingStatus.request), isNull);
    });

    test('a cancelled booking keeps the passenger on Home', () {
      expect(bookingRedirectRoute(BookingStatus.cancel), isNull);
    });

    test('an unknown status the server may add later keeps the passenger on '
        'Home rather than guessing', () {
      expect(bookingRedirectRoute(9999), isNull);
    });
  });
}
