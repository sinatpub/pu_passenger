import 'package:com.tara.passenger/presentation/screens/login/logic.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginLogic>(() => LoginLogic());
  }
}
