import 'package:get/get.dart';

import 'logic.dart';

class AnnouncementDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AnnouncementDetailLogic());
  }
}
