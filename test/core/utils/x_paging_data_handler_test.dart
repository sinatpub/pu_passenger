import 'package:com.tara.passenger/core/network_config/paging.dart';
import 'package:com.tara.passenger/core/utils/x_paging_data_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

void main() {
  late PagingController<int, String> controller;

  setUp(() => controller = PagingController<int, String>(firstPageKey: 1));
  tearDown(() => controller.dispose());

  Future<void> feed(Future<Paging<String>?> page, {int pageNo = 1}) =>
      xPagingDataHandler<int, String>(
        pagingController: controller,
        function: page,
        isRefresh: false,
        pageNo: pageNo,
      );

  test('a fetch that came back as nothing is an error, not a wait', () async {
    // The datasources answer null for a failed request or an unreadable
    // response. Ignoring it left the list on its skeleton for good.
    await feed(Future.value(null));

    expect(controller.error, isA<PageFetchFailure>());
    expect(controller.itemList, isNull);
  });

  test('a fetch that threw reports what was thrown', () async {
    await feed(Future<Paging<String>?>.error('no connection'));

    expect(controller.error, 'no connection');
  });

  test('a single page is the last page', () async {
    await feed(Future.value(Paging(data: ['a', 'b'], totalPages: 1)));

    expect(controller.error, isNull);
    expect(controller.itemList, ['a', 'b']);
    expect(controller.nextPageKey, isNull);
  });

  test('more pages to come asks for the next one', () async {
    await feed(Future.value(Paging(data: ['a'], totalPages: 3)));

    expect(controller.itemList, ['a']);
    expect(controller.nextPageKey, 2);
  });

  test('an empty answer is an empty list, so the empty state can show',
      () async {
    await feed(Future.value(Paging<String>(data: [], totalPages: 0)));

    expect(controller.error, isNull);
    expect(controller.itemList, isEmpty);
    expect(controller.nextPageKey, isNull);
  });

  test('a page with no counters is shown as the last page', () async {
    await feed(Future.value(Paging(data: ['a'], totalPages: 0)));

    expect(controller.itemList, ['a']);
    expect(controller.nextPageKey, isNull);
  });
}
