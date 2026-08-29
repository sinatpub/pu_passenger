import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/features/profile/data/repository/profile_repository.dart';
import 'package:com.tara.passenger/presentation/screens/profile/state.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ProfileLogic extends GetxController {
  final ProfileRepository _repository = Get.find<ProfileRepository>();
  final ProfileState state = ProfileState();
  final AppLogic appLogic = Get.find<AppLogic>();

  @override
  void onInit() {
    Logger().i("profile initialize");
    super.onInit();
    getProfile();
  }

  // P-14 (docs/12) — the old getProfileApi() call had no try/catch, so a
  // failed fetch left isLoading stuck at true forever with no error
  // surfaced (the view doesn't currently gate on isLoading, so this didn't
  // show as a stuck spinner, but the profile silently never populated).
  Future<void> getProfile() async {
    state.isLoading.value = true;
    final result = await _repository.getProfile();
    result.when(
      ok: (data) {
        state.data.value = data;
        state.errorMessage.value = null;
      },
      err: (error) => state.errorMessage.value = error.message,
    );
    state.isLoading.value = false;
  }
}
