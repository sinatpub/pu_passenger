import 'package:com.tara.passenger/core/utils/vehicle_cell_data.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:flutter_test/flutter_test.dart';

SingleVehical _vehicle({
  int id = 1,
  String name = 'Rickshaw',
  int price = 1500,
  int? miniMunFare = 4000,
}) {
  return SingleVehical(
    id: id,
    name: name,
    price: price,
    orderKey: 1,
    miniMunFare: miniMunFare,
    image: null,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  group('vehicleCellData (C2/C3 shared mapping)', () {
    test('masks model fields into presentational VehicleData', () {
      final data = vehicleCellData(_vehicle());

      expect(data.name, 'Rickshaw');
      expect(data.seats, '3 Seats'); // P-06: id 1 → 3 seats
      expect(data.pricePerKm, '1,500 ៛/km'); // PDD-01: formatter + KHR
      expect(data.priceFrom, 'from 4,000 ៛');
      expect(data.eta, '~2 min'); // deterministic lookup placeholder
    });

    test('unknown vehicle id falls back to default seats/eta', () {
      final data = vehicleCellData(
        _vehicle(id: 99, name: 'Alphard', price: 3000, miniMunFare: null),
      );

      expect(data.seats, '5 Seats'); // P-06 default
      expect(data.eta, '~5 min');
    });

    test('no min fare → "from —"', () {
      final data = vehicleCellData(
        _vehicle(id: 2, name: 'Classic Car', price: 2000, miniMunFare: null),
      );

      expect(data.priceFrom, 'from —');
    });
  });
}