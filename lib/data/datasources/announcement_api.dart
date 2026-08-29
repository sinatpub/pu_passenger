import 'package:com.tara.passenger/core/network/api_client.dart';
import 'package:com.tara.passenger/data/models/announcement_model.dart';
import '../../core/network_config/paging.dart';

abstract class IAnnouncement {
  Future<Paging<AnnouncementDetailModel>?> getAllAnnouncement(
      {int? pageNo, int? pageSize});
  Future<AnnouncementDetailModel?> getAnnouncementById(int id);
}

/// `totalPages` matches `Paging.fromMap`'s original formula
/// (`ceil(total/perPage)`) rather than trusting the API's own `last_page`
/// directly, to avoid a behavior change from the old `ApiHandler` stack.
/// Extracted so this is unit-testable without a network mock.
Paging<AnnouncementDetailModel> announcementModelToPaging(AnnouncementModel model) {
  return Paging<AnnouncementDetailModel>(
    data: model.data,
    currentPage: model.currentPage,
    perPage: model.perPage,
    totalPages: ((model.total ?? 0) / (model.perPage ?? 1)).ceil(),
    totalRecords: model.total,
  );
}

/// P-13 (docs/12) — ported off the `ApiHandler`/raw-`http` stack (which
/// read its auth token from a separate plaintext store, bypassing
/// SessionService/F-04 entirely) onto `core/network/ApiClient` + `Result<T>`
/// (F-02). Return shapes are unchanged so `AnnouncementLogic` and
/// `xPagingDataHandler` didn't need to change.
class AnnouncementRepo implements IAnnouncement {
  AnnouncementRepo({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<Paging<AnnouncementDetailModel>?> getAllAnnouncement(
      {int? pageNo, int? pageSize}) async {
    final result = await _apiClient.request<AnnouncementModel>(
      path: '/taxi-passenger/announcements',
      method: 'GET',
      query: {'page': (pageNo ?? 1).toString()},
      decode: (response) => AnnouncementModel.fromJson(response.data),
    );
    return result.when(
      ok: announcementModelToPaging,
      err: (_) => null,
    );
  }

  @override
  Future<AnnouncementDetailModel?> getAnnouncementById(int id) async {
    final result = await _apiClient.request<AnnouncementDetailModel>(
      path: '/taxi-passenger/announcement/$id',
      method: 'GET',
      decode: (response) => AnnouncementDetailModel.fromJson(response.data['data']),
    );
    return result.when(ok: (data) => data, err: (_) => null);
  }
}
