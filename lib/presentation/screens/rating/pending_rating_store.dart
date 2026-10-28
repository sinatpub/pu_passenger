import 'dart:convert';

import 'package:com.tara.passenger/presentation/screens/rate_driver/rating.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Audit S-6 — the ratings waiting for an endpoint, kept on the phone.
///
/// The queue lived only in memory (`RatingRecorder.pendingRatings`) while the
/// trip was marked "handled" on disk ([RatingPromptStore]): after a restart
/// the rating was gone, and the passenger was never asked again. Kept here,
/// it is still there for whatever wires up the endpoint.
///
/// Never throws, like [RatingPromptStore]: storage must not block the
/// post-trip flow.
class PendingRatingStore {
  PendingRatingStore({SharedPreferences? preferences})
      : _injected = preferences;

  static const String _key = 'pending_ratings';

  final SharedPreferences? _injected;

  Future<SharedPreferences> get _prefs async =>
      _injected ?? await SharedPreferences.getInstance();

  /// The stored queue, or null when storage could not be read.
  Future<List<PendingRating>?> read() async {
    try {
      final prefs = await _prefs;
      final raw = prefs.getString(_key);
      return raw == null ? const [] : decodePendingRatings(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(List<PendingRating> queue) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_key, encodePendingRatings(queue));
    } catch (_) {
      // Kept in memory for this run; see `RatingRecorder.pendingRatings`.
    }
  }
}

String encodePendingRatings(List<PendingRating> queue) => jsonEncode([
      for (final r in queue)
        {
          'booking_id': r.bookingId,
          'stars': r.stars,
          'tags': [for (final t in r.tags) t.name],
        },
    ]);

/// [raw] as a queue. An entry that cannot be read is dropped, and a tag this
/// version does not know is left out, rather than losing the whole queue.
List<PendingRating> decodePendingRatings(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! List) return const [];
  final queue = <PendingRating>[];
  for (final entry in decoded) {
    if (entry is! Map) continue;
    final bookingId = entry['booking_id'];
    final stars = entry['stars'];
    if (bookingId is! int || stars is! int) continue;
    final tagNames = entry['tags'] is List ? entry['tags'] as List : const [];
    queue.add(PendingRating(
      bookingId: bookingId,
      stars: stars,
      tags: {
        for (final t in RatingTag.values)
          if (tagNames.contains(t.name)) t,
      },
    ));
  }
  return queue;
}
