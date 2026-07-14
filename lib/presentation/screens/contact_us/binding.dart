import 'package:get/get.dart';

import 'logic.dart';

class ContactUsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ContactUsLogic());
  }
}
