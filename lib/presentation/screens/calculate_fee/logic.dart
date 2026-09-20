import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/data/datasources/check_request_book_source.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/state.dart';
import 'package:com.tara.passenger/presentation/screens/rate_driver/rating.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_prompt_store.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';


class CalculateFeeLogic extends GetxController {
  CalculateFeeLogic({RatingPromptStore? promptStore})
      : _promptStore = promptStore ?? RatingPromptStore();

  final CheckBookingApi requestBookingApi = CheckBookingApi();
  final CalculateFeeState state = CalculateFeeState();

  /// C7 — reads whether this trip's rating was already handled. Injectable so
  /// the navigation choice is testable without SharedPreferences.
  final RatingPromptStore _promptStore;

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

  /// C7 — the post-payment chain is now `Fee → Rating → Receipt → Home`
  /// rather than `Fee → Home`. Everything else here is unchanged: the same
  /// 2s settle, the same socket re-init, the same `offAll` semantics.
  ///
  /// The rating screen is offered only when N-10's rule says to
  /// ([shouldPromptForRating]) — a trip already rated or already skipped goes
  /// straight home, because re-asking is the punishment that rule forbids. If
  /// the booking has no id there is nothing to key that on, so the passenger
  /// goes home rather than being asked about a trip that cannot be recorded.
  void syncNavigateBack() async {
    EasyLoading.show();
    await 2.delay();

    final booking = state.data.value?.data;
    final bookingId = booking?.id;
    final prompt = bookingId != null &&
        shouldPromptForRating(
          tripCompleted: true,
          alreadyRated: await _promptStore.isHandled(bookingId),
          skipped: false,
        );

    if (prompt) {
      Get.offAllNamed(AppRoutes.RATING, arguments: {'booking': booking});
    } else {
      Get.offAllNamed(AppRoutes.BOTTOMNAV);
    }
    // Re-init socket before navigating
    Get.find<AppLogic>().initSocket(context: Get.context!);
    EasyLoading.dismiss();
  }

  @override
  onClose() {}
}
