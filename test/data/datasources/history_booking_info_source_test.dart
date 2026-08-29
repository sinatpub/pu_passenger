import 'package:flutter_test/flutter_test.dart';
import 'package:com.tara.passenger/data/datasources/history_booking_info_source.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';

void main() {
  group('historyBookingModelToPaging', () {
    test('computes totalPages as ceil(total/perPage)', () {
      final model = HistoryBookingModel(
        data: const [],
        currentPage: 1,
        perPage: 10,
        total: 25,
      );

      final paging = historyBookingModelToPaging(model);

      expect(paging.totalPages, 3);
      expect(paging.currentPage, 1);
      expect(paging.perPage, 10);
      expect(paging.totalRecords, 25);
    });

    test('missing total/perPage default to 0/1, giving totalPages 0', () {
      final model = HistoryBookingModel();

      final paging = historyBookingModelToPaging(model);

      expect(paging.totalPages, 0);
    });

    test('carries the ride list through unchanged', () {
      final items = [Datum(id: 1), Datum(id: 2)];
      final model = HistoryBookingModel(data: items, perPage: 10, total: 2);

      final paging = historyBookingModelToPaging(model);

      expect(paging.data, items);
    });
  });
}
