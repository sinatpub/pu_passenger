import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_dialog.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_recorder.dart';
import 'package:com.tara.passenger/presentation/screens/receipt/state.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';

/// `GetBuilder` ids: the countdown ticks every second and only the button
/// that shows it needs to follow.
enum ReceiptUpdate { countdown }

/// Screen 12 (Thank you) controller — no fetching. It opens the rating
/// dialog when the trip has not been rated, and returns home by itself once
/// the passenger has been idle for [autoHomeSeconds].
class ReceiptLogic extends GetxController {
  ReceiptLogic({
    Data? booking,
    int? stars,
    bool promptRating = false,
    RatingRecorder? recorder,
  })  : state = ReceiptState(
          booking: booking,
          stars: stars,
          promptRating: promptRating,
          secondsLeft: autoHomeSeconds,
        ),
        _recorder = recorder ?? RatingRecorder();

  /// How long the page waits, untouched, before going home.
  static const int autoHomeSeconds = 60;

  final ReceiptState state;
  final RatingRecorder _recorder;

  Timer? _countdown;
  bool _ratingOpen = false;
  bool _left = false;

  @override
  void onReady() {
    super.onReady();
    _startCountdown();
    final context = Get.context;
    if (state.promptRating && context != null) promptForRating(context);
  }

  @override
  void onClose() {
    _countdown?.cancel();
    super.onClose();
  }

  void _startCountdown() {
    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (state.secondsLeft > 1) {
      state.secondsLeft--;
      update([ReceiptUpdate.countdown]);
      return;
    }
    state.secondsLeft = 0;
    update([ReceiptUpdate.countdown]);
    // Nobody is here. A rating dialog still open is closed for them, which
    // `promptForRating` records as the skip it is.
    if (_ratingOpen) Get.back();
    backToHome();
  }

  /// The passenger is still choosing a rating: start the minute again rather
  /// than take the dialog away from under their finger.
  void restartCountdown() {
    if (_left) return;
    state.secondsLeft = autoHomeSeconds;
    update([ReceiptUpdate.countdown]);
  }

  /// Opens the rating dialog and records what comes back: a rating is queued
  /// and shown on the page; anything else — Skip, Back, the countdown
  /// closing it — is a skip, and the trip is never asked about again.
  Future<void> promptForRating(BuildContext context) async {
    if (_ratingOpen) return;
    _ratingOpen = true;
    final draft = await showRatingDialog(
      context,
      driverName: state.booking?.driver?.name,
      onInteraction: restartCountdown,
    );
    _ratingOpen = false;

    final bookingId = state.booking?.id;
    if (draft == null || !draft.canSubmit) {
      await _recorder.skip(bookingId: bookingId);
      return;
    }
    await _recorder.submit(draft, bookingId: bookingId);
    state.stars = draft.stars;
    if (!_left) update();
  }

  /// Clears the whole post-trip stack: the trip is over and the Thank you
  /// page should not be reachable by Back.
  void backToHome() => _leave(AppRoutes.BOTTOMNAV);

  /// "Book again" lands on the map, which is where a new trip starts.
  void bookAgain() => _leave(AppRoutes.MAP);

  void _leave(String route) {
    if (_left) return;
    _left = true;
    _countdown?.cancel();
    Get.offAllNamed(route);
  }
}
