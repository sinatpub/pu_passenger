import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/core/utils/app_version.dart';
import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/initials.dart';
import 'package:com.tara.passenger/presentation/screens/profile/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 15 — Profile.
///
/// `ProfileLogic` and `AppLogic.logout()` are read-only (roadmap S2): this
/// screen only renders their state and calls them.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Resolved here rather than in fields so the widget stays `const` — the
    // bottom-nav host builds it as `const ProfileScreen()`.
    final logic = Get.find<ProfileLogic>();
    final appLogic = Get.find<AppLogic>();

    return Scaffold(
      backgroundColor: TaColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(appLogic),
              const SizedBox(height: 14),
              ProfileCard(logic: logic),
              const SizedBox(height: 14),
              _menu(context, appLogic),
              const SizedBox(height: 14),
              const ProfileVersionLabel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(AppLogic appLogic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocale.profile.tr,
          style: TaTextStyles.titleLarge.copyWith(fontSize: 17),
        ),

        /// The flag `IconButton` becomes the spec's segmented control. The
        /// toggle itself is still `AppLogic.toggleLanguage`, untouched.
        Obx(
          () => SizedBox(
            width: 132,
            child: TaSegment(
              options: const ['EN', 'ខ្មែរ'],
              selectedIndex:
                  appLogic.languageKeyCode.value == AppConstant.englishCode
                      ? 0
                      : 1,
              onChanged: (index) {
                final wantsEnglish = index == 0;
                final isEnglish =
                    appLogic.languageKeyCode.value == AppConstant.englishCode;
                // `toggleLanguage` flips; only call it when the tap actually
                // changes the language.
                if (wantsEnglish != isEnglish) appLogic.toggleLanguage();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _menu(BuildContext context, AppLogic appLogic) {
    return Column(
      children: [
        TaProfileRow(
          icon: const Icon(Icons.notifications_none, size: 20),
          label: AppLocale.announcement.tr,
          onTap: () => Get.toNamed(AppRoutes.ANNOUNCEMENT),
        ),
        TaProfileRow(
          icon: const Icon(Icons.place_outlined, size: 20),
          label: AppLocale.savedPlaces.tr,
          // No saved-places feature exists; the spec itself asks for a toast.
          onTap: () =>
              TaToast.show(context, AppLocale.savedPlacesComingSoon.tr),
        ),
        TaProfileRow(
          icon: const Icon(Icons.description_outlined, size: 20),
          label: AppLocale.termNCondition.tr,
          onTap: () => Get.toNamed(AppRoutes.TERMCONDITION),
        ),
        TaProfileRow(
          icon: const Icon(Icons.mail_outline, size: 20),
          label: AppLocale.contactUs.tr,
          onTap: () => Get.toNamed(AppRoutes.CONTACTUS),
        ),

        /// `PDD-03` — restored 2026-09-19 on explicit user sign-off (bell
        /// stays commented; there is no notifications screen for it).
        /// `AppLogic.logout()` already raises its own confirm dialog
        /// (re-skinned at F3) and owns the token clear + route, so the row
        /// only calls it.
        TaProfileRow(
          icon: const Icon(Icons.logout, size: 20),
          label: AppLocale.logout.tr,
          isDanger: true,
          onTap: appLogic.logout,
        ),
      ],
    );
  }
}

/// Name, phone and avatar — plus the error `ProfileLogic` has always recorded
/// and nothing ever showed.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.logic});

  final ProfileLogic logic;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = logic.state.errorMessage.value;
      if (logic.state.isLoading.value) {
        return const TaSkeletonCard(children: [TaSkeleton(height: 48)]);
      }

      /// Roadmap S2 / `05-blueprint` B5 — `state.errorMessage` was set by
      /// P-14's error path but never rendered, so a failed profile fetch
      /// showed an empty card and no explanation.
      if (error != null) {
        return TaCard(
          child: Column(
            children: [
              const Icon(Icons.wifi_off, size: 32, color: TaColors.textMuted),
              const SizedBox(height: 10),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TaTextStyles.bodyMedium
                    .copyWith(color: TaColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TaButton(
                label: AppLocale.retry.tr,
                variant: TaButtonVariant.ghost,
                size: TaButtonSize.small,
                width: 140,
                onTap: logic.getProfile,
              ),
            ],
          ),
        );
      }

      final data = logic.state.data.value?.data;
      final name = data?.name;
      return TaCard(
        child: Row(
          children: [
            TaAvatar(
              variant: TaAvatarVariant.profile,
              initials: initialsFromName(name),
              imageUrl: data?.profileImage,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? AppLocale.unKnown.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TaTextStyles.titleLarge.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 2),

                  /// Display degrades: no phone on the account shows the
                  /// "see profile" prompt rather than an empty line.
                  Text(
                    profilePhone(data?.countryCode, data?.phone) ??
                        AppLocale.seeProfile.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TaTextStyles.bodySmall
                        .copyWith(color: TaColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// The account's phone as one display string, or null when there is none.
String? profilePhone(String? countryCode, String? phone) {
  final number = phone?.trim();
  if (number == null || number.isEmpty || number == 'null') return null;
  final code = countryCode?.trim();
  if (code == null || code.isEmpty || code == 'null') return number;
  return '$code $number';
}

/// The installed build's version (`03 §Screen 15`).
///
/// Read through the existing `installedAppVersion()` rather than hardcoding
/// the spec's "1.2.1" — a stale version string on a support screen is worse
/// than none. Renders nothing until the platform channel answers, and nothing
/// at all if it fails.
class ProfileVersionLabel extends StatelessWidget {
  const ProfileVersionLabel({super.key, this.reader = installedAppVersion});

  final Future<String> Function() reader;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: reader(),
      builder: (context, snapshot) {
        final version = snapshot.data;
        if (version == null || version.isEmpty) return const SizedBox.shrink();
        return Text(
          '${AppLocale.version.tr} $version',
          textAlign: TextAlign.center,
          style: TaTextStyles.bodySmall.copyWith(color: TaColors.textMuted),
        );
      },
    );
  }
}
