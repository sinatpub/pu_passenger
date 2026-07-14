import 'package:com.tara.passenger/data/models/history_booking_model.dart';

import '../../data/models/announcement_model.dart';

class Paging<T> {
  final List<T>? data;
  final int? currentPage;
  final int? perPage;
  final int? totalPages;
  final int? totalRecords;

  Paging({
    this.data,
    this.currentPage,
    this.perPage,
    this.totalPages,
    this.totalRecords,
  });

  @override
  String toString() {
    return 'Paging{data: $data, pageNo: $currentPage, pageSize: $perPage, totalPages: $totalPages, totalRecords: $totalRecords}';
  }

  factory Paging.fromMap(Map<String, dynamic> json, {required Type type}) {
    final List<T> mappedData = (json['data'] as List<dynamic>)
        .map<T>((item) => factoryDataList(type, item))
        .toList();

    return Paging(
      data: mappedData,
      currentPage:
          json['current_page'] as int?, // <-- maps `current_page` to `pageNo`
      perPage: json['per_page'] as int?,
      totalPages: ((json['total'] ?? 0) / (json['per_page'] ?? 1)).ceil(),
      totalRecords: json['total'] as int?,
    );
  }

  static final Map<Type, dynamic Function(Map<String, dynamic>)> _dataFactory =
      {
    Datum: Datum.fromJson,
    AnnouncementDetailModel: AnnouncementDetailModel.fromJson,
  };

  static T factoryDataList<T>(Type type, dynamic data) {
    if (data is String || data is num || data is bool) {
      return data as T;
    }
    final factoryFunc = _dataFactory[type];
    if (factoryFunc != null) {
      return factoryFunc(data) as T;
    }
    throw Exception("No factory found for type $type");
  }
}
