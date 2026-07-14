import 'package:com.tara.passenger/core/api_service/base_api_service.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';

class RequestBookingApi {
  Future<RequestBookingModel> requestBookingApi({
    required double startLatitude,
    required double startLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    String? address,
    String? destinationAddress,
    int? typeVehicleId,
  }) async {
    Map<String, dynamic> bodyParse = {
      "start_latitude": startLatitude.toString(),
      "start_longitude": startLongitude.toString(),
    };

    if (destinationLatitude != null) {
      bodyParse["end_latitude"] = destinationLatitude.toString();
    }
    if (destinationLongitude != null) {
      bodyParse["end_longitude"] = destinationLongitude.toString();
    }
    if (address != null) {
      bodyParse["start_address"] = address;
    }

    if (typeVehicleId != null) {
      bodyParse["type_vehicle_id"] = typeVehicleId;
    }

    return await BaseApiService().onRequest<RequestBookingModel>(
      path: "/taxi-passenger/request-booking",
      method: "POST",
      bodyParse: bodyParse,
      onSuccess: (result) {
        return RequestBookingModel.fromJson(result.data);
      },
    );
  }
}
