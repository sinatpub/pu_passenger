import 'dart:math' as _logger;

import 'package:com.tara.passenger/core/utils/pretty_logger.dart';
import 'package:com.tara.passenger/presentation/screens/splash_screen/state.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes/app_pages.dart';
import '../../../storages/key_storage.dart';

class SplashLogic extends GetxController with keyStoragePref {
  SplashState state = SplashState();
  @override
  void onInit() {
    _checkAuthorization();
    super.onInit();
    tlog("Initialize Login");
  }

  // authorized
  Future<void> _checkAuthorization() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      final String? token = pref.getString(jsonToken);
      await 1.delay();
      if (token == null) {
        Get.offAllNamed(AppRoutes.LOGIN);
      } else {
        Get.offAllNamed(AppRoutes.BOTTOMNAV);
      }
    } catch (e) {
      // _logger.e("Authorization check failed: $e");
      // Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
