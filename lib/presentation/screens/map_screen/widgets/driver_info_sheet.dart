import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/data/models/driver_around_model.dart';
import 'package:com.tara.passenger/presentation/widgets/fbtn_widget.dart';
import 'package:com.tara.passenger/presentation/widgets/g_showmodal_bottom.dart';
import 'package:com.tara.passenger/presentation/widgets/x_network_image.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// The driver-info bottom sheet shown when a driver marker on the map is
/// tapped. Extracted from `MapLogic.displayDriverMarker()` (docs/01 Problem
/// 6, `08` M-1) — the controller was building ~130 lines of widget tree
/// directly, the "no widget-building code in a controller" violation
/// (`.agent/skills/architecture.md`). Pure move; behavior unchanged.
Future<void> showDriverInfoSheet(
  BuildContext context, {
  required Driver driver,
}) {
  return gShowModalBottomSheet(
    initialChildSize: 0.3,
    minChildSize: .2,
    context: context,
    body: (context, scrollController) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocale.driverInfo.tr,
              style: ThemeConstands.font14SemiBold,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: ClipOval(
                    child: XNetworkImage(
                      src: driver.profileImage ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.name ?? AppLocale.unKnown.tr,
                        style: ThemeConstands.font16SemiBold),
                    Text(driver.vehicle?.model ?? "",
                        style: ThemeConstands.font14SemiBold),
                    InkWell(
                      onTap: () {
                        if (driver.phone != null && driver.phone!.isNotEmpty) {
                          _makePhoneCall(driver.phone!);
                        }
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone,
                                size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              driver.phone ?? "",
                              style: ThemeConstands.font14SemiBold.copyWith(
                                color: Colors.blue, // Visual cue that it's a link
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 28),
            Center(
              child: FBTNWidget(
                onPressed: () {
                  Get.back();
                  // requestBooking(
                  //     isClickOnDriverMarker: true, driverID: driver.id);
                },
                color: AppColors.main,
                textColor: AppColors.light4,
                label: AppLocale.back.tr,
                width: MediaQuery.of(context).size.width / 2,
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    debugPrint('Could not launch $phoneNumber');
  }
}
