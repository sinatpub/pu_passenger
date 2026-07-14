import 'package:com.tara.passenger/presentation/screens/bottom_nav/logic.dart';
import 'package:get/get.dart';

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomNavController>(() => BottomNavController());

  }
}
