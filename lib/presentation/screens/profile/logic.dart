import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/features/profile/data/repository/profile_repository.dart';
import 'package:com.tara.passenger/presentation/screens/profile/state.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ProfileLogic extends GetxController {
  /// Collaborators arrive by constructor and resolve lazily. A `Get.find`
  /// in a field initializer runs at construction, so building this
  /// controller demanded every collaborator already be registered — the
  /// gap logged in `.agent/TODO.md` Discovered Tasks against
  /// `docs/10` §3.2. Production behaviour is unchanged: bindings register
  /// everything before first access.
  ProfileLogic({
    ProfileRepository? repository,
    AppLogic? appLogic,
  })  : _injectedRepository = repository,
        _injectedAppLogic = appLogic;

  final ProfileRepository? _injectedRepository;
  final AppLogic? _injectedAppLogic;

  late final ProfileRepository _repository =
      _injectedRepository ?? Get.find<ProfileRepository>();
  late final AppLogic appLogic =
      _injectedAppLogic ?? Get.find<AppLogic>();
  final ProfileState state = ProfileState();
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
