import 'package:com.tara.passenger/core/api_service/base_api_service.dart';
import 'package:com.tara.passenger/data/models/login_phone_model.dart';

class PhoneNumerRemoteDataSource {
  Future<PhoneNumberModel> postPhoneNumberApi(
      {required String phoneNumer}) async {
    return BaseApiService().onRequest(
        path: "/taxi-passenger/login-phone",
        method: "POST",
        onSuccess: (result) {
          return PhoneNumberModel.fromJson(result.data);
        },
        bodyParse: {"phone": phoneNumer});
  }
}
