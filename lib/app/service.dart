import 'dart:io';
import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/services/booking_session.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../service/notification_logic.dart';

initialService() async {
  Get.put(AppLogic(), permanent: true);
  // P-08: the booking attempt must outlive the route that started it.
  Get.put(BookingSession(), permanent: true);
  Get.put(NotificationLogic(), permanent: true);
  if (Platform.isAndroid) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
}
