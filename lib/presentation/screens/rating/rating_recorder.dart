import 'package:com.tara.passenger/presentation/screens/rate_driver/rating.dart';
import 'package:com.tara.passenger/presentation/screens/rating/pending_rating_store.dart';
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
  RatingRecorder({
    RatingPromptStore? promptStore,
    PendingRatingStore? queueStore,
  })  : _promptStore = promptStore ?? RatingPromptStore(),
        _queueStore = queueStore ?? PendingRatingStore();

  final RatingPromptStore _promptStore;
  final PendingRatingStore _queueStore;

  /// The queue of ratings waiting for an endpoint, as this run last saw it.
  /// It is also kept on the phone ([PendingRatingStore], audit S-6), which is
  /// where whatever wires up the endpoint should drain it from.
  static List<PendingRating> pendingRatings = const [];

  /// Queues the rating and marks the trip handled. The passenger never waits
  /// on the network (N-10: "a submission that fails is queued, so it
  /// dismisses the same way"). A booking with no id cannot be keyed, so
  /// there is nothing to queue.
  ///
  /// Audit S-6: the queue was in memory only, while the trip was marked
  /// handled on disk — after a restart the rating was gone and never asked
  /// for again. It now builds on the stored queue and is stored back.
  Future<void> submit(RatingDraft draft, {required int? bookingId}) async {
    if (!draft.canSubmit || bookingId == null) return;
    final stored = await _queueStore.read();
    pendingRatings = enqueueRating(
      stored ?? pendingRatings,
      pendingFrom(draft, bookingId: bookingId),
    );
    await _queueStore.write(pendingRatings);
    await _promptStore.markHandled(bookingId);
  }

  /// Skip is unpunished: the trip is marked handled so it is never
  /// re-prompted, and nothing is queued.
  Future<void> skip({required int? bookingId}) async {
    if (bookingId != null) await _promptStore.markHandled(bookingId);
  }
}
