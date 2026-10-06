import 'package:com.tara.passenger/core/utils/vehicle_kind.dart';
import 'package:com.tara.passenger/core/utils/vehicle_seat_capacity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('seatCapacityFor', () {
    test('a moto carries one passenger', () {
      expect(seatCapacityFor(VehicleKind.moto), 1);
    });

    test('a tuk tuk carries three', () {
      expect(seatCapacityFor(VehicleKind.tukTuk), 3);
    });

    test('a car and an SUV carry four', () {
      expect(seatCapacityFor(VehicleKind.car), 4);
      expect(seatCapacityFor(VehicleKind.suv), 4);
    });

    test('a mini van carries seven, a VIP van five', () {
      expect(seatCapacityFor(VehicleKind.miniVan), 7);
      expect(seatCapacityFor(VehicleKind.vip), 5);
    });

    test('a type the app does not recognise is taken to be a car', () {
      expect(seatCapacityFor(null), 4);
    });
  });

  group('etaMinutesFor (C2 home vehicle list)', () {
    test('the smaller the vehicle, the sooner one is near', () {
      expect(etaMinutesFor(VehicleKind.moto), 2);
      expect(etaMinutesFor(VehicleKind.tukTuk), 2);
      expect(etaMinutesFor(VehicleKind.car), 3);
      expect(etaMinutesFor(VehicleKind.miniVan), 4);
      expect(etaMinutesFor(VehicleKind.suv), 4);
      expect(etaMinutesFor(VehicleKind.vip), 5);
    });

    test('an unrecognised type gets the longest wait', () {
      expect(etaMinutesFor(null), 5);
    });

    test('formatEtaMinutes renders the display string', () {
      expect(formatEtaMinutes(VehicleKind.moto), '~2 min');
      expect(formatEtaMinutes(null), '~5 min');
    });
  });
}
