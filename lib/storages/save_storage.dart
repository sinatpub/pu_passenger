import 'package:com.tara.passenger/storages/key_storage.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/pretty_logger.dart';

class SaveStoragePref with keyStoragePref {
  void saveJsonToken({required String authModel}) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref
          .setString(jsonToken, authModel)
          .then((value) => debugPrint("Success to store json in cache"));
    } catch (e) {
      debugPrint("Unsuccessful to store json auth in cache");
    }
  }

  void saveSwitchLanguage({required String languageKey}) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref
          .setString(language, languageKey)
          .then((e) => Logger().f("complete save locale language"));
    } catch (e) {
      Logger().f("Fail save language");
    }
  }

  void saveRegister({required bool register}) async {
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      _pref
          .setBool(isRegister, register)
          .then((value) => debugPrint("Success to store json in cache"));
    } catch (e) {
      Logger().f("Fail save register");
    }
  }

  // save phone number
  void savePhoneNumber({required String phoneNum}) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString(phoneNumber, phoneNum).then(
          (value) => debugPrint("Success phone number to store json in cache"));
    } catch (e) {
      Logger().f("Fail save phone number");
    }
  }

  //// FCM TOKEN
  Future<void> setFcmToken(String fcmTokenn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(fcmToken, fcmTokenn);
    tlog("fcmToken stored in pref $fcmToken");
  }
}
