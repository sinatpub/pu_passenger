import 'package:com.tara.passenger/core/api_service/base_api_service.dart';
import 'package:com.tara.passenger/data/models/profile_model.dart';

class ProfileApi {
  Future<ProfileModel> getProfileApi() async {
    return BaseApiService().onRequest<ProfileModel>(
      path: "/taxi-passenger/get-profile",
      method: "GET",
      onSuccess: (result) {
        return ProfileModel.fromJson(result.data);
      },
    );
  }
}
