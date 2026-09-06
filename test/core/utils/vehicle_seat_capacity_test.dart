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
}
