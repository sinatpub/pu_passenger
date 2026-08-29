import 'package:com.tara.passenger/features/auth/data/datasource/auth_datasource.dart';
import 'package:com.tara.passenger/features/auth/data/repository/auth_repository.dart';
import 'package:com.tara.passenger/presentation/screens/login/logic.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthDatasource>(() => AuthDatasource());
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()));
    Get.lazyPut<LoginLogic>(() => LoginLogic());
  }
}
