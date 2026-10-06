import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../network_config/paging.dart';

/// Feeds one fetched page into [pagingController].
///
/// A [function] that completes with null is a fetch that failed (the
/// datasources answer null for a request or a response they could not use).
/// That is reported as the controller's error. It used to be ignored: the
/// controller was told nothing, stayed "loading the first page" for good,
/// and the list showed its skeleton with no error and no retry.
xPagingDataHandler<PageKeyType, ItemType>({
  required PagingController<PageKeyType, ItemType> pagingController,
  required Future<Paging<ItemType>?> function,
  required bool isRefresh,
  required int pageNo,
  int? needPage,
  Function()? functionHandleIsRefresh1,
}) async {
  try {
    // Handle refresh case
    if (isRefresh) {
      pagingController.refresh();
      functionHandleIsRefresh1?.call();
    }

    // Fetch new items with error handling
    Object? failure;
    final newItems = await function.onError(
      (error, stackTrace) {
        failure = error;
        return null;
      },
    );
    if (newItems == null) {
      pagingController.error = failure ?? const PageFetchFailure();
      return;
    }

    // Handle cases based on the page number and `needPage` limit (if provided)
    if (needPage == null || pageNo <= needPage) {
      if ((newItems.totalPages ?? 0) == 1) {
        pagingController.itemList?.clear();
        pagingController.appendLastPage(newItems.data ?? []);
      } else if ((newItems.totalPages ?? 0) > pageNo) {
        if (newItems.data != null) {
          pagingController.appendPage(
              newItems.data ?? [], (pageNo + 1) as PageKeyType?);
        }
      } else {
        pagingController.appendLastPage(newItems.data ?? []);
      }
    } else {
      // If the current page exceeds `needPage`, stop pagination
      pagingController.appendLastPage([]);
    }
  } catch (error) {
    pagingController.error = error;
  }
}

/// A page that could not be fetched or read, when the datasource gave no
/// more detail than "nothing came back".
class PageFetchFailure implements Exception {
  const PageFetchFailure();

  @override
  String toString() => 'PageFetchFailure: the page could not be loaded.';
}
