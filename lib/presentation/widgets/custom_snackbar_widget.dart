import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

showCustomSnackBar({
  required String title,
  required String message,
  Color? backgroundColor,
  Color? color,
  bool isError = false,
  Widget? icon,
  Widget? iconTrailing,
}) {
  toastification.showCustom(
    context: Get.context,
    autoCloseDuration: const Duration(seconds: 2),
    alignment: Alignment.topCenter,
    builder: (BuildContext context, ToastificationItem holder) {
      return Container(
        decoration: BoxDecoration(
          color: TaColors.surface,
          border: Border.all(color: TaColors.error, width: .1),
          borderRadius: BorderRadius.circular(18),
        ),

        // getBoxDecoration(background: Colors.white, hasShadow: true),
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // icon ?? const Icon(Icons.home),
                const SizedBox(
                  height: 15.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Get.width * 0.8,
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    // const SizedBox(
                    //   height: 15.0,
                    // ),
                    // SizedBox(
                    //   width: Get.width * 0.6,
                    //   child: Text(
                    //     message,
                    //     overflow: TextOverflow.ellipsis,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
            iconTrailing ?? const SizedBox()
          ],
        ),
      );
    },
  );
}
