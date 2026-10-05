import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:get/get.dart';

class CalculateFeeState {
  Rx<bool> isLoading = false.obs;

  /// The fare request failed. The page offers a retry instead of a receipt
  /// made of dashes.
  Rx<bool> hasError = false.obs;
  Rxn<RequestBookingModel> data = Rxn<RequestBookingModel>();
}
