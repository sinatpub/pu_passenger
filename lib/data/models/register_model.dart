import 'package:com.tara.passenger/core/utils/json_field.dart';

class RegisterModel {
  Data? data;
  bool? status;
  String? message;

  RegisterModel({
    this.data,
    this.status,
    this.message,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
        data: json["data"] is Map<String, dynamic>
            ? Data.fromJson(json["data"])
            : null,
        status: boolOrNull(json["status"]),
        message: stringOrNull(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "status": status,
        "message": message,
      };
}

class Data {
  User? user;
  String? token;

  Data({
    this.user,
    this.token,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: json["user"] is Map<String, dynamic>
            ? User.fromJson(json["user"])
            : null,
        token: stringOrNull(json["token"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "token": token,
      };
}

class User {
  int? id;
  String? name;
  String? lastName;
  String? firstName;
  dynamic email;
  // String? gender;
  String? dob;
  String? countryCode;
  String? phone;
  dynamic cardType;
  dynamic cardNumber;
  dynamic cardImage;
  int? status;
  String? statusDate;
  int? roleId;
  dynamic profileImage;
  dynamic lastLocation;

  User({
    this.id,
    this.name,
    this.lastName,
    this.firstName,
    this.email,
    // this.gender,
    this.dob,
    this.countryCode,
    this.phone,
    this.cardType,
    this.cardNumber,
    this.cardImage,
    this.status,
    this.statusDate,
    this.roleId,
    this.profileImage,
    this.lastLocation,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: intOrNull(json["id"]),
        name: stringOrNull(json["name"]),
        lastName: stringOrNull(json["last_name"]),
        firstName: stringOrNull(json["first_name"]),
        email: json["email"],
        // gender: json["gender"],
        dob: stringOrNull(json["dob"]),
        countryCode: stringOrNull(json["country_code"]),
        phone: stringOrNull(json["phone"]),
        cardType: json["card_type"],
        cardNumber: json["card_number"],
        cardImage: json["card_image"],
        status: intOrNull(json["status"]),
        statusDate: stringOrNull(json["status_date"]),
        roleId: intOrNull(json["role_id"]),
        profileImage: json["profile_image"],
        lastLocation: json["last_location"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "last_name": lastName,
        "first_name": firstName,
        "email": email,
        // "gender": gender,
        "dob": dob,
        "country_code": countryCode,
        "phone": phone,
        "card_type": cardType,
        "card_number": cardNumber,
        "card_image": cardImage,
        "status": status,
        "status_date": statusDate,
        "role_id": roleId,
        "profile_image": profileImage,
        "last_location": lastLocation,
      };
}
