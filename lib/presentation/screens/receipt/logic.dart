import 'package:get/get.dart';

import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/receipt/state.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';

/// Screen 12 (Receipt) controller — two exits and no fetching.
class ReceiptLogic extends GetxController {
  ReceiptLogic({Data? booking, int? stars})
      : state = ReceiptState(booking: booking, stars: stars);

  final ReceiptState state;

  /// Clears the whole post-trip stack: the trip is over and neither the
  /// receipt nor the rating behind it should be reachable by Back.
  void backToHome() => Get.offAllNamed(AppRoutes.BOTTOMNAV);

  /// "Book again" lands on the map, which is where a new trip starts.
  void bookAgain() => Get.offAllNamed(AppRoutes.MAP);
}
