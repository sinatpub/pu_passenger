import 'package:shared_preferences/shared_preferences.dart';

/// Which bookings have already been rated or skipped (`N-10` §6 / roadmap C7
/// "Skip is available and **unpunished**").
///
/// `shouldPromptForRating` takes `alreadyRated` and `skipped` as facts; this is
/// where those facts are kept. Persisted rather than held in memory because
/// re-asking after a restart is exactly the punishment the rule forbids — and a
/// passenger who force-quits on the rating screen is the likeliest person to be
/// re-asked.
///
/// Both outcomes share one set: the rule treats them identically (do not
/// prompt), and storing *why* would invite reading it as "this passenger
/// refuses to rate", which is not something this app should record.
class RatingPromptStore {
  RatingPromptStore({SharedPreferences? preferences})
      : _injected = preferences;

  static const String _key = 'rating_handled_booking_ids';

  final SharedPreferences? _injected;

  Future<SharedPreferences> get _prefs async =>
      _injected ?? await SharedPreferences.getInstance();

  /// Never throws: a storage failure must not block the post-trip flow. On a
  /// read failure the passenger may be asked once more, which is the harmless
  /// direction — the alternative is silently dropping the prompt for everyone.
  Future<bool> isHandled(int bookingId) async {
    try {
      final prefs = await _prefs;
      return (prefs.getStringList(_key) ?? const [])
          .contains(bookingId.toString());
    } catch (_) {
      return false;
    }
  }

  Future<void> markHandled(int bookingId) async {
    try {
      final prefs = await _prefs;
      final current = prefs.getStringList(_key) ?? const <String>[];
      final id = bookingId.toString();
      if (current.contains(id)) return;
      // Bounded: only the recent tail matters, and an unbounded list would
      // grow for the life of the install.
      final next = [...current, id];
      await prefs.setStringList(
        _key,
        next.length > 50 ? next.sublist(next.length - 50) : next,
      );
    } catch (_) {
      // Losing the mark costs at most one extra prompt.
    }
  }
}
