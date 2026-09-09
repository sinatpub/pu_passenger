import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/core/helper/local_notification_helper.dart';
import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:com.tara.passenger/core/utils/pretty_logger.dart';
import 'package:com.tara.passenger/storages/get_storage.dart';
import 'package:com.tara.passenger/data/datasources/check_request_book_source.dart';
import 'package:com.tara.passenger/data/datasources/get_vehical_remote_data_source.dart';
import 'package:com.tara.passenger/presentation/screens/home/booking_redirect.dart';
import 'package:com.tara.passenger/presentation/screens/home/state.dart';
import 'package:com.tara.passenger/service/location_imp.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../../data/datasources/device_info_repo.dart';

class HomeLogic extends GetxController {
  /// P-03 — collaborators arrive by constructor and resolve lazily, matching
  /// `MapLogic` (P-08). A `Get.find` in a field initializer runs at
  /// construction, so building a `HomeLogic` used to demand that every
  /// collaborator already be registered.
  HomeLogic({
    CheckBookingApi? checkBookingApi,
    GetVehicalRemoteDataSource? vehicleRepo,
    DeviceInfoRepo? deviceInfoRepo,
    LocationRepo? locationRepo,
  })  : _injectedCheckBookingApi = checkBookingApi,
        _injectedVehicleRepo = vehicleRepo,
        _injectedDeviceInfoRepo = deviceInfoRepo,
        _injectedLocationRepo = locationRepo;

  final CheckBookingApi? _injectedCheckBookingApi;
  final GetVehicalRemoteDataSource? _injectedVehicleRepo;
  final DeviceInfoRepo? _injectedDeviceInfoRepo;
  final LocationRepo? _injectedLocationRepo;

  late final CheckBookingApi checkBookingApi =
      _injectedCheckBookingApi ?? CheckBookingApi();
  late final GetVehicalRemoteDataSource vehicleRepo =
      _injectedVehicleRepo ?? GetVehicalRemoteDataSource();
  late final DeviceInfoRepo deviceInfoRepo =
      _injectedDeviceInfoRepo ?? DeviceInfoRepo();

  // Location
  late final LocationRepo _locationRepo =
      _injectedLocationRepo ?? Get.find<LocationRepo>();

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
      }
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
  ///
  /// Fetches, then delegates the decision to `bookingRedirectRoute()` and
  /// does nothing but navigate. The rules live in that function so they can
  /// be tested without a GetX navigator.
  Future<void> checkingBookingStatus() async {
    try {
      var data = await checkBookingApi.checkBookingApi();
      final route = bookingRedirectRoute(data.data?.status);
      if (route == null) {
        tlog("No active booking to resume (status: ${data.data?.status})");
        return;
      }
      Get.offNamed(route);
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
