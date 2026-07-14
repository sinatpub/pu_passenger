import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeState {
  RxStatus isLoading = RxStatus.loading();
  Rx<bool> isCheckBookingLoading = false.obs;
  Rx<bool> isGetAllLoading = false.obs;

  Rx<bool> isDriverAccepted = false.obs;
  Rx<bool> isDriverArrival = false.obs;
  Rx<bool> isDriverNotFound = true.obs;

  Rx<String> titleRide = "".obs;
  RxList<Marker> markers = <Marker>[].obs;

  // * Driver Location
  Rx<double> driverLat = 0.0.obs;
  Rx<double> driverLng = 0.0.obs;
  int? vehicleTypeId;

  // * Vehicle Data
  VehicalTypeEntities? vehicleAllType;
  Rxn<RequestBookingModel> requestBookingData = Rxn<RequestBookingModel>();

// * Current Passenger Location
  Rxn<Position> currentPassengerLocation = Rxn<Position>();

// * Single Data of Vehical
  Rxn<SingleVehical> singleVehicle = Rxn<SingleVehical>();
}
