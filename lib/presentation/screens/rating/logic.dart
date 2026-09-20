import 'package:get/get.dart';

import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/rate_driver/rating.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_prompt_store.dart';
import 'package:com.tara.passenger/presentation/screens/rating/state.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';

/// Screen 11 (Rating) controller.
///
/// **`PDD-02`: there is no rating endpoint.** Probe-confirmed (N-10 / P-11),
/// and nothing is invented here — no datasource, no request. A submitted
/// rating is turned into a `PendingRating` by the N-10 rules and queued, which
/// is what that module already prescribes for a submission that cannot be
/// sent. When an endpoint appears, the queue is what drains into it.
class RatingLogic extends GetxController {
  RatingLogic({Data? booking, RatingPromptStore? promptStore})
      : state = RatingState(booking: booking),
        _promptStore = promptStore ?? RatingPromptStore();

  final RatingState state;
  final RatingPromptStore _promptStore;

  /// The queue of ratings waiting for an endpoint. Static so it survives this
  /// controller being disposed on navigation; it is drained by whatever wires
  /// up the endpoint, not here.
  static List<PendingRating> pendingRatings = const [];

  void setStars(int value) {
    // N-10 drops tags the new count no longer offers, so a passenger who
    // picked 5★ + "Clean" and then chose 2★ cannot submit praise they chose
    // for a different answer.
    state.draft = state.draft.withStars(value);
    update();
  }

  void toggleTag(RatingTag tag) {
    state.draft = state.draft.toggle(tag);
    update();
  }

  /// Queue the rating and move on. The passenger never waits on the network
  /// (N-10: "a submission that fails is queued, so it dismisses the same way").
  Future<void> submit() async {
    if (!state.canSubmit) return;
    final bookingId = state.booking?.id;
    if (bookingId != null) {
      pendingRatings = enqueueRating(
        pendingRatings,
        pendingFrom(state.draft, bookingId: bookingId),
      );
      await _promptStore.markHandled(bookingId);
    }
    _toReceipt();
  }

  /// Skip is unpunished: the trip is marked handled so it is never re-prompted,
  /// nothing is queued, and the passenger lands on the same receipt.
  Future<void> skip() async {
    final bookingId = state.booking?.id;
    if (bookingId != null) await _promptStore.markHandled(bookingId);
    _toReceipt();
  }

  void _toReceipt() {
    Get.offNamed(
      AppRoutes.RECEIPT,
      arguments: {
        'booking': state.booking,
        'stars': state.draft.stars,
      },
    );
  }

  @override
  void onClose() {
    state.noteController.dispose();
    super.onClose();
  }
}
