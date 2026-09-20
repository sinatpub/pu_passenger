import 'package:flutter_test/flutter_test.dart';
import 'package:com.tara.passenger/core/utils/vehicle_seat_capacity.dart';

void main() {
  group('seatCapacityForVehicleId', () {
    test('rickshaw (id 1) seats 3', () {
      expect(seatCapacityForVehicleId(1), 3);
    });

    test('classic car (id 2) seats 4', () {
      expect(seatCapacityForVehicleId(2), 4);
    });

    test('mini van (id 3) seats 7', () {
      expect(seatCapacityForVehicleId(3), 7);
    });

    test('suv (id 4) seats 4', () {
      expect(seatCapacityForVehicleId(4), 4);
    });

    test('unrecognized id defaults to 5 seats', () {
      expect(seatCapacityForVehicleId(5), 5);
      expect(seatCapacityForVehicleId(99), 5);
    });

    test('null id defaults to 5 seats', () {
      expect(seatCapacityForVehicleId(null), 5);
    });
  });

  group('etaMinutesForVehicleId (C2 home vehicle list)', () {
    test('rickshaw ~2 min, classic ~3, mini van ~4, suv ~4', () {
      expect(etaMinutesForVehicleId(1), 2);
      expect(etaMinutesForVehicleId(2), 3);
      expect(etaMinutesForVehicleId(3), 4);
      expect(etaMinutesForVehicleId(4), 4);
    });

    test('unknown id and alphard/vip default to 5 min', () {
      expect(etaMinutesForVehicleId(5), 5);
      expect(etaMinutesForVehicleId(99), 5);
      expect(etaMinutesForVehicleId(null), 5);
    });

    test('formatEtaMinutes renders the display string', () {
      expect(formatEtaMinutes(1), '~2 min');
      expect(formatEtaMinutes(null), '~5 min');
    });
  });
}
