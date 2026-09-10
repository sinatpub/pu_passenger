/// P-04 (docs/12) — the destination-search state machine from
/// `ux_ui_design/taxi-booking-ux-spec.md` Screen 2.
///
/// The spec states the states as a table, and two of its rules are
/// behavioural rather than visual — they belong here, not in a widget.
library;

/// Characters required before a query reaches the Places API.
///
/// The spec's rule is "Typing (<3 chars) — show recents filtered locally; **do
/// not hit the network yet**". The previous implementation searched on a
/// single character, which is wrong twice over: one- and two-character
/// queries return results too generic to disambiguate — the exact failure
/// Screen 2's mandatory sub-line exists to prevent — and Places autocomplete
/// is billed per request, so every passenger typing a destination paid for
/// two useless calls before the first useful one.
const int kMinQueryLengthForNetwork = 3;

/// What the results area is showing.
enum DestinationSearchStatus {
  /// No query. The spec shows recents and saved places here.
  idle,

  /// Below the network threshold — filter recents locally, stay off the wire.
  belowThreshold,

  /// A network search is in flight. Previous results stay on screen, dimmed,
  /// rather than being cleared; the keyboard stays up.
  searching,

  /// Results came back.
  results,

  /// The search succeeded and matched nothing.
  empty,

  /// The search failed. The typed query is kept so it can be retried.
  error,
}

/// Whether [query] is long enough to justify a network call.
bool shouldQueryNetwork(String query) =>
    query.trim().length >= kMinQueryLengthForNetwork;

/// The status implied by a query and the outcome of the last search.
///
/// Kept pure and separate from the controller so the table in the spec can be
/// checked against tests rather than against a running app.
DestinationSearchStatus destinationSearchStatus({
  required String query,
  required bool isSearching,
  required bool hasError,
  required int resultCount,
}) {
  if (query.trim().isEmpty) return DestinationSearchStatus.idle;
  if (!shouldQueryNetwork(query)) return DestinationSearchStatus.belowThreshold;
  // Checked before `hasError` on purpose: a retry that is already in flight
  // should read as searching, not as the failure it is replacing.
  if (isSearching) return DestinationSearchStatus.searching;
  if (hasError) return DestinationSearchStatus.error;
  if (resultCount == 0) return DestinationSearchStatus.empty;
  return DestinationSearchStatus.results;
}

/// Whether previously-fetched results should remain visible.
///
/// The spec is explicit that a search in flight dims the previous results
/// rather than clearing them — clearing produces a flash of empty list on
/// every keystroke. They are only truly gone once the query itself is.
bool keepsPreviousResults(DestinationSearchStatus status) =>
    status == DestinationSearchStatus.searching ||
    status == DestinationSearchStatus.results;
