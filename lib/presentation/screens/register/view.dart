import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/presentation/screens/login/auth_language_toggle.dart';
import 'package:com.tara.passenger/presentation/screens/register/logic.dart';
import 'package:com.tara.passenger/presentation/screens/register/state.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Whether Create may be pressed.
///
/// **Pinned, not "improved"** (roadmap S4 Risk / Scope): submit is disabled
/// unless there is a name *and* a photo. `03 §Screen 4` says the photo is
/// optional and adds a Skip button that registers with an auto-generated name;
/// the roadmap is explicit that where the spec and the code disagree here,
/// **the code wins**, so neither is built.
///
/// The timestamp name auto-generation in `RegisterLogic.passengerRegister`
/// therefore stays what it is today: a defensive path at submit time that this
/// rule makes unreachable through the UI.
bool canSubmitRegistration(RegisterState state) =>
    state.passengerName != '' && state.profileImage != null;

/// Screen 4 — Register.
///
/// `RegisterLogic` is untouched: the same `controllerName`, the same
/// `showModal` → gallery/camera picker, the same `removeProfileImage`, and the
/// same `passengerRegister()`.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaColors.background,
      body: SafeArea(
        child: GetBuilder<RegisterLogic>(
          builder: (logic) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TaStepIndicator(steps: 3, current: 2),
                    AuthLanguageToggle(),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppLocale.completeProfile.tr,
                          style: TaTextStyles.displayLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLocale.desRegister.tr,
                          style: TaTextStyles.bodyMedium
                              .copyWith(color: TaColors.textSecondary),
                        ),
                        const SizedBox(height: 18),
                        Center(child: RegisterAvatarPicker(logic: logic)),
                        const SizedBox(height: 6),

                        /// The spec's caption says the photo is optional. It
                        /// is not — `canSubmitRegistration` requires it — so
                        /// the caption says so instead of misleading.
                        Text(
                          AppLocale.tapToAddPhotoRequired.tr,
                          textAlign: TextAlign.center,
                          style: TaTextStyles.bodySmall
                              .copyWith(color: TaColors.textMuted),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          AppLocale.fullName.tr,
                          style: TaTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: TaColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TaTextField(
                          controller: logic.controllerName,
                          hint: AppLocale.enterFullName.tr,
                          textInputAction: TextInputAction.done,

                          /// Unchanged: writes straight to `state` and calls
                          /// `update()`, which is what re-evaluates the
                          /// submit rule.
                          onChanged: (value) {
                            logic.state.passengerName = value;
                            logic.update();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TaButton(
                  label: AppLocale.create.tr,
                  isEnabled: canSubmitRegistration(logic.state),
                  onTap: logic.passengerRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The 120px avatar well plus its camera affordance.
///
/// Tapping either opens `logic.showModal()` — the existing gallery/camera
/// sheet — and the small badge clears the picked image through
/// `logic.removeProfileImage()`, exactly as `CardUploadAttachment` did.
class RegisterAvatarPicker extends StatelessWidget {
  const RegisterAvatarPicker({super.key, required this.logic});

  final RegisterLogic logic;

  @override
  Widget build(BuildContext context) {
    final image = logic.state.profileImage;

    return SizedBox(
      width: 132,
      height: 132,
      child: Stack(
        children: [
          TaPressable(
            onTap: logic.showModal,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: TaColors.surface,
                shape: BoxShape.circle,
                boxShadow: TaShadows.shadowMd,
              ),
              clipBehavior: Clip.antiAlias,
              child: image == null
                  ? const Icon(
                      Icons.person,
                      size: 44,
                      color: TaColors.textMuted,
                    )
                  : Image.file(image, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 6,
            child: TaPressable(
              // With a photo picked this clears it; without one it opens the
              // picker — the same two actions the old widget offered.
              onTap: image == null ? logic.showModal : logic.removeProfileImage,
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TaColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: TaColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  image == null ? Icons.camera_alt : Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
