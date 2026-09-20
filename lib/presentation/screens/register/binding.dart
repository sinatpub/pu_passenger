import 'package:com.tara.passenger/presentation/screens/login/data/datasource/auth_datasource.dart';
import 'package:com.tara.passenger/presentation/screens/login/data/repository/auth_repository.dart';
import 'package:get/get.dart';

import 'logic.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthDatasource>(() => AuthDatasource());
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()));
    Get.lazyPut<RegisterLogic>(() => RegisterLogic());
  }
}