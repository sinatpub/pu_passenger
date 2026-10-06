import 'package:com.tara.passenger/core/utils/json_field.dart';
import 'dart:convert';

AppVersionModel appVersionModelFromJson(String str) =>
    AppVersionModel.fromJson(json.decode(str));

String appVersionModelToJson(AppVersionModel data) =>
    json.encode(data.toJson());

class AppVersionModel {
  Data? data;

  AppVersionModel({
    this.data,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) =>
      AppVersionModel(
        data: json["data"] is Map<String, dynamic>
            ? Data.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
      };
}

class Data {
  int? id;
  int? appType;
  DateTime? releaseDate;
  DateTime? releaseDateIos;
  String? versionAndroid;
  String? versionIos;
  String? playStoreLink;
  String? appStoreLink;
  String? featuresRelease;
  bool? isActive;

  Data({
    this.id,
    this.appType,
    this.releaseDate,
    this.releaseDateIos,
    this.versionAndroid,
    this.versionIos,
    this.playStoreLink,
    this.appStoreLink,
    this.featuresRelease,
    this.isActive,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: intOrNull(json["id"]),
        appType: intOrNull(json["app_type"]),
        releaseDate: dateOrNull(json["release_date"]),
        releaseDateIos: dateOrNull(json["release_date_ios"]),
        versionAndroid: stringOrNull(json["version_android"]),
        versionIos: stringOrNull(json["version_ios"]),
        playStoreLink: stringOrNull(json["play_store_link"]),
        appStoreLink: stringOrNull(json["app_store_link"]),
        featuresRelease: stringOrNull(json["features_release"]),
        isActive: _asBool(json["is_active"]),
      );

  /// The API sends `is_active` as `1`/`0`; accept a real bool too.
  static bool? _asBool(Object? value) => switch (value) {
        bool b => b,
        num n => n != 0,
        String s => s == '1' || s.toLowerCase() == 'true',
        _ => null,
      };

  Map<String, dynamic> toJson() => {
        "id": id,
        "app_type": appType,
        "release_date":
            "${releaseDate!.year.toString().padLeft(4, '0')}-${releaseDate!.month.toString().padLeft(2, '0')}-${releaseDate!.day.toString().padLeft(2, '0')}",
        "release_date_ios":
            "${releaseDateIos!.year.toString().padLeft(4, '0')}-${releaseDateIos!.month.toString().padLeft(2, '0')}-${releaseDateIos!.day.toString().padLeft(2, '0')}",
        "version_android": versionAndroid,
        "version_ios": versionIos,
        "play_store_link": playStoreLink,
        "app_store_link": appStoreLink,
        "features_release": featuresRelease,
        "is_active": isActive,
      };
}
