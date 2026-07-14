import 'dart:convert';

AppVersionModel appVersionModelFromJson(String str) => AppVersionModel.fromJson(json.decode(str));

String appVersionModelToJson(AppVersionModel data) => json.encode(data.toJson());

class AppVersionModel {
  Data? data;

  AppVersionModel({
    this.data,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) => AppVersionModel(
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
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
    id: json["id"],
    appType: json["app_type"],
    releaseDate: json["release_date"] == null ? null : DateTime.parse(json["release_date"]),
    releaseDateIos: json["release_date_ios"] == null ? null : DateTime.parse(json["release_date_ios"]),
    versionAndroid: json["version_android"],
    versionIos: json["version_ios"],
    playStoreLink: json["play_store_link"],
    appStoreLink: json["app_store_link"],
    featuresRelease: json["features_release"],
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "app_type": appType,
    "release_date": "${releaseDate!.year.toString().padLeft(4, '0')}-${releaseDate!.month.toString().padLeft(2, '0')}-${releaseDate!.day.toString().padLeft(2, '0')}",
    "release_date_ios": "${releaseDateIos!.year.toString().padLeft(4, '0')}-${releaseDateIos!.month.toString().padLeft(2, '0')}-${releaseDateIos!.day.toString().padLeft(2, '0')}",
    "version_android": versionAndroid,
    "version_ios": versionIos,
    "play_store_link": playStoreLink,
    "app_store_link": appStoreLink,
    "features_release": featuresRelease,
    "is_active": isActive,
  };
}
