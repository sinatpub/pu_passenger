import 'dart:async';
import 'dart:convert';
import 'package:com.tara.passenger/core/utils/debug_auth_bypass.dart';
import 'package:com.tara.passenger/features/auth/data/repository/auth_repository.dart';
import 'package:com.tara.passenger/presentation/screens/login/logic.dart';
import 'package:com.tara.passenger/presentation/screens/otp/view.dart';
import 'package:com.tara.passenger/presentation/widgets/error_dialog_widget.dart';
import 'package:com.tara.passenger/presentation/widgets/shake_widget.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/storages/save_storage.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

class OtpLogic extends GetxController {
  final AuthRepository _repository = Get.find<AuthRepository>();
  final SaveStoragePref _savePref = SaveStoragePref();
  LoginLogic loginLogic = Get.find<LoginLogic>();

  final phoneShake = GlobalKey<ShakeWidgetState>();
  final smartAuth = SmartAuth.instance;
  late final SmsRetriever smsRetriever;
  late Timer timer;
  RxInt secondsRemaining = 0.obs;
  RxBool isResendEnabled = false.obs;
  RxBool loading = false.obs;
  RxBool forceErrorPinPut = false.obs;

  late final TextEditingController pinController;
  late final FocusNode focusNode;
  late String phoneNumber;
  late int timeResend;
  final Map<String, dynamic> args = Get.arguments ?? {};

  @override
  void onInit() {
    super.onInit();

    phoneNumber = args['phoneNumber'];
    timeResend = args['resendTime'] ?? 30;
    pinController = TextEditingController();
    focusNode = FocusNode();
    smsRetriever = SmsRetrieverImpl(smartAuth);
    secondsRemaining.value = timeResend;
    startTimer();
  }

  @override
  void onClose() {
    pinController.dispose();
    focusNode.dispose();
    timer.cancel();
    super.onClose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (secondsRemaining.value == 0) {
        isResendEnabled.value = true;
        timer.cancel();
      } else {
        secondsRemaining.value--;
      }
    });
  }

  void verifyOtp(String otpCode) async {
    // Debug-only shortcut — see [DebugAuthBypass] for the three conditions
    // that must all hold. Compiled out of release builds entirely.
    if (DebugAuthBypass.accepts(otpCode)) {
      loading.value = true;
      try {
        final ok = await DebugAuthBypass.seedSession();
        if (!ok) {
          forceErrorPinPut.value = true;
          showErrorCustomDialog(
            Get.context!,
            AppLocale.pleaseTryAgain.tr,
            'Debug bypass could not obtain a session — see the log.',
            () {
              Get.back();
            },
          );
          return;
        }
        forceErrorPinPut.value = false;
        Get.offAllNamed(AppRoutes.BOTTOMNAV);
      } finally {
        loading.value = false;
      }
      return;
    }

    loading.value = true;
    try {
      final result = await _repository.verifyOtp(
          phone: phoneNumber.toString(), otpCode: otpCode.toString());
      result.when(
        ok: (data) {
          if (data.data?.user == null && data.data?.token == null) {
            Get.toNamed(AppRoutes.REGISTER);
          } else {
            forceErrorPinPut.value = false;
            _savePref.saveJsonToken(authModel: json.encode(data));
            Get.offAllNamed(AppRoutes.BOTTOMNAV);
          }
        },
        err: (_) {
          forceErrorPinPut.value = true;
          HapticFeedback.heavyImpact();
          phoneShake.currentState?.shake();
          showErrorCustomDialog(
            Get.context!,
            AppLocale.pleaseTryAgain.tr,
            AppLocale.desErrorOTP.tr,
            () {
              Get.back();
            },
          );
        },
      );
    } finally {
      loading.value = false;
    }
  }

  void resendCode() {
    secondsRemaining.value = 30;
    loginLogic.phoneLogin(phoneNumber, Get.context);
    startTimer();
    isResendEnabled.value = false;
  }
}
