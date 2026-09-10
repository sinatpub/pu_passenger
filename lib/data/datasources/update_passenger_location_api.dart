import 'package:com.tara.passenger/core/network/api_client.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/data/models/passenger_location_model.dart';

/// P-06 (docs/12) — ported off `BaseApiService` onto `ApiClient` +
/// `Result<T>` (F-02).
class UpdatePassengerLocationApi {
  UpdatePassengerLocationApi({ApiClient? apiClient}) : _injectedClient = apiClient;

  final ApiClient? _injectedClient;

  /// Lazy for the same reason as `RequestBookingApi`: constructing this class
  /// must not build a Dio-backed client, so a test subclass can override the
  /// request method without touching the network stack.
  late final ApiClient _apiClient = _injectedClient ?? ApiClient();

  Future<Result<UpdateLocationModel>> updatePassengerLocationApi(
      {required String lat, required String lng}) {
    return _apiClient.request<UpdateLocationModel>(
      path: "/taxi-passenger/update-passenger-location",
      method: "POST",
      body: {"latitude": lat, "longitude": lng},
      decode: (response) => UpdateLocationModel.fromJson(response.data),
    );
  }
}
