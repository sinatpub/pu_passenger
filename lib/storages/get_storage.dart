// ignore_for_file: avoid_print, unnecessary_null_comparison
import 'dart:convert';
import 'package:com.tara.passenger/data/models/user_response_model.dart';
import 'package:com.tara.passenger/storages/key_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/pretty_logger.dart';

class GetStoragePref with keyStoragePref {
  Future<UserResponseModel> get getJsonToken async {
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      String? data = _pref.getString(jsonToken) ?? "";
      if (data.isEmpty) {
        return UserResponseModel(); // Return a default instance if data is empty
      }

      var result = json.decode(data);
      return UserResponseModel.fromJson(result);
    } catch (e) {
      throw Exception("Failed to retrieve and parse JSON token: $e");
    }
  }

  Future<String?> get languagePrefKey async {
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      String? data = _pref.getString(language) ?? null;

      return data;
    } catch (e) {
      throw Exception("Failed to retrieve and parse JSON language: $e");
    }
  }

  Future<bool> get isRegisterPref async {
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      bool? data = _pref.getBool(isRegister) ?? false;
      return data;
    } catch (e) {
      throw Exception("Failed to retrieve and parse JSON language: $e");
    }
  }

  Future<String?> get phoneNumberPref async {
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      String? data = _pref.getString(phoneNumber);
      return data;
    } catch (e) {
      throw Exception("Failed to retrieve and parse JSON language: $e");
    }
  }

  ////// FCM TOKEN
  Future<String?> getFcmTokenLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var fcmPref = prefs.getString(fcmToken);
    tlog("get pref FCM TOKEN $fcmPref");
    return fcmPref;
  }
}
