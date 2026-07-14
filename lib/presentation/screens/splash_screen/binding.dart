import 'package:com.tara.passenger/presentation/screens/login/logic.dart';
import 'package:com.tara.passenger/presentation/screens/splash_screen/logic.dart';
import 'package:get/get.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashLogic());

  }
}
