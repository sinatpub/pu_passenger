import 'package:com.tara.passenger/core/network/api_client.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';

/// P-06 (docs/12) — ported off `BaseApiService` onto `ApiClient` +
/// `Result<T>` (F-02) for consistency with the rest of the app.
/// `MapLogic`'s map/marker/booking-request behavior is unchanged.
class RequestBookingApi {
  RequestBookingApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Result<RequestBookingModel>> requestBookingApi({
    required double startLatitude,
    required double startLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    String? address,
    String? destinationAddress,
    int? typeVehicleId,
  }) {
    final body = <String, dynamic>{
      "start_latitude": startLatitude.toString(),
      "start_longitude": startLongitude.toString(),
    };

    if (destinationLatitude != null) {
      body["end_latitude"] = destinationLatitude.toString();
    }
    if (destinationLongitude != null) {
      body["end_longitude"] = destinationLongitude.toString();
    }
    if (address != null) {
      body["start_address"] = address;
    }
    if (typeVehicleId != null) {
      body["type_vehicle_id"] = typeVehicleId;
    }

    return _apiClient.request<RequestBookingModel>(
      path: "/taxi-passenger/request-booking",
      method: "POST",
      body: body,
      decode: (response) => RequestBookingModel.fromJson(response.data),
    );
  }
}
