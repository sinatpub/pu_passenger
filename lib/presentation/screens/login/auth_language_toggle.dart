import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';

/// The `EN` / `ខ្មែរ` segment shown on the auth screens (`03 §Screen 2/4`),
/// replacing the flag `IconButton` they used to carry.
///
/// Shared by login and register so the two cannot drift. The toggle itself is
/// still `AppLogic.toggleLanguage`, untouched — and because that method flips
/// rather than sets, it is only called when the tap actually changes the
/// language (same guard as the profile header, S2).
class AuthLanguageToggle extends StatelessWidget {
  const AuthLanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final appLogic = Get.find<AppLogic>();

    return Obx(() {
      final isEnglish =
          appLogic.languageKeyCode.value == AppConstant.englishCode;
      return SizedBox(
        width: 132,
        child: TaSegment(
          options: const ['EN', 'ខ្មែរ'],
          selectedIndex: isEnglish ? 0 : 1,
          onChanged: (index) {
            if ((index == 0) != isEnglish) appLogic.toggleLanguage();
          },
        ),
      );
    });
  }
}
