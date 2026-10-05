import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/data/datasources/check_request_book_source.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/state.dart';
import 'package:com.tara.passenger/presentation/screens/rate_driver/rating.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_prompt_store.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';


class CalculateFeeLogic extends GetxController {
  CalculateFeeLogic({
    RatingPromptStore? promptStore,
    CheckBookingApi? checkBookingApi,
  })  : _promptStore = promptStore ?? RatingPromptStore(),
        requestBookingApi = checkBookingApi ?? CheckBookingApi();

  /// Injectable so loading, failing and retrying are testable without the
  /// network client.
  final CheckBookingApi requestBookingApi;
  final CalculateFeeState state = CalculateFeeState();

  /// C7 — reads whether this trip's rating was already handled. Injectable so
  /// the navigation choice is testable without SharedPreferences.
  final RatingPromptStore _promptStore;

  @override
  onInit() {
    super.onInit();
    getCalculateFeeApi();
  }

  /// Loads the finished trip and its fare. Also the page's Retry: a failure
  /// is recorded in `hasError` rather than swallowed, so the passenger is
  /// told and can ask again.
  Future<void> getCalculateFeeApi() async {
    state.isLoading.value = true;
    state.hasError.value = false;
    try {
      state.data.value = await requestBookingApi.checkBookingApi();
    } catch (e) {
      state.hasError.value = true;
    } finally {
      state.isLoading.value = false;
    }
  }

  /// The post-payment chain is `Fee → Thank you → Home`: the rating is a
  /// dialog over the Thank you page, not a page of its own. Everything else
  /// here is unchanged: the same 2s settle, the same socket re-init, the same
  /// `offAll` semantics.
  ///
  /// The dialog is offered only when N-10's rule says to
  /// ([shouldPromptForRating]) — a trip already rated or already skipped is
  /// not asked again, because re-asking is the punishment that rule forbids.
  /// If the booking has no id there is nothing to key that on, so it is not
  /// asked either. With no booking at all there is nothing to thank for, and
  /// the passenger goes home.
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

    if (booking != null) {
      Get.offAllNamed(
        AppRoutes.RECEIPT,
        arguments: {'booking': booking, 'promptRating': prompt},
      );
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
