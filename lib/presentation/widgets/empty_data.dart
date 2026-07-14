import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class EmptyData extends StatelessWidget {
  const EmptyData(
      {super.key, this.size, this.message, this.isNeedShowFullScreen = false});
  final double? size;
  final String? message;
  final isNeedShowFullScreen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isNeedShowFullScreen ? Get.height * 0.85 : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SizedBox.square(
          //   dimension: (size ?? 100.0.d),
          //   child: SvgPicture.asset(
          //     Assets.svg.appStoreIOS,
          //     fit: BoxFit.contain,
          //   ),
          // ),

          const SizedBox(height: 8.0),
          Text(
            message ?? AppLocale.noResultFound.tr,
            textAlign: TextAlign.center,

            // style: textDisplaySmall(
            //     color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
