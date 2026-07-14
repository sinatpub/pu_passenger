import 'package:com.tara.passenger/presentation/screens/calculate_fee/logic.dart';
import 'package:get/get.dart';

class CalculateFeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CalculateFeeLogic>(() => CalculateFeeLogic());
  }
}
