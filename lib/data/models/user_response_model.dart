import 'package:com.tara.passenger/core/utils/json_field.dart';

class UserResponseModel {
  Data? data;
  bool? status;
  String? message;

  UserResponseModel({
    this.data,
    this.status,
    this.message,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) =>
      UserResponseModel(
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
  // int? gender;
  String? dob;
  String? countryCode;
  String? phone;
  dynamic cardType;
  dynamic cardNumber;
  dynamic cardImage;
  int? status;
  String? statusDate;
  int? roleId;
  String? profileImage;
  LastLocation? lastLocation;

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
        profileImage: stringOrNull(json["profile_image"]),
        lastLocation: json["last_location"] is Map<String, dynamic>
            ? LastLocation.fromJson(json["last_location"])
            : null,
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
        "last_location": lastLocation?.toJson(),
      };
}

class LastLocation {
  String? latitude;
  String? longitude;

  LastLocation({
    this.latitude,
    this.longitude,
  });

  factory LastLocation.fromJson(Map<String, dynamic> json) => LastLocation(
        latitude: stringOrNull(json["latitude"]),
        longitude: stringOrNull(json["longitude"]),
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}
