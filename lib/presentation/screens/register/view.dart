import 'package:com.tara.passenger/presentation/screens/register/logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/presentation/widgets/card_atta_widget.dart';
import 'package:com.tara.passenger/presentation/widgets/fbtn_widget.dart';
import '../../../app/logic.dart';
import '../../../core/utils/app_constant.dart';
import '../../../translations/app_locale.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final RegisterLogic logic = Get.find<RegisterLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light4,
      body: SafeArea(
        top: true,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: GetBuilder<RegisterLogic>(builder: (logic) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 18,
                        ),
                        Text(
                          AppLocale.completeProfile.tr,
                          style: ThemeConstands.font20SemiBold,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          AppLocale.desRegister.tr,
                          style: ThemeConstands.font16Regular,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 28,
                        ),
                        Stack(
                          children: [
                            SizedBox(
                              width: 160,
                              height: 160,
                              child: CardUploadAttachment(
                                radius: 90,
                                onPressedIcon: () {
                                  logic.removeProfileImage();
                                },
                                image: logic.state.profileImage,
                                child: SvgPicture.asset(
                                  ImageAssets.profile,
                                  width: 60,
                                ),
                                onPressed: () {
                                  logic.showModal();
                                },
                              ),
                            ),
                            // Positioned(
                            //   top: 4,
                            //   right: 0,
                            //   child: Text("*",style: ThemeConstands.font16SemiBold.copyWith(color: AppColors.main),)
                            // ),
                            Positioned(
                              bottom: 10,
                              right: 0,
                              child: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    logic.showModal();
                                  },
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: AppColors.main,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 48,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  "Full Name - ឈ្មោះពេញ ",
                                  style: ThemeConstands.font18Regular,
                                  textAlign: TextAlign.left,
                                ),
                                // Text(
                                //   "*",
                                //   style: ThemeConstands.font18Regular
                                //       .copyWith(color: AppColors.main),
                                //   textAlign: TextAlign.left,
                                // ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            TextFormField(
                              controller: logic.controllerName,
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.text,
                              onChanged: (value) {
                                logic.state.passengerName = value;
                                logic.update();
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.light3,
                                hintText: "Enter Full Name - បញ្ចូលឈ្មោះពេញ",
                                hintStyle: ThemeConstands.font16Regular
                                    .copyWith(color: AppColors.dark3),
                                border: border,
                                enabledBorder: enableBorder,
                                focusedBorder: focusColor,
                                errorBorder: errorColor,
                              ),
                            ),
                            const SizedBox(height: 32),
                            FBTNWidget(
                              onPressed: logic.state.passengerName == "" ||
                                      logic.state.profileImage == null
                                  ? null
                                  : () {
                                      logic.passengerRegister();
                                    },
                              color: AppColors.red,
                              textColor: AppColors.light4,
                              label: AppLocale.create.tr,
                              // enableWidth: true,
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        Text(
                          AppLocale.or.tr,
                          style: ThemeConstands.font14Regular,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.black),
                          onPressed: () {
                            logic.passengerRegister();
                          },
                          child: Text(
                            AppLocale.skip.tr,
                            style: ThemeConstands.font14SemiBold,
                          ),
                        )
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
  );
  final enableBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  );
  final focusColor = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.main),
  );
  final errorColor = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.red),
  );
}
