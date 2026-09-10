import 'package:com.tara.passenger/core/utils/pretty_logger.dart';
import 'package:com.tara.passenger/presentation/screens/splash_screen/state.dart';
import 'package:com.tara.passenger/services/session_service.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class SplashLogic extends GetxController {
  SplashState state = SplashState();
  @override
  void onInit() {
    _checkAuthorization();
    super.onInit();
    tlog("Initialize Login");
  }

  // P-01 (docs/12) — was a presence-only check reading the legacy `jsonToken`
  // blob straight out of SharedPreferences, with an empty catch and its
  // fallback route commented out (docs/08 M-14): any exception here
  // stranded the user on the splash screen forever. Now goes through
  // SessionService (F-04), which migrates that same blob into secure
  // storage on first read, and any failure falls back to login instead of
  // hanging.
  Future<void> _checkAuthorization() async {
    String? token;
    try {
      token = await SessionService.instance.getToken();
      await 1.delay();
    } catch (e) {
      token = null;
    }
    if (token == null) {
      Get.offAllNamed(AppRoutes.LOGIN);
    } else {
      Get.offAllNamed(AppRoutes.BOTTOMNAV);
    }
  }
}
