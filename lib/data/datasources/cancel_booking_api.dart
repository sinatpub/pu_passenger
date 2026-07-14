import 'package:com.tara.passenger/core/api_service/base_api_service.dart';

class CancelBookingApi {
  Future<bool> cancelBookingApi() async {
    return BaseApiService().onRequest<bool>(
      path: "/taxi-passenger/cancel-request-booking-info",
      method: "POST",
      onSuccess: (result) {
        return true;
      },
      bodyParse: {"cancel_reason": "No Reason"},
    );
  }
}
