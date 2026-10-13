import 'dart:io';
import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/datasource/referral_datasource.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/repository/referral_repository.dart';
import 'package:com.tara.passenger/presentation/screens/invite/logic.dart';
import 'package:com.tara.passenger/services/booking_session.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/notification_logic.dart';

initialService() async {
  Get.put(AppLogic(), permanent: true);
  // P-08: the booking attempt must outlive the route that started it.
  Get.put(BookingSession(), permanent: true);
  Get.put(NotificationLogic(), permanent: true);
  // D40: one answer for the QR sheet, the Profile card, the rewards screen
  // and the booking sheet. It fetches nothing while the feature is off.
  Get.put(
    InviteLogic(ReferralRepository(ReferralDatasource())),
    permanent: true,
  );
  if (Platform.isAndroid) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
}
