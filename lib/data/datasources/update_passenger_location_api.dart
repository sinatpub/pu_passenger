import 'package:com.tara.passenger/core/api_service/base_api_service.dart';
import 'package:com.tara.passenger/data/models/passenger_location_model.dart';

class UpdatePassengerLocationApi {
  Future<UpdateLocationModel> updatePassengerLocationApi(
      {required String lat, required String lng}) async {
    return BaseApiService().onRequest<UpdateLocationModel>(
      path: "/taxi-passenger/update-passenger-location",
      method: "POST",
      onSuccess: (result) {
        return UpdateLocationModel.fromJson(result.data);
      },
      bodyParse: {"latitude": lat, "longitude": lng},
    );
  }
}
