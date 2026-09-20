import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:smart_auth/smart_auth.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/presentation/screens/otp/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/loading_widget.dart';
import 'package:com.tara.passenger/presentation/widgets/shake_widget.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 3 — OTP.
///
/// **`Pinput` is kept, not replaced by the spec's `TaOtpField`.** The spec
/// draws four plain boxes; the real field carries `smsRetriever` (Android SMS
/// autofill), `forceErrorState` and the `onCompleted` auto-submit that roadmap
/// S4 names explicitly. Swapping it would silently drop autofill and the
/// error state, so the theme is restyled with tokens instead and every
/// behavioural prop is passed through unchanged.
///
/// The prototype's "Demo: type any 4 digits" line is **not** built (`D14`).
class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpLogic>();

    /// Radius 14, 64px tall, 26/800 — the spec's OTP box, expressed as a
    /// `PinTheme` so `Pinput` keeps doing the work.
    final defaultPinTheme = PinTheme(
      width: 58,
      height: 64,
      textStyle: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: TaColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: TaColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TaColors.border, width: 1.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );

    return Scaffold(
      backgroundColor: TaColors.background,
      body: SafeArea(
        child: Obx(
          () => Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TaStepIndicator(steps: 3, current: 1),
                        TaIconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    semanticLabel: AppLocale.back.tr,
                          onTap: Get.back,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      AppLocale.otpVertification.tr,
                      style: TaTextStyles.displayLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocale.desOtpVerification.tr,
                      style: TaTextStyles.bodyMedium
                          .copyWith(color: TaColors.textSecondary),
                    ),
                    const SizedBox(height: 4),

                    /// The number the code went to, which the screen never
                    /// showed before.
                    Text(
                      controller.phoneNumber,
                      style: TaTextStyles.titleMedium.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 18),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: ShakeWidget(
                        key: controller.phoneShake,
                        shakeCount: 3,
                        shakeOffset: 10,
                        child: Pinput(
                          // Every prop below is carried over verbatim — the
                          // 4-digit length and `onCompleted` are the
                          // auto-submit S4 requires be preserved.
                          length: 4,
                          autofocus: true,
                          smsRetriever: controller.smsRetriever,
                          controller: controller.pinController,
                          focusNode: controller.focusNode,
                          defaultPinTheme: defaultPinTheme,
                          hapticFeedbackType: HapticFeedbackType.lightImpact,
                          onCompleted: controller.verifyOtp,
                          forceErrorState: controller.forceErrorPinPut.value,
                          errorPinTheme: defaultPinTheme.copyWith(
                            decoration:
                                defaultPinTheme.decoration!.copyWith(
                              color: TaColors.errorBg,
                              border: Border.all(
                                color: TaColors.error,
                                width: 1.5,
                              ),
                            ),
                          ),
                          focusedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              border: Border.all(
                                color: TaColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                          submittedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              color: TaColors.primaryBg,
                              border: Border.all(
                                color: TaColors.primaryBorder,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    OtpResendRow(controller: controller),
                    const Spacer(),
                  ],
                ),
              ),
              if (controller.loading.value) const LoadingWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Didn't get the code?" plus either the countdown pill or the resend link.
/// The countdown is still `SlideCountdown` driven by
/// `controller.secondsRemaining`, and resend still calls
/// `controller.resendCode` — neither is touched.
class OtpResendRow extends StatelessWidget {
  const OtpResendRow({super.key, required this.controller});

  final OtpLogic controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocale.didNotGetCode.tr,
            style: TaTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w400,
              color: TaColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          if (controller.secondsRemaining.value > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: TaColors.primaryBg,
                borderRadius: BorderRadius.circular(99),
              ),
              child: SlideCountdown(
                duration:
                    Duration(seconds: controller.secondsRemaining.value),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: TaColors.primary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
                separatorType: SeparatorType.symbol,
                slideDirection: SlideDirection.down,
                separatorStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: TaColors.primary,
                ),
                decoration: const ShapeDecoration(
                  color: Colors.transparent,
                  shape: StadiumBorder(),
                ),
              ),
            )
          else if (controller.isResendEnabled.value)
            GestureDetector(
              onTap: controller.resendCode,
              child: Text(
                AppLocale.sendAgain.tr,
                style: TaTextStyles.labelLarge.copyWith(
                  color: TaColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Unchanged — Android SMS Retriever plumbing for `Pinput`'s autofill.
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
