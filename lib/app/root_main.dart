import 'package:com.tara.passenger/core/theme/app_theme.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/main.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_translation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      gestures: const [
        GestureType.onTap,
        GestureType.onPanUpdateDownDirection,
      ],
      child: GetMaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.SPLASH,
        translations: AppTranslation(),
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 500),
        locale: const Locale(AppConstant.englishCode),
        fallbackLocale: const Locale(AppConstant.khmerCode),
        getPages: AppPages.pages,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          final easyLoading = EasyLoading.init()(context, child);
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: easyLoading,
          );
        },
      ),
    );
  }
}
