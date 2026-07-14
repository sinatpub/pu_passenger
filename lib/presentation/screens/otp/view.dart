import 'dart:async';

import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/presentation/screens/otp/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/loading_widget.dart';
import 'package:com.tara.passenger/presentation/widgets/shake_widget.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:smart_auth/smart_auth.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpLogic>();

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: ThemeConstands.font22SemiBold,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dark1, width: 2),
      ),
      margin: const EdgeInsets.only(left: 4, right: 4),
    );

    return Scaffold(
      backgroundColor: AppColors.light4,
      body: SafeArea(
        bottom: false,
        child: Obx(
          () => Container(
            margin: EdgeInsets.symmetric(
                horizontal: controller.loading.value ? 0 : 18),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    alignment: Alignment.centerLeft,
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 24,
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 25),
                          child: Column(
                            children: [
                              const SizedBox(height: 28),
                              Text(
                                AppLocale.otpVertification.tr,
                                style: ThemeConstands.font20SemiBold,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 18),
                              Text(
                                AppLocale.desOtpVerification.tr,
                                style: ThemeConstands.font16Regular,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 48),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: ShakeWidget(
                                  key: controller.phoneShake,
                                  shakeCount: 3,
                                  shakeOffset: 10,
                                  shakeDuration:
                                      const Duration(milliseconds: 500),
                                  child: Pinput(
                                    length: 4,
                                    autofocus: true,
                                    smsRetriever: controller.smsRetriever,
                                    controller: controller.pinController,
                                    focusNode: controller.focusNode,
                                    defaultPinTheme: defaultPinTheme,
                                    hapticFeedbackType:
                                        HapticFeedbackType.lightImpact,
                                    onChanged: (value) =>
                                        debugPrint("---> value ---> $value"),
                                    onCompleted: (value) =>
                                        controller.verifyOtp(value),
                                    forceErrorState:
                                        controller.forceErrorPinPut.value,
                                    errorPinTheme: defaultPinTheme.copyWith(
                                      decoration:
                                          defaultPinTheme.decoration!.copyWith(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.main,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    focusedPinTheme: defaultPinTheme.copyWith(
                                      decoration:
                                          defaultPinTheme.decoration!.copyWith(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppColors.main, width: 2),
                                      ),
                                      padding: const EdgeInsets.only(
                                          left: 11, right: 11),
                                    ),

                                    followingPinTheme:
                                        defaultPinTheme.copyWith(),
                                    submittedPinTheme: defaultPinTheme.copyWith(
                                      decoration:
                                          defaultPinTheme.decoration!.copyWith(
                                        color: AppColors.light4,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppColors.dark4, width: 2),
                                      ),
                                      margin: const EdgeInsets.only(
                                          left: 1, right: 1),
                                    ),
                                    // errorPinTheme:
                                    //   defaultPinTheme.copyBorderWith(
                                    // border: Border.all(
                                    //     color: Colors.redAccent, width: 2),
                                    // ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocale.didNotGetCode.tr,
                                    style: ThemeConstands.font16Regular,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(width: 8),
                                  controller.secondsRemaining.value == 0
                                      ? const SizedBox(width: 0)
                                      : SlideCountdown(
                                          duration: Duration(
                                              seconds: controller
                                                  .secondsRemaining.value),
                                          style: ThemeConstands.font16SemiBold
                                              .copyWith(color: AppColors.main),
                                          separatorType: SeparatorType.symbol,
                                          slideDirection: SlideDirection.down,
                                          separatorStyle:
                                              ThemeConstands.font12Regular,
                                          decoration: ShapeDecoration(
                                            color: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onDone: () {
                                            // logic.state.isNeedSendAgain.value = true;
                                            // logic.state.isStartListen.value = false;
                                            // logic.update();
                                          },
                                        ),
                                ],
                              ),
                              controller.isResendEnabled.value
                                  ? TextButton(
                                      onPressed: controller.resendCode,
                                      child: Text(
                                        AppLocale.sendAgain.tr,
                                        style: ThemeConstands.font16SemiBold
                                            .copyWith(
                                          // decoration: TextDecoration.underline,
                                          color: AppColors.main,
                                        ),
                                      ),
                                    )
                                  : const SizedBox(height: 0),
                            ],
                          ),
                        ),
                      ),
                      if (controller.loading.value) const LoadingWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SmsRetrieverImpl implements SmsRetriever {
  SmsRetrieverImpl(this.smartAuth);

  final SmartAuth smartAuth;

  @override
  Future<void> dispose() {
    return smartAuth.removeSmsRetrieverApiListener();
  }

  @override
  Future<String?> getSmsCode() async {
    final signature = await smartAuth.getAppSignature();
    debugPrint('App Signature: $signature');
    final res = await smartAuth.getSmsWithRetrieverApi();

    if (res.hasData) {
      return res.requireData.code!;
    }
    return null;
  }

  @override
  bool get listenForMultipleSms => false;
}
