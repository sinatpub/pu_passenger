// ignore: camel_case_types
mixin class keyStoragePref {
  static const String _jsonToken = 'jsonToken';
  static const String _language = 'language';
  static const String _register = "isRegister";
  static const String _phoneNumber = "phoneNumber";
  static const String _fcmTokenData = "fcmTokenData";

  String get jsonToken => _jsonToken;
  String get language => _language;
  String get isRegister => _register;
  String get phoneNumber => _phoneNumber;
  String get fcmToken => _fcmTokenData;
}
