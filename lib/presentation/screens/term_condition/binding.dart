import 'package:get/get.dart';

import 'logic.dart';

class TermConditionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TermConditionLogic());
  }
}
