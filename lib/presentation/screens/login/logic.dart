import 'package:com.tara.passenger/core/helper/phone_validate_helper.dart';
import 'package:com.tara.passenger/features/auth/data/repository/auth_repository.dart';
import 'package:com.tara.passenger/presentation/screens/login/state.dart';
import 'package:com.tara.passenger/presentation/widgets/custom_snackbar_widget.dart';
import 'package:com.tara.passenger/presentation/widgets/shake_widget.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../translations/app_locale.dart';
import '../../widgets/error_dialog_widget.dart';

class LoginLogic extends GetxController {
  /// Collaborators arrive by constructor and resolve lazily. A `Get.find`
  /// in a field initializer runs at construction, so building this
  /// controller demanded every collaborator already be registered — the
  /// gap logged in `.agent/TODO.md` Discovered Tasks against
  /// `docs/10` §3.2. Production behaviour is unchanged: bindings register
  /// everything before first access.
  LoginLogic({
    AuthRepository? repository,
  })  : _injectedRepository = repository;

  final AuthRepository? _injectedRepository;

  late final AuthRepository _repository =
      _injectedRepository ?? Get.find<AuthRepository>();
  PhoneRepo phoneRepo = PhoneRepo();
  final AuthState state = AuthState();
  // * TextEditingController
  TextEditingController? phoneTextController;

  final phoneShake = GlobalKey<ShakeWidgetState>();

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  Future<void> phoneLogin(String phone, context) async {
    if (phoneRepo.isValid(phone.removeAllWhitespace) == true) {
      EasyLoading.show(dismissOnTap: false);
      try {
        String phoneNum = validatePhoneNumber(phone);
        final result = await _repository.loginPhone(phoneNum);
        result.when(
          ok: (data) {
            Get.toNamed(AppRoutes.OTP, arguments: {
              "phoneNumber": phoneNum,
              "resendTime": data.data.seconde
            });
          },
          err: (_) {
            state.isLoading.value = false;
            showErrorCustomDialog(
              Get.context!,
              AppLocale.pleaseTryAgain.tr,
              AppLocale.desPleaseLoginAgain.tr,
              () {
                Get.back();
              },
            );
          },
        );
      } finally {
        EasyLoading.dismiss();
      }
    } else {
      HapticFeedback.heavyImpact();
      phoneShake.currentState?.shake();
      showCustomSnackBar(title: phoneRepo.getErrorMessage(), message: "");
    }
  }

  String validatePhoneNumber(String value) {
    String normalizedPhone = value.removeAllWhitespace;
    if (!normalizedPhone.startsWith("0")) {
      normalizedPhone = "0$normalizedPhone";
    }

    return normalizedPhone;
  }
}
