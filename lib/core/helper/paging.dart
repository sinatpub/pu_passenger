import 'package:com.tara.passenger/data/models/history_booking_model.dart';

import '../../data/models/announcement_model.dart';

class Paging<T> {
  List<T>? data;
  int? pageNo;
  int? pageSize;
  int? totalPages;
  int? totalRecords;

  Paging({
    this.data,
    this.pageNo,
    this.pageSize,
    this.totalPages,
    this.totalRecords,
  });

  @override
  String toString() {
    return 'Paging{data: $data, pageNo: $pageNo, pageSize: $pageSize, totalPage: $totalPages, totalRecords: $totalRecords}';
  }

  factory Paging.fromMap(Map<String, dynamic> data, {required Type type}) {
    final totalRecords = data['total'] as int? ?? 0;
    final pageSize = data['per_page'] as int? ?? 10;

    return Paging(
      data: (data['data'] as List<dynamic>)
          .map<T>((e) => factoryDataList(type, e))
          .toList(),
      pageNo: data['current_page'] as int?,
      pageSize: pageSize,
      totalPages: (totalRecords / pageSize).ceil(),
      totalRecords: totalRecords,
    );
  }

  static final _dataFactory = <Type, dynamic Function(Map<String, dynamic>)>{
    Datum: Datum.fromJson,
    AnnouncementDetailModel: AnnouncementDetailModel.fromJson,
    // HistoryBookingModel: HistoryBookingModel.fromJson,
  };

  static factoryDataList(Type type, data) {
    if (data is String || data is num || data is bool) {
      return data;
    }
    return _dataFactory[type]?.call(data);
  }
}
