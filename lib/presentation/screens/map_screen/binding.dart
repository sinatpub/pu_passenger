import 'package:com.tara.passenger/presentation/screens/map_screen/logic.dart';
import 'package:get/get.dart';

import '../../../data/datasources/driver_around_api.dart';
import '../../../data/datasources/update_passenger_location_api.dart';
import 'package:com.tara.passenger/services/socket_service.dart';

class MapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapLogic>(() => MapLogic());

    Get.lazyPut(() => GetDriverAroundDataSource());
    Get.lazyPut(() => PassengerSocketService());
    Get.lazyPut(() => UpdatePassengerLocationApi());
  }
}
