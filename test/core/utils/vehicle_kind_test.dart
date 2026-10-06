import 'package:com.tara.passenger/core/utils/vehicle_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('vehicleKindFromName', () {
    test('the real backend\'s three types (2026-10-06)', () {
      expect(vehicleKindFromName('Moto'), VehicleKind.moto);
      expect(vehicleKindFromName('Tuktuk'), VehicleKind.tukTuk);
      expect(vehicleKindFromName('Car'), VehicleKind.car);
    });

    test('the larger types the mock keeps', () {
      expect(vehicleKindFromName('Mini Van'), VehicleKind.miniVan);
      expect(vehicleKindFromName('SUV'), VehicleKind.suv);
      expect(vehicleKindFromName('Alphard VIP'), VehicleKind.vip);
    });

    test('other spellings of the same vehicle', () {
      expect(vehicleKindFromName('Tuk Tuk'), VehicleKind.tukTuk);
      expect(vehicleKindFromName('TUK-TUK'), VehicleKind.tukTuk);
      expect(vehicleKindFromName('Rickshaw'), VehicleKind.tukTuk);
      expect(vehicleKindFromName('Motorbike'), VehicleKind.moto);
      expect(vehicleKindFromName('Classic Car'), VehicleKind.car);
      expect(vehicleKindFromName('  car  '), VehicleKind.car);
    });

    test('Khmer names', () {
      expect(vehicleKindFromName('ម៉ូតូ'), VehicleKind.moto);
      expect(vehicleKindFromName('តុកតុក'), VehicleKind.tukTuk);
      expect(vehicleKindFromName('ឡាន'), VehicleKind.car);
    });

    test('a van is a van even when it is also called a car or a VIP', () {
      expect(vehicleKindFromName('Van car'), VehicleKind.miniVan);
      expect(vehicleKindFromName('VIP Van'), VehicleKind.vip);
    });

    test('a name that says nothing has no kind, rather than a guessed one',
        () {
      expect(vehicleKindFromName(null), isNull);
      expect(vehicleKindFromName(''), isNull);
      expect(vehicleKindFromName('   '), isNull);
      expect(vehicleKindFromName('Standard'), isNull);
    });
  });
}
