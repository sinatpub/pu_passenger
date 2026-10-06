import 'package:com.tara.passenger/core/utils/json_field.dart';

class PhoneNumberModel {
  Data data;
  bool status;
  String message;

  PhoneNumberModel({
    required this.data,
    required this.status,
    required this.message,
  });

  factory PhoneNumberModel.fromJson(Map<String, dynamic> json) =>
      PhoneNumberModel(
        // Still fails without `data`: an answer that carries no resend time
        // is a code that was not sent, and the caller says so.
        data: Data.fromJson(json["data"]),
        status: boolOrDefault(json["status"]),
        message: stringOrEmpty(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "status": status,
        "message": message,
      };
}

class Data {
  int seconde;

  Data({
    required this.seconde,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        // A number or numeric text; 30 s is the OTP screen's own default.
        seconde: intOrDefault(json["seconde"], fallback: 30),
      );

  Map<String, dynamic> toJson() => {
        "seconde": seconde,
      };
}
