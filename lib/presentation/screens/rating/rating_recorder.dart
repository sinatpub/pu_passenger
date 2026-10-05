import 'package:com.tara.passenger/presentation/screens/rate_driver/rating.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_prompt_store.dart';

/// What happens to a rating once the passenger has answered — or declined —
/// the prompt.
///
/// **`PDD-02`: there is no rating endpoint.** Probe-confirmed (N-10 / P-11),
/// and nothing is invented here — no datasource, no request. A submitted
/// rating is turned into a `PendingRating` by the N-10 rules and queued, which
/// is what that module already prescribes for a submission that cannot be
/// sent. When an endpoint appears, the queue is what drains into it.
class RatingRecorder {
  RatingRecorder({RatingPromptStore? promptStore})
      : _promptStore = promptStore ?? RatingPromptStore();

  final RatingPromptStore _promptStore;

  /// The queue of ratings waiting for an endpoint. Static so it outlives the
  /// screen that filled it; it is drained by whatever wires up the endpoint,
  /// not here.
  static List<PendingRating> pendingRatings = const [];

  /// Queues the rating and marks the trip handled. The passenger never waits
  /// on the network (N-10: "a submission that fails is queued, so it
  /// dismisses the same way"). A booking with no id cannot be keyed, so
  /// there is nothing to queue.
  Future<void> submit(RatingDraft draft, {required int? bookingId}) async {
    if (!draft.canSubmit || bookingId == null) return;
    pendingRatings = enqueueRating(
      pendingRatings,
      pendingFrom(draft, bookingId: bookingId),
    );
    await _promptStore.markHandled(bookingId);
  }

  /// Skip is unpunished: the trip is marked handled so it is never
  /// re-prompted, and nothing is queued.
  Future<void> skip({required int? bookingId}) async {
    if (bookingId != null) await _promptStore.markHandled(bookingId);
  }
}
