import 'package:com.tara.passenger/core/network/api_client.dart';
import 'package:com.tara.passenger/core/network/result.dart';

/// P-06 (docs/12) — ported off `BaseApiService` onto `ApiClient` +
/// `Result<T>` (F-02).
class CancelBookingApi {
  CancelBookingApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Result<bool>> cancelBookingApi() {
    return _apiClient.request<bool>(
      path: "/taxi-passenger/cancel-request-booking-info",
      method: "POST",
      body: {"cancel_reason": "No Reason"},
      decode: (response) => true,
    );
  }
}
