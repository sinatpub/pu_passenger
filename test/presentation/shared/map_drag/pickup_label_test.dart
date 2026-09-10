import 'package:com.tara.passenger/presentation/shared/map_drag/pickup_label.dart';
import 'package:flutter_test/flutter_test.dart';

/// P-05 (docs/12) — spec Screen 3, "the highest-risk screen in the product".
void main() {
  group('pickupLabelTier', () {
    test('no address resolves to coordinates only', () {
      expect(pickupLabelTier(), PickupLabelTier.coordinateOnly);
      expect(pickupLabelTier(address: null), PickupLabelTier.coordinateOnly);
    });

    test('a blank address is not an address', () {
      // Geocoders return empty strings as readily as nulls.
      expect(pickupLabelTier(address: ''), PickupLabelTier.coordinateOnly);
      expect(pickupLabelTier(address: '   '), PickupLabelTier.coordinateOnly);
    });

    test('a resolved address reaches the street tier', () {
      expect(pickupLabelTier(address: '12 St 271, Toul Kork'),
          PickupLabelTier.streetAddress);
    });

    test('a mapped venue outranks its street address', () {
      // Unreachable until venue data exists, but the branch is explicit so
      // degrading to Tier 2 is a decision rather than an absence.
      expect(
        pickupLabelTier(address: '12 St 271', venue: Object()),
        PickupLabelTier.venueEntrance,
      );
    });
  });

  group('pickupConfirmState', () {
    test('no pin yet means resolving, so Confirm cannot be tapped', () {
      // Location permission denied and no interaction: the pin never arrives.
      final s = pickupConfirmState(
          hasPin: false,
          isResolving: false,
          tier: PickupLabelTier.coordinateOnly);
      expect(s, PickupConfirmState.resolving);
      expect(canConfirmPickup(s), isFalse);
    });

    test('a geocode in flight disables Confirm', () {
      // Spec: confirming a point whose address has not resolved is the
      // failure this screen exists to prevent.
      final s = pickupConfirmState(
          hasPin: true, isResolving: true, tier: PickupLabelTier.streetAddress);
      expect(s, PickupConfirmState.resolving);
      expect(canConfirmPickup(s), isFalse);
    });

    test('a resolved street address is confirmable', () {
      final s = pickupConfirmState(
          hasPin: true,
          isResolving: false,
          tier: PickupLabelTier.streetAddress);
      expect(s, PickupConfirmState.ready);
      expect(canConfirmPickup(s), isTrue);
    });

    test('a coordinate-only point stays confirmable — an approximate pickup '
        'with a note beats no pickup at all', () {
      final s = pickupConfirmState(
          hasPin: true,
          isResolving: false,
          tier: PickupLabelTier.coordinateOnly);
      expect(s, PickupConfirmState.approximate);
      expect(canConfirmPickup(s), isTrue);
    });

    test('outside the service area outranks everything else', () {
      final s = pickupConfirmState(
        hasPin: true,
        isResolving: true,
        tier: PickupLabelTier.streetAddress,
        outsideServiceArea: true,
      );
      expect(s, PickupConfirmState.outsideServiceArea);
      expect(canConfirmPickup(s), isFalse);
    });

    test('a restricted road blocks a perfectly good address', () {
      final s = pickupConfirmState(
        hasPin: true,
        isResolving: false,
        tier: PickupLabelTier.streetAddress,
        restrictedRoad: true,
      );
      expect(s, PickupConfirmState.restrictedRoad);
      expect(canConfirmPickup(s), isFalse);
    });
  });

  group('normaliseDriverNote', () {
    test('an absent or blank note is null, not an empty string', () {
      expect(normaliseDriverNote(null), isNull);
      expect(normaliseDriverNote(''), isNull);
      expect(normaliseDriverNote('    '), isNull);
    });

    test('a normal note is kept, trimmed', () {
      expect(normaliseDriverNote('  Blue gate by the pharmacy  '),
          'Blue gate by the pharmacy');
    });

    test('a note at the cap is untouched', () {
      final exact = 'x' * kDriverNoteMaxLength;
      expect(normaliseDriverNote(exact), exact);
    });

    test('an over-long note is cut at a word boundary where one is close', () {
      final note = '${'word ' * 20}tail';
      final result = normaliseDriverNote(note)!;

      expect(result.length, lessThanOrEqualTo(kDriverNoteMaxLength));
      expect(result, isNot(endsWith(' ')));
      expect(result.split(' ').last, 'word',
          reason: 'should not end mid-word');
    });

    test('a single unbroken word is cut hard rather than emptied', () {
      final result = normaliseDriverNote('x' * 200)!;
      expect(result.length, kDriverNoteMaxLength);
    });
  });
}
