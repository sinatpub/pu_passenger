import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:get/get.dart';

class SplashState {
  Rx<bool> isLoading = false.obs;
  Rx<RequestBookingModel?> bookingData = null.obs;

  // * Params Checking Request Booking
  Rx<double> startLat = 0.0.obs;
  Rx<double> startLng = 0.0.obs;
  Rx<String> address = "".obs;
}
