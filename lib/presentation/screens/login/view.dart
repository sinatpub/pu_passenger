import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/debug_auth_bypass.dart';
import 'package:com.tara.passenger/core/utils/phone_formatter.dart';
import 'package:com.tara.passenger/presentation/screens/login/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/shake_widget.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

import 'auth_language_toggle.dart';

/// Screen 2 — Login.
///
/// **Every validation rule is `LoginLogic`'s and is untouched** (roadmap S4
/// Risk): the same `inputFormatters` chain produces the same spaced value,
/// `state.phoneNumber` still holds that formatted string, and both the Next
/// button and the keyboard's done action still call
/// `phoneLogin(state.phoneNumber.value, context)`. The shake-on-invalid is
/// still driven by `logic.phoneShake`.
///
/// `PDD-04` — the three-step indicator is built as specified.
///
/// A debug build that asks for the OTP bypass also gets one extra button
/// under Next, which signs in as the account in `dart_defines.json` — see
/// [DebugAuthBypass]. No release build shows it.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key, @visibleForTesting this.showDebugLogin});

  /// Null follows [DebugAuthBypass.isEnabled]. Tests set it, because that
  /// flag is a compile-time constant they cannot switch on.
  final bool? showDebugLogin;

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<LoginLogic>();

    return Scaffold(
      backgroundColor: TaColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TaStepIndicator(steps: 3, current: 0),
                  AuthLanguageToggle(),
                ],
              ),
              const SizedBox(height: 18),
              Text(AppLocale.titleLogin.tr, style: TaTextStyles.displayLarge),
              const SizedBox(height: 6),
              Text(
                AppLocale.desLogin.tr,
                style: TaTextStyles.bodyMedium
                    .copyWith(color: TaColors.textSecondary),
              ),
              const SizedBox(height: 18),
              Text(
                AppLocale.phoneNumber.tr,
                style: TaTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: TaColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => ShakeWidget(
                  key: logic.phoneShake,
                  shakeCount: 3,
                  shakeOffset: 10,
                  child: TaTextField(
                    controller: logic.phoneTextController,
                    hint: AppLocale.enterPhoneNumber.tr,
                    enabled: !logic.state.isLoading.value &&
                        !logic.state.debugLoggingIn.value,

                    /// Display-only prefix, exactly as before — the country
                    /// code is **not** part of the submitted value, which
                    /// `validatePhoneNumber` normalizes by prepending "0".
                    prefix: const Text('+855'),

                    /// Unchanged chain: digits only, capped at 12, then the
                    /// grouping formatter. `state.phoneNumber` therefore holds
                    /// a spaced string, which `phoneLogin` strips.
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                      CardNumberInputFormatter(),
                    ],
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onChanged: (value) =>
                        logic.state.phoneNumber.value = value,
                    onSubmitted: (_) => logic.phoneLogin(
                      logic.state.phoneNumber.value,
                      context,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => TaButton(
                  label: AppLocale.next.tr,
                  isEnabled: !logic.state.debugLoggingIn.value,
                  onTap: () => logic.phoneLogin(
                    logic.state.phoneNumber.value,
                    context,
                  ),
                ),
              ),
              if (showDebugLogin ?? DebugAuthBypass.isEnabled) ...[
                const SizedBox(height: 24),
                Obx(
                  () => TaButton(
                    label: DebugAuthBypass.loginLabel,
                    variant: TaButtonVariant.ghost,
                    size: TaButtonSize.small,
                    isLoading: logic.state.debugLoggingIn.value,
                    onTap: logic.debugLogin,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DebugAuthBypass.loginCaption,
                  textAlign: TextAlign.center,
                  style: TaTextStyles.bodySmall
                      .copyWith(color: TaColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
