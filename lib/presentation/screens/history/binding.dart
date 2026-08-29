import 'package:get/get.dart';

class HistoryBinding extends Bindings {
  // HistoryLogic is actually registered in history/view.dart's
  // Get.put(HistoryLogic(), permanent: true) instead of here — left as-is,
  // out of scope for P-12.
  @override
  void dependencies() {}
}
