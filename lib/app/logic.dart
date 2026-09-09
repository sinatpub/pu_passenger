import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:com.tara.passenger/data/datasources/app_version_repo.dart';
import 'package:com.tara.passenger/data/models/user_response_model.dart';
import 'package:com.tara.passenger/presentation/widgets/yesno_dialog_widget.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/storages/get_storage.dart';
import 'package:com.tara.passenger/storages/key_storage.dart';
import 'package:com.tara.passenger/storages/remove_storage.dart';
import 'package:com.tara.passenger/storages/save_storage.dart';
import 'package:com.tara.passenger/taxi_single_ton/init_socket.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:com.tara.passenger/core/utils/app_version.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/app_version_model.dart';

class AppLogic extends GetxController with keyStoragePref {
  PassengerSocketService socketRepo = PassengerSocketService();
  AppVersionRepoApi appVersionRepoApi = AppVersionRepoApi();

  String? titleEvent;

  final _logger = Logger();
  RxString languageKeyCode = ''.obs;

  /// P-16: the installed version is read at runtime via
  /// `installedAppVersion()`. Injectable so the update decision can be tested
  /// without a platform channel.
  Future<String> Function() appVersionReader = installedAppVersion;

  String releaseDateVersionIos = "2026-04-25";
  String releaseDateVersionAndroid = "2026-04-25";

  @override
  void onInit() {
    super.onInit();
    _loadLanguageLocale();
  }

  // init socket
  Future<void> initSocket({required BuildContext context}) async {
    UserResponseModel model = await GetStoragePref().getJsonToken;
    if (model.data?.user?.id != null) {
      socketRepo.connectToSocket(
        AppConstant.socketBasedUrl,
        model.data!.user!.id.toString(),
        "passenger",
        context: context,
      );
    } else {
      Get.snackbar("Not Found User ID", "Please try again!!");
    }
  }

  // * language
  Future<void> _loadLanguageLocale() async {
    try {
      final GetStoragePref getPref = GetStoragePref();
      String? languageKey = await getPref.languagePrefKey;
      Get.updateLocale(Locale(languageKey ?? AppConstant.englishCode));
      await setLocaleIdentifier(languageKey ?? AppConstant.englishCode);
      languageKeyCode.value = languageKey ?? AppConstant.englishCode;
    } catch (e) {
      _logger.e("Failed to load language locale: $e");
    }
  }

  Future<void> toggleLanguage() async {
    final newLanguageCode = languageKeyCode.value == AppConstant.englishCode
        ? AppConstant.khmerCode
        : AppConstant.englishCode;
    await changeLanguage(newLanguageCode);

    // change Locale of geo locator khmer and english
    await setLocaleIdentifier(newLanguageCode);
  }

  Future<void> changeLanguage(String languageCode) async {
    EasyLoading.show();

    final SaveStoragePref savePref = SaveStoragePref();
    late Locale newLocale;

    switch (languageCode) {
      case AppConstant.englishCode:
        newLocale = const Locale(AppConstant.englishCode);
        break;
      case AppConstant.khmerCode:
        newLocale = const Locale(AppConstant.khmerCode);
        break;
      default:
        newLocale = const Locale(AppConstant.khmerCode);
        _logger
            .w("Unknown language code: $languageCode, defaulting to English");
    }

    try {
      savePref.saveSwitchLanguage(languageKey: newLocale.languageCode);
      Get.updateLocale(newLocale);
      // !
      languageKeyCode.value = newLocale.languageCode;
      _logger.f("Current Locale: $newLocale");
    } catch (e) {
      _logger.e("Failed to change language: $e");
    }
    await 0.5.delay();
    EasyLoading.dismiss();
  }
  // end language

  // logout
  void logout() async {
    try {
      final RemoveStoragePref pref = RemoveStoragePref();
      showYesNoCustomDialog(Get.context!,
          title: AppLocale.logout.tr,
          description: AppLocale.logoutDescription.tr, onYes: () async {
        EasyLoading.show();
        await pref.removeToken();
        await 1.delay();
        Get.offAllNamed(AppRoutes.LOGIN);
        EasyLoading.dismiss();
      });
    } catch (e) {
      Logger().e("message: $e");
    }
  }

  Future<void> getAppUpdate() async {
    var result = await appVersionRepoApi.getCurrentAppVersionApi();
    if (result?.data != null) {
      await checkForUpdate(result);
    }
  }

// final String nowDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  Future<void> checkForUpdate(AppVersionModel? appVersion) async {
    var data = appVersion?.data;
    final currentVersion = await appVersionReader();
    final String urlLink = GetPlatform.isIOS
        ? data?.appStoreLink ?? ""
        : data?.playStoreLink ?? "";

    String updateDate = dateFormat(appVersion);

    final String releaseDate =
        GetPlatform.isIOS ? releaseDateVersionIos : releaseDateVersionAndroid;

    final String version =
        GetPlatform.isIOS ? data?.versionIos ?? "" : data?.versionAndroid ?? "";

    if (shouldPromptUpdate(
      currentVersion: currentVersion,
      serverVersion: version,
      releaseDate: releaseDate,
      updateDate: updateDate,
    )) {
      showBeautifulUpdateDialog(
          version: version, link: urlLink, features: data?.featuresRelease);
    } else {
      xPrettyLog(message: "App is up to date!");
    }
  }

  String dateFormat(AppVersionModel? appVersion) {
    var data = appVersion?.data;

    String updateDateRaw =
        (GetPlatform.isIOS ? data?.releaseDateIos : data?.releaseDate)
            .toString();

    String updateDate = "";
    try {
      final date = DateTime.parse(updateDateRaw);
      updateDate = DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      updateDate = updateDateRaw;
    }
    return updateDate;
  }

  void showBeautifulUpdateDialog({
    required String version,
    String? features,
    String? link,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Icon / Illustration
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.main.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.system_update,
                    size: 50, color: AppColors.main),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                AppLocale.updateAvailable.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.main,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.0.d),

              // Subtitle
              Text(
                "${AppLocale.newVersion.tr} ($version) ${AppLocale.updateDescription.tr}",
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Features List
              if (features != null && features.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "✨ ${AppLocale.whatNew.tr}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.main,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: double.infinity,
                  child: Text(
                    features,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        AppLocale.later.tr,
                        style: ThemeConstands.font14Regular
                            .copyWith(color: Colors.black45),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.main,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        if (link != null && link.isNotEmpty) {
                          if (await canLaunchUrl(Uri.parse(link))) {
                            await launchUrl(Uri.parse(link),
                                mode: LaunchMode.externalApplication);
                          }
                        }
                      },
                      child: Text(
                        AppLocale.updateNow.tr,
                        style: ThemeConstands.font14SemiBold
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

enum AppUpdate { titleEventID }
