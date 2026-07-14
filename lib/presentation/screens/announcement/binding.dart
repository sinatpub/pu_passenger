import 'package:get/get.dart';

import '../../../data/datasources/announcement_api.dart';
import 'logic.dart';

class AnnouncementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AnnouncementLogic());
    Get.lazyPut(() => AnnouncementRepo());
  }
}
