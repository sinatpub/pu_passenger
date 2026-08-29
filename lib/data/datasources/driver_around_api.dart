import 'package:com.tara.passenger/core/network/api_client.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/data/models/driver_around_model.dart';

/// P-06 (docs/12) — ported off `BaseApiService` onto `ApiClient` +
/// `Result<T>` (F-02).
class GetDriverAroundDataSource {
  GetDriverAroundDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Result<DriverAroundModel>> getAllDriverAroundApi({required int typeVehicle}) {
    return _apiClient.request<DriverAroundModel>(
      path: "/taxi-passenger/get-driver-location-around",
      method: "POST",
      body: {"type_vehicle": "$typeVehicle"},
      decode: (response) => DriverAroundModel.fromJson(response.data),
    );
  }
}
