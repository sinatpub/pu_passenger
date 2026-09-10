import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/core/utils/phone_formatter.dart';
import 'package:com.tara.passenger/presentation/screens/login/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/fbtn_widget.dart';
import 'package:com.tara.passenger/presentation/widgets/shake_widget.dart';
import 'package:com.tara.passenger/presentation/widgets/x_text_field.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../app/logic.dart';
import '../../../core/utils/app_constant.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final LoginLogic logic = Get.find<LoginLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light4,
      body: SafeArea(
        bottom: false,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0.d),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 25),
            child: Column(
              children: [
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.topRight,
                  child: Obx(
                    () => IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Get.find<AppLogic>().toggleLanguage();
                      },
                      icon: Get.find<AppLogic>().languageKeyCode.value ==
                              AppConstant.englishCode
                          ? Image.asset(
                              ImageAssets.flag_en,
                              width: 30,
                            )
                          : SvgPicture.asset(
                              ImageAssets.flag_km,
                              width: 30,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  AppLocale.titleLogin.tr,
                  style: ThemeConstands.font20SemiBold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Text(
                  AppLocale.desLogin.tr,
                  style: ThemeConstands.font16Regular,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.phoneNumber.tr,
                      style: ThemeConstands.font18Regular,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 12),
                    ShakeWidget(
                      key: logic.phoneShake,
                      shakeCount: 3,
                      shakeOffset: 10,
                      shakeDuration: const Duration(milliseconds: 500),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: XTextField(
                          textController: logic.phoneTextController,
                          hintText: AppLocale.enterPhoneNumber.tr,
                          enable: !logic.state.isLoading.value,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(12),
                            CardNumberInputFormatter(),
                          ],
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(top: 2.0),
                            child: Text(
                              "+855",
                              style: ThemeConstands.font16SemiBold,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          hasShadow: false,
                          borderColor: AppColors.dark1,
                          maxLength: 25,
                          onChanged: (value) =>
                              logic.state.phoneNumber.value = value,
                          onFieldSubmitted: (value) => logic.phoneLogin(
                              logic.state.phoneNumber.value, context),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ),
                    const SizedBox(height: 38),
                    FBTNWidget(
                      onPressed: () async {
                        logic.phoneLogin(
                            logic.state.phoneNumber.value, context);
                      },
                      color: AppColors.red,
                      textColor: AppColors.light4,
                      label: AppLocale.next.tr,
                      // enableWidth: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
