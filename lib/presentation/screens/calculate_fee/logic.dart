import 'dart:async';

import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/data/datasources/check_request_book_source.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/state.dart';
import 'package:com.tara.passenger/presentation/screens/rate_driver/rating.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_prompt_store.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

/// How often the fee page asks the server whether the trip has been paid
/// (audit X-2).
const Duration kPaymentPollInterval = Duration(seconds: 5);

/// Whether the trip the fee page is waiting on is over, by the server's own
/// record (audit X-2).
///
/// `get-request-booking-info` returns the active booking only. Once the
/// driver has confirmed the payment the trip leaves it, and the answer
/// carries no booking — that is how the QA mock backend models it; the
/// backend's source is not available to confirm it. A booking that moved on
/// from "pending payment" to "completed", or was cancelled, is over too.
bool tripSettled({required int? loadedStatus, required RequestBookingModel now}) {
  final data = now.data;
  if (data == null) return true;
  if (data.status == BookingStatus.cancel) return true;
  return loadedStatus == BookingStatus.pendingPayment &&
      data.status == BookingStatus.completed;
}

class CalculateFeeLogic extends GetxController {
  CalculateFeeLogic({
    RatingPromptStore? promptStore,
    CheckBookingApi? checkBookingApi,
    Duration? paymentPollInterval = kPaymentPollInterval,
    this.paymentConfirmed = false,
  })  : _promptStore = promptStore ?? RatingPromptStore(),
        _paymentPollInterval = paymentPollInterval,
        requestBookingApi = checkBookingApi ?? CheckBookingApi();

  /// Null: the page does not ask on its own, and only the
  /// `driverAcceptPayment` push moves it on.
  final Duration? _paymentPollInterval;

  /// The page was opened after the driver had already confirmed the payment
  /// (audit X-3): it loads the trip and goes straight on to the Thank you
  /// page.
  final bool paymentConfirmed;

  Timer? _paymentPoll;
  bool _checkingPayment = false;

  /// Set once the page starts leaving, so the push and the poll arriving
  /// together leave once.
  bool _leaving = false;

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
    getCalculateFeeApi().then((_) {
      if (paymentConfirmed) syncNavigateBack();
    });
  }

  /// Audit X-2: the page used to leave only on the `driverAcceptPayment`
  /// push. It loads the trip once and has no back button, so a passenger
  /// whose socket was down at that moment waited here for good — and on a
  /// relaunch Home sent them straight back.
  @override
  void onReady() {
    super.onReady();
    final interval = _paymentPollInterval;
    if (interval == null || paymentConfirmed) return;
    _paymentPoll = Timer.periodic(interval, (_) => checkPayment());
  }

  /// One look at whether the trip has been paid. Leaves for the Thank you
  /// page when it has ([tripSettled]).
  @visibleForTesting
  Future<void> checkPayment() async {
    if (_checkingPayment || _leaving || state.isLoading.value) return;
    _checkingPayment = true;
    try {
      final now = await requestBookingApi.checkBookingApi();
      if (_leaving) return;
      final settled = tripSettled(
        loadedStatus: state.data.value?.data?.status,
        now: now,
      );
      if (!settled) return;
      xPrettyLog(
        message: "The trip has been settled (status: ${now.data?.status}), "
            "leaving the fee page",
      );
      syncNavigateBack();
    } catch (e) {
      // A check that failed is not a payment that failed: ask again on the
      // next tick.
      xPrettyLog(message: "Could not check the payment: $e");
    } finally {
      _checkingPayment = false;
    }
  }

  void _stopPaymentPoll() {
    _paymentPoll?.cancel();
    _paymentPoll = null;
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
    if (_leaving) return;
    _leaving = true;
    _stopPaymentPoll();
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
  onClose() {
    _stopPaymentPoll();
    super.onClose();
  }
}
