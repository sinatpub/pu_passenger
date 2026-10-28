import 'package:com.tara.passenger/presentation/screens/rate_driver/rating.dart';
import 'package:com.tara.passenger/presentation/screens/rating/pending_rating_store.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_prompt_store.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_recorder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Audit S-6 — ratings waiting for an endpoint survive a restart.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RatingRecorder.pendingRatings = const [];
  });

  group('encode / decode', () {
    test('a queue reads back as it was written', () {
      final queue = [
        const PendingRating(
            bookingId: 7, stars: 5, tags: {RatingTag.clean, RatingTag.onTime}),
        const PendingRating(bookingId: 8, stars: 2, tags: {}),
      ];

      final back = decodePendingRatings(encodePendingRatings(queue));

      expect(back.map((r) => r.bookingId), [7, 8]);
      expect(back.first.stars, 5);
      expect(back.first.tags, {RatingTag.clean, RatingTag.onTime});
      expect(back.last.tags, isEmpty);
    });

    test('a bad entry or an unknown tag does not lose the queue', () {
      final back = decodePendingRatings(
        '[{"booking_id": 7, "stars": 4, "tags": ["clean", "teleported"]},'
        ' {"booking_id": "x"}, 3]',
      );

      expect(back.single.bookingId, 7);
      expect(back.single.tags, {RatingTag.clean});
    });
  });

  test('a submitted rating is still queued after a restart', () async {
    await RatingRecorder()
        .submit(const RatingDraft(stars: 5), bookingId: 7);

    // A restart: the in-memory queue is gone, the phone's is not.
    RatingRecorder.pendingRatings = const [];
    final stored = await PendingRatingStore().read();

    expect(stored!.single.bookingId, 7);
    expect(stored.single.stars, 5);
  });

  test('a later rating joins the stored ones, one per trip', () async {
    await RatingRecorder()
        .submit(const RatingDraft(stars: 5), bookingId: 7);
    RatingRecorder.pendingRatings = const [];

    await RatingRecorder()
        .submit(const RatingDraft(stars: 3), bookingId: 8);
    await RatingRecorder()
        .submit(const RatingDraft(stars: 4), bookingId: 8);

    final stored = await PendingRatingStore().read();
    expect(stored!.map((r) => (r.bookingId, r.stars)), [(7, 5), (8, 4)]);
    expect(RatingRecorder.pendingRatings, hasLength(2));
    expect(await RatingPromptStore().isHandled(8), isTrue);
  });
}
