import 'package:com.tara.passenger/presentation/screens/otp/logic.dart';
import 'package:get/get.dart';

class OTPBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpLogic>(() => OtpLogic());
  }
}
