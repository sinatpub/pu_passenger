import 'package:get/get.dart';

import 'logic.dart';

class MapDragBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MapDragLogic());
  }
}
