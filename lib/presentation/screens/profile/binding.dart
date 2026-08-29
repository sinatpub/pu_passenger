import 'package:com.tara.passenger/features/profile/data/datasource/profile_datasource.dart';
import 'package:com.tara.passenger/features/profile/data/repository/profile_repository.dart';
import 'package:com.tara.passenger/presentation/screens/profile/logic.dart';
import 'package:get/get.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileDatasource>(() => ProfileDatasource());
    Get.lazyPut<ProfileRepository>(() => ProfileRepository(Get.find()));
    Get.put<ProfileLogic>(ProfileLogic());
  }
}
