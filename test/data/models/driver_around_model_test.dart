import 'package:com.tara.passenger/data/models/driver_around_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// `POST /taxi-passenger/get-driver-location-around`.
///
/// On 2026-10-06 the real backend's answer could not be read:
/// `type 'String' is not a subtype of type 'int?'`. The log did not say which
/// field, so none of them may depend on how the backend writes a number.
Map<String, dynamic> _driver({bool numbersAsText = false}) {
  Object n(int value) => numbersAsText ? '$value' : value;
  return {
    'id': n(2),
    'name': 'Dummy Driver',
    'gender': n(0),
    'card_type': null,
    'status': n(1),
    'profile_image': null,
    'vehicle': {
      'id': n(1),
      'type_vehicle_id': n(1),
      'model': 'Toyota Camry',
      'manufacturer': 'Toyota',
      'year_of_manufacture': n(2020),
      'color': 'White',
      'plate_number': '2AB-1234',
      'engine_power': '2.0L',
      'max_passenger': n(4),
      'status': n(1),
      'vehicle_image': <dynamic>[],
    },
    'last_location': {
      'latitude': numbersAsText ? '11.5259059' : 11.5259059,
      'longitude': numbersAsText ? '104.9233522' : 104.9233522,
    },
  };
}

void main() {
  for (final asText in [false, true]) {
    test('drivers parse with numbers ${asText ? 'as text' : 'as numbers'}',
        () {
      final model = DriverAroundModel.fromJson({
        'data': [_driver(numbersAsText: asText)],
        'status': true,
        'message': 'success',
      });

      final driver = model.data!.single;
      expect(driver.id, 2);
      expect(driver.gender, 0);
      expect(driver.status, 1);
      expect(driver.vehicle?.typeVehicleId, 1);
      expect(driver.vehicle?.yearOfManufacture, 2020);
      expect(driver.vehicle?.maxPassenger, 4);
      expect(driver.vehicle?.plateNumber, '2AB-1234');
      expect(driver.lastLocation?.latitude, '11.5259059');
      expect(driver.lastLocation?.longitude, '104.9233522');
    });
  }

  test('a field that cannot be read is left out, not fatal to the list', () {
    final odd = _driver()
      ..['gender'] = 'male'
      ..['vehicle'] = <dynamic>[]
      ..['last_location'] = null;

    final model = DriverAroundModel.fromJson({
      'data': [odd, _driver()],
    });

    expect(model.data, hasLength(2));
    expect(model.data!.first.gender, isNull);
    expect(model.data!.first.vehicle, isNull);
    expect(model.data!.first.lastLocation, isNull);
    expect(model.data!.last.vehicle?.model, 'Toyota Camry');
  });

  test('no drivers near is an empty list', () {
    expect(DriverAroundModel.fromJson({'data': null}).data, isEmpty);
    expect(DriverAroundModel.fromJson({'data': []}).data, isEmpty);
    expect(DriverAroundModel.fromJson({}).data, isEmpty);
  });
}
