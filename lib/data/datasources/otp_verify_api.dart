import 'package:com.tara.passenger/core/api_service/base_api_service.dart';
import 'package:com.tara.passenger/data/models/user_response_model.dart';

class OtpVerifyApi {
  Future<UserResponseModel> verifyOTPApi(
      {required String phoneNumer, required String otpCode}) async {
    return BaseApiService().onRequest<UserResponseModel>(
        path: "/taxi-passenger/verify-phone-otp",
        method: "POST",
        onSuccess: (result) {
          return UserResponseModel?.fromJson(result.data);
        },
        bodyParse: {
          "phone": phoneNumer,
          "otp_code": otpCode,
        });
  }
}
