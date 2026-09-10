import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every one of these models parsed its list with
/// `List<T>.from(json["key"].map(...))`, which calls `.map` on whatever the
/// key holds — so an absent or null key was a NoSuchMethodError and a screen
/// that could not open. Found in the wallet first (N-01) and then in ten more
/// places by grepping for the same shape.
///
/// These pin the empty cases, which are exactly the new-user cases.
///
/// Note what these tests do NOT cover, found while writing them: this model
/// declares `message` and `status` non-nullable and reads them straight off
/// the JSON, so an omitted key throws `type 'Null' is not a subtype of type
/// 'String'`. `SingleVehical` is the same one level down — `price`,
/// `created_at` and `updated_at` are all required and unguarded, which is why
/// the fixture below is fuller than it looks like it needs to be. That is a
/// separate defect class from the list one and is logged rather than fixed
/// here — .agent/RULES.md rules out unrelated changes in a
/// diff, and it affects many models.
void main() {
  group('VehicalTypeEntities — loaded on Home at startup', () {
    test('a null data list parses instead of crashing the home screen', () {
      final m = VehicalTypeEntities.fromJson(
          {'data': null, 'message': 'ok', 'status': true});
      expect(m.data, isEmpty);
    });

    test('an absent data key is survivable', () {
      final m = VehicalTypeEntities.fromJson({'message': 'ok', 'status': true});
      expect(m.data, isEmpty);
    });

    test('a populated list still parses', () {
      final m = VehicalTypeEntities.fromJson({
        'message': 'ok',
        'status': true,
        'data': [
          {
            'id': 1,
            'name': 'Rickshaw',
            'price': 3000,
            'created_at': '2026-01-01T00:00:00Z',
            'updated_at': '2026-01-01T00:00:00Z',
          },
          {
            'id': 2,
            'name': 'Classic',
            'price': 5000,
            'created_at': '2026-01-01T00:00:00Z',
            'updated_at': '2026-01-01T00:00:00Z',
          },
        ],
      });
      expect(m.data, hasLength(2));
      expect(m.data.first.id, 1);
    });
  });

  group('HistoryBookingModel — a passenger with no rides', () {
    test('a null data list parses instead of crashing ride history', () {
      final m = HistoryBookingModel.fromJson({'data': null});
      expect(m.data, isEmpty);
    });

    test('an absent data key is survivable', () {
      expect(HistoryBookingModel.fromJson({}).data, isEmpty);
    });

    test('an empty list is empty', () {
      expect(HistoryBookingModel.fromJson({'data': []}).data, isEmpty);
    });
  });
}
