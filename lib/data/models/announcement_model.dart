import 'package:com.tara.passenger/core/utils/json_field.dart';
import 'package:com.tara.passenger/core/utils/json_list.dart';

class AnnouncementModel {
  bool? status;
  List<AnnouncementDetailModel>? data;
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  AnnouncementModel({
    this.status,
    this.data,
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      AnnouncementModel(
        status: boolOrNull(json["status"]),
        data: parseJsonList<AnnouncementDetailModel>(
            json["data"], (x) => AnnouncementDetailModel.fromJson(x)),
        currentPage: intOrNull(json["current_page"]),
        lastPage: intOrNull(json["last_page"]),
        perPage: intOrNull(json["per_page"]),
        total: intOrNull(json["total"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "current_page": currentPage,
        "last_page": lastPage,
        "per_page": perPage,
        "total": total,
      };
}

class AnnouncementDetailModel {
  int? id;
  String? title;
  String? description;
  DateTime? releaseDate;
  DateTime? expiredDate;
  int? target;
  dynamic status;
  int? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<dynamic>? files;

  AnnouncementDetailModel({
    this.id,
    this.title,
    this.description,
    this.releaseDate,
    this.expiredDate,
    this.target,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.files,
  });

  factory AnnouncementDetailModel.fromJson(Map<String, dynamic> json) =>
      AnnouncementDetailModel(
        id: intOrNull(json["id"]),
        title: stringOrNull(json["title"]),
        description: stringOrNull(json["description"]),
        releaseDate: dateOrNull(json["release_date"]),
        expiredDate: dateOrNull(json["expired_date"]),
        target: intOrNull(json["target"]),
        status: json["status"],
        createdBy: intOrNull(json["created_by"]),
        createdAt: dateOrNull(json["created_at"]),
        updatedAt: dateOrNull(json["updated_at"]),
        files: json["files"] is List
            ? List<dynamic>.from(json["files"])
            : <dynamic>[],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "release_date":
            "${releaseDate!.year.toString().padLeft(4, '0')}-${releaseDate!.month.toString().padLeft(2, '0')}-${releaseDate!.day.toString().padLeft(2, '0')}",
        "expired_date":
            "${expiredDate!.year.toString().padLeft(4, '0')}-${expiredDate!.month.toString().padLeft(2, '0')}-${expiredDate!.day.toString().padLeft(2, '0')}",
        "target": target,
        "status": status,
        "created_by": createdBy,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "files": files == null ? [] : List<dynamic>.from(files!.map((x) => x)),
      };
}
