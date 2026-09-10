/// P-05 (docs/12) — the pickup-point label from
/// `ux_ui_design/taxi-booking-ux-spec.md` Screen 3, which the spec calls
/// "the core of Problem P2" and the highest-risk screen in the product.
///
/// This models the *decision* — which tier of specificity a resolved point
/// has reached, and whether the passenger may confirm it — and deliberately
/// carries no user-facing copy. The strings live with the view, alongside
/// their translations. A pure enum here means the rules are testable without
/// the i18n decision (Q-11) being settled first.
library;

/// How specifically a pickup point could be described.
///
/// The spec's argument for why this matters: "A GPS pin alone is not a
/// pickup point." Tier 3 is what separates a driver finding you from a
/// driver circling the building.
enum PickupLabelTier {
  /// No address matched. The spec shows `Pinned location` plus a distance to
  /// the nearest named street, and leans on the note-for-driver field.
  coordinateOnly,

  /// A street address resolved. The normal case.
  streetAddress,

  /// The point sits inside a known venue with mapped entrances.
  ///
  /// **Unreachable today, on purpose.** It needs venue-entrance data that
  /// does not exist — `docs/12` records Screen 3b as blocked on exactly this,
  /// and the spec itself says nationwide coverage is unrealistic and the
  /// design "must degrade gracefully to Tier 2". Modelled rather than
  /// omitted so that degrading is an explicit branch instead of an absence.
  venueEntrance,
}

/// Which tier a reverse-geocode result reached.
///
/// [address] is whatever the geocoder returned; [venue] is a mapped venue the
/// point falls inside, which is always null until venue data exists.
PickupLabelTier pickupLabelTier({String? address, Object? venue}) {
  if (venue != null) return PickupLabelTier.venueEntrance;
  if (address != null && address.trim().isNotEmpty) {
    return PickupLabelTier.streetAddress;
  }
  return PickupLabelTier.coordinateOnly;
}

/// What the confirm button and sheet should be doing.
enum PickupConfirmState {
  /// Reverse-geocode in flight. Spec: label goes to a skeleton and Confirm is
  /// disabled — dimmed, with no spinner on the button itself.
  resolving,

  /// A point is resolved and confirmable.
  ready,

  /// Resolved, but only to coordinates. Still confirmable — the spec keeps
  /// Confirm enabled here and asks for a note instead, because an
  /// approximate pickup with a note beats no pickup at all.
  approximate,

  /// Outside the service area. Confirm is replaced, not merely disabled.
  ///
  /// Not reachable yet: needs a coverage boundary the app does not have.
  outsideServiceArea,

  /// On a road drivers cannot stop on. Confirm disabled with an explanation.
  ///
  /// Not reachable yet: needs road classification the app does not have.
  restrictedRoad,
}

/// The confirm state for a pin.
///
/// [hasPin] is false before the map has ever reported a position — with
/// location permission denied and no interaction, it stays false and Confirm
/// stays disabled, which is the behaviour P-05 established in 2026-09-06.
PickupConfirmState pickupConfirmState({
  required bool hasPin,
  required bool isResolving,
  required PickupLabelTier tier,
  bool outsideServiceArea = false,
  bool restrictedRoad = false,
}) {
  // Checked first: both replace the CTA outright, so they outrank the
  // question of whether an address resolved.
  if (outsideServiceArea) return PickupConfirmState.outsideServiceArea;
  if (restrictedRoad) return PickupConfirmState.restrictedRoad;
  if (!hasPin || isResolving) return PickupConfirmState.resolving;
  if (tier == PickupLabelTier.coordinateOnly) {
    return PickupConfirmState.approximate;
  }
  return PickupConfirmState.ready;
}

/// Whether Confirm accepts a tap in [state].
bool canConfirmPickup(PickupConfirmState state) =>
    state == PickupConfirmState.ready ||
    state == PickupConfirmState.approximate;

/// The spec's cap on the free-text note shown to the driver on assignment.
const int kDriverNoteMaxLength = 60;

/// Trims a driver note to the cap without cutting a word in half where it can
/// be avoided.
String? normaliseDriverNote(String? note) {
  if (note == null) return null;
  final trimmed = note.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.length <= kDriverNoteMaxLength) return trimmed;

  final clipped = trimmed.substring(0, kDriverNoteMaxLength);
  final lastSpace = clipped.lastIndexOf(' ');
  // Only prefer the word boundary when it does not cost most of the note.
  if (lastSpace > kDriverNoteMaxLength ~/ 2) {
    return clipped.substring(0, lastSpace).trimRight();
  }
  return clipped.trimRight();
}
