import 'package:com.tara.passenger/features/auth/data/datasource/auth_datasource.dart';
import 'package:com.tara.passenger/features/auth/data/repository/auth_repository.dart';
import 'package:com.tara.passenger/presentation/screens/otp/logic.dart';
import 'package:get/get.dart';

class OTPBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthDatasource>(() => AuthDatasource());
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()));
    Get.lazyPut<OtpLogic>(() => OtpLogic());
  }
}
