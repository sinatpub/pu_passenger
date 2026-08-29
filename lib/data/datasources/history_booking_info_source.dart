import 'package:com.tara.passenger/core/network/api_client.dart';
import 'package:com.tara.passenger/core/network_config/paging.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';

/// `totalPages` matches `Paging.fromMap`'s original formula
/// (`ceil(total/perPage)`), since `HistoryBookingModel` has no `last_page`
/// field to compare against. Extracted so this is unit-testable without a
/// network mock.
Paging<Datum> historyBookingModelToPaging(HistoryBookingModel model) {
  return Paging<Datum>(
    data: model.data,
    currentPage: model.currentPage,
    perPage: model.perPage,
    totalPages: ((model.total ?? 0) / (model.perPage ?? 1)).ceil(),
    totalRecords: model.total,
  );
}

/// P-12 (docs/12) — ported off `ApiHandler`/raw-`http` onto
/// `core/network/ApiClient` + `Result<T>` (F-02), same as P-13's
/// announcements. `histroyBookingApi()`, the old non-paginated
/// `BaseApiService`-based method, had no callers anywhere in the app and
/// is dropped rather than ported.
class HistroyBookingApi {
  HistroyBookingApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Paging<Datum>?> getAllHistoryPaging({int? filterStatus, int? pageNo}) async {
    final result = await _apiClient.request<HistoryBookingModel>(
      path: '/taxi-passenger/history-booking-info',
      method: 'GET',
      query: {
        'page': (pageNo ?? 1).toString(),
        'status': (filterStatus ?? 0).toString(),
      },
      decode: (response) => HistoryBookingModel.fromJson(response.data),
    );
    return result.when(ok: historyBookingModelToPaging, err: (_) => null);
  }
}
