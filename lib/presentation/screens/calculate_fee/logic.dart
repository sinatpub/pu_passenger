import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/data/datasources/check_request_book_source.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/state.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../booking_map_screen/logic.dart';

class CalculateFeeLogic extends GetxController {
  final CheckBookingApi requestBookingApi = CheckBookingApi();
  final CalculateFeeState state = CalculateFeeState();

  @override
  onInit() {
    super.onInit();
    getCalculateFeeApi();
  }

  getCalculateFeeApi() async {
    try {
      state.isLoading.value = true;
      var result = await requestBookingApi.checkBookingApi();
      state.data.value = result;
      state.isLoading.value = false;
    } catch (e) {
      state.isLoading.value = false;
    }
  }

  void syncNavigateBack() async {
    EasyLoading.show();
    await 2.delay();
    Get.offAllNamed(AppRoutes.BOTTOMNAV);
    // Re-init socket before navigating
    Get.find<AppLogic>().initSocket(context: Get.context!);
    EasyLoading.dismiss();
  }

  @override
  onClose() {}
}
