import 'package:get/get.dart';

import 'logic.dart';

class HistoryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HistoryDetailLogic());
  }
}
