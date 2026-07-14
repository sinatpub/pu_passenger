import 'package:com.tara.passenger/presentation/screens/booking_map_screen/logic.dart';
import 'package:get/get.dart';

import '../../../data/datasources/check_request_book_source.dart';

class BookingMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingMapLogic>(() => BookingMapLogic());
  }
}
