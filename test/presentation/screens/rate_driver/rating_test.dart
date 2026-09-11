import 'package:com.tara.passenger/presentation/screens/rate_driver/rating.dart';
import 'package:flutter_test/flutter_test.dart';

/// N-10 (docs/12) — spec Screen 11, Rate Driver.
void main() {
  group('tone and tags', () {
    test('four and five stars are positive', () {
      expect(toneFor(4), RatingTone.positive);
      expect(toneFor(5), RatingTone.positive);
    });

    test('one to three stars are negative', () {
      for (final s in [1, 2, 3]) {
        expect(toneFor(s), RatingTone.negative, reason: '$s');
      }
    });

    test('no stars, no tone, no tags', () {
      expect(toneFor(null), isNull);
      expect(tagsFor(null), isEmpty);
    });

    test('out-of-range stars have no tone', () {
      expect(toneFor(0), isNull);
      expect(toneFor(6), isNull);
    });

    test('a good rating offers the spec\'s four tags, in its order', () {
      expect(tagsFor(5), [
        RatingTag.clean,
        RatingTag.onTime,
        RatingTag.friendly,
        RatingTag.goodRoute,
      ]);
    });

    test('a low rating offers no tags until the spec names negative ones',
        () {
      // Screen 11 says negative tags appear after 1–3★ but lists none.
      // Not invented here.
      expect(tagsFor(2), isEmpty);
    });
  });

  group('the draft', () {
    test('cannot be submitted without a star', () {
      expect(const RatingDraft().canSubmit, isFalse);
      expect(const RatingDraft().withStars(3).canSubmit, isTrue);
    });

    test('a tag can be chosen and cleared', () {
      final d = const RatingDraft().withStars(5).toggle(RatingTag.clean);
      expect(d.tags, {RatingTag.clean});
      expect(d.toggle(RatingTag.clean).tags, isEmpty);
    });

    test('a tag not offered is ignored, not stored', () {
      final d = const RatingDraft().withStars(2).toggle(RatingTag.clean);
      expect(d.tags, isEmpty);
      expect(const RatingDraft().toggle(RatingTag.clean).tags, isEmpty);
    });

    test('dropping to a low rating drops the praise chosen for a high one', () {
      final d = const RatingDraft()
          .withStars(5)
          .toggle(RatingTag.clean)
          .toggle(RatingTag.friendly)
          .withStars(2);
      expect(d.stars, 2);
      expect(d.tags, isEmpty);
    });

    test('moving between good ratings keeps the tags', () {
      final d = const RatingDraft()
          .withStars(5)
          .toggle(RatingTag.onTime)
          .withStars(4);
      expect(d.tags, {RatingTag.onTime});
    });

    test('an out-of-range star count fails loudly', () {
      expect(() => const RatingDraft().withStars(0), throwsArgumentError);
      expect(() => const RatingDraft().withStars(6), throwsArgumentError);
    });

    test('the draft is immutable', () {
      const original = RatingDraft();
      original.withStars(5);
      expect(original.stars, isNull);
    });
  });

  group('when to ask', () {
    test('after a completed trip', () {
      expect(
          shouldPromptForRating(
              tripCompleted: true, alreadyRated: false, skipped: false),
          isTrue);
    });

    test('never for a trip that did not complete', () {
      expect(
          shouldPromptForRating(
              tripCompleted: false, alreadyRated: false, skipped: false),
          isFalse);
    });

    test('never twice', () {
      expect(
          shouldPromptForRating(
              tripCompleted: true, alreadyRated: true, skipped: false),
          isFalse);
    });

    test('a skip is not punished by asking again', () {
      expect(
          shouldPromptForRating(
              tripCompleted: true, alreadyRated: false, skipped: true),
          isFalse);
    });
  });

  group('the prompt names the driver only when there is a name', () {
    test('a name is shown trimmed', () {
      expect(promptDriverName('  Sok Dara '), 'Sok Dara');
    });

    test('no name means no "with ?"', () {
      expect(promptDriverName(null), isNull);
      expect(promptDriverName('   '), isNull);
    });
  });

  group('couldn\'t submit → queue', () {
    PendingRating p(int booking, int stars) =>
        PendingRating(bookingId: booking, stars: stars, tags: const {});

    test('a chosen rating becomes a pending one', () {
      final draft = const RatingDraft().withStars(5).toggle(RatingTag.clean);
      final pending = pendingFrom(draft, bookingId: 42);
      expect(pending.bookingId, 42);
      expect(pending.stars, 5);
      expect(pending.tags, {RatingTag.clean});
    });

    test('a skip is never queued', () {
      expect(() => pendingFrom(const RatingDraft(), bookingId: 42),
          throwsStateError);
    });

    test('one per booking: re-rating offline replaces, never duplicates', () {
      final q = enqueueRating(enqueueRating([p(1, 5), p(2, 3)], p(1, 2)),
          p(3, 4));
      expect(q.map((e) => e.bookingId), [2, 1, 3]);
      expect(q.firstWhere((e) => e.bookingId == 1).stars, 2);
    });

    test('a sent rating leaves the queue; the rest stay in order', () {
      final q = withoutSubmitted([p(1, 5), p(2, 3), p(3, 4)], 2);
      expect(q.map((e) => e.bookingId), [1, 3]);
    });

    test('removing an unknown booking changes nothing', () {
      final q = withoutSubmitted([p(1, 5)], 9);
      expect(q.map((e) => e.bookingId), [1]);
    });
  });
}
