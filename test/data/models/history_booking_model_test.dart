import 'package:com.tara.passenger/data/datasources/history_booking_info_source.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// One past trip, in the shapes the real backend was seen to use on
/// 2026-10-06 for the same fields elsewhere: `booking_code` as a number,
/// coordinates and amounts as text. The history response itself was not
/// seen; this is those parts in the history record's layout.
Map<String, dynamic> _trip() => {
      'id': 2,
      'booking_code': 1791280927,
      'start_latitude': '11.52590516098051',
      'start_longitude': '104.92335179820657',
      'end_latitude': null,
      'end_longitude': null,
      'start_time': '2026-10-06 10:05:11',
      'end_time': '2026-10-06 10:21:40',
      'start_address': 'Near Chip Mong 271 Mega Mall',
      'end_address': null,
      'fare': '2.40',
      'status': 4,
      'status_name': 'Completed',
      'passenger': {'id': 3, 'name': 'Dummy Passenger'},
      'driver': {
        'id': 2,
        'name': 'Dummy Driver',
        'vehicle': {
          'id': 1,
          'type_vehicle_id': 1,
          'model': 'Toyota Camry',
          'year_of_manufacture': 2020,
          'engine_power': '2.0L',
          'vehicle_image': <dynamic>[],
        },
      },
      'payment': {
        'id': 1,
        'invoice_id': 1,
        'ride_id': 2,
        'distance': '4.20 km',
        'duration': '16 mins 29 seconds',
        'amount': 2.4,
        'payment_method': 'Cash',
        'status': 1,
      },
      'created_at': '2026-10-06 10:02:05',
      'updated_at': '2026-10-06 10:21:40',
    };

void main() {
  test('a trip whose booking code is a number parses', () {
    // The model wanted text. This one field threw, the list came back as
    // "nothing", and the screen stayed on its skeleton.
    final model = HistoryBookingModel.fromJson({
      'data': [_trip()],
      'current_page': 1,
      'per_page': 10,
      'total': 1,
      'status': true,
      'message': 'success',
    });

    final trip = model.data!.single;
    expect(trip.bookingCode, '1791280927');
    expect(trip.status, 4);
    expect(trip.driver?.vehicle?.typeVehicleId, 1);
    expect(trip.payment?.amount, '2.4');
    expect(trip.payment?.distance, '4.20 km');
    expect(trip.endAddress, isNull);
    expect(model.total, 1);
  });

  test('numbers sent as text, and text sent as numbers, both read', () {
    final json = _trip()
      ..['id'] = '2'
      ..['status'] = '4'
      ..['start_latitude'] = 11.5259;

    final trip = Datum.fromJson(json);

    expect(trip.id, 2);
    expect(trip.status, 4);
    expect(trip.startLatitude, '11.5259');
  });

  test('an empty list where an object belongs is "none", not a crash', () {
    // PHP writes an empty object as `[]`.
    final trip = Datum.fromJson(_trip()
      ..['driver'] = <dynamic>[]
      ..['payment'] = <dynamic>[]);

    expect(trip.driver, isNull);
    expect(trip.payment, isNull);
    expect(trip.id, 2);
  });

  group('where the page sits in the response', () {
    test('a paginator inside data', () {
      final model = HistoryBookingModel.fromJson({
        'data': {
          'data': [_trip()],
          'current_page': 2,
          'per_page': 10,
          'total': 25,
        },
        'status': true,
        'message': 'success',
      });

      expect(model.data, hasLength(1));
      expect(model.currentPage, 2);
      expect(model.total, 25);
      expect(historyBookingModelToPaging(model).totalPages, 3);
    });

    test('counters under meta', () {
      final model = HistoryBookingModel.fromJson({
        'data': [_trip()],
        'meta': {'current_page': 1, 'per_page': 15, 'total': 16},
      });

      expect(model.data, hasLength(1));
      expect(model.perPage, 15);
      expect(historyBookingModelToPaging(model).totalPages, 2);
    });

    test('no counters at all is one page of whatever came', () {
      final model = HistoryBookingModel.fromJson({
        'data': [_trip()],
      });

      expect(model.data, hasLength(1));
      expect(historyBookingModelToPaging(model).totalPages, 0);
    });
  });
}
