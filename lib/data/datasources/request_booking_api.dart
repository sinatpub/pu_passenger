import 'package:com.tara.passenger/core/network/api_client.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';

/// P-06 (docs/12) — ported off `BaseApiService` onto `ApiClient` +
/// `Result<T>` (F-02) for consistency with the rest of the app.
/// `MapLogic`'s map/marker/booking-request behavior is unchanged.
class RequestBookingApi {
  RequestBookingApi({ApiClient? apiClient}) : _injectedClient = apiClient;

  final ApiClient? _injectedClient;

  /// Lazy so that constructing a `RequestBookingApi` — or a test subclass that
  /// overrides every method on it — does not build a Dio-backed `ApiClient`
  /// and hit `LateInitializationError: Field 'dio' has not been initialized`.
  /// The public constructor signature is unchanged.
  late final ApiClient _apiClient = _injectedClient ?? ApiClient();

  Future<Result<RequestBookingModel>> requestBookingApi({
    required double startLatitude,
    required double startLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    String? address,
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
