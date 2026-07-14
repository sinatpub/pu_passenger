import 'package:com.tara.passenger/presentation/screens/announcement/logic.dart';
import 'package:com.tara.passenger/presentation/screens/home/logic.dart';
import 'package:get/get.dart';

import '../../../service/location_imp.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeLogic>(() => HomeLogic());
    Get.lazyPut(() => LocationRepo());
    Get.lazyPut<AnnouncementLogic>(() => AnnouncementLogic());
  }
}
