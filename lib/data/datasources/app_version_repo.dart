import 'package:com.tara.passenger/core/api_service/base_api_service.dart';
import 'package:com.tara.passenger/data/datasources/api_endpoint.dart';
import 'package:com.tara.passenger/data/models/app_version_model.dart';

class AppVersionRepoApi {
  Future<AppVersionModel?> getCurrentAppVersionApi() async {
    String versionType = "1"; // passenger
    return BaseApiService().onRequest<AppVersionModel?>(
      path: "${ApiEndPoint.get_current_app_version}/2",
      method: Method.GET,
      onSuccess: (result) {
        return AppVersionModel.fromJson(result.data);
      },
      bodyParse: versionType,
    );
  }
}
