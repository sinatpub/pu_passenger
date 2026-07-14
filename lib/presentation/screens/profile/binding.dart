import 'package:com.tara.passenger/presentation/screens/profile/logic.dart';
import 'package:get/get.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ProfileLogic>(ProfileLogic());
  }
}
