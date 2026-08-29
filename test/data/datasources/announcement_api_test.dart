import 'package:flutter_test/flutter_test.dart';
import 'package:com.tara.passenger/data/datasources/announcement_api.dart';
import 'package:com.tara.passenger/data/models/announcement_model.dart';

void main() {
  group('announcementModelToPaging', () {
    test('computes totalPages as ceil(total/perPage), matching the old Paging.fromMap formula', () {
      final model = AnnouncementModel(
        data: const [],
        currentPage: 1,
        perPage: 10,
        total: 25,
      );

      final paging = announcementModelToPaging(model);

      expect(paging.totalPages, 3);
      expect(paging.currentPage, 1);
      expect(paging.perPage, 10);
      expect(paging.totalRecords, 25);
    });

    test('a total that divides evenly by perPage does not round up an extra page', () {
      final model = AnnouncementModel(perPage: 10, total: 20);

      final paging = announcementModelToPaging(model);

      expect(paging.totalPages, 2);
    });

    test('missing total/perPage default to 0/1, giving totalPages 0', () {
      final model = AnnouncementModel();

      final paging = announcementModelToPaging(model);

      expect(paging.totalPages, 0);
    });

    test('carries the announcement list through unchanged', () {
      final items = [
        AnnouncementDetailModel(id: 1, title: 'A'),
        AnnouncementDetailModel(id: 2, title: 'B'),
      ];
      final model = AnnouncementModel(data: items, perPage: 10, total: 2);

      final paging = announcementModelToPaging(model);

      expect(paging.data, items);
    });
  });
}
