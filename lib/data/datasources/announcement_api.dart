import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:com.tara.passenger/data/models/announcement_model.dart';
import '../../core/api_service/base_api_service.dart';
import '../../core/network_config/api_handler.dart';
import '../../core/network_config/paging.dart';
import '../../core/utils/app_constant.dart';

abstract class IAnnouncement {
  Future<Paging<AnnouncementDetailModel>?> getAllAnnouncement(
      {int? pageNo, int? pageSize});
  Future<AnnouncementDetailModel?> getAnnouncementById(int id);
}

class AnnouncementRepo implements IAnnouncement {
  @override
  Future<Paging<AnnouncementDetailModel>?> getAllAnnouncement(
      {int? pageNo, int? pageSize}) async {
    ApiHandler<Paging<AnnouncementDetailModel>> handler =
        ApiHandler<Paging<AnnouncementDetailModel>>.get(
      converter: (json) => Paging<AnnouncementDetailModel>.fromMap(
        json,
        type: AnnouncementDetailModel,
      ),
    );

    var result = await handler.executePaging<AnnouncementDetailModel>(
        onComplete: (data) {
          return data;
        },
        queryParams: {
          "page": (pageNo ?? 1).toString(),
        },
        endPoint: "${AppConstant.baseUrlApi}/taxi-passenger/announcements");
    return result;
  }

  @override
  Future<AnnouncementDetailModel?> getAnnouncementById(int id) {
    return BaseApiService().onRequest<AnnouncementDetailModel>(
      path: "/taxi-passenger/announcement/$id",
      method: "GET",
      onSuccess: (result) {
        return AnnouncementDetailModel.fromJson(result.data['data']);
      },
    );
  }
}
