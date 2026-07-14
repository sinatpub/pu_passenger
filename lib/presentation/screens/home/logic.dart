import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/core/helper/local_notification_helper.dart';
import 'package:com.tara.passenger/core/network_config/telegram.dart';
import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:com.tara.passenger/core/utils/pretty_logger.dart';
import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/logic.dart';
import 'package:com.tara.passenger/storages/get_storage.dart';
import 'package:com.tara.passenger/data/datasources/check_request_book_source.dart';
import 'package:com.tara.passenger/data/datasources/get_vehical_remote_data_source.dart';
import 'package:com.tara.passenger/presentation/screens/home/state.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/service/location_imp.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../../data/datasources/device_info_repo.dart';

class HomeLogic extends GetxController {
  final CheckBookingApi checkBookingApi = CheckBookingApi();
  final GetVehicalRemoteDataSource vehicleRepo = GetVehicalRemoteDataSource();
  final DeviceInfoRepo deviceInfoRepo = DeviceInfoRepo();

  // Location
  final LocationRepo _locationRepo = Get.find<LocationRepo>();

  HomeState state = HomeState();

  @override
  void onInit() async {
    await Get.find<AppLogic>().initSocket(context: Get.context!);
    await getVehicleType();
    await Get.find<AppLogic>().getAppUpdate();
    await pushFcmToken();
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    await requestPermissionLocation();
    await NotificationLocal().requestPermission();

    await checkingBookingStatus();
    super.onReady();
  }

  /// 1. Get All Vehicle Type
  Future<void> getVehicleType() async {
    try {
      EasyLoading.show();
      state.isLoading = RxStatus.loading();
      update();
      var data = await vehicleRepo.getAllVehicalApi();

      if (data.data.isNotEmpty) {
        state.vehicleAllType = data;
        state.isLoading = RxStatus.success();
        update();
      } else {}
    } catch (e) {
      state.isLoading = RxStatus.error();
      update();
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// 2. Push FCM TOKEN
  Future<void> pushFcmToken() async {
    try {
      var fcmToke = await GetStoragePref().getFcmTokenLocal();
      if (fcmToke == null || fcmToke.isEmpty) {
        var result = await deviceInfoRepo.deviceCreateOrUpdate();
        tlog("Device Info: $result");
      }
    } catch (e) {
      xPrettyLog(message: "Error get FCM token: $e");
    }
  }

  /// 3. Checking Booking Status
  Future<void> checkingBookingStatus() async {
    try {
      var data = await checkBookingApi.checkBookingApi();
      if (data.data != null) {
        switch (data.data?.status) {
          // case BookingStatus.request:
          //   break;
          case BookingStatus.arrival:
          case BookingStatus.accepted:
          case BookingStatus.onGoing:
            Get.offNamed(
              AppRoutes.BOOKING,
            );
            break;
          case BookingStatus.completed:
          case BookingStatus.pendingPayment:
            Get.offNamed(AppRoutes.CALCULATEFEE);
          default:
            tlog("Default Route from Checking Status API");
        }
      }
    } catch (e) {
      Logger().e("Error booking request: ${e.toString()}");
    }
  }

// * Checking Permission Location
  Future<void> requestPermissionLocation() async {
    bool hasPermission = await _locationRepo.checkPermission();

    if (!hasPermission) {
      LocationPermission status = await Geolocator.checkPermission();

      if (status == LocationPermission.deniedForever) {
        _locationRepo.showDialog(
          title: AppLocale.locationRequired.tr,
          content: AppLocale.locationPermanentlyDisabled.tr,
          actionText: AppLocale.openSetting.tr,
          onActionPressed: () {
            Get.back();
            _locationRepo.openAppSettings();
          },
        );
        return;
      }

      // Otherwise, try requesting normally
      bool result = await _locationRepo.requestLocationPermission();
      if (!result) {
        tlog("User denied location again.");
      }
    }
  }
}

// class HomeLogic extends GetxController {
// ! Here is how to call another GetXController inner GetXController
// BookingMapLogic get bookingLogic => Get.find<BookingMapLogic>();
// MapLogic get mapLogic => Get.find<MapLogic>();
//
// GetVehicalRemoteDataSource api = GetVehicalRemoteDataSource();
// final CheckBookingApi checkBookingApi = CheckBookingApi();
// final LocationRepo locationImpl = LocationRepo();
//
// final DeviceInfoRepo deviceInfoRepo = DeviceInfoRepo();
//
// // Cancel Booking
// CancelBookingApi cancelBookingRepo = CancelBookingApi();
// HomeState state = HomeState();
//
// final RxDouble totalDistance = 0.0.obs; // Observable total distance
// geo_locator.Position? lastPosition;
//
// final AppLogic _appLogic = Get.find<AppLogic>();
//
// @override
// void onInit() async {
//   super.onInit();
//   Get.find<AppLogic>().getAppUpdate();
//   // * 0. Init Socket
//   Get.find<AppLogic>().initSocket(context: Get.context!);
//
//   // * 0.1 pushFcmToken
//   pushFcmToken();
//   // * 1. Get All Vehicle Type
//   await getVehicleType();
//   // * 2. Checking Permission Granted
//   await requestPermissionLocation();
//   await NotificationLocal().requestPermission();
//   // * 3. Checking Booking Status
//   checkingBookingStatus();
//
//   // * 4. Notification
//   await NotificationLocal().initLocationNotification();
//   await TaxiNotification.shared.initLocationNotification();
// }
//
// // Push Device Token
// Future<void> pushFcmToken() async {
//   try {
//     var fcmToke = await GetStoragePref().getFcmTokenLocal();
//     if (fcmToke == null) {
//       var result = await deviceInfoRepo.deviceCreateOrUpdate();
//       tlog("Device Info: $result");
//     }
//   } catch (e) {
//     xPrettyLog(message: "Error get FCM token: $e");
//   }
// }
//
// Future<void> getVehicleType() async {
//   try {
//     EasyLoading.show();
//     state.isGetAllLoading.value = true;
//     var vehicleData = await api.getAllVehicalApi();
//     state.vehicelTypeData.value = vehicleData;
//   } catch (e) {
//     tlog("Error fetching vehicle data: $e");
//     state.vehicelTypeData.value = null;
//   } finally {
//     state.isGetAllLoading.value = false;
//     EasyLoading.dismiss();
//     update();
//   }
// }
//
// // * update driver location latlng
// void driverLocation({required double lat, required double lng}) {
//   try {
//     state.driverLat.value = lat;
//     state.driverLng.value = lng;
//   } catch (e) {
//     Logger().e("Driver location $e");
//   }
// }
//
// // * CheckingBooking State
// void checkingBookingStatus() async {
//   try {
//     var data = await checkBookingApi.checkBookingApi();
//     if (data.data != null) {
//       await 1.delay();
//
//       driverLocation(
//           lat: double.parse("${data.data?.driver?.lastLocation?.latitude}"),
//           lng: double.parse("${data.data?.driver?.lastLocation?.longitude}"));
//
//       // convertor string to double
//       double passengerLat =
//           double.tryParse("${data.data?.startLatitude}") ?? 0.0;
//       double passengerLng =
//           double.tryParse("${data.data?.startLongitude}") ?? 0.0;
//       double desPassengerLat =
//           double.tryParse("${data.data?.endLatitude}") ?? 0.0;
//       double desPassengerLng =
//           double.tryParse("${data.data?.endLongitude}") ?? 0.0;
//       double driverLat =
//           double.tryParse("${data.data?.driver?.lastLocation?.latitude}") ??
//               0.0;
//       double driverLng =
//           double.parse("${data.data?.driver?.lastLocation?.longitude}");
//
//       state.vehicleTypeId = data.data?.typeVehicleId;
//
//       switch (data.data?.status) {
//         // case BookingStatus.request: //! 1
//         //   _appLogic.titleEvent = AppLocale.waitingDriverAccepted.tr;
//         //   _appLogic.update([AppUpdate.titleEventID]);
//         //   break;
//         case BookingStatus.accepted: //! 2 => Waiting Driver Arrive
//           _appLogic.titleEvent = AppLocale.waitingDriverAccepted.tr;
//           _appLogic.update([AppUpdate.titleEventID]);
//           HapticFeedback.vibrate();
//           Get.offNamed(
//             AppRoutes.BOOKING,
//           );
//           bookingLogic.driverAccepted(
//             passengerLat: passengerLat,
//             passengerLng: passengerLng,
//             driverLat: driverLat,
//             driverLng: driverLng,
//           );
//           break;
//         case BookingStatus.arrival:
//           Get.back(); // ! Close the Dialog
//           HapticFeedback.vibrate();
//           Get.offNamed(
//             AppRoutes.BOOKING,
//           );
//           state.titleRide.value = AppLocale.driverArrivedLocation.tr;
//           // * BookingLogic => Handle Draw Polylines
//           bookingLogic.driverAccepted(
//               passengerLat: passengerLat ?? 0.0,
//               passengerLng: passengerLng ?? 0.0,
//               driverLat: driverLat ?? 0.0,
//               driverLng: driverLng ?? 0.0,
//               isDriverArrived: true);
//           break;
//
//         case BookingStatus.onGoing: //! 3
//           state.titleRide.value = AppLocale.onGoing.tr;
//           Get.back(); // Close the Dialog
//           HapticFeedback.vibrate();
//           Get.offNamed(AppRoutes.BOOKING);
//           await bookingLogic.driverStartRide(
//               driverLat: driverLat,
//               driverLng: driverLng,
//               driverHeading: data.data?.driver?.lastLocation?.heading,
//               desPassengerLat: desPassengerLat,
//               desPassengerLng: desPassengerLng);
//           break;
//         case BookingStatus.completed: //! 4
//           state.titleRide.value = AppLocale.rideComplete.tr;
//           HapticFeedback.vibrate();
//           Get.offNamed(AppRoutes.CALCULATEFEE);
//           bookingLogic.stopUpdatingDriverLocation();
//           break;
//         case BookingStatus.pendingPayment: //! 6
//           state.titleRide.value = AppLocale.pendingPayment.tr;
//           Get.offNamed(AppRoutes.CALCULATEFEE);
//           HapticFeedback.vibrate();
//           bookingLogic.stopUpdatingDriverLocation();
//           break;
//         default:
//           tlog("Default Route from Checking Status API");
//           break;
//       }
//     }
//   } catch (e) {
//     Logger().e("Error booking request: ${e.toString()}");
//   }
// }
//
// // * Checking Permission Location
// Future<void> requestPermissionLocation() async {
//   // Request location permission
//   bool permissionGranted = await locationImpl.checkPermission();
//   if (!permissionGranted) {
//     tlog("Location permission denied.");
//     return;
//   }
//
//   geo_locator.Position? currentLocation =
//       await locationImpl.getCurrentLocation();
//   if (currentLocation == null) {
//     tlog("Current location not available.");
//     return;
//   }
//
//   // Now that we have the location, proceed to request the booking
//   state.currentPassengerLocation.value = currentLocation;
//   // getMarker(
//   //     title: "Passenger",
//   //     position: LatLng(currentLocation.latitude, currentLocation.longitude));
//   tlog("Current Location: $currentLocation");
//
//   tlog("Location permission granted.");
// }
//
// void driverNotFoundDialog() {
//   showGetXErrorCustomDialog(
//       title: AppLocale.driverNotFound.tr,
//       description: AppLocale.driverNotFoundDes.tr,
//       onCancel: () {
//         Get.back();
//         // CancelBookingApi().cancelBookingApi();
//       },
//       onPressed: () {
//         mapLogic.requestBooking();
//       });
// }
//
// Image vehicleImage({int? vehicleType}) {
//   String? vehicleImage;
//   switch (vehicleType) {
//     // Rickshaw
//     case 1:
//       vehicleImage = ImageAssets.tokt_tok;
//     case 2:
//       vehicleImage = ImageAssets.classic_car;
//     case 4:
//       vehicleImage = ImageAssets.suv_car;
//     case 3:
//       vehicleImage = ImageAssets.min_van_car;
//     default:
//       vehicleImage = ImageAssets.placeholder_png;
//   }
//   return Image.asset(vehicleImage);
// }
// }
