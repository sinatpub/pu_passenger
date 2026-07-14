import 'package:com.tara.passenger/core/api_service/base_api_service.dart';
import 'package:com.tara.passenger/core/utils/pretty_logger.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';

class GetVehicalRemoteDataSource {
  Future<VehicalTypeEntities> getAllVehicalApi() async {
    return BaseApiService().onRequest(
      path: "/taxi/get-type-vehicle",
      method: "GET",
      onSuccess: (result) {
        tlog("Message after success: ${result.data}");
        return VehicalTypeEntities.fromJson(result.data);
      },
    );
  }
}
