import 'package:com.tara.passenger/core/api_service/base_api_service.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';

class CheckBookingApi {
  Future<RequestBookingModel> checkBookingApi() async {
    return BaseApiService().onRequest<RequestBookingModel>(
        path: "/taxi-passenger/get-request-booking-info",
        method: "GET",
        // customToken: "142|uzsrRAgIHjZ9fmNnlywGXZL6GeHHzy7F8HCwf24o",
        onSuccess: (result) {
          return RequestBookingModel.fromJson(result.data);
        });
  }
}
