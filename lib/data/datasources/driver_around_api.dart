import 'package:com.tara.passenger/core/api_service/base_api_service.dart';
import 'package:com.tara.passenger/core/utils/pretty_logger.dart';
import 'package:com.tara.passenger/data/models/driver_around_model.dart';

class GetDriverAroundDataSource {
  Future<DriverAroundModel> getAllDriverAroundApi(
      {required int typeVehicle}) async {
    return BaseApiService().onRequest(
      path: "/taxi-passenger/get-driver-location-around",
      method: "POST",
      bodyParse: {"type_vehicle": "$typeVehicle"},
      onSuccess: (result) {
        tlog("Message after success: ${result.data}");
        return DriverAroundModel.fromJson(result.data);
      },
    );
  }
}
