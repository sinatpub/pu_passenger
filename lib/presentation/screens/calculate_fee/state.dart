import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:get/get.dart';

class CalculateFeeState {
  Rx<bool> isLoading = false.obs;
  Rxn<RequestBookingModel> data = Rxn<RequestBookingModel>();
}
