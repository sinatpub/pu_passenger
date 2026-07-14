import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/data/datasources/get_profile_api.dart';
import 'package:com.tara.passenger/presentation/screens/profile/state.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ProfileLogic extends GetxController {
  final ProfileApi profileApi = ProfileApi();
  final ProfileState state = ProfileState();
  final AppLogic appLogic = Get.find<AppLogic>();

  @override
  void onInit() {
    Logger().i("profile initialize");
    super.onInit();
    getProfile();
  }

  getProfile() async {
    state.isLoading.value = true;
    var data = await profileApi.getProfileApi();
    state.data.value = data;
    state.isLoading.value = false;
  }


}
