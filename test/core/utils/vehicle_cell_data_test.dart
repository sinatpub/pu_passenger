import 'package:com.tara.passenger/core/utils/vehicle_cell_data.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';

SingleVehical _vehicle({
  int id = 2,
  String name = 'Tuktuk',
  num price = 0.5,
  num? miniMunFare = 1,
}) {
  return SingleVehical(
    id: id,
    name: name,
    price: price,
    orderKey: null,
    miniMunFare: miniMunFare,
    image: '',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  group('vehicleCellData (C2/C3 shared mapping)', () {
    test('masks model fields into presentational VehicleData', () {
      final data = vehicleCellData(_vehicle());

      expect(data.name, 'Tuktuk');
      expect(data.seats, '3 Seats');
      expect(data.pricePerKm, '\$0.50/km');
      expect(data.priceFrom, 'from \$1.00');
      expect(data.eta, '~2 min'); // deterministic lookup placeholder
    });

    test('drawing, seats and wait follow the name, whatever the id', () {
      // The real backend numbers Moto 1, Tuktuk 2, Car 3; an earlier one
      // numbered a tuk tuk 1. The id decides nothing here.
      final moto = vehicleCellData(_vehicle(id: 1, name: 'Moto'));
      final car = vehicleCellData(_vehicle(id: 1, name: 'Car'));

      expect(moto.seats, '1 Seat');
      expect(car.seats, '4 Seats');
      expect(moto.art, isA<SvgPicture>());
      expect(car.art, isA<SvgPicture>());
    });

    test('the name shown is the one the server sent', () {
      // The app draws the vehicle and counts its seats from the name, but
      // does not rename it: the name is the backend's to set.
      expect(vehicleCellData(_vehicle(name: 'Tuk Tuk')).name, 'Tuk Tuk');
    });

    test('a type the app does not recognise has no drawing and car seats',
        () {
      final data = vehicleCellData(_vehicle(name: 'Standard'));

      expect(data.art, isNull);
      expect(data.seats, '4 Seats');
      expect(data.eta, '~5 min');
    });

    test('no min fare → "from —"', () {
      final data = vehicleCellData(_vehicle(miniMunFare: null));

      expect(data.priceFrom, 'from —');
    });
  });
}
