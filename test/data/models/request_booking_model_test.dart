import 'package:com.tara.passenger/core/utils/status_util.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// A booking with a driver attached, in the shapes the real backend was seen
/// to send on 2026-10-06: the driver record as `POST /taxi-driver/login`
/// returns it, a location as `update-driver-location` returns it (latitude,
/// longitude and heading all as text), and the vehicle type's rate as a
/// dollar decimal in text.
///
/// The whole booking was not seen in one response; this joins those parts.
Map<String, dynamic> _acceptedBooking() => {
      'data': {
        'id': 2,
        'booking_code': 1791280927,
        'type_vehicle_id': 1,
        'type_vehicle': {
          'id': 1,
          'name': 'Moto',
          'price': '0.30',
          'image': '',
          'created_at': '2026-08-31 14:41:13',
          'updated_at': '2026-08-31 14:41:13',
        },
        'start_latitude': '11.52590516098051',
        'start_longitude': '104.92335179820657',
        'end_latitude': null,
        'end_longitude': null,
        'start_address': 'Near Chip Mong 271 Mega Mall',
        'end_address': null,
        'fare': null,
        'status': BookingStatus.accepted,
        'status_name': 'Accepted',
        'passenger': {
          'id': 3,
          'name': 'Dummy Passenger',
          'phone': '+855900000003',
          'profile_image': null,
        },
        'driver': {
          'id': 2,
          'name': 'Dummy Driver',
          'last_name': 'Driver',
          'first_name': 'Dummy',
          'email': 'driver@example.com',
          'gender': 0,
          'dob': '',
          'country_code': '+855',
          'phone': '+855086733521',
          'card_type': null,
          'status': 1,
          'status_date': '',
          'profile_image': null,
          'vehicle': {
            'id': 1,
            'type_vehicle_id': 1,
            'model': 'Toyota Camry',
            'manufacturer': 'Toyota',
            'year_of_manufacture': 2020,
            'color': 'White',
            'plate_number': '2AB-1234',
            'engine_power': '2.0L',
            'max_passenger': 4,
            'status': 1,
            'vehicle_image': <dynamic>[],
          },
          'last_location': {
            'id': 1,
            'user_id': 2,
            'latitude': '11.5259059',
            'longitude': '104.9233522',
            'heading': '89.99986267089844',
          },
        },
        'payment': null,
        'timeout_param': 15,
        'created_at': '2026-10-06 10:02:05',
        'updated_at': '2026-10-06T10:02:31.000000Z',
      },
      'status': true,
      'message': 'success',
    };

void main() {
  test('a booking with a driver attached parses', () {
    // `heading` as text threw (`"…".toDouble()`), and took the whole booking
    // with it: the passenger could not be moved to the ride screen.
    final booking = RequestBookingModel.fromJson(_acceptedBooking()).data!;

    expect(booking.status, BookingStatus.accepted);
    expect(booking.typeVehicle?.price, 0.30);
    expect(booking.driver?.name, 'Dummy Driver');
    expect(booking.driver?.vehicle?.plateNumber, '2AB-1234');
    expect(booking.driver?.lastLocation?.latitude, '11.5259059');
    expect(booking.driver?.lastLocation?.heading, closeTo(89.99986, 0.00001));
    expect(booking.createdAt, DateTime(2026, 10, 6, 10, 2, 5));
  });

  test('numbers and text read the same', () {
    final json = _acceptedBooking();
    final data = json['data'] as Map<String, dynamic>;
    data['status'] = '${BookingStatus.arrival}';
    data['id'] = '2';
    final driver = data['driver'] as Map<String, dynamic>;
    driver['last_location'] = {
      'latitude': 11.5259059,
      'longitude': 104.9233522,
      'heading': 90,
    };

    final booking = RequestBookingModel.fromJson(json).data!;

    expect(booking.status, BookingStatus.arrival);
    expect(booking.id, 2);
    expect(booking.driver?.lastLocation?.latitude, '11.5259059');
    expect(booking.driver?.lastLocation?.heading, 90.0);
  });

  test('what cannot be read is left out, and the booking still parses', () {
    final json = _acceptedBooking();
    final data = json['data'] as Map<String, dynamic>;
    data['created_at'] = 'yesterday';
    (data['type_vehicle'] as Map<String, dynamic>)['price'] = 'free';
    ((data['driver'] as Map<String, dynamic>)['last_location']
        as Map<String, dynamic>)['heading'] = 'north';

    final booking = RequestBookingModel.fromJson(json).data!;

    expect(booking.status, BookingStatus.accepted);
    expect(booking.createdAt, isNull);
    expect(booking.typeVehicle?.price, isNull);
    expect(booking.driver?.lastLocation?.heading, isNull);
  });
}
