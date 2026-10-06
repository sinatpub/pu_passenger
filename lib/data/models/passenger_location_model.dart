import 'package:com.tara.passenger/core/utils/json_field.dart';

class UpdateLocationModel {
  Data? data;
  bool? status;
  String? message;

  UpdateLocationModel({
    this.data,
    this.status,
    this.message,
  });

  factory UpdateLocationModel.fromJson(Map<String, dynamic> json) =>
      UpdateLocationModel(
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
  int? userId;
  String? latitude;
  String? longitude;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? id;

  Data({
    this.userId,
    this.latitude,
    this.longitude,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: intOrNull(json["user_id"]),
        latitude: stringOrNull(json["latitude"]),
        longitude: stringOrNull(json["longitude"]),
        updatedAt: dateOrNull(json["updated_at"]),
        createdAt: dateOrNull(json["created_at"]),
        id: intOrNull(json["id"]),
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "latitude": latitude,
        "longitude": longitude,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "id": id,
      };
}
