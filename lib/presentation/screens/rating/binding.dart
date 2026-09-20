import 'package:get/get.dart';

import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/rating/logic.dart';

class RatingBinding extends Bindings {
  @override
  void dependencies() {
    // The trip arrives as a route argument from the fee screen; a direct
    // entry with no argument still builds, and the screen degrades to the
    // unnamed prompt.
    final args = Get.arguments;
    Get.lazyPut<RatingLogic>(
      () => RatingLogic(
        booking: args is Map && args['booking'] is Data
            ? args['booking'] as Data
            : null,
      ),
    );
  }
}
