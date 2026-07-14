import 'package:com.tara.passenger/storages/key_storage.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoveStoragePref with keyStoragePref {
  removeToken() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.remove(jsonToken);
    } catch (e) {
      debugPrint("Fail to remove pref $e");
    }
  }

  // remove language
  removeLanguagePref(context) async {
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      await _pref
          .remove(language)
          .then((e) => Logger().f("Removed language pref "));
    } catch (e) {
      Logger().e("Fail to remove pref $e");
    }
  }

  // remove isRegister
  removeRegisterPref() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.remove(isRegister);
    }catch(e){
      Logger().e("Fail to remove pref $e");
    }
  }

  // remove phone number
  removePhonePref() async {
    try{
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.remove(phoneNumber);

    }catch(e){
      Logger().e("Fail to remove pref $e");
    }
  }
}
