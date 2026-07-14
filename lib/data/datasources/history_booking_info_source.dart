import 'package:com.tara.passenger/core/api_service/base_api_service.dart';
import 'package:com.tara.passenger/core/network_config/paging.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';

import 'package:com.tara.passenger/storages/get_storage.dart';
import 'package:logger/logger.dart';

import '../../core/network_config/api_handler.dart';

class HistroyBookingApi {
  Future<HistoryBookingModel> histroyBookingApi(
      {required String pageNumer}) async {
    return BaseApiService().onRequest<HistoryBookingModel>(
      path: "/taxi-passenger/history-booking-info?page=$pageNumer",
      method: "GET",
      onSuccess: (result) {
        return HistoryBookingModel.fromJson(result.data);
      },
    );
  }

  // History Pagination
  Future<Paging<Datum>?> getAllHistoryPaging(
      {int? filterStatus, int? pageNo}) async {
    ApiHandler<Paging<Datum>> handler = ApiHandler<Paging<Datum>>.get(
      converter: (json) => Paging<Datum>.fromMap(json, type: Datum),
    );

    var result = await handler.executePaging<Datum>(
        onComplete: (data) {
          return data;
        },
        onFail: (Exception e) {
          Logger().e("Request failed: ${e.toString()}");
        },
        queryParams: {
          "page": (pageNo ?? 1).toString(),
          "status": (filterStatus ?? 0).toString()
        },
        endPoint:
            "${AppConstant.baseUrlApi}/taxi-passenger/history-booking-info");

    return result;
  }
}
