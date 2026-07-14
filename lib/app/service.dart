import 'dart:io';
import 'package:com.tara.passenger/app/logic.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../service/notification_logic.dart';

initialService() async {
  Get.put(AppLogic(), permanent: true);
  Get.put(NotificationLogic(), permanent: true);
  if (Platform.isAndroid) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
}
