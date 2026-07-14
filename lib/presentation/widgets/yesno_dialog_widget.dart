import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showYesNoCustomDialog(
  BuildContext context, {
  Function()? onYes,
  bool? showOnlyOkay,
  required String title,
  required String description,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(description),
            ],
          ),
        ),
        actions: <Widget>[
          showOnlyOkay == true
              ? const SizedBox()
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: Text(AppLocale.no.tr),
                  onPressed: () {
                    Get.back();
                  },
                ),
          showOnlyOkay == true
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.light1,
                    foregroundColor: AppColors.dark1,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(AppLocale.ok.tr))
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  onPressed: () {
                    Get.back();
                    if (onYes != null) {
                      onYes();
                    }
                  },
                  child: Text(AppLocale.yes.tr),
                ),
        ],
      );
    },
  );
}
