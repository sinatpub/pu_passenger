import 'package:get/get.dart';

import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/receipt/logic.dart';

class ReceiptBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final map = args is Map ? args : const {};
    Get.lazyPut<ReceiptLogic>(
      () => ReceiptLogic(
        booking: map['booking'] is Data ? map['booking'] as Data : null,
        stars: map['stars'] is int ? map['stars'] as int : null,
      ),
    );
  }
}
