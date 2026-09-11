/// N-10 (docs/12) — the Rate Driver rules from
/// `ux_ui_design/taxi-booking-ux-spec.md` Screen 11 and its row in the §6
/// state matrix.
///
/// There is **no rating endpoint** anywhere in the API (probe-confirmed
/// 2026-09-10, `.agent/PLAN.md` P-11), so this is the part that must hold
/// whatever the endpoint turns out to be: what may be selected, when the
/// prompt appears, and what happens when a submission cannot be sent. No
/// screen, no datasource.
///
/// Two spec rules shape the flow and are not modelled because they are
/// navigation, not state: a submitted rating "dismiss[es] and return[s] to
/// Home. No thank-you screen", and a submission that fails is queued, so it
/// dismisses the same way. The passenger never waits on the network here.
library;

const int kMinStars = 1;
const int kMaxStars = 5;

/// Screen 11: tags "appear after 4–5★ (negative tags after 1–3★)".
const int kPositiveFromStars = 4;

enum RatingTone { positive, negative }

bool isValidStars(int stars) => stars >= kMinStars && stars <= kMaxStars;

/// The tone a star count sets, or null before a star is chosen.
RatingTone? toneFor(int? stars) {
  if (stars == null || !isValidStars(stars)) return null;
  return stars >= kPositiveFromStars ? RatingTone.positive : RatingTone.negative;
}

/// The tags Screen 11 lists: `[Clean] [On time] [Friendly] [Good route]`.
///
/// **All positive. The spec names no negative tags**, only that they appear
/// after 1–3★. They are not invented here: a passenger's complaint about a
/// driver is worded by whoever writes this list, and it should be the
/// spec's author, not this file. Until they exist, a low rating offers no
/// tags, which is a smaller screen rather than a broken one.
enum RatingTag { clean, onTime, friendly, goodRoute }

extension RatingTagTone on RatingTag {
  RatingTone get tone => RatingTone.positive;
}

/// The tags offered at [stars], in the spec's order.
List<RatingTag> tagsFor(int? stars) {
  final tone = toneFor(stars);
  if (tone == null) return const [];
  return [
    for (final t in RatingTag.values)
      if (t.tone == tone) t,
  ];
}

/// What the passenger has chosen so far.
class RatingDraft {
  const RatingDraft({this.stars, this.tags = const {}});

  final int? stars;
  final Set<RatingTag> tags;

  List<RatingTag> get offeredTags => tagsFor(stars);

  /// Submit needs a star. Everything else is optional, and not rating at all
  /// is what Skip is for.
  bool get canSubmit => stars != null;

  /// A new star count. Tags the new count no longer offers are dropped: a
  /// passenger who tapped 5★ and `Clean` and then changed their mind to 2★
  /// must not submit a 2★ rating still carrying praise they chose for a
  /// different answer.
  ///
  /// Throws on an out-of-range value. The widget only offers 1–5, so this is
  /// a programming error, and it fails loudly rather than being clamped.
  RatingDraft withStars(int value) {
    if (!isValidStars(value)) {
      throw ArgumentError.value(value, 'stars', 'must be 1–5');
    }
    final offered = tagsFor(value).toSet();
    return RatingDraft(
      stars: value,
      tags: {
        for (final t in tags)
          if (offered.contains(t)) t,
      },
    );
  }

  /// Selects or clears [tag]. A tag not offered at the current star count
  /// is ignored rather than stored, so hidden state cannot be submitted.
  RatingDraft toggle(RatingTag tag) {
    if (!offeredTags.contains(tag)) return this;
    final next = {...tags};
    if (!next.remove(tag)) next.add(tag);
    return RatingDraft(stars: stars, tags: next);
  }
}

/// Whether to show Screen 11 for a trip.
///
/// "Skip must be available and unpunished. A forced rating produces noise,
/// not data." Asking again after a skip would be the punishment, so a
/// skipped trip is never re-prompted, and skipping affects nothing else.
///
/// Takes [tripCompleted] as a fact rather than a status integer, because
/// pu_passenger's `BookingStatus` still disagrees with the driver's contract
/// on several codes (Q-1).
bool shouldPromptForRating({
  required bool tripCompleted,
  required bool alreadyRated,
  required bool skipped,
}) =>
    tripCompleted && !alreadyRated && !skipped;

/// The driver's name for `How was your trip with {driver}?`, or null when
/// there is none to show, in which case the prompt drops the name rather
/// than rendering `with ?`. Display degrades (`.agent/RULES.md` §Payload
/// policy).
String? promptDriverName(String? name) {
  final trimmed = name?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}

// ---- Couldn't submit → queue (§6) ---------------------------------------

/// A rating waiting to be sent.
class PendingRating {
  const PendingRating({
    required this.bookingId,
    required this.stars,
    required this.tags,
  });

  final int bookingId;
  final int stars;
  final Set<RatingTag> tags;
}

/// [draft] as a queued rating for [bookingId].
///
/// Throws if nothing was chosen. A rating without stars is a skip, and a
/// skip is never sent.
PendingRating pendingFrom(RatingDraft draft, {required int bookingId}) {
  final stars = draft.stars;
  if (stars == null) {
    throw StateError('A rating without stars is a skip, not a submission.');
  }
  return PendingRating(bookingId: bookingId, stars: stars, tags: draft.tags);
}

/// [queue] with [rating] added. **One per booking, latest wins**, so a
/// passenger who re-rates a trip while offline cannot end up sending two
/// ratings for one trip. Other bookings keep their order.
List<PendingRating> enqueueRating(
  List<PendingRating> queue,
  PendingRating rating,
) =>
    [
      for (final q in queue)
        if (q.bookingId != rating.bookingId) q,
      rating,
    ];

/// [queue] without the rating for [bookingId], once it has been sent.
List<PendingRating> withoutSubmitted(
  List<PendingRating> queue,
  int bookingId,
) =>
    [
      for (final q in queue)
        if (q.bookingId != bookingId) q,
    ];
