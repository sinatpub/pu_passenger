import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/initials.dart';
import 'package:com.tara.passenger/data/models/driver_around_model.dart';
import 'package:com.tara.passenger/presentation/widgets/g_showmodal_bottom.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// The driver-info bottom sheet shown when a driver marker on the map is
/// tapped. Extracted from `MapLogic.displayDriverMarker()` (docs/01 Problem
/// 6, `08` M-1) — the controller was building ~130 lines of widget tree
/// directly, the "no widget-building code in a controller" violation
/// (`.agent/skills/architecture.md`).
///
/// **S5** moved it onto tokens and components: it was the last importer of
/// `fbtn_widget.dart`, and the legacy button could not be deleted while it
/// stood. `TaDriverCard` replaces the hand-rolled avatar + name + model row,
/// so this sheet and the booking screen's driver card now look the same. The
/// host sheet (`gShowModalBottomSheet`) was already re-skinned at F3, and the
/// `tel:` launch and the commented-out `requestBooking` call are untouched.
Future<void> showDriverInfoSheet(
  BuildContext context, {
  required Driver driver,
}) {
  return gShowModalBottomSheet(
    initialChildSize: 0.3,
    minChildSize: .2,
    context: context,
    body: (context, scrollController) {
      final name = driver.name ?? AppLocale.unKnown.tr;
      final phone = driver.phone;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocale.driverInfo.tr,
              style: TaTextStyles.titleMedium,
            ),
            const SizedBox(height: 10),
            TaDriverCard(
              name: name,
              initials: initialsFromName(driver.name),
              vehicleInfo: driver.vehicle?.model ?? '---',
              plateNumber: driver.vehicle?.plateNumber,
            ),
            if (phone != null && phone.isNotEmpty) ...[
              const SizedBox(height: 10),
              TaProfileRow(
                icon: const Icon(Icons.phone_outlined, size: 20),
                label: phone,
                onTap: () => _makePhoneCall(phone),
              ),
            ],
            const SizedBox(height: 18),
            TaButton(
              label: AppLocale.back.tr,
              variant: TaButtonVariant.ghost,
              onTap: () {
                Get.back();
                // requestBooking(
                //     isClickOnDriverMarker: true, driverID: driver.id);
              },
            ),
            const SizedBox(height: 12),
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
