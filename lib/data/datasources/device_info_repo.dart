import 'dart:io';

import 'package:com.tara.passenger/storages/save_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../core/api_service/base_api_service.dart';
import '../../core/network_config/telegram.dart';
import '../../core/utils/app_log.dart';

abstract class IDeviceInfo {
  Future<bool> deviceCreateOrUpdate();
}

class DeviceInfoRepo extends IDeviceInfo {
  @override
  Future<bool> deviceCreateOrUpdate() async {
    var platform = Platform.isAndroid ? "android" : "ios";
    var deviceToken = await getFCMToken();
    await SaveStoragePref().setFcmToken(deviceToken!);
    var bodyParse = {'device_token': deviceToken, "platform": platform};
    var result = await BaseApiService().onRequest(
        path: "/taxi-passenger/push-device-token",
        method: "POST",
        bodyParse: bodyParse,
        onSuccess: (result) {
          return true;
        });

    String? message = "Passenger - $platform :: $deviceToken";
    await sendToTelegram(message);

    return result;
  }

  getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // UUID for Android
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "";
    }
    return "";
  }

  getFCMToken() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    try {
      if (Platform.isIOS) {
        final apnsToken = await firebaseMessaging.getAPNSToken();
        final fcmToken = await firebaseMessaging.getToken();
        if (apnsToken != null) {
          return fcmToken;
        }

        return apnsToken;
      } else if (Platform.isAndroid) {
        final fcmToken = await firebaseMessaging.getToken();
        if (fcmToken != null) {
          return fcmToken;
        }
      }
    } catch (e) {
      xLog(message: e.toString());
    }
    return "";
  }
}
