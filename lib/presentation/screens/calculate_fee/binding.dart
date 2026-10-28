import 'package:com.tara.passenger/presentation/screens/calculate_fee/logic.dart';
import 'package:get/get.dart';

class CalculateFeeBinding extends Bindings {
  @override
  void dependencies() {
    // Audit X-3: opened by the `driverAcceptPayment` push when the passenger
    // was somewhere else, the payment is already confirmed.
    final args = Get.arguments;
    final paymentConfirmed = args is Map && args['paymentConfirmed'] == true;
    Get.lazyPut<CalculateFeeLogic>(
      () => CalculateFeeLogic(paymentConfirmed: paymentConfirmed),
    );
  }
}
