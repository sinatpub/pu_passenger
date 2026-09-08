import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/presentation/screens/profile/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/fbtn_widget.dart';
import 'package:com.tara.passenger/presentation/widgets/t_image_widget.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileLogic logic = Get.find<ProfileLogic>();
  final AppLogic appLogic = Get.find<AppLogic>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1, color: AppColors.light1),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileInfo(),
              _buildSettingsSection(),
              // FBTNWidget(
              //   label: AppLocale.logout.tr,
              //   onPressed: () {
              //     appLogic.logout();
              //   },
              //   color: Colors.white,
              //   textStyle: AppTextStyles.body.copyWith(color: Colors.black),
              //   prefix: const Icon(
              //     size: 20,
              //     Icons.logout,
              //     color: Colors.black,
              //   ),
              //   centerTitle: false,
              // )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocale.profile.tr,
            style:
                ThemeConstands.font22SemiBold.copyWith(color: AppColors.dark1),
          ),
          Obx(
            () => IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Get.find<AppLogic>().toggleLanguage();
              },
              icon: appLogic.languageKeyCode.value == AppConstant.englishCode
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
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TImageWidget(
                image: NetworkImage(
                    "${logic.state.data.value?.data?.profileImage}"),
                width: 80,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    logic.state.data.value?.data?.name ?? "---",
                    style: ThemeConstands.font22SemiBold
                        .copyWith(color: AppColors.dark1),
                  ),
                  Text(
                    AppLocale.seeProfile.tr,
                    style: ThemeConstands.font14Regular
                        .copyWith(color: AppColors.dark1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   AppLocale.setting.tr,
          //   style:
          //       ThemeConstands.font16SemiBold.copyWith(color: AppColors.dark1),
          // ),
          const SizedBox(
            height: 8,
          ),
          FBTNWidget(
            label: AppLocale.termNCondition.tr,
            onPressed: () async {
              Get.toNamed(AppRoutes.TERMCONDITION);
              // TaxiNotification.shared.notifyBooking(
              //   title: "title",
              //   isSound: false,
              // );
            },
            color: Colors.white,
            textStyle:
                AppTextStyles.body.copyWith(color: Colors.black, fontSize: 16),
            prefix: const Icon(
                size: 20, CupertinoIcons.doc_text, color: AppColors.main),
            centerTitle: false,
          ),
          const SizedBox(
            height: 12,
          ),
          FBTNWidget(
            label: AppLocale.contactUs.tr,
            onPressed: () async {
              // TaxiNotification.shared.notifyBooking(
              //   title: "title",
              //   isSound: true,
              // );
              Get.toNamed(AppRoutes.CONTACTUS);
            },
            color: Colors.white,
            textStyle:
                AppTextStyles.body.copyWith(color: Colors.black, fontSize: 16),
            prefix: const Icon(
              size: 20,
              CupertinoIcons.person_crop_circle_fill,
              color: AppColors.main,
            ),
            centerTitle: false,
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }
}

BorderSide get customBorderSide => BorderSide(
      color: AppColors.dark2.withAlpha(10),
      width: 1,
    );

class Item {
  final IconData icon;
  final String title;
  final int actionIndex;

  Item({required this.icon, required this.title, required this.actionIndex});
}
